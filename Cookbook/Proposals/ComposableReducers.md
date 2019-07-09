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

    static func >>> <Part2>(l: Lens<Whole, Part>, r: Lens<Part, Part2>) -> Lens<Whole, Part2> {
        return Lens<Whole, Part2>(
            setter: { a, c in l.setter(a, r.setter(l.getter(a), c)) },
            getter: { r.getter(l.getter($0)) }
        )
    }
}

/// For accessing enum cases.
/// e.g. Whole = all possible enum cases, B = partial case
struct Prism<Whole, Part> {
    let preview: (Whole) -> Part?
    let review: (Part) -> Whole

    static func >>> <Part2>(l: Prism<Whole, Part>, r: Prism<Part, Part2>) -> Prism<Whole, Part2> {
        return Prism<Whole, Part2>(
            preview: { a in l.preview(a).flatMap(r.preview) },
            review: { a in l.review(r.review(a)) }
        )
    }
}
```

- `Lens` is a pair of "getter" and "setter" (similar to `WritableKeyPath<A, B>`, but more composable)
- `Prism` is a pair of:
    - `preview` (tryGet): Tries to get an associated value of particular enum case from whole enum cases, which is failable
    - `review` (inject): Creates whole enum from particular case (i.e. `case` as enum constructor)

While `Lens` is useful for traversing `struct` members, `Prism` is useful for traversing `enum` cases.

Because in ReactiveFeedback, `State` is normally defined as `struct` and `Event` is `enum`,
we need both features to be able to transform `reducer` and `feedback` into arbitrary structure.

#### Why `Prism` ?

The power of `Prism` shines when they make composition using `>>>`.

For example, consider refactoring gigantic `enum Event` that has flattened cases:

```swift
/// 999 flattened cases, oh my! 🤯
enum Event {
    case button1(String)
    case button2(String)
    case button3(String)
    ...
    case button999(String)

    var button1: String? { ... }
}

let event: Event = Event.button1("OK")
let ok: String? = event.button1
```

into a more structured nested `enum`s (so that we can focus on each sub-domains):

```swift
// NOTE: Splitted into subdomains
enum Event {
    case sub1(Sub1Event)
    case sub2(Sub2Event)
    ...
    var sub1: Sub1Event? { ... }

    enum Sub1Event {
        case button1(String)
        case button2(String)

        var button1: String? { ... }
    }
    enum Sub2Event {
        case button3(String)
    }
}

// Because it has one level deeper, the code becomes longer than previous example.
let event: Event = Event.sub1(.button1("OK"))
let ok: String? = event.sub1?.button1
```

But this kind of code becomes more and more verbose if we have more deeply nested structure,
e.g. `Event.sub(.sub2(.sub3(.sub4(.sub5(.button1("OK"))))))`, which is not scalable.

To alleviate this situation, `Prism` composition can be used:

```swift
extension Prism where Whole == Event, Part == Sub1Event {
    static let sub1Prism = Prism(...)
}

extension Prism where Whole == Sub1Event, Part == String {
    static let button1Prism = Prism(...)
}

let deepPrism = .sub1Prism >>> .button1Prism

let event = deepPrism.review("OK") // Event.sub.tap("OK")
deepPrism.preview(event)           // Optional("OK")
```

And for many more deeply nested structure:

```swift
let deepPrism = .sub1Prism >>> .sub2Prism >>> .sub3Prism
    >>> .sub4Prism >>> .sub5Prism >>> .button1Prism

let event = deepPrism.review("OK") // Event.sub(.sub2(.sub3(.sub4(.sub5(.button1("OK"))))))
deepPrism.preview(event)           // Optional("OK")
```

For more information about `Lens` and `Prism`, please see following links:

- [Brandon Williams \- Lenses in Swift \- YouTube](https://www.youtube.com/watch?v=ofjehH9f-CU)
- [Lenses and Prisms in Swift: a pragmatic approach \| Fun iOS](https://broomburgo.github.io/fun-ios/post/lenses-and-prisms-in-swift-a-pragmatic-approach/)
- [Making your own Code Formatter in Swift \- Speaker Deck](https://speakerdeck.com/inamiy/making-your-own-code-formatter-in-swift?slide=41)
    - Adds `Lens >>> Prism` composition (called `AffineTraversal`) for further accessing the deeply nested structure

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

`Reducer` is a wrapper type around `reduce: (Action, State) -> State` function that can combine 2 reducers into one (has "zero" and "+" called "monoid").

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

### `Feedback` composition

`Lens` and `Prism` are useful for not only composing `Reducer` but also [`ReactiveFeedback.Feedback`](https://github.com/Babylonpartners/ReactiveFeedback/blob/0.6.0/ReactiveFeedback/Feedback.swift#L6).

```swift
struct Feedback<Action, State> {
    let transform: (Signal<State, NoError>) -> Signal<Action, NoError>

    /// Zero value for `+`.
    static var empty: Feedback {
        return Feedback { _ in .empty }
    }

