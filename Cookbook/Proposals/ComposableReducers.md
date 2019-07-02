# Composable Reducers using Lenses and Prisms

* Author: Yasuhiro Inami
* Review Manager: David Rodrigues

## Introduction

This proposal adds functional [`Lens` and `Prism`](#functional-lens--prism) to break down `reducer` / `state` / `event` (`action`) in [ReactiveFeedback](https://github.com/Babylonpartners/ReactiveFeedback) so that we can create a large application from small component compositions.

## Motivation

In Babylon.app, we are using [ReactiveFeedback](https://github.com/Babylonpartners/ReactiveFeedback) to control states, side-effects, and feedback loops to define a particular screen (view controller) behavior, owned by `ViewModel`.

However, this `ViewModel` can easily become too complex as `reducer: (State, Event) -> State` grows large with tons of pattern-matching.

Unfortunately, splitting into multiple `ViewModel`s is not a clever solution, as managing multiple `ReactiveFeedback`s that interact with each other tends to be hard to control.

To curcumvent this problem, we instead **split `reducer`s and also `state`s and `event`s**, and then combine them using `Lens` and `Prism`.

The basic idea can be found in @mbrandonw ’s talk:

[Brandon Williams \- Composable Reducers & Effects Systems \- YouTube](https://www.youtube.com/watch?v=QOIigosUNGU)

## Proposed solution

### Functional `Lens` & `Prism`

```swift
/// For accessing struct members.
/// e.g. Whole = whole struct (members), Part = partial member
struct Lens<Whole, Part> {
    let get: (Whole) -> Part
    let set: (Whole, Part) -> Whole
}

/// For accessing enum cases.
/// e.g. Whole = all possible enum cases, B = partial case
struct Prism<Whole, Part> {
    let preview: (Whole) -> Part?
    let review: (Part) -> Whole
}
```

- `Lens` is a pair of "getter" and "setter" (similar to `WritableKeyPath<A, B>`, but more composable)
- `Prism` is a pair of:
    - `preview` (tryGet): Tries to get an associated value of particular enum case from whole enum cases, which is failurable
    - `review` (inject): Creates whole enum from particular case (i.e. `case` as enum constructor)

While `Lens` is useful for traversing `struct` members, `Prism` is useful for traversing `enum` cases.
Because in ReactiveFeedback, `State` is normally defined as `struct` and `Event` is `enum`,
we need both features to be able to transform `reducer` and `feedback` into arbitrary structure.

### `Reducer`

```swift
struct Reducer<Action, State> {
    let reduce: (Action, State) -> State

    init(_ reduce: @escaping (Action, State) -> State) {
        self.reduce = reduce
    }

    /// Zero value for `+`.
    static var empty: Reducer {
        return Reducer { _, s in s }
    }

    // Append operator, just like `+`.
    static func <> (lhs: Reducer, rhs: Reducer) -> Reducer {
        return Reducer { action, state in
            rhs.reduce(action, lhs.reduce(action, state))
        }
    }
}
```

`Reducer` is a wrapper type around `reduce: (Action, State) -> State` function that conforms to `Monoid` (has "zero" and "+") to combine 2 reducers into one.

By using this `append`ing capability, we can create more complex `Reducer` from splitted `SubReducer`s.

### `Reducer` lifting from `SubState` / `SubAction`

However, `SubReducer`s don't normally have the same type with the others, even with the `(Main)Reducer` type.

For example,

- Main screen: `MainReducer = Reducer<MainAction, MainState>`
    - Component 1: `SubReducer1 = Reducer<Sub1Action, Sub1State>`
    - Component 2: `SubReducer2 = Reducer<Sub2Action, Sub2State>`
    - ...

To convert `SubReducer1` and `SubReducer2` types into `MainReducer` (so that they can be combined using `<>`), we can use the following `lift` functions:

```swift
extension Reducer {
    /// `Reducer<Action, SubState> -> `Reducer<Action, State>`
    func lift<SuperState>(state lens: Lens<SuperState, State>) -> Reducer<Action, SuperState> {
        return Reducer<Action, SuperState> { action, superState in
            lens.set(superState, self.reduce(action, lens.get(superState)))
        }
    }

    /// `Reducer<SubAction, State> -> `Reducer<Action, State>`
    func lift<SuperAction>(action prism: Prism<SuperAction, Action>) -> Reducer<SuperAction, State> {
        return Reducer<SuperAction, State> { superAction, state in
            guard let action = prism.preview(superAction) else { return state }
            return self.reduce(action, state)
        }
    }
}
```

In short, to bring each small reducers to the same level and combine, we need `lift`.

And to `lift`, we need `Lens` and `Prism`.

## Example

```swift
// MARK: - Component 1 (isolated from Main & Component 2)
//---------------------------------------------------------

enum Sub1Action {
    case increment
    case decrement
}

struct Sub1State {
    var count: Int = 0
}

let subReducer1 = Reducer<Sub1Action, Sub1State> { action, state in
    switch action {
    case .increment: return state.with { $0.count + 1 }
    case .decrement: return state.with { $0.count - 1 }
    }
}

// MARK: - Component 2 (isolated from Main & Component 1)
//---------------------------------------------------------

enum Sub2Action { ... }
struct Sub2State { ... }
let subReducer2: Reducer<Sub2Action, Sub2State> = ...

// MARK: - Main
//---------------------------------------------------------

enum MainAction {
    case sub1(Sub1Action)
    case sub2(Sub2Action)
    ...
}

extension Prism where Whole == MainAction, Part == Sub1Action {
    static let sub1Action = Prism(
        preview: {
            guard case let .sub1Action(action) = $0 else { return nil }
            return action
        },
        review: AppAction.sub1Action
    )
}

...

struct MainState {
    var sub1: Sub1State
    var sub2: Sub2State
    // var shared: ...  /* NOTE: Shared state can belong to here */
}

extension Lens where Whole == MainState, Part == Sub1State {
    static let sub1State = Lens(
        get: { $0.sub1 },
        set: { whole, part in
            whole.with { $0.sub1 = part }
        }
    )
}

...

let mainReducer: Reducer<MainAction, MainState> =
    sub1
        .lift(action: .sub1Action)
        .lift(state: .sub1State)
    <>
    sub2
        .lift(action: .sub2Action)
        .lift(state: .sub2State)
```

## Impact on existing codebase

This proposal will affect all construction of `ViewModel` and `RAF`, but we can apply modification little by little.

## Alternatives considered

TBD
