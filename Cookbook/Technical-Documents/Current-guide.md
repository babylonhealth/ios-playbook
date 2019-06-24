# `Current` Guide - how to use it in Babylon iOS Project

### Where can I find it?
- `Current` is the global instance of the `World` type which is located in the `BabylonDependencies.framework`.
Its purpose is to provide convenient access to the instances that should be shared between different parts of the app (cross-cutting concerns). 
For more information please read the [How Control the World](/Cookbook/Proposals/ControlTheWorld.md) proposal.

### Beyond the Proposal
All the properties in `Current` must have their initial values provided at initialisation time. 
But that's not the reality for all of them. These `async` properties have their initial value provided in the `SharedAppDelegate` through the method `setupCurrent`. Only after that, the whole world is ready to be used.

## `Do`s and `Don't`s

#### Do
- access `Current` **only** from topmost `AppDelegate` until `Builder`s layer
- pass the required dependencies down the chain;
- create a customized version to fit your specific needs **for tests** and set it in the test `setUp` method. Please reset it on the `tearDown` method 
```swift
override func setUp() {
    let utc = TimeZone(identifier: "UTC")!
    let locale = Locale(identifier: "en_GB")
    Current = World(autoupdatingTimeZone: utc, autoupdatingLocale: locale)
}

override func tearDown() {
    Current = .production // which returns a new `World()`
}
```
#### Don't
- access `Current` from any other layer other than `Builder`. All the other layers (`ViewModel`, `FlowController`, `ViewController`, `Model`, `BusinessController`) continue to receive their dependencies through injection when created by the builder, preferably at initialisation time;
- inject `current` as a dependency;
- mutate `Current`'s properties – or re-affect it to another instance – after `SharedAppDelegate.setupCurrent()`. You are only allowed to mutate `Current` in tests, not in app. In `Release` configuration it's a constant `let` anyway to prevent mutation;
```swift
#if DEBUG
public var Current: World = .production
#else
public let Current: World = .production
#endif
```

