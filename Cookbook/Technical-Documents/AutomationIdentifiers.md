# Automation Identifiers

## Updating how Screen Elements are located

One of the challenges/maintenance activities we face with our UI tests is that the majority of elements do not have an `accessibilityIdentifier` defined and the value of the element is used instead. This makes the tests more fragile to changes in copy and requires a corresponding update to the automation. Normally we need to update how elements are located because the text has changed either in lokalise or a backend response.

This page covers why this happens and how we can improve the testing moving forward.

## How to Find Elements

The most efficient way to locate an `XCUIElement` on screen is to use accessibility combined with a query. The framework supports among other methods accessibility labels and accessibility identifiers. We should avoid using accessibility labels because these are used by VoiceOver, can be localized and can be accessed by external tools. Accessibility identifiers are developer-facing, not localized and is the method recommended by Apple.

### Locating Elements

Identification of `XCUIElement`s in automation code should be done in the screen objects and screen objects should not reference each other. If interacting with an element is handled elsewhere this is probably a bug. Though in some cases the identifiers are injected at run time, this has been used in content driven screens i.e. promo code details.

#### Identifiers

The identifiers are strings defined in a Screen Object namespace using a private enum or injected into the constructor of Screen Object. As you can see from the example below, we have used both accessibility identifiers and the text within the element to locate `XCUIElement`s.

##### Chatbot Bento Screen

```swift
fileprivate enum Others {
    static let ctaInput = "inputContentbarCTAInputView"
    static let textInput = "inputContentInputBarView"
    static let imageInput = "inputContentPhotosAccessoryView"
    static let outgoingImage = "outgoingImage"
    static let outgoingText = "outgoingText"
    static let assessment = "incomingOutcomeAssessment"
    static let miniMap = "outgoingMiniMap"
}

fileprivate enum StaticTexts {
    static let callSamaritans = "Are you sure you want to call Samaritans?"
    static let callSupport = "Are you sure you want to call support?"
    static let leafletOne = "NHS Choices"
    static let leafletTwo = "NHSChoices"
    static let summary = "View information about possible causes for your symptoms."
    static let assessment = "View Assessment"
    static let rate = "Rate answer"
}
```

#### Queries

The other way to find an element is using an `XCUIElementQuery` which can either make use of an identifier or not. The key difference is that a query requires detailed knowledge of the screen layout and is more commonly used when several `XCUIElement`s with the same identifier are displayed on the screens i.e. the address list.

##### Examples

- `let element = app.navigationBars[NavigationBars.pageHeader]` Returns a single `XCUIElement` or throws an error if there are multiple matches
 - `let queryWithIdentifier = app.navigationBars.matching(identifier: NavigationBars.pageHeader)` Returns a `XCUIElementQuery` array with multiple `XCUIElement`
- `let queryWithOutIdentifier = app.navigationBars` Returns a `XCUIElementQuery` array with all navigation bars on screen
- `let queryWithSingleResult  = app.navigationBars.firstMatch` Returns the first `XCUIElment` matching the `XCUIElementQuery` and is the only method that stops searching on the first match, while the other methods will search the entire view hierarchy.

## Updating Locators

The quick solution is to simply update the enum. When an identifier's text has changed, this is very straightforward and simple. Update the text defined in the enum to the correct value and automation should start working. Resulting in Pull Requests like this https://github.com/Babylonpartners/babylon-ios/pull/6475

```swift
fileprivate enum NavigationBar {
    static let header = "Privacy policy"
    - static let telus = "Babylon by TELUS Health Privacy Policy"
    + static let telus = "Privacy Policy"
}
```

While this will fix the test, it is susceptible to future changes. In this case time permitting, we should attempt to define an `accessibilityIdentifier` for the element and then update the enum to use this identifier. This is not always possible as in the case with chat responses, but it is something we should strive for in order to make our tests more stable and maintainable, reducing the amount of updates needed in the future.

