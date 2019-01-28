# Babylon Design Library

* Author(s): Giorgos Tsiapaliokas
* Review Manager: ReviewManager

## Introduction
This proposal is about introducing a Design Library.

## Motivation
With our current infrastrure we have have reusable components which don't reuse the same style,
we provide different styesheets based on the design.

The idea behind this is to have reusable components with a predefined stylesheet displaying different data.
The benefit of having a design library is
1. to develop new UIs faster
2. to catch inconsistencies in the UI due to a deisgn flaw or due to an engineering mistake.

The requirement is to cover most of the common use cases and *not* to extend to edge cases.
Also we must reuse our current tools like `Bento`

## Proposed solution
We can introduce a new service which will be responsible for creating these components following
the semantics of the design styleguide which will be provided to us.

The purpose of this service isn't to expose the full potential of `Bento` components but to follow the
given design guidelines. This is an example.
Also with this service we want to limit the exposure of specific components, in order to be able to introduce  
drastic design changes in the future as easy as possible.

Furthermore, this service can also host alerts, custom viewcontroller animations, etc. 

``` swift
final class AppearenceService {
    let appearence: MutableProperty<Appearence>
    init(appearence: Appearence) {
        self.appearence = MutableProperty(appearence)
    }
}

extension AppearenceService {
    struct Appearence {
        let typography: Typography
        let colors: Colors
    }
}

extension AppearenceService.Appearence {
    struct Typography {
        typealias Font = (UIFont, UIColor)
        let headline1: Font
        let headline2: Font
        let body1: Font
        let body2: Font
    }

    struct Colors {
        let primary: UIColor
        let secondary: UIColor
    }
}

extension AppearenceService.Appearence {

     func makeButton(title: String, isEnabled: Bool, didTap: (() -> Void)?) -> AnyRenderable {
        let buttonStyleSheet = ButtonStyleSheet()

        let colorForState = isEnabled ? colors.primary : colors.primary.withAlphaComponent(0.5)

        buttonStyleSheet.compose(\.backgroundColor, colorForState)

        let activityIndicatorStyleSheet = ActivityIndicatorStyleSheet()
        let styleSheet = Component.Button.StyleSheet(
            button: buttonStyleSheet,
            activityIndicator: activityIndicatorStyleSheet,
            hugsContent: true,
            autoRoundCorners: false
        )

        return Component.Button(
            title: title,
            isEnabled: isEnabled,
            isLoading: false,
            didTap: didTap,
            styleSheet: styleSheet
        )
    }
    
    func makeLoader() -> AnyRenderable {
        let buttonStyleSheet = ButtonStyleSheet()

        let activityIndicatorStyleSheet = ActivityIndicatorStyleSheet()
        activityIndicatorStyleSheet.compose(\.activityIndicatorViewStyle, .gray)

        let styleSheet = Component.Button.StyleSheet(\
            button: buttonStyleSheet,
            activityIndicator: activityIndicatorStyleSheet,
            hugsContent: false,
            autoRoundCorners: false
        )

        return Component.Button(
            title: nil,
            isEnabled: false,
            isLoading: true,
            didTap: nil,
            styleSheet: styleSheet
        )
    }
}
```

## Impact on existing codebase
This is not a breaking change. If we agree on this one, we can port the existing codebase.

## Alternatives considered
Our current approach. We will continue to use reusable components with dedicated stylesheets.

--- 
* [x] **By creating this proposal, I understand that it might not be accepted**. I also agree that, if it's accepted,
depending on its complexity, I might be requested to give a workshop to the rest of the team. 🚀
