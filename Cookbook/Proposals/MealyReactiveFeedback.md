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
```

- `Feedback` preserves the streaming format, i.e. `Signal<???> -> Signal<Event>` rather than `??? -> Signal<Event>` so that it can have flattening capability e.g. `flatMap(.latest)` or `flatMap(.first)`.
- Resolves [Babylonpartners/ReactiveFeedback#32](https://github.com/Babylonpartners/ReactiveFeedback/pull/32)
- Improves [Babylonpartners/ios-playbook#44](https://github.com/Babylonpartners/ios-playbook/pull/44)
    - Resolves "idle -> routing -> idle" navigation state transition dance.
- **Backward compatible** with current Moore machine (we can still add as many states for precise control as we want)

### Usage

```swift
let externalEvent = Signal.merge(
    increment.map { Event.increment },
    decrement.map { Event.decrement }
)

let system = Property(
    initial: 0,
    reduce: counterReducer,
    events: externalEvent,
    feedbacks: [loggingFeedback, analyticsFeedback]
)

/// We can simply create SignalProducer from this system,
/// without creating producer first then bind to property.
let p = system.producer
```

## Impact on existing codebase

This proposal will be a **breaking change**, but modification will be relatively **small** because current state structures can be fully preserved (though it can be minimized).

## Alternatives considered

N/A