### Using AccessibilityContent

It is now possible to directly use accessibility identifiers defined during implementation time without resorting to raw strings.

There is a namespace `AccessibilityContent` in `BabylonDependencies` that should be used by developers to define accessibility identifiers for controls, grouped by screen, for example for Promo Code Entry screen we define a `PromoCode` enum with child controls:

``` swift
public enum AccessibilityContent {
    public enum PromoCode: String {
        case codeCell
    }
}
```

After this identifier has been set on a control, we can `import BabylonDependencies` in a Screen implementation in automation, and update the query to use this identifier:

``` swift
let promofield = app.tables
    .matching(.cell, identifier: AccessibilityContent.PromoCode.codeCell)
    .textFields
    .firstMatch
```

Note that you may need to set the identifier on the cell itself rather than its internal components, as automation may have problems finding elements otherwise.

It is also preferable to always use `.matching(.cell, identifier: …).firstMatch` rathen than a subscript (`[…]`) as the subscript variant only expects a single match. If, for some reason, there are several, it will throw an error.

### Using identifiers to find screens

A common pattern for a screen is to define its title in a `NavigationBars` enum and check for that:

``` swift
class NotificationsScreen: BaseScreen {
    fileprivate enum NavigationBars {
        case pageHeader = "Notifications"
    }

    func isScreenDisplayed() -> Bool {
        let header = app.navigationBars[NavigationBars.pageHeader]
        return tryWait(for: header, with: .exists, timeout: normalWait)
    }
}
```

Instead, we can define the screen identifier in `AccessibilityContent`…
``` swift
public enum AccessibilityContent {
    public enum Notifications: String {
        case screenName = "notificationsScreen"
    }
}
```

…and then set it as an accessibility identifier on the `Screen` in our `Renderer`:
``` swift
func render(state: State) -> Screen<SectionID, NodeID> {
    return Screen(
        title: localization.title,
        …
        accessibilityIdentifier: AccessibilityContent.Notifications.screenName.rawValue
    )
}
```

This identifier is then set either on the table or collection view (rather than the root view), depending on which flavour of the `BoxViewController` we are using for rendering the screen.

Now we can modify the `isScreenDisplayed` function to search for it:

``` swift
class NotificationsScreen: BaseScreen {
    func isScreenDisplayed() -> Bool {
        let header = app.tables[AccessibilityContent.Notifications.screenName.rawValue]
        return tryWait(for: header, with: .exists, timeout: waitToLoad)
    }
}
```

We are using subscript access here rather than `.matching(…)` because we only expect one instance of the screen's identifier present at one time.

### Updating Queries

The most common root cause is that the `XCUIElementQuery` requires an update. The thing we need to consider is that the performance of the XCTest framework is affected by how much of the view hierarchy is searched when looking for an element. This is because the framework will by default search the entire view hierarchy. This is time consuming, the recommended solution is to give the query as much information as possible. For example, below, we are telling the framework that the button is within an alert, this improves the performance of the test.

```swift
let okButton = app.alerts.buttons[Buttons.okButton]
```

But comes at the cost, that if the layout changes, the query itself, not the identifier can be broken. In this case the query will need to be updated to reflect the change, i.e. if the button moves from the alert to table. Then the query should be updated to:

```swift
let okButton = app.tables.buttons[Buttons.okButton]
```

This will fix the issue, while not changing the identifier itself.

### Accessibility Identifier Naming

This is something that tends to be subjective. But in general I would recommend using the naming convention used in ChatBot Bento, which has worked well. The key requirement is that identifier should be unique to each screen, except when used in a dynamic list i.e an address list. Also if the element itself can be present on multiple screens we should also include a reference to the screen in the name.

For example in the registration screen I would recommend the following for the "Lets go" button as it is both unique to the screen and application.
- **"letsGo"**

However for the first name field as this is present in multiple screens I would use:
    - **"registerFirstName"**
