# DesignLibrary Technical Documentation

The purpose of this document is provide information regarding

- how you can use existing components
- General Design Guidelines related to `DesignLibrary`.
- how you can implement new components to `DesignLibrary`.

## How to use DesignLibrary

- How can I reuse view controllers?

```swift
DesignLibrary.viewControllersBuilder().navigationController(....)
```

- If you are working on a feature called `Foo` and you are following our architecture then you also have `FooRenderer` like 

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

- How can I access fonts and colors from my renderer? 

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

## General Design Guidelines related to `DesignLibrary`.

-  Why `DesignLibrary` doesn't allow me to construct a custom color or font?

Because we must use specific colors and fonts which have been decided by our design team.

- Do you have any real examples?

Yes, there is the `GalleryApp`. The scheme of the target is `GalleryApp` and the source
code location is `Babylon/GalleryApp`. It contains all the available components. 

- Where can I find all the components which are approved by our design team?

 You can find them in [Zeplin](https://zpl.io/2ZL1odJ)


## How you can implement new components to `DesignLibrary`

### Guidelines for adding new factory methods to `DesignLibrary`
The API the factory method should be semantically relative  to the functionality of the method.

For instance, if you have a banner which has an icon which can aligned vertically then

__Wrong__

```swift
    func banner(title: String, color: UIColor, stackViewAlignment: UIStackView.Alignment) -> AnyRenderable { ... }
```

__Correct__

```swift
    enum IconAlignment {
        case top
        case center
        case bottom
    }
    func banner(title: String, color: UIColor, iconAlignment: IconAlignment) -> AnyRenderable { ... }
```

### Nomenclature around `DesignLibrary` and the available tools

In order to implement a new factory method in `DesignLibrary` you need to 
be aware of all the available tools that we have.
Also the nomenclature is important, so we will start with defining that we have.

### What are the `BentoKit` components and how to use them in order to create new factory methods in `DesignLibrary`

`BentoKit` contains feature rich components. `BentoKit` was designed with developer ergonomics in
mind. All the `BentoKit` components are available under the `Component` namespace.
All the `BentoKit` components are configurable via their initializer.
This is an example of a factory method using `BentoKit`

```swift
    func input(      
        title: String,
        placeholder: String? = nil,
        textDidChange: (String) -> ()
    ) -> AnyRenderable {
        let inputStyleSheet = ...
        return Component.Input(
            title: title, 
            placeholder: placeholder,
             textDidChange: textDidChange, 
             styleSheet: inputStyleSheet
        ).asAnyRenderable()
    }
```

These components are feature rich but they aren't as flexible as `Atomic` components.
You should always prefer the `Atomic` components over these.

### `Atomic` components

`Atomic` components are lightweight components which are the `Bento` equivalent of standard `UIKit` components.
They are lightweight because the purpose is to compose them.

# TODO add Documentation about atomic components!

### When and why to create custom  `Bento` components using view based composition in `DesignLibrary`

This applies when you create custom components from scratch. In practice this rarely happens. 
You should follow this approach only if there are technical limitations which doesn't allow you to implement the component otherwise.
*Component composition* is always preferred over *view composition*.

### Component Composition
So by this point you must be familiar with these terms `BentoKit` components, `Atomic` components and custom components with view based composition.
In order to do component composition there are two ways 
- either manually
- or by making use of the `Layout` Components

Composing components manually is more flexible but its not a trivial task. Due to its non trivial nature we have created the `Layout` Components. 
These components do comfort to the `Renderable` protocol.

### Layout Components 

# TODO add Documentation about Layout components!