    // Append operator, just like `+`.
    static func <> (lhs: Feedback, rhs: Feedback) -> Feedback {
        return Feedback { state in
            Signal.merge(lhs.transform(state), rhs.transform(state))
        }
    }
}

extension Feedback {
    public func lift<SuperState>(state lens: Lens<SuperState, State>) -> Feedback<Action, SuperState> {
        return Feedback<Action, SuperState> { superState in
            self.transform(superState.map(lens.get))
        }
    }

    public func lift<SuperAction>(action prism: Prism<SuperAction, Action>) -> Feedback<SuperAction, State> {
        return Feedback<SuperAction, State> { state in
            self.transform(state).map(prism.review)
        }
    }
}
```

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

let subFeedback1: Feedback<Sub1Action, Sub1State> = .empty

// MARK: - Component 2 (isolated from Main & Component 1)
//---------------------------------------------------------

enum Sub2Action { ... }
struct Sub2State { ... }
let subReducer2: Reducer<Sub2Action, Sub2State> = ...
let subFeedback2: Feedback<Sub2Action, Sub2State> = ...

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
            guard case let .sub1(action) = $0 else { return nil }
            return action
        },
        review: .sub1
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
    subReducer1
        .lift(action: .sub1Action)
        .lift(state: .sub1State)
    <>
    subReducer2
        .lift(action: .sub2Action)
        .lift(state: .sub2State)

let mainFeedback: Feedback<MainAction, MainState> =
    subFeedback1
        .lift(action: .sub1Action)
        .lift(state: .sub1State)
    <>
    subFeedback2
        .lift(action: .sub2Action)
        .lift(state: .sub2State)
```

Please notice how consistent the compositions of various types can be achieved with the same syntax!

## Impact on existing codebase

This proposal will affect all construction of `ViewModel` and `RAF`, but we can apply modification little by little.

## Alternatives considered

### 1. Split into un-composable multiple ViewModels

```swift
class MainViewModel {
    let state: Property<MainState> // ReactiveFeedback
    let route: Signal<MainRoute>

    let sub1: Sub1ViewModel
    let sub2: Sub2ViewModel

    init(...) {
        self.state = Property(
            ...,
            feedbacks: [
                sub1.route.toFeedback(...),
                sub2.route.toFeedback(...),
                ...
            ]
        )

        self.route = self.state.filterMap(MainRoute.init)
    }

    class Sub1ViewModel {
        let state: Property<Sub1State> // ReactiveFeedback
        let route: Signal<Sub1Route>   // NOTE: This is rather an output for `ViewModel`
    }

    class Sub2ViewModel {
        ... // same goes here
    }
}
```

While this also works, there are problems that:

- There are multiple `ReactiveFeedback`s in each ViewModel, so that each `state` becomes isolated from each other and hard to sync
    - It is hard to define what is the "single source of truth (state)" for rendering `View`
        - Is it `MainViewModel.state` or `Signal.combineLatest(sub1.state, sub2.state)` or mixture of both?
        - It depends on how we define `MainState`
- Same issue can be said for how we define `MainRoute` alongside `Sub_N_Route` (N = 1,2,...)
- Since it's not easy to compose multiple `ReactiveFeedback`s, we probably end up by writing a lot of manual FRP stream pipeline to workaround

### 2. Composable Reducers without `Lens` and `Prism`

cf. See [Discussion](https://github.com/Babylonpartners/ios-playbook/pull/171#discussion_r299147437).

```swift
// Domain: Main -> Sub1 -> Sub2 -> Sub3

func reducer(state: State, event: Event) -> Event {
    switch event {
    case .sub1(sub1Event):
        return state.set(\.sub1, sub1Reducer(state: state.sub1, event: sub1Event))
    ...
    }
}

func sub1Reducer(state: Sub1State, event: Sub1Event) -> Sub1Event {
    switch event {
    case .sub2(sub2Event):
        return state.set(\.sub2, sub2Reducer(state: state.sub2, event: sub2Event))
    ...
    }
}

func sub2Reducer(state: Sub2State, event: Sub2Event) -> Sub2Event {
    switch event {
    case .sub3(sub3Event):
        return state.set(\.sub3, sub3Reducer(state: state.sub3, event: sub3Event))
    ...
    }
}

func sub3Reducer(state: Sub3State, event: Sub3Event) -> Sub3Event {
    switch event {
    case .tap:
        return state.set(\.status, .showAlert)
    ...
    }
}
```

While this reducer split work with relatively simple syntax rule, we still need quite a lot of effort to write down boilerplate pattern-matching code for each nested level.
And unfortunately, all of them are NOT reusable.

By using `Lens` and `Prism` compositions, it becomes as simple as:

```swift
let reducer: Reducer<Action, State> =
    sub3Reducer
        .lift(action: .sub3Event >>> .sub2Event >>> .sub1Event)
        .lift(state: .sub3State >>> .sub2State >>> .sub1State)
```
