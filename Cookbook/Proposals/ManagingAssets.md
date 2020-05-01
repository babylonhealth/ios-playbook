
# Managing Assets

* Author(s): Adrian Śliwa
* Review Manager: Danilo Aliberti

## Introduction
 
Babylon's iOS application is a large and advanced software project. This project consists of many frameworks. Each of them consists of many tools or features, most of which need assets (images, icons, colors, data files) to be fully implemented. The goal of this proposal is to standardize the way of adding, changing, removing and accessing assets in our codebase. 

## Motivation 

Managing assets is not a difficult engineering problem but without standardized rules, we can encounter the following issues: 
1. It can be difficult to find if a given asset is already included in one of the frameworks. At the moment we have assets in many places. 
2. It can cause duplications of assets if one misses that the asset already exists and adds it again, in the same framework or in a different one. 
3. It could be impossible to reuse an asset included in the framework A if it is not linked to the framework B where someone is implementing a feature – and requiring to link to an entire framework A just to access one asset declared in that framework A from the framework B is not a viable solution. 
4. We can end up with many duplicate solutions for accessing assets in the code. 

To make sure we won't have duplicated assets in the project and all of them will be accessible in all places where we implement features, all of us should agree on uniform rules about how and where we should add new assets and how we should manage them. 

To automate the process of generating assets' identifiers we are going to use SwiftGen (agreed solution for Localization https://github.com/babylonhealth/ios-playbook/pull/187). Having that tool in place we could also use it to generate assets' identifiers. 

## Proposed solution 

`SwiftGen` is generating 0-case enum called `Asset` with `static let`s corresponding to a given asset: 
``` 
enum Asset {
    static let close = ImageAsset(name: "Close") 
}
``` 
Then you can use it like this: 
``` let closeImage = UIImage(asset: Asset.close) ``` 
or 
``` let sameCloseImage = Asset.close.image ``` 

`SwiftGen` is supporting custom templates that gives us freedom what final code will be generated. We would like to have a tamplate which will generate something like this for assets (e.g. icons):

```
extension DesignLibrary.Icons {
    var closeImage: UIImage {
        return image(name: "Close")
    }
}
```
Than we could use it like this:
```
designLibrary.icons.close
```

### Usage 

Ultimately we would like to have a solution which allows us just add new asset and be able to use it immediately: 
1. To add new asset e.g. close icon to the project it just should be placed in `Assets.xcassets` catalog in `BabylonDependencies.framework` 
2. And then just use it like e.g: `designLibrary.icons.close` (Xcode will report an error that will be fixed by recompiling). 

To achieve this level of simplicity we have to extend the `SwiftGen` configuration to create identifiers for assets. 

### Structure
 
We agreed to have a flat structure for assets which increases discoverability (the same approach was chosen for localization). 

### Overriding 

To support the overriding of standard icons in white label apps we should update `SwiftGen` implementation to firstly access the image from `Bundle.main` which will pick target specific image and then fallback to `BabylonDependencies` if the image was not overridden. By using `SwiftGen`'s' custom template we can provide implementation like this:
```
extension DesignLibrary.Icons {
    public func image(name: String) -> UIImage {
        let bundle = Bundle(for: BundleToken.self)
        let img = UIImage(named: name, in: Bundle.main, compatibleWith: nil) 
            ?? UIImage(named: name, in: bundle, compatibleWith: nil)
        guard let result = img else { fatalError("Unable to load image named \(name).") }
        return result
    }
}
```

We should also configure SwiftGen to generate identifiers for additional assets provided by application-specific targets. We can configure `SwiftGen` to name `enum`s like `enum TargetAsset` to not have conflicts with BabylonDependencies' `enum Asset`.

### Other rules
 
Besides standard rules of adding new assets we should also take care when: 
1. We are updating an icon we should check if any other place uses it. If so and that other place shouldn't be updated we should create a new icon with an updated design. 
2. If we are removing some code which is using some icons we should check if that code was the last place which was using a given icon, if so icon should be deleted from `Assets.xcassets`. This step could be automated: if we are not using a specific image its identifier won't be used across the project. 
We can write a script which checks the usage of every asset and when it is not used anywhere, it can be deleted.

## Impact on existing codebase
 
Unfortunately, in our codebase assets are located in different places. If we will agree on the above set of rules, they should be applied for newly created assets. 

We should also make an effort to eliminate technical debt and migrate all existing assets into `BabylonDependencies`. During that process, we should have in mind it is a good opportunity to improve assets' names for SwiftGen integration. Keeping every asset in one location potentially shouldn’t increase the size of the target application on the condition that the app has all our frameworks linked.

## Alternatives considered 

1. We could try to systematize the way we include assets in specific feature frameworks but it can cause problems described in the motivation section. 

2. (`@deprecated - This point was discussed at the meeting, because we can generate code to access every asset, usage of @dynamicMemberLookup is not adding us any extra value.`) Instead of accessing icons or images by subscripts `designLibrary.tokens.icons[Asset.close]` we could use a new feature of Swift 5.1 `@dynamicMemberLookup` which could be combined with `KeyPath`. Then we could write just `designLibrary.tokens.icons.close`. 
To achieve that firstly we have to mark `struct Icons` with `@dynamicMemberLookup`. Then `enum Asset` has to become `struct`. Its `static let`s has to became just `let`s because `Dynamic key path member lookup cannot refer to static member 'close'`. To match this requirements we can just create custom templates in SwiftGen. `struct Asset` will look like this: 
```
public struct Asset {
    public let add = ImageAsset(name: "Add")
    public let close = ImageAsset(name: "Close")
    ... 
}
``` 
Then we have to write special subscript: 
``` 
@dynamicMemberLookup 
public struct Icons {
    let asset = Asset()

    public subscript(dynamicMember keyPath: KeyPath<Asset, ImageAsset>) -> UIImage {
        return asset[keyPath: keyPath].image 
    }
}
```
Having these pieces in place call side will be really simple and clean: `designLibrary.tokens.icons.close`
