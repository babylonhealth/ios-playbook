# DesignLibrary Technical Documentation

This is a FAQ for `DesignLibrary`.

## How can I use `DesignLibrary`?

If you are working on a feature called `Foo` and you are following our architecture then you also have `FooRenderer` like 

```swift
struct Foo: BoxRenderer {
    struct Config {}
   
    private let appearance: BabylonAppAppearance
    private let observer: (Action) -> Void
    private let config: Config

    init(
        observer: @escaping (Action) -> Void,
        appearance: BabylonAppAppearance,
        config: Config
    ) {
        self.observer = observer
        self.appearance = appearance
        self.config = config
    }
```

`BabylonAppAppearance` is a typealias for `DesignLibrary.ComponentsBuilder` so you can call `appearance` in order to reuse Bento components, here is an example

```swift
private func renderTextInput(
    id: ItemID,
    title: String? = nil,
    placeholder: String,
    text: String?,
    isEnabled: Bool,
    isSecure: Bool = false,
    accessory: UIImage? = nil,
    textDidChange: @escaping (String) -> Void,
    didTapAccessory: (() -> Void)? = nil
) -> Node<ItemID> {
    return Node(
        id: id,
        component: appearance.input(
            title: title ?? "",
            placeholder: placeholder,
            image: accessory.map { image in return { _ in image } },
            text: text.map(TextValue.plain),
            isSecure: isSecure,
            textDidChange: {
                textDidChange($0 ?? "")
            },
            didTapImage: didTapAccessory
        )
    )
}
```

## How can I access fonts and colors from my renderer? 

```swift
struct Foo: BoxRenderer {
    struct Config {}
   
    private let appearance: BabylonAppAppearance
    private var tokens: DesignLibrary.Tokens { 
        return appearance.tokens
    }
    .......

    private func renderSomething() {
        tokens.colors.primary // This is our primary color
        appearance.font(fontAttributes: tokens.footer) // This is a footer
    }

```

## Why `DesignLibrary` doesn't allow me to construct a custom color or font?

Because we must use specific colors and fonts which have been decided by our design team.
 
## Do you have any real examples.

Yes, check the `GalleryApp` :)

## Where can I find all the components which are approved by our design team?

Go to `Zeplin` and select the `Design System` tag.


## How can I reuse navigation controllers?

In `DesignLibrary` there is a factory method which will create a navigation controller which will be
compatible with out design guidelines.

```swift
    DesignLibrary.viewControllersBuilder().navigationController(rootViewController: someViewController)
```

## Custom styling for navigation controllers

Also the styling of the navigation controllers can be configured from the `Renderer`.
The navigation controllers support different navigation behaviours.
Currently these behaviours are related only to styling and they don't interfere with the actual navigation.

The available Navigation Behaviours are 
- `NavigationBarHidingBehaviour`
- `NavigationControllerBackgroundColorBehaviour`
- `NavigationBarTitlesBehaviour`


As an example of that if we have a `Renderer` called `MyFeatureRenderer` then we can extend it and 
comfort to `NavigationBehavioursProvider`


```swift
extension MyFeatureRenderer: NavigationBehavioursProvider {
    func navigationBehaviours() -> [NavigationBehaviour] {
        return [
            NavigationBarHidingBehaviour(hideNavigationBar: false),
            NavigationControllerBackgroundColorBehaviour.sameBackgroundColor,
            NavigationBarTitlesBehaviour.displayNormalTitles
        ]
    }
}
```

- `NavigationBarHidingBehaviour` controls if the navigation bar will be hidden.
- `NavigationControllerBackgroundColorBehaviour` controls the background color of the navigation contoller
- `NavigationBarTitlesBehaviour` controls the style of the title, the available values are `.displayLargeTitles` and `.displayNormalTitles`