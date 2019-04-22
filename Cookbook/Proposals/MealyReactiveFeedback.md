# Mealy-Machine ReactiveFeedback

* Author: Yasuhiro Inami
* Review Manager: TBD

## Introduction

This proposal focuses on following improvements in `ReactiveFeedback`.

1. Allow `Feedback` to also handle "incoming event" (not just from "current state" only)
2. Distinguish between "external event" and "feedback"
3. Remove duplicated `state` caching in both `SignalProducer` and `Property`

## Motivation

### 1. Allow `Feedback` to also handle "incoming event"

Current `ReactiveFeedback` (as of ver 0.5.0) has `Feedback` type which represents side-effect and event feedback loop for a particular or entire system:

```swift
public struct Feedback<State, Event> {
    let events: (Scheduler, Signal<State, NoError>) -> Signal<Event, NoError>
}
```

(For simplicity, we will ignore `Scheduler` for this entire discussion)

This kind of structure is so-called [Moore machine](https://en.wikipedia.org/wiki/Moore_machine) where feedback (output function) only takes `State` (or stream of `State`s) as argument and produces side-effects with accompanying new `Event` (or stream of `Event`s).

Compared to this approach, current frontend architecture normally uses [Mealy machine](https://en.wikipedia.org/wiki/Mealy_machine), or [Queue automaton](https://en.wikipedia.org/wiki/Queue_automaton) (feedback model) instead, where reducer (transition function) takes both `State` and `Event`, then produces a new `State` and `Output` (with feedback).

<details>
<summary>Examples of Mealy machine (Click to open)</summary>

For example, [Elm](https://package.elm-lang.org/packages/elm-lang/core/latest/Platform) uses `update: Event -> State -> (State, Cmd<Event>)` as reducer.
Note that this single function can be splitted into two functions:

1. `Event -> State -> State`, and
2. `Event -> State -> Cmd<Event>`

which we often call 1. reducer and 2. feedback.

[Redux](https://redux.js.org) also provides similar mechanism called `Middleware`, where `middleware: (store: Store) -> (next: Dispatch) -> Action -> Any`.
This can be rewritten as `State -> Observer<Event> -> Event -> Any` which can then be re-interpreted as `State -> Event -> Signal<Event>` (Caveat: This is not 100% logically correct).

</details>

More information about differences between Moore and Mealy can be found here:
[Moore and Mealy Machines](https://www.tutorialspoint.com/automata_theory/moore_and_mealy_machines.htm)

Please note that **both Moore and Mealy machines are theoretically convertible to each other** , so it is still reasonable to keep using current Moore-based machine.

However, from practical point of view, Mealy machine has several advantages over Moore machine:

- Requires less states
    - This is a general conclusion of Mealy machine compared to Moore because we will add more graph-edges (transition patterns) than graph-nodes (states).
- `Event`-recognizable `Feedback`
    - For simple side-effects such as **logging**, **sending analytics events**, or somtimes **routing** or **image-loading** can be handled just from incoming events without precisely handling their states inside `ReactiveFeedback`
    - This will remove verbose "idle -> routing -> idle" navigation state transition dance, and improves the feedback-based-navigation idea in [Babylonpartners/ios-playbook#44](https://github.com/Babylonpartners/ios-playbook/pull/44)
    - We can discard `Event`s to turn the system back into current Moore machine at any time (**backward compatible**)

### 2. Distinguish between "external event" and "feedback"

Current `Feedback` is NOT actually handling "feedback" only, but also handling "external events" by injecting them into feedback closure, e.g.:

```swift
let incrementFeedback = Feedback<Int, Event> { _ in // NOTE: argument is not used
    incrementSignal.map { _ in Event.increment }
}
```

Notice that `Signal<State>` argument is not used at all.
While this code works in general, mixing these 2 different semantics causes verbosity and sometimes confusion.

The ideal approach will be to **separate "external events" as plain `Signal<Event>`, and pass it as a new argument next to `Feedback`s**.

The idea of "external event" has been previously discussed in [Babylonpartners/ReactiveFeedback#32](https://github.com/Babylonpartners/ReactiveFeedback/pull/32), and it also makes sense from automata theory that "external events" (alphabets) and "feedbacks" (output function) are different.
Also, Elm provides [`Subscription`](https://package.elm-lang.org/packages/elm/core/latest/Platform-Sub) which works just as same as observing "external events" and it is different from feedback type called `Cmd<Event>`.

Furthermore, by separating "external event" nicely, we can send "initial external event" only after system is instantiated, so that the racing issue described in [ReactiveFeedback/pull#38](https://github.com/Babylonpartners/ReactiveFeedback/pull/38#issuecomment-468478325) will no longer occur.

### 3. Remove duplicated `state` caching in both `SignalProducer` and `Property`

`State` is stored in both `scan` and `Property` which is obviously inefficient.

## Proposed solution

### Changes

```diff
 public struct Feedback<State, Event> {
-    let events: (Scheduler, Signal<State, NoError>) -> Signal<Event, NoError>
+    let events: (Scheduler, Signal<(Event, State), NoError>) -> Signal<Event, NoError>
 }

 extension Property {
     public convenience init<Event>(
         initial: Value,
         scheduler: Scheduler = QueueScheduler.main,
         reduce: @escaping (Value, Event) -> Value,
+        events: Signal<Event>,   // external events
         feedbacks: [Feedback<Value, Event>]
     ) {
         ...
     }
 }

+// NOTE: We won't have `SignalProducer.system` using `scan` anymore,
+// but instead we use `Property.producer`.
-extension SignalProducer where Error == NoError {
-    public static func system<Event>(
-        initial: Value,
-        scheduler: Scheduler = QueueScheduler.main,
-        reduce: @escaping (Value, Event) -> Value,
-        feedbacks: [Feedback<Value, Event>]
-    ) -> SignalProducer<Value, NoError> {
-        ...
-    }
-}
```

- `Feedback` preserves the streaming format, i.e. `Signal<???> -> Signal<Event>` rather than `??? -> Signal<Event>` so that it can have flattening capability e.g. `flatMap(.latest)` or `flatMap(.first)`.
- Resolves [Babylonpartners/ReactiveFeedback#32](https://github.com/Babylonpartners/ReactiveFeedback/pull/32)
- Improves [Babylonpartners/ios-playbook#44](https://github.com/Babylonpartners/ios-playbook/pull/44)
    - Resolves "idle -> routing -> idle" navigation state transition dance.
- **Backward compatible** with current Moore machine (we can still add as many states for precise control as we want)

### Usage Examples

#### Example 1: Simple (counter, logging, analytics event)

```swift
let externalEvent = Signal.merge(
    increment.map { Event.increment },
    decrement.map { Event.decrement }
)

let loggingFeedback = Feedback { signal -> Signal<Event> in
    return signal
        .on(value: { event, state in // side-effect
            // NOTE: Now we can also retrieve `event` as well as `state`!
            print("receiving event = \(event) with state = \(state)")
        })
        .ignoreValues() // no feedback loop
        .promoteValue() // for adjusting type
}

let analyticsFeedback = Feedback { signal -> Signal<Event> in
    return signal
        .filter { event, _ in event == .increment }
        .on(value: { event, _ in // side-effect
            // NOTE: Analytics is one of the example that doesn't need state changes at all.
            analytics.send(event: Analytics.Event.didTapIncrement)
        })
        .ignoreValues() // no feedback loop
        .promoteValue() // for adjusting type
}

let system = Property(
    initial: 0,
    reduce: counterReducer,
    events: externalEvent,
    feedbacks: [loggingFeedback, analyticsFeedback]
)
```

To simplify the duplicated code above, see `Feedback.noFeedback` in [ios-playbook#102](https://github.com/Babylonpartners/ios-playbook/pull/102).

#### Example 2: Navigation

```swift
let externalEvent = Signal.merge(
    didTapA.map { Event.route(Route.pushA) },
    didTapB.map { Event.route(Route.modalB) }
)

let navigationFeedback = Feedback { signal -> Signal<Event> in
    return signal
        // NOTE: Using `flatMap(.first)` prevents from routing to multiple screens simultaneously
        .flatMap(.first) { event, _ in
            guard case let route = event.route else { return .empty }
            return flowController.handle(route)
        }
        .ignoreValues() // no feedback loop
        .promoteValue() // for adjusting type
}

let system = Property(
    initial: 0,
    reduce: reducer,
    events: externalEvent,
    feedbacks: [navigationFeedback]
)
```

For navigation feedback rule and `flatMap(.first)`, see also [Babylonpartners/ios-playbook#44](https://github.com/Babylonpartners/ios-playbook/pull/44).
This is a handy FRP way of managing "isTransitioning" state outside of `State`.

Because this routing is now event-driven rather than state-driven, **we don't need to transit the state back to the original position after completed, which will reduce the intermediate `case`s e.g. `State.isPushingA` and `Event.didFinishPushingA`**.
(But note that we might still want to have these cases if we want to precisely handle tem to avoid interfering with other events/states/feedbacks)

#### Example 3: Image Loading

```swift
enum Event {
    case callAPI(Request)
    case fetchImages(Response)
    case reloadCell(image: UIImage, index: Int)
}

struct State {
    var images: [/* cellIndex */ Int: UIImage?] = [:]
}

let externalEvent = Signal.merge(
    viewDidLoad.map { Event.callAPI(Request(apiURL)) }
}

let apiFeedback = Feedback { signal -> Signal<Event> in
    return signal
        .flatMap(.first) { event, _ in
            guard case let .callAPI(request) = event else { return .empty }
            return apiSession.send(request)
        }
        .map(Event.fetchImages)
}

let imageFeedback = Feedback { signal -> Signal<Event> in
    return signal
        .flatMap(.merge) { event, _ -> Signal<(UIImage?, index: Int)> in
            guard case let .fetchImages(response) = event else { return .empty }
            return imageLoader.fetchAllImages(response.imageURLs)
        }
        .map { image, index in
            Event.reloadCell(image: image, index: index)
        }
}

let reducer = { state, event in
    guard case let .reloadCell(image, index) = event else { return state }

    var state = state
    state.images[index] = image
    return state
}

let system = Property(
    initial: State(),
    reduce: reducer,
    events: externalEvent,
    feedbacks: [apiFeedback, imageFeedback]
)

system.signal
    .combinePrevious(initial: system.value)
    .startWithValues { oldState, newState in
        // NOTE: diff & patch algorithm must be efficient enough to update images only
        let patch = diff(oldState, newState)
        realView.apply(patch: patch)
    }
```

This is a typical image loading example that changes state for every cell's image being ready.

**Caveat:** Diff & patch algorithm must be efficient enough to update images only. Otherwise, we need to rely on primitive FRP e.g. `ReactiveSwift.Property` which will become tightly coupled with virtual view (See [Babylonpartners/Bento#144](https://github.com/Babylonpartners/Bento/issues/144) and [Slack](https://babylonhealth.slack.com/archives/G9S9L0TEK/p1554731131006300))

## Impact on existing codebase

This proposal will be a **breaking change**, but modification will be relatively **small** because current state structures can be fully preserved (though it can be minimized).

## Alternatives considered

N/A
