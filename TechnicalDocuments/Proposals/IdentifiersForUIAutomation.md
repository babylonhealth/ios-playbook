# Improve discoverability of elements in UI automation tests

* Author(s): Anders Ha
* Review Manager: David Rodrigues, Sergey Shulga

## Introduction
At the moment, there is no systematic approach to apply accessibility identifiers in Bento. Some components accept a custom accessibility identifier as a temporary measure, e.g. Chatbot UI components.

## Motivation
`String` accessibility identifier is fragile, and there were already a few breakages observed due to accessibility identifier mismatch. This is because the main codebase does not publish accessibility identifiers used, and therefore automation tests have no mean to ensure themselves always pick up the same identifier as defined in the main codebase. In other words, automation tests are prone to breakage when changes in accessibility identifiers happen.

## Proposed solution

### New Bento mechanism
Bento shall introduce a new requirement to `ViewLifecycleAware`:

```swift
public protocol ViewLifecycleAware: NativeView {
    // ... existing requirements.

    func updateAccessibilityIdentifiers(usingPrefix prefix: String)
}
```

When Bento is built with a Debug configuration, it should invoke `updateAccessibilityIdentifiers(usingPrefix:)` on the component root view, whenever it is bound to a given component at a given ID path for the first time.

Components are free to set accessibility identifiers in whatever way they see fit, but they *must* append the given prefix to any accessibility identifier it set.

Bento shall generates a prefix based on the section ID and the item ID. All variables are suffixed by `/`. So for example, the prefix for item `card` of section `activity` should be `activity/card/`.

### Working with Atomic Components and Design Library

Atomic components present a challenge, since composition is allowed and thus multiple components may present at the same ID path.

The proposal suggests that all atomic components to allow specifying a custom _automation name_, and implements `ViewLifecycleAware.updateAccessibilityIdentifiers(usingPrefix:)`. Composite components, that have multiple opaque child components, should propagate this call to its children if appropriate.

For example, given the conformance of these two atomic components:

```swift
struct UI.Label {
    // ... other properties
    let automationName: String

    init(/* ..., */automationName: String = "label") {
        self.automationName = automationName
    }
}

struct UI.Button {
    // ... other properties
    let automationName: String

    init(/* ..., */automationName: String = "button") {
        self.automationName = automationName
    }
}

extension UI.Label: ViewLifecycleAware {
    func updateAccessibilityIdentifiers(usingPrefix prefix: String) {
        return prefix + automationName
    }
}

extension UI.Button: ViewLifecycleAware {
    func updateAccessibilityIdentifiers(usingPrefix prefix: String) {
        return prefix + automationName
    }
}
```

When this particular composite component is rendered:

```swift
public enum PrettyCardAutomationName: String {
    case notice
    case submit
}

func prettyCard() -> AnyRenderable {
    return [
        UI.Label(/* ... */, automationName: PrettyCardAutomationName.notice),
        UI.Button(/* ... */, automationName: PrettyCardAutomationName.submit)
    ].stack(axis: .vertical)
}

render(
    Box(
        sections: [
            Section(id: .activity, items: [
                Node(id: .card, component:
                    prettyCard()
                )
            ])
        ]
    )
)
```

It should result in two accessibility identifiers:

* `activity/card/notice` applied to the label; and
* `activity/card/submit` applied to the button.

Notice that an enum for the automation name `PrettyCardAutomationName` has been defined. This publishes the automation names, so as to facilitate the next suggestion of this proposal...

### Working with UI automation tests

Now that we have a systematic approach of defining and publishing information about accessibility identifiers, we can use this to reliably generate accessibility identifiers in UI automation tests!

The proposal suggests that the UI automation test target should link with all UI frameworks. This allows the automation code to have access to `Renderer`s and any published `AutomationName` enums, and can therefore construct accessibility identifiers. Changes made to any section ID, item ID or automation name enums would either be automatically picked up by the automation code, or lead to compile-time breakage depending on the circusmtances.

`BaseScreen` shall be extended to provide a conveinence:
```swift
extension BaseScreen {
    subscript<Renderer: BoxRenderer>(
        _ renderer: Renderer.Type,
        _ section: Renderer.SectionID,
        _ item: Renderer.ItemID,
        _ subcomponent: String? = nil
    ) -> String {
        return "\(section)/\(item)/" + (subcomponent ?? "")
    }
}
```

which the automation code can rely on. For example:

```swift
import BabylonHealthManagementUI

class FeedScreen: BaseScreen {
    func tapSubmit() {
        let button = app[FeedRenderer.self, .activity, .card, PrettyCardAutomationName.submit]
        button.tap()
    }
}
```

### Solving the associated enum issue

In our use cases, it is very common to have section IDs and item IDs associated with unique identifiers of some other domain models, and hence the use of enums with associated values.

Unfortunately, results from printing these enums via `String.init` is not quite ideal for our use cases. For example, considering this snippet:

```swift
enum SpecialItem {
    case bento
    case sushi
}

enum ItemID {
    case item(SpecialItem)
    case generic(String)
}
```

Printing `.item(.bento)` results in `item(SwiftPlayground.SpecialItem.bento)`, which includes the fully qualified type name of the enum as part of the associated payload. On the other hand, printing `.generic("wasabi")` results in `generic("wasabi")`, which preserves the double quote.

The issue can be resolved by implementing `CustomStringConvertible` on the ID enums. But to improve the developer experience, the proposal sugggests also providing a utility printing enums in a consistent way that works for us. Specifically, these criteria should be met:

* enum without associated values should be printed as `caseName`; and
* enum with associated values should be printed as `caseName(value)`; and
* integer and strings as associated values should be printed as is without any punctuation added; and
* Repeated printing should always lead to the same outcome.

The utility would be in the form of a `AutoPrettyEnumDescription` protocol which refines `CustomStringConvertible` with a default implementation of `description`. It would use `Mirror` internally.

A caveat: There is a scenario, filed as [SR-10272](https://bugs.swift.org/browse/SR-10272), where `Mirror` does not reflect an enum correctly as expected. But it should be rare in practice.

## Impact on existing codebase
Additive changes.

## Alternatives considered
Status quo: Fragile accessibility identifier; ad hoc definition of accessibility identifier.
