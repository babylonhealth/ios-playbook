# Simple side-effect in ReactiveFeedback

* Author: Yasuhiro Inami
* Review Manager: TBD

## Introduction

This proposal adds an architectural guideline for [ReactiveFeedback](https://github.com/Babylonpartners/ReactiveFeedback) (`RAF`) that **allows to handle "simple side-effects" inside `Feedback` without actual feedback loop implemented**.

This is a companion proposal of [Mealy-Machine ReactiveFeedback](https://github.com/Babylonpartners/ios-playbook/pull/98).

## Motivation

Managing side-effect is the most important and unpredictably difficult part in iOS app development.
Fortunately, we are currently using a one-stop [ReactiveFeedback](https://github.com/Babylonpartners/ReactiveFeedback) to control states, side-effects, and feedback loops to define a whole system (or subsystem per view controller) behavior.
However, we still have a problem about **how to handle (simple) side-effects that don't require to send a next feedback event**.
For example, **logging** and **analytics event** are part of this discussion.

A typical implementation of analytics event goes like this:

```swift
class ViewModel {
    let (userAction, input) = Signal.pipe()
    let state: Property<State>
    let routes: Signal<Route>

    init(analytics: Analytics, ...) {
        analytics.track(TrackingEvent.initialized)

        /* ReactiveFeedback setup */
        self.state = Property(
            ...,
            feedbacks: [
                whenButtonTapped(analytics: analytics)
            ]
        )

        self.routes = state.signal
            .filterMap { $0.route }
            .on(value: { route in
                analytics.track(TrackingEvent.routingByFeedback(route))
            })

        userAction
            .filterMap(Route.init(userAction:))
            .observeValues { route in
                analytics.track(TrackingEvent.routingByUser(route))
            }
    }

    func send(action: UserAction) {
        input.observer(Event.ui(action))
        analytics.track(TrackingEvent.userAction(action)
    }
}

// MARK: - Feedbacks

func whenButtonTapped(analytics: Analytics) -> Feedback {
    return Feedback { signal in
        return signal
            .flatMap(.latest) { someAPI }
            .on(value: { response in
                analytics.track(TrackingEvent.apiComplete(response))
            })
            .map(Event.didFinishAPI)
    }
}
```

Please notice **how `analytics.track()`s are scattered across `ViewModel`**, mostly outside of `RAF`'s feedback system.
This is because FRP e.g. `ReactiveSwift` is **too easy to inject side-effects anywhere** by using `on(value:)` and `observeValues`.
While maintaining these side-effects inside `ViewModel` (rather than `RAF`) could be sufficient, "where to implement side-effects" ambiguity still remains, which is not ideal for practicing `RAF` architecture.

In contrast, other architectures e.g. [Elm](https://elm-lang.org) and [Redux](https://redux.js.org) focuses their side-effect handling in `Feedback` layer (`Cmd` and `Middleware`) that _may_ send next feedback event.
It's worth noting that **non-feedback type `Feedback<Never>` is a subset of `Feedback<Event>`**, thus thinking `Feedback` type as a side-effect handler is more important than using it as a feedback loop.

## Proposed solution

This proposal will let us handle side-effects inside `Feedback` without actual feedback loop implemented.

For example, instead of writing:

```swift
    func send(action: UserAction) {
        ...
        analytics.track(TrackingEvent.userAction(action)
    }
```

we can replace with `Feedback`:

```swift
let whenUserActionReceived = Feedback.sideEffect(^\Event.userAction) {
    analytics.track(TrackingEvent.userAction($0))
}

extension Feedback {
    /// Helper: simple side-effect without feedback-loop.
    static func sideEffect<Value>(_ filter: Event -> Value?, _ effect: Value -> Void) -> Feedback<Event> {
        return Feedback { signal in
            return signal
                .filterMap(filter)
                .on(value: { value in // side-effect
                    effect(value)
                })
                .ignoreValues() // no feedback loop
                .promoteValue() // for adjusting type
        }
    }
}
```

By doing so...

1. Side-effects from `on(value:)` and `observeValues` will be encapsulated inside `Feedback`, which will provide a consistent rule for practicing `RAF` architecture.
2. All side-effects occuring in `ViewModel` becomes easy to read just by checking registered `feedbacks` when instantiating `RAF.Property`.
3. Whenever this simple side-effect may in future require to send a next feedback event, we can easily modify its `Feedback` implementation without finding and moving the side-effect code that exists outside of `RAF`, then integrate into `Feedback` (or vice-versa, when we no longer need to send feedback event).

## Impact on existing codebase

This proposal will affect all construction of `ViewModel` and `RAF`, but we can apply modification little by little.

## Alternatives considered

[#98 Mealy-Machine ReactiveFeedback](https://github.com/Babylonpartners/ios-playbook/pull/98) suggests a clear separation of "feedback events" and "external events" illustrated as:

```swift
Property.init(initial: ..., reduce: ..., events: Signal<Event>, feedbacks: ...)
```

To make things more simply, we can make alternative rule to add side-effects on top of `events`.

For example, instead of writing:

```swift
let externalEvents = Signal<Event>(...)

/* This proposal's Feedback.sideEffect() style */
self.state = Property(
    ...,
    events: externalEvents, // external events
    feedbacks: [
        whenButtonTapped(analytics: analytics),
        .sideEffect(^\Event.userAction) {
            analytics.track(TrackingEvent.userAction($0))
        },
        .sideEffect(^\Event.login) {
            print("login")
        }
    ]
)
```

we can rewrite using ReactiveSwift's `Signal.on(value:)`:

```swift
// iff : (UserAction -> Event?) -> Event -> Void

let externalEvents = Signal<Event>(...)

/* Alternative: `Signal.on(value:)` style */
self.state = Property(
    ...,
    events: externalEvents
        .on(value: iff(^\Event.userAction) {
            analytics.track(TrackingEvent.userAction($0))
        })
        .on(value: iff(^\Event.login) {
            print("login")
        })
    feedbacks: [
        whenButtonTapped(analytics: analytics)
    ]
)
```

While this is more efficient than proposed solution by minimizing verbose intermediate signals, separated occurances of side-effects in `events` and `feedbacks` might look awkward if one is familiar with Elm or Redux.
