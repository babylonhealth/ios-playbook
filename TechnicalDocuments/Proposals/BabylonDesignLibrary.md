# Babylon Design Library

* Author(s): Giorgos Tsiapaliokas
* Review Manager: Anders Ha

## Introduction
This proposal is about introducing a Design Library.

## Motivation
With our current infrastrure we have have reusable components which don't reuse the same style,
we provide different styesheets based on the design.

The idea behind this is to have reusable components with a predefined stylesheet displaying different data.
The benefit of having a design library is
1. to develop new UIs faster.
2. to catch inconsistencies in the UI due to a deisgn flaw or due to an engineering mistake.

The requirement is to cover most of the common use cases and *not* to extend to edge cases.
Also we must reuse our current tools like `Bento`.

For instance, in our codebase a common UI element is a rounded button with background color. 
For that we use `Component.Button` and a stylesheet while this approach is functional is has a few drawbacks.
The attributes of the button (background color, alpha, corner radius etc) can either 
1. have been redefined in another part of the codebase which is good from a design point of view *and if* we search
for them we can use them, *if we don't* search for them we will just reimplement something which already exists.
2. or the attributes of the button haven't been redefined in another part of the application and we may not
notice that so a design flaw will be implemented. We are humans after all :).


## Proposed solution
We can introduce `DesignLibrary` which will be responsible for creating these components following
the semantics of the design styleguide which will be provided to us.

The purpose of  `DesignLibrary` isn't to expose the full potential of `Bento` components but to 
follow specific design guidelines.
As an example of this is: 
A `Bento` component supports different behaviours like  `Deletable` the goal of this
proposal isn't to replicate them or to make a wrapper around them but to follow specific design guidelines
and to offer reusable UI elements.

Also with `DesignLibrary` we want to limit the exposure of specific components, in order to be able to introduce  
drastic design changes in the future as easy as possible.
For example `DesignLibrary.ComponentsBuilder.button` returns `AnyRenderable` instead of `Component.Button`
because in the future we may decide that we need to use a different button component. We want to depend on abstractions.

Furthermore, `DesignLibrary` can also host alerts, custom viewcontroller animations, etc.

``` swift

struct DesignLibrary {
    let configuration: Configuration

    var viewControllerBuilder: ViewControllerBuilder {
        return ViewControllerBuilder(configuration: configuration)
    }

    var componentBuilder: ComponetsBuilder {
        return ComponetsBuilder(configuration: configuration, traits: UITraitCollection())
    }

    init(
        configuration: Configuration
    ) {
        self.configuration = configuration
    }
}

extension DesignLibrary {
    struct Configuration {
        let typography: Typography
        let colors: Colors
    }
}

extension DesignLibrary.Configuration {
    struct Typography {
        let headline1: UIFont
        let headline2: UIFont
        let body1: UIFont
        let body2: UIFont
    }

    struct Colors {
        let primary: UIColor
        let secondary: UIColor
    }
}

extension DesignLibrary {
    struct ComponetsBuilder: BoxDesignLibrary {
        let configuration: Configuration
        var traits: UITraitCollection

        @available(*, deprecated, message: "Use DesignLibrary.Configuration")
        public var brandColors: BrandColorsProtocol = DefaultBrandColor()

        @available(*, deprecated, message: "Use DesignLibrary.Configuration")
        public var appColors: AppColors = AppColors()

        @available(*, deprecated, message: "Use DesignLibrary.componentBuilder")
        public var modern: ModernPalette {
            return ModernPalette(self)
        }

        fileprivate init(configuration: Configuration, traits: UITraitCollection) {
            self.configuration = configuration
            self.traits = traits
        }

        func primaryButton(title: String, isEnabled: Bool, didTap: (() -> Void)?) -> AnyRenderable { ... }

        func secondaryButton(title: String, isEnabled: Bool, didTap: (() -> Void)?) -> AnyRenderable { ... }

        func loader() -> AnyRenderable { ... }
    }
}

extension DesignLibraryService {
    struct ViewControllerBuilder {
        let configuration: Configuration

        func makeConfirmationModal(
            title: String,
            description: String,
            acceptButtonTitle: String,
            declineButtonTitle: String
        ) -> UIViewController { ... }
    }
}
```

## Impact on existing codebase
`DesignLibrary` will be accessible via `Current` and `BabylonBoxViewController` will be modified in order to
make the change less distruptive.
Here is the implementation of the above statement

```swift
/// extend `World`
import Bento
import BentoKit
import ReactiveSwift

protocol DesignLibraryProtocol {
    associatedtype ComponentsBuilder: BoxAppearance
    var componentsBuilder: ComponentsBuilder { get }
}

extension DesignLibrary.ComponetsBuilder: BoxAppearance {}
extension DesignLibrary: DesignLibraryProtocol {}

/// Note: DesignLibrary can't be used directly here due to
/// framework dependencies.
struct World<DesignLibrary: DesignLibraryProtocol> {
    let DesignLibrary: MutableProperty<DesignLibrary>
}

/// Use Current in BabylonBoxViewController
class BabylonBoxViewController<ViewModel, Renderer>: BoxViewController<
    ViewModel,
    Renderer,
    DesignLibrary.ComponetsBuilder
> where
    ViewModel: BoxViewModel,
    Renderer: BoxRenderer,
    ViewModel.State == Renderer.State,
    ViewModel.Action == Renderer.Action,
    Renderer.DesignLibrary == DesignLibrary.ComponetsBuilder {
    init(
        viewModel: ViewModel,
        renderer: Renderer.Type,
        rendererConfig: Renderer.Config
    ) {
        super.init(
            viewModel: viewModel,
            renderer: renderer,
            rendererConfig: rendererConfig,
            appearance: Current.DesignLibrary.map(\.componentsBuilder)
        )
    }
}
```
This initializer can also be dropped but the change will be more disruptive.

Also `DesignLibrary.ComponentsBuilder` includes
- `DesignLibrary.ComponentsBuilder.brandColors`
- `DesignLibrary.ComponentsBuilder.appColors`
- `DesignLibrary.ComponentsBuilder.modern`

in order to be source compatible with the current `BabylonAppAppearance` and to replace it. 

## Alternatives considered
Our current approach. We will continue to use reusable components with dedicated stylesheets.

--- 
* [x] **By creating this proposal, I understand that it might not be accepted**. I also agree that, if it's accepted,
depending on its complexity, I might be requested to give a workshop to the rest of the team. 🚀
