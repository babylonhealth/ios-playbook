# 13. Replace Builders with Free Functions

* Author(s): Rui Peres
* Review Manager: Giorgos Tsiapaliokas

## Introduction

The goal of this proposal is to simplify the usage of builders across the codebase, improve discoverability and development ergonomics. This can be achieve via `Current`, since most, but not all, dependencies can be found there. An example of such change would be going from this:

```swift
struct FlowControllerFooBar {
   private let primary: Flow
   private let builder: BuilderFooBarProtocol

   init(primary: Flow, builder: BuilderFooBarProtocol) {
      self.primary = primary
      self.builder = builder
   } 

   func handle(state: State) {
      switch (state) {
       case .bar: 
           builder.makeFooBar() |> primary.present
      }
   }
}
```

To this:

```swift
struct FlowControllerFooBar {
   private let primary: Flow
   private let builder: BuilderFooBar

   init(primary: Flow, builder: Builder.FooBar = Builder.FooBar()) {
      self.primary = primary
      self.builder = builder
   } 

   func handle(state: State) {
      switch (state) {
       case .bar: 
           builder.makeFooBar() |> primary.present
      }
   }
}
```

I will further examplify the advantages of said approach in the next sections.

## Motivation

There are a couple of reasons for this change:

1. It was decided that DI via `Current` would happen at the builder level. This means that the requirement to inject dependencies via the initializer, in builders, ceases to exist. This would: remove protocols, clean FlowController's APIs and dissolve the concept of child builders. 
2. It would become easier to find factory methods to construct screens. One could just type `Builder.` and Xcode would autocomplete with the available factories. It would also free engineers from wasting too much time finding dependencies if they are immediately accessible via `Current` and the namespaced factory entities. This is not a justification for engineers to not understand the codebase and how to do things "properly". It is simply an observation of how cumbersome passing dependencies via initializer is, the raison d'être for `Current` and the overall way of creating screens (VM + VC + FC). 

The first point is about simplicity and clean-up of multiple ways of creating screens, while the second point focuses on discoverability and development ergonomics.   

## Proposed solution

**Note:** The proposed solution assumes that a way to authenticate HTTP requests is available at `Current` level (in this case something in the shape of `MainUserSession` abstracted via `UserSession`).

Let's use `MedicalHistoryBuilder.swift` as an example, since it offers a trivial API: 

``` swift
init(session: UserSession, visuals: VisualDependenciesProtocol)
```

And the corresponding public API:

```swift
func make(modal: Flow) -> UIViewController
```

Given the Module where it's located it could be migrated to:

```swift
extension Builder {
    struct ClinicalRecords {
        internal(set) var makeMedicalHistory: (Flow) -> UIViewController = { _ in UIViewController() }
    }
}
```

Which would allow the consumer to set a default parameter value in the `FlowController` initializer. Instead of:

```swift
struct ClinicalRecordsFlowController {
    private let navigation: Flow
    private let modal: Flow
    private let presenting: Flow
    private let builders: ClinicalRecordsChildBuilders

    public init(navigation: Flow,
                modal: Flow,
                presenting: Flow,
                builders: ClinicalRecordsChildBuilders) {
        self.navigation = navigation
        self.modal = modal
        self.presenting = presenting
        self.builders = builders
    }
```

One would:

```swift
struct ClinicalRecordsFlowController {
    private let navigation: Flow
    private let modal: Flow
    private let presenting: Flow
    private let builder: Builder.ClinicalRecordsBuilder

    public init(navigation: Flow,
                modal: Flow,
                presenting: Flow,
                builder: Builder.ClinicalRecordsBuilder = Builder.ClinicalRecordsBuilder()) {
        self.navigation = navigation
        self.modal = modal
        self.presenting = presenting
        self.builder = builder
    }
```

This provides the flexibility, in case testing is desirable via the `internal(set)`.

Particular medical histories (e.g. for minors) can also be created, but in this case, the minor session would be passed instead of relying on `Current`. This situation (with child builders) can be observed at `ClinicalRecordsChildBuilders.swift`:

```swift
extension Builder {
    struct ClinicalRecords {
        internal(set) var makeMedicalHistory: (Session, Flow) -> UIViewController 
        internal(set) var makeMedicalHistory: (Flow) -> UIViewController
    }
}
```

This would remove the intricate structure we have with builders and their children and protocols.

## Impact on an existing codebas

There is the question about moving `UserSession`, or something in that shape, to `Current`. Based on an initial conversation with Anders, and quoting him, it would be a "fairly low" effort. This is for me a point that should be thought about carefully and could be a reason to reject this proposal. 

As a proposal on its own, it wouldn't have any immediate impact. For new features, and assuming `UserSession` in `Current` is in place, those could start using this approach. **Builders that don't rely on `UserSession` could be migrated immediately**. 

## Alternatives considered

Using Ilya's suggestion about structs with functions as properties, versus static free functions. The overall goals of the proposal are preserved and it provides flexibility for testing. 

