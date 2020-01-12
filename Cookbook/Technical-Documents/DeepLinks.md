# Handling deep links

The app can handle several types of deep links, directly opening the related screens from inside or outside the app. A deep link is usually composed of a prefix, like `babylon://`, and the deep link intent with or without a parameter:

- `babylon://homepage`
- `babylon://somescreen/parameter`
- `babylon://nested/screen/parameter`

Currently only single, simple parameters are supported app-wide as there was no requirement for anything else, and for reliability.

The prefix is not only `babylon://`, but also several others, and the app does not distinguish between them, looking only at the intent, as long as the OS is able to invoke the app. Thus, `babylon://link` and `otherprefix://link` are equivalent from the deep link handling standpoint within the app.

Let's trace the whole process from defining a new deep link intent, possibly restricting it to specific app targets, to presenting a new screen.

## Overall architecture

The central place to handle deep links is `ApplicationInvocationRouter`, instantiated during the app bootstrap, which takes a signal of `ApplicationInvocation` wrapping deep links and `NSUserActivity`.

Deep links are represented by the struct `DeepLink`:

``` swift
struct DeepLink: Decodable {
    let url: URL
    let options: [UIApplication.OpenURLOptionsKey : Any]
    let intent: ApplicationInvocation.Intent?
```

Incoming deep link events are then processed in the private `handle` method, producing a routing event, bound to the `routes` variable in the invocation router protocol:

``` swift
protocol ApplicationInvocationRouterProtocol {
    var routes: Signal<RoutingEvent, NoError> { get }
}
```

The produced routes are then plugged into `BabylonTabBarViewModel` (always present when the user is logged in) where we define which ones require a clinical access check first, and which can be handled right away. If the route requires clinical access, the user is presented a password prompt. If, for some reason, the password check fails, the route is discarded, thus maintaining secure access to the patient's data.

`BabylonTabBarViewModel` in its turn produces a `Route.external(RoutingEvent, .deeplink)` event handled through its Flow controller, always presented modally over the tab bar controller. Some deep links switch tabs instead of presenting screens modally, which is encapsulated in the `RoutingEvent` as well.

Overall, the initial `DeepLink` value gets transformed into a `RoutingEvent` which is, essentially, just like a regular `Route` handled by Flow controllers in other parts of the app, and in `BabylonTabBarFlowController` these events are also handled in a regular fashion by constructing a screen with a `Builder` and presenting it.

### Prevent certain deep links from being handled

As a measure to release support for new deep links when the feature is fully complete, which is not necessarily at the time when the deep link is introduced, we have a special protocol:

``` swift
protocol DeeplinkConfiguration {
    func isEnabled(for intent: ApplicationInvocation.Intent) -> Bool
}
```

Any app target can define a simple `var deeplinkConfiguration: DeeplinkConfiguration { get }` as part of its `AppConfiguration` and specify which deep links are not supported by that particular app flavour. These will be filtered out during handling in `ApplicationInvocationRouter` and will have no effect.

The default value is just to return `true`, this enabling all available deep links.

### Open a deep link from within the app

When the deep links found extended usage within the app, it became apparent that interacting with them in the app through `UIApplication.openURL(_:)` was extremely inconvenient during testing. It was common for both testers and developers to have multiple versions of the app installed at the same time, and iOS, as it turned out, randomly chooses the app to handle a particular custom URL scheme from the ones installed, as long as they support it. We were unable to control which app would be opened, when interacting with a deep link from inside an app, and this could even affect end users, since they could, in theory, have several of our apps installed at the same time.

We created a special router to handle this situation:

``` swift
protocol TabDeeplinkRouterProtocol {
    func openDeeplink(_ deeplink: DeepLink)
    func handle(intent: ApplicationInvocation.Intent)
}
```

Internally it simply forwards the deep link interaction to the instance of `ApplicationInvocationRouter`, removing the OS from the equation and making sure that the deep link is always opened in the same app that it was interacted in.

If you're creating a new screen or just want to open an existing screen by using a deep link without the need to construct it, use `TabDeeplinkRouterProtocol` instead of `UIApplication.openURL(_:)` to avoid the problem described above.

## Create a new deep link

Let's dive into how to define, use and test a new deep link.

### Intent and routing event

First off, we need to introduce a new intent, which is the part of the deeplink after the prefix:

