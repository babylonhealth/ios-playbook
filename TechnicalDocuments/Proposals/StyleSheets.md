# Composable value-type style sheets

* Author(s): Anders Ha
* Review Manager: Sergey Shulga, David Rodrigues

## Problem Statement
The current inheritance based StyleSheet approach is unideal in three areas:

1. Ease of Use: Requiring upfront declarations of all styleable properties.

    We would have to constantly match UIKit changes. Custom views would require manual implementation.

2. Mental Model: Awkwardness when being applied to views that are opened for extension.

    When one defines a non generic `ExtensibleViewStyleSheet` for an `ExtensibleView`, the `StyleSheetProtocol.Element` associated type is immediately satisfied with the concrete view type. This means in a generic environment bound to `StyleSheetProtocol`, only `apply(to _: ExtensibleView)` would be recognised since `Element == ExtensibleView` per the conformance. In other words, all stylesheet subclasses must override this base class typed method & are required to downcast at runtime to access stuff defined in the subclass.

    On the other hand, when one defines a generic `ExtensibleViewStyleSheet<T: ExtensibleView>` stylesheet, it does address the said issue by satisfying `StyleSheetProtocol.Element` with a generic parameter. However, it leads to awkward and verbose spellings at use sites in general, e.g. `ExtensibleViewStyleSheet<ExtensibleView>`.

3. Correctness: Unintended Sharing

    Stylesheets are currently classes so as to be able to take advantage of inheritance, and this makes them prone to unintended sharing. With Swift offering first-class value type, this might amplify its possibility due to common perception of configurations being modelled as value types.

## Identified Requirements

1. The approach must be applicable to reusable views.

    When multiple style sheets with symmetrical differences are applied in a row in any order, the reused view would not end up in an indeterministic state.

1. The approach must be compatible with view subclassing.

1. The approach should address unintended sharing if possible.

## Proposed Solution

A new value type `StyleSheet<View>` shall be introduced, with the following features:

1. Copy on write & value semantics: Backed by CoW `Dictionary`. Support `Equatable` out of the box.

2. Built around Key Paths introduced since Swift 4, and has proper support of entries setting key paths that are partially overlapping with each other.

3. Support producing **inverses** for deterministic view reuse.

    Before applying a stylesheet, a snapshot of all affected key paths is taken, and is returned to the callee after the application. It is up to the callee whether to and when to apply the snapshot for change reversal.

    In the case of a reusable view/cell, the expectation is that the view would store the inverse/snapshot & apply it as part of the cleanup e.g. in `prepareForReuse()`.
    
    This eliminates the state indeterminism of closure-based styling approaches, while not requiring any default value to be declared upfront like how our `StyleSheet` framework currently does. 

4. Can be used for any view and any arbitrary subclass without type declaration.

### Implementation Plan

1. As soon as the new `StyleSheet` type is available in Bento, new components shall start using it.

2. Extensions to either `UIView` or `Base*View` shall be made to provide a convenience which stores & applies style sheets on one's behalf. For example:

   ```swift
   view.backgroundColor = .green
   view.clipsToBound = false

    // NOTE: `apply` automatically keeps the inverse.
   view.apply(
       StyleSheet()
            .setting(\.backgroundColor, .red)
            .setting(\.clipsToBound, true)
    )
   expect(view.backgroundColor) == .red
   expect(view.clipsToBound) == true

    // NOTE: The stored inverse is applied before the new style sheet is applied.
    //       So `clipsToBound` would be reverted to the original value.
   view.apply(
       StyleSheet()
            .setting(\.backgroundColor, .blue)
    )

   expect(view.backgroundColor) == .blue
   expect(view.clipsToBound) == false
   ```

3. BentoKit components shall be gradually migrated as soon as possible, potentially in batches to limit source breakage. Existing components may continue to use their existing style sheet types until author wishes to migrate.

### Potential Issues
#### Support only mutable properties.
Not all stying parameters are exposed as instance properties.

`UIButton` is the most apparent example. We could mitigate this by providing extensions with computed properties of `[UIControl.State: U]`.

#### Might require use of protocols to limit exposed surface.
If there are properties, inherited from a parent view class, that should be hidden on the component root view, one might need to declare a protocol with all whitelisted properties.

```swift
protocol SpecialButtonProtocol {
    var layoutMargins: UIEdgeInsets { get set }
}

extension UIButton: SpecialButtonProtocol {}

// EXAMPLE: We hide all properties except for `layoutMargins`.
let styleSheet: StyleSheet<SpecialButtonProtocol>

var button = UIButton()
styleSheet.apply(to: &button)
```

## Impact on existing APIs
The value type `StyleSheet` is an additive change alone.

However, assuming we subsequently replace all existing BentoKit component style sheets, this shall be a massive source breaking change.

### Potential Migration Path
While script-based and staged migration is a viable solution, additional effort on top of snapshot testing might be required to verify that the removal of style sheet defaults does not lead to changes in visual appearance. 

## Alternatives considered
### Status Quo
We can continue to use the existing solution, redeclaring all customizable parameters, writing the manual code to apply them, and continuing to avoid unintended sharing of style sheet instances at best effort.

### Code Generation
Code generation is an equally viable solution, in the sense that style sheets would become partially synthezied value types which resolves unintended sharing, whereas inhertiance is replaced by annotations. However, as part of an infrastructual solution, requiring build-time integration beyond linkage, need of learning Bento specific code-gen configurations and the maintenance might not be appealling to the general crowd.