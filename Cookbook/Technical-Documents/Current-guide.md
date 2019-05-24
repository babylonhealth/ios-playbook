# `Current` Guide - how to use it in Babylon iOS Project

### Where is that? 
- `Current` is the global instance of the `World` type which is located in the `BabylonDependencies.framework`. 
Its purpose is to provide convenient access to the instances that should be shared between different parts of the app (cross-cutting concerns). For more information please read the [How Control the World](/Cookbook/Proposals/ControlTheWorld.md) document.

## `Do`s and `Don't`s

#### Dos
- access `Current` **only** from `Builder`s layer;
- pass the required dependencies down the chain;
- create a customised version to fit your specific needs **for tests**;
```swift
let locale = Locale(identifier: "haw_US")
Current = World(autoupdatingLocale: locale)
```

#### Don't
- access `Current` from any other layer other than `Builder`. All the other layers (`ViewModel`, `FlowController`, `ViewController`, `Model`, `BusinessController`) continue to receive their dependencies through injection when created by the builder, preferably at initialisation time;
- inject `current` as a dependency;
- try to mutate `Current`. In `Release` configuration it's a constant `let`;
```swift
#if DEBUG
public var Current: World = .production
#else
public let Current: World = .production
#endif
```

