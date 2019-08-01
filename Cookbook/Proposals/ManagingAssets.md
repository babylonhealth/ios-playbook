
# Managing Assets

* Author(s): Adrian Śliwa
* Review Manager: Danilo Aliberti

## Introduction

Babylon's iOS application is a large and advanced software project. This project consists of many frameworks. Each of them consists of many tools or features, most of which need icons or images to be fully implemented. The goal of this proposal is to standardise the way of adding, changing, removing and accessing assets in our codebase.

## Motivation

Managing assets is not difficult engineering problem but without standardised rules we can encounter following issues:
1. It can be difficult to find if a given icon or image is already included in one of the frameworks. At the moment we have icons and images in many places.
2. It can cause duplications of icons if the existing icon will be added again.
3. It could be impossible to reuse icon or image included in one of the frameworks which is not linked to the framework where someone is implementing a feature.
4. We can end up with many duplicate solutions for accessing icons or images in the code.

To make sure we won't have duplicated icons in the project and all icons will be accessible in all places where we implement the user interface, all of us should agree on uniform rules how and where we should add new assets and how we should manage them.


## Proposed solution

The proposed solution contains a set of rules which should be followed during manipulation of our assets:
1. All new icons and images we are going to use should be added to `BabylonDependencies.framework` in `Assets.xcassets` catalog 
2. `struct DesignLibrary.Tokens` should have another property for icons `public let icons: Icons`
3. Then we have to add a new case to `enum ImageIdentifier` which will be embedded in `struct Icons`.
4. To access e.g. close icon we could use subscripts `designLibrary.tokens.icons[.close]`
5. If we are updating an icon we should check if any other place uses it. If so and that other place shouldn't be updated we should create a new icon with an updated design.
6. If we are removing some code which is using some icons we should check if that code was the last place which was using given icon, if so icon should be deleted from `Assets.xcassets`.
7. To support the overriding of standard icons in white label apps we should update `ImageCatalogueAware.image(for imageIdentifier:in bundle: compatibleWith traitCollection:) -> UIImage` to firstly access image from `Bundle.main` and then fallback to `BabylonDependencies` if image was not overridden. We can also add support to specify from which location we would like to access given image.

## Impact on existing codebase

Unfortunately, in our codebase icons and images are located in different places. If we will agree on above set of rules, they should be applied for newly created assets. We should also make an effort to eliminate technical debt and migrate all existing icons into `BabylonDependencies`.
Keeping every icon and image in one location potentially shouldn’t increase the size of the target application on the condition that the app has all our frameworks linked.

## Alternatives considered

1. We could try to systematize the way we include assets in specific feature frameworks but it can cause problems described in the motivation section.

2. Instead of accessing icons or images by subscripts `designLibrary.tokens.icons.iconography[.close]` we could use new feature of Swift 5.1 `@dynamicMemberLookup` which could be combined with `KeyPath`. Then we could write just `designLibrary.tokens.icons.close`.
To achieve that firstly we have to mark `struct Icons` with `@dynamicMemberLookup`. Then `ImageIdentifier` has to become `struct` with `String` properties with default value:
```
struct ImageIdentifier {
    let close = "close"
}
```
Later we need create property `let imageIdentifier = ImageIdentifier()` inside `struct Icons`. Having all of these we can finally write dynamicMember subscript:
```
subscript(dynamicMember keyPath: KeyPath<ImageIdentifier, String>) -> UIImage {
    return Icons.image(for: imageIdentifier[keyPath: keyPath])
}
```
And finally use it like: `designLibrary.tokens.icons.close`. The only drawback of this approach is the fact that for new icons we have to create new property and assign the default value to it, compared to just create new `enum` `case` with the name matching asset name.

3. We are going to use SwiftGen tool to auto-generate localizable strings identifiers. Having that tool in place we could also use it to generate assets identifiers.