``` swift
public enum ApplicationInvocation {
    /// Custom Scheme URL.
    case deeplink(DeepLink)

    /// - note: `rawValue` is URL host name.
    public enum Intent: String {
        /// Opens Some Screen
        case someScreen = "somescreen"
    }
```

Please note that `Intent` is a string, so if the case value uses camel case, you need to specify the literal string for it to be parsed correctly.

We then add a new routing event to present the new screen in the Flow controller. Let's add a simple parameter for the sake of example:

``` swift
enum RoutingEvent {
    case showSomeScreen(id: Int)
}
```

That's it! No other type changes are needed, unless you want to “hide” the deep link, in which case you'll want to edit the `DeeplinkConfiguration` described above.

### Transform the `ApplicationInvocation`

We now need to edit `ApplicationInvocationRouter` to transform our `DeepLink` into a `RoutingEvent`:

``` swift
    private static func handle(
        _ intent: ApplicationInvocation.Intent,
        deeplinkPath: String?,
        …
    ) -> SignalProducer<RoutingEvent, AlertError> {
        switch intent {
            …
            case .someScreen:
                // Since we require an Int parameter, just 
                // go back to the home tab if it's missing.
                guard 
                    let deeplinkPath = deeplinkPath,
                    let id = Int(deeplinkPath)
                else {
                    return .value(.show(.home))
                }

                return .value(.showSomeScreen(id: id))
        }
    }
```

### Configure clinical access

Next, in `BabylonTabBarViewModel` add the new `RoutingEvent` to the relevant section of the handler based on whether the new screen requires clinical authentication or not.

So it will be either `return session.ensureClinicalAccess().then(.value(())).map(const(event))` or `return .value(event)`.

The compiler will help you here, since `RoutingEvent` is an enum and you'll have to add the new case to the switch in order for the code to compile. There is no `default` case so that we don't miss any new events here.

### Construct and present the new screen

What's left is to present the new screen in `BabylonTabBarFlowController`:

``` swift
func handle(_ route: RoutingEvent, _ location: InteractionLocation) {
    switch route {
        …
        case let .showSomeScreen(id):
            // This is an internal helper function for presenting modal screens
            presentContent { navigation, modal, presenting, showCloseIcon in
                builder.make(
                    id: id,
                    navigation: navigation,
                    modal: modal,
                    presenting: presenting
                )
            }
    }
}
```

And we're done, you should be able to open Safari, type in `babylon://somescreen`, tap “go” on the keyboard and it would take you to the app and present the new screen.

### Open the deep link from inside the app

If you also need to open this deep link from within the app, use the `TabDeeplinkRouter` described above. Assuming your deep link comes from the backend, it should already be parsed into a `DeepLink`, then all you need to do is:

``` swift
let yourDeepLink = someBackendModel.deepLink
tabDeepLinkRouter.openDeeplink(yourDeepLink)
```

This can be done from anywhere in the app. In case something is presented above the tab bar, it will be dismissed first, and the new screen will be presented.

### Testing

Most of the defined deep links are unit-tested in `ApplicationInvocationRouterTests`. In `func testTransformsDeepLinkEventToRoutingEvent()` the test is simply defined as pairs of `String` (raw deep link URLs without prefix) and `RoutingEvent`. For a new deep link, you would define a pair:

``` swift
var urls: [(String, RoutingEvent)] = [
    …
    ("somescreen/42", .showSomeScreen(id: 42))
]
```

Followed by the test check in the `expect` switch:

``` swift
switch (event, urls[events.count].1) {
    …
    case let (.showSomeScreen(id1), .showSomeScreen(id2)): return id1 == id2
}
```

We verify that a deep link URL is correctly transformed into the matching `RoutingEvent` along with the parameter, if it's required.

The deep links can also be verified in the UI tests in the `DeeplinksFeature`. We can reuse existing steps and define a test like this:

``` swift
func test_some_screen_deep_link() {
    Given("I'm logged in as a mock user")
    let id = 42
    When("I open the app with \"somescreen/\(id)\" deeplink")
    // This step would need to be created if Some Screen is a new screen.
    Then("the Some Screen screen is displayed")
}
```

This would verify, in a running app, that an external deep link results in the correct screen being open. Depending on how you specify the parameter, it may even talk to the backend, so you can also check that the screen is presenting the correct information.