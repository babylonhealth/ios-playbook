# Bento-as-SwiftUI manifesto
## Preface
As part of our commitment to eventually migrate to SwiftUI, it was made clear that our infrastructure needs to be gradually made aligned with SwiftUI to both (1) prepare developers for SwiftUI paradigms and (2) reduce the cost and impact of the migration with source compatibility at best effort.
This document outlines the planned changes to Bento.
## Component composition
SwiftUI view composites are encoded into the type system, say (in pseudo code) a modifier view is expressed as `Modified<Original, U>` and the modified version of it being `Modified<Modified<Original, U>, T>`, similar to lazy collections in the Standard Library. Since different compositions always result in a unique type, it can take advantage of the implied non-substitutibility to reuse view hierarchies and reconstruct them /only/ when the component type differs.
### Modifiers
Bento would be migrated to the same composition model, and the current half-baked `styling(_:)` operator would be removed. This implies many component operators would now return a unique type that carries information about the modification. For example:
```swift
extension Renderable {
	// Before
	public func width(_ value: CGFloat) -> AnyRenderable

	// After
	public func width(_ value: CGFloat) -> Self._ConstraintModified<ExactWidth>
}
```
The unfortunate side effect is that spelling the type out in code might become an annoyance, as we cannot use opaque result types while still having to support iOS 12. Note that type erasure with `AnyRenderable` still remains an option.
Here is a list of existing operators that would be affected by this change:
| Group | Operators |
| ---- | ---- |
| Accessibility | `accessibility(label:)`, `accessibility(value:)`, `accessibility(identifier:)` |
| Frame | `width(_:)`, `requiredWidth(_:)`, `height(_:)`, `requiredHeight(_:)`, `minHeight(_:)`, `aspectRatio(_:)` |
#### Bonus: Compact hierarchy
The side benefit of such model is that changes to key paths and constraints are now directly applied against the view being modified. As an example:
```swift
UI.Image(image: appearance.tokens.icons.image(.heartFilled))
    .width(100)
    .height(100)
```
Layout operators applied against a `UIImageView` based component currently do not behave as expected — the intrinsic content size of the `UIImageView` sometimes overrides the size constraints applied by its container. With the new composition model, the size constraints are now applied to the `UIImageView`  directly and are considered by the layout engine alongside the intrinsic content size, thus producing the expected result.
### Expanding the reach of modifiers
Component styling is primarily done by supplying reference-type style sheets at component instantiation time. This is however different from the SwiftUI model, which relies on compositions for all styling needs. 
With the cornerstone brought by the accessibility and frame operators above, Bento shall introduce parity with SwiftUI by bringing in styling operators, and migrate away from style sheets.
For example, an `UI.Image` may be composed like the following snippet:
```swift
UI.Image(image: appearance.tokens.icons.image(.heartFilled))
    .renderingMode(.alwaysTemplate)
    .scaledToFit()
    .width(24)
    .height(24)
```
