# Base class for FeedbackLoops systems

* Author(s): Sergey Shulga
* Review Manager: Anders Ha

## Introduction

Almost for all our screens, we implement ViewModels which are powered by the [ReactiveFeeedback](https://github.com/Babylonpartners/ReactiveFeedback).

The current interface of VM looks like this

```swift
public protocol BoxViewModel: AnyObject {
    associatedtype State
    associatedtype Action

    var state: Property<State> { get }

    func send(action: Action)
}
```

## Motivation

One of the main issues with this approach

1. We need to implement `input` feedback in pretty much every VM which may lead to errors if do not schedule input correctly, for this we have `Feedback.input()` convenience extension

2. If the screen contains a lot of input fields we end up having a lot of events that just mutate one property of the `State` e.g
`Action.didChangeUserName(String)` `Action.didPickBirthDate(Date)`
 
## Proposed solution
1. Implementation of the feedback:

```swift
open class FeedbackLoop<State, Event, Action>: FeedbackLoopType {
  public let state: Property<State>
  private let input = Feedback<State, Update>.input()
  private let actionTransformer: (Action) -> Event

  public init(
    initial: State,
    reducer: @escaping (State, Event) -> State,
    feedbacks: [Feedback<State, Event>],
    scheduler: DateScheduler,
    actionTransformer: @escaping (Action) -> Event
  ) {
    self.actionTransformer = actionTransformer
    self.state = Property(
      initial: initial,
      scheduler: scheduler,
      reduce: { (state: State, update: Update) -> State in
        switch update {
        case let .event(event):
          return reducer(state, event)
        case let .mutation(mutation):
          return mutation.mutate(state)
        }
      },
      feedbacks: feedbacks.map { $0.mapEvent(Update.event) }
        .appending(self.input.feedback)
    )
  }

  open func send(action: Action) {
    self.input.observer(.event(actionTransformer(action)))
  }

  open func mutate<V>(keyPath: WritableKeyPath<State, V>, value: V) {
    self.input.observer(.mutation(Mutation(keyPath: keyPath, value: value)))
  }

  private enum Update {
    case event(Event)
    case mutation(Mutation)
  }

  private struct Mutation {
    let mutate: (State) -> State

    init<V>(keyPath: WritableKeyPath<State, V>, value: V) {
      self.mutate = { state in
        var copy = state

        copy[keyPath: keyPath] = value

        return copy
      }
    }
  }
}
```

2. Have one entity that both contains the State and can dispatch the action e.g [StateSnapshot](https://github.com/andersio/Cycler/blob/master/View/BoundView.swift#L34)
```swift
//@dynamicMemberLookup
public struct StateSnapshot<T: FeedbackLoopType> {
  public let state: T.State
  private weak var feedbackLoop: T?

  public init(state: T.State, feedbackLoop: T) {
    self.state = state
    self.feedbackLoop = feedbackLoop
  }

  public subscript<U>(dynamicMember keyPath: KeyPath<T.State, U>) -> U {
    get {
      return state[keyPath: keyPath]
    }
  }

  public func send(action: T.Action) {
    feedbackLoop?.send(action: action)
  }

  public func mutate<V>(keyPath: WritableKeyPath<T.State, V>, value: V) {
    feedbackLoop?.mutate(keyPath: keyPath, value: value)
  }
}
```
Then our render would look like:

```swift
public protocol Renderer {
  associatedtype FeedbackLoop: FeedbackLoopType
  associatedtype Appearance: BoxAppearance
  associatedtype Config

  init(appearance: Appearance, config: Config)

  func render(snapshot: StateSnapshot<FeedbackLoop>) -> AnyRenderable
}
```

This will allow us easier bind VM to a component e.g

```swift
return Component(textDidChange: {
   //This will still couse rerendering but we would not need to create an Event for it
    snapshot.mutate(\.userName, value: $0)
})
```


## Impact on the existing codebase

This is additive no impact can be bundled together with new `RenderableViewController`

## Alternatives considered

Leave as it is

## Referance

- [Cycler](https://github.com/andersio/Cycler)
- [CombineFeedback](https://github.com/sergdort/CombineFeedback)

