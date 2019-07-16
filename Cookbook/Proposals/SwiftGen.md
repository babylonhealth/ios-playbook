## Adopt SwiftGen for localisable strings

* Author: David Rodrigues
* Review Manager: Danilo Aliberti

### Introduction

Localisable strings by themselves are not a hard thing to use but for apps with a significant number of strings it's entirely impossible to remember or discover easily the respective key to use.

```swift
title = NSLocalizedString("hello_world_title", comment: "")
```

Because of this, and considering the size of our codebase, we use concrete types that map our localisable strings which enables the usage of autocomplete.

```swift
public struct LocalizationUI {
    public struct Common {
        public static var ok: String { return localizedName(key: "general_ok") }
        ...
    }
}
```

### Problems

The current approach works, as we would expect, but there's a couple of caveats in it.

##### 1. Maintenance

This types at the moment are created and managed by us manually which means any new addition/edition/removal needs to be done by us. This may not look very significant but considering the number of strings, more than 3k, it is a lot to be maintained/extended.

##### 2. Safety

While this types are useful for development by enabling autocomplete they don't provide any safety since we can add a new property for a new key without necessarily adding the new string.

### Proposed Solution

SwiftGen is a code generator which is able to generate all this types and properties automatically by running a script which would fix the two main problems that we have with the current approach.

- Maintenance will be zero because everything will be mapped based on the localisable strings;
- Compile-time type safety will be guaranteed because everything will be generated from the localizable strings making it impossible to use something without being in the strings file or keep using something that was deleted.

SwiftGen also supports strings with dynamic input generating a function to be called with all the parameters which also ensures safety as we clearly know that a certain string requires some dynamic values.

We still need to ensure this script is correctly executed every time that we add/edit/remove a string but that's a easier task to manage over the current approach.

### Implementation

Adopting SwiftGen won't be a trivial task and would require a certain level of investment from us.

##### Namespacing

Based on how we have our keys defined we won't be able to mangle them into namespaces directly, we will have a huge flat list with all the strings. This can be changed but requires a major refactor of the keys to define the respective vertical/domain/module.

As an example, `chatbot_send` should become `chatbot.send` to ensure we get a namespace for chatbot. Ideally we would like to keep the same namespaces to avoid a huge refactor in the codebase.

```swift
enum L10n {
  enum Chatbot {
    static let send = L10n.tr("chatbot.send")
  }
```

Because this involves a major rename of keys this needs to be properly analyzed and coordinated to avoid any side-effects.

##### Target Specific Localization

We current have two sets of strings, the main localization and one target specific to allow further customisation if/when needed. This requires custom handling where we query the target specific table first and only then we fallback to the main table. SwiftGen has support to search in other strings files but considering our specific flow we may need to write our own custom template to ensure we keep the same flow.

##### Tests

We have a couple of tests using localisable strings from the tests bundle and they will be impacted with this change. The alternative is to use the main bundle for them which can cause more failures with snapshot testing depending how often the strings get updated after being introduced. Alternatively, we can write our own custom template to keep the existent flow.

### Alternatives

There are other code generators that we can use as an alternative but SwiftGen seems the most popular in the community and we have the creator in our team 😃, if we have any issue we can have a great level of support.

The other alternative is to keep the current approach and don't make any changes although keep the problems stated above since they are not easily solvable.

### Future

Assuming this gets accepted we could use it to extend to asset catalogs and colors.