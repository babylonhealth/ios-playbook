# Feedback Navigation

* Author(s): Sergey Shulga
* Review Manager: TBD

## Introduction

As all of you probably know in our codebase we use `Route` based navigation, where VM has a signal of routes which emits a specific route and FlowController just listens to it and performs navigation.

Although the current concept is fine and we've been happy with it for a while now, it does look a bit weird when it comes to integration with RAF.
For example, we've recently agreed that we derive all routes from the `State`  of the VM. Also, sometimes we need to pass closures to the routes as we need to notify our VM when a user selects something on the child screen.

```swift
routes = state.signal.skipRepeats().filterMap { state in
            switch state {
            case let .loaded(_, error?):
                return .showAlert(.make(error: error))
            case .searching:
                return .showMap(mapResponsesObserver.send(value:)) // here we are passing a closure which will push value into our VM
            case let .showingDirections(_, place):
                return .showDirections(place)
            }
        }
```

## Motivation

The idea is to deal with navigation in the same way we deal with networking. Where navigation can be treated as an async operation the result of which is going to impact the current state of the VM.

## Proposed solution

```swift    
static func whenSearching(flowController: PharmaciesFlowController) -> Feedback<State, Event> {
        return Feedback { state -> SignalProducer<Event, NoError> in
            guard case .searching = state else {
                return .empty
            }
            return flowController.showMap()
                .map(Event.didSelectPlace)
        }
    }

final class PharmaciesFlowController {
    func showMap() -> SignalProducer<MapResponse, NoError> {}
    
    // I case where navigation does not impact current screen
    func showSomething() -> SignalProducer<Never, NoError> {}
}
```

Unlike other Feedbacks, we may not want the navigation to be canceled when the state changes so we can not use `Feedback` overloads which are using `flatMapLatest` under the hood. The possible solution would be to use `flatMapFirst` strategy instead, so if navigation effect is in progress it won't be canceled until it's finished and a new one wont be started.

Other things that we can improve with this approach is we can finally unify the way we manage presentation of a screen. Meaning that an object that is responsible for presenting a screen would be responsible for dismissing it.

```swift
    func showMap() -> SignalProducer<MapResponse, NoError> {
    
// This is not a final  implementation, it's just a hint how it may look conceptualy.
	return SignalProducer { observer, lifetime in
		let vc = self.builders.makeMap(response: observer, modal: modal, presenting: self.presentationFlow)
            lifetime += AnyDisposable {
            
// Here is example how we can rely on the `SignalProducer` lifecycle to dismiss the screen
                self.presentationFlow.dismiss()
            }
        }
    }
```

## Impact on an existing codebase

This proposal is additive so it should not impact much on the rest of the codebase. Even the same flow controller potentially could have old (with routes) and new interface (with methods that return SignalProducer)

## Alternatives considered

N/A

---
* [x] I will send a meeting invitation, using this [template](Template_Proposal_Meeting_Invitation.MD), scheduled for 2 weeks after this proposal is made, so an agreement can be reached.
* [x] **By creating this proposal, I understand that it might not be accepted**. I also agree that, if it's accepted,
depending on its complexity, I might be requested to give a workshop to the rest of the team. 🚀
