# `Current` Guide - how to use it in Babylon iOS Project

### Where can I find it?
- `Current` is the global instance of the `World` type which is located in the `BabylonDependencies.framework`. 
Its purpose is to provide convenient access to the instances that should be shared between different parts of the app (cross-cutting concerns). For more information please read the [How Control the World](/Cookbook/Proposals/ControlTheWorld.md) document.

## `Do`s and `Don't`s

#### Do
- access `Current` **only** from topmost `AppDelegate` until `Builder`s layer
- pass the required dependencies down the chain;
- create a customized version to fit your specific needs **for tests** and set it in the test `setUp` method
```swift
let locale = Locale(identifier: "haw_US")
Current = World(autoupdatingLocale: locale)
```
- reset the instance of `Current` to the default in the `tearDown` method
#### Don't
- access `Current` from any other layer other than `Builder`. All the other layers (`ViewModel`, `FlowController`, `ViewController`, `Model`, `BusinessController`) continue to receive their dependencies through injection when created by the builder, preferably at initialisation time;
- inject `current` as a dependency;
- try to mutate `Current` (excluding Tests). In `Release` configuration it's a constant `let`;
```swift
#if DEBUG
public var Current: World = .production
#else
public let Current: World = .production
#endif
```

