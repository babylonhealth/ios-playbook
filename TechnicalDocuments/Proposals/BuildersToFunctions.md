# 13. Replace Builders with Free Functions

* Author(s): Rui Peres
* Review Manager: Giorgos Tsiapaliokas

## Introduction

The goal of this proposal is to replace the concept of a Builder as a struct to Builder as a "namespaced" static function. This could be in the following shape:

```swift
enum Builder {}

extension Builder  {
    enum Alert {
            static func makeAlert(for error: CoreError, dismiss: (() -> Void)?) -> UIAlertController
            static func makeAlert(for message: String, title: String?, dismiss: (() -> Void)?) -> UIAlertController
            static func makeAlert(for error: AlertError,
                                  primaryAction: UIAlertAction,
                                  secondaryAction: UIAlertAction) -> UIAlertController
    }
}
```

This would allow us to remove the protocol `AlertBuilder` and remove all the compliances across the codebase. From a usage point of view:

```swift
final class AppointmentListFlowController {
    let primary: Flow
    let secondary: Flow

    init(primary: Flow, secondary: Flow) {
        self.primary = primary
        self.secondary = secondary
    }

    func handle(_ route: AppointmentListViewModel.Route) {
        switch route {
        case let .showAlert(error):
            Builder.Alert.makeAlert(for: error, dismiss: secondary.dismiss)
                |> secondary.present
        }
    }
}
```

I will provide further examples in the proposal

## Motivation

There are a couple of reasons for this change:

1. It was decided that DI via `Current` would happen at the builders level. This means that the requirement to inject dependencies via initializer, in builders, cease to exist. This would remove: protocols, clean FlowControllers APIs and dissolve the concept of child builders. 
2. It would become easier to find factory methods to construct screens. One could just type `Builder.` and Xcode would autocomplete with the available factory methods. It would also free engineers from wasting too much time finding dependencies if they are immediately accessible via `Current` and the namespaced free functions. This is not a justification for engineers to not understand the codebase and how to do things "properly". It is simply an observation of how cumbersome passing dependencies via initializer is, the raison d'être for `Current` and the overall way of creating screens (VM + VC + FC). 

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
    enum ClinicalRecords {
        static func makeMedicalHistory(modal: Flow) -> UIViewController
    }
}
```

Particular medical histories (e.g. for minors) can also be created, but in this case, the minor session would be passed instead of relying on `Current`. This situation (with child builders) can be observed at `ClinicalRecordsChildBuilders.swift`:

```swift
extension Builder {
    enum ClinicalRecords {
        func makeMedicalHistory(with session: Session, modal: Flow) -> UIViewController
        func makeMedicalHistory(modal: Flow) -> UIViewController
    }
}
```

This would remove the intricate structure we have with builders and their children.

A side effect of this approach, because we are dealing with functions (versus structs) we are able to remove local state. An example of this is `enableClinicalDownloads` in `ClinicalRecordsChildBuilders`. You can see the code smell here:

```swift
builders.appointmentList(with: session,
                         enableClinicalDownloads: builders.enableClinicalDownloads,
                         addressSwitches: builders.addressSwitches)
```

With the free functions approach, this would never be possible to do, since builders don't hold state:

```swift
extension Builder {
    enum ClinicalRecords {
        static func makeAppointmentList(session: UserSession,
                                 enableClinicalDownloads: Bool,
                                 addressSwitches: AddressSwitchesProtocol,
                                 primary: Flow,
                                 secondary: Flow) -> UIViewController
    }
}
```

At the call site, we would replace this:

```swift
case let .appointmentList(session):
    builders
            .appointmentList(with: session,
                             enableClinicalDownloads: builders.enableClinicalDownloads,
                             addressSwitches: builders.addressSwitches)
            .make(primary: navigation, secondary: modal)
            |> navigation.present
```

With this:

```swift
case let .appointmentList(session):
    Builder.ClinicalRecords
            .makeAppointmentList(with: session,
                                enableClinicalDownloads: enableClinicalDownloads,
                                addressSwitches: addressSwitches,
                                primary: navigation,
                                secondary: modal)
            |> navigation.present
```

## Impact on an existing codebase

As Ilya pointed out it would make unit testing a bit more cumbersome. That's the case because you no longer inject builders. I would like to make the case for the following:

1. We don't test `FlowControllers` with Unit tests anyway. This is not a reason to not do it, it's simply difficult to justify time doing so, when there are more important pieces to be tested and those tests would bring, in my opinion, little value. More value would be achieved by the next point (**2.**).
2. We can test that a particular navigation/flow is done as expected independently of this proposal being approved or not. For that to happen we simply observe a ViewModel state and assert on it, since we derive routes from the state.
3. If we "really" want to test FlowControllers, it's still possible by mocking `Current`, which is something trivial to achieve (`World.init()`). The difference here is that we can't say we are **Unit** testing FlowControllers, but instead these become **Integration** tests. I personally don't feel this is semantically significant. 

Given all those points, it has no impact, since we don't test that layer and there are currently no plans in the short term to do so. 

There is still the question about moving `UserSession`, or something in that shape, to `Current`. Based on an initial conversation with Anders, and quoting him, it would be a "fairly low" effort. This is for me a point that should be thought carefully and be a reason to reject this proposal. 

As a proposal on its own, it wouldn't have any immediate impact. For new features, and assuming `UserSession` in `Current` is in place, those could start using this approach. Builders that don't rely on `UserSession` could be migrated immediately. 

## Alternatives considered

Leave as is.


