Babylon iOS Architecture
========================

## Overview

In Babylon, we use [Model-View-ViewModel (MVVM)](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel) architecture pattern to develop each GUI screen and its business logic.
The most common MVVM practice in iOS is to treat `UIViewController` as `View`, which holds `ViewModel` to delegate the event and business logic handling to decouple from `View`'s primary goal of "rendering its appearance".

While MVVM architecture gained its popularity in iOS community as the rise of Functional Reactive Programming (FRP, e.g. [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift)) with its easy data-binding mechanism, there are still concerns about the following issues:

1. How to manage states (in more testable way)
2. How to deliver events (in simpler way than data-bindings)
3. How to setup MVVM (single screen)
4. How to coordinate / scale multiple MVVMs (mutliple screens with navigation / single screen with nested MVVMs)

Unfortunately, FRP itself does not offer a best practice for these questions, since it's main purpose is to build small pipelines through reactive operator compositions, splitting and combining their stateful representation, to make a large application.
It's a bottom-up development tool, so states and event-flows can easily get scattered and spaghetti-ed across the entire codebase if we don't share the same architectural mindset among the team.

Luckily, web-development community has reached a more consistent architectural solution to use [Redux](https://redux.js.org) as a predictable (global) state container alongside [React](https://reactjs.org/), a state (or virtual-view) diffing renderer.
Redux encourages the developers to apply uni-directional flow architecture (inspired by [Elm](https://elm-lang.org/)) and centralize state management (powered by [Automata Theory](https://en.wikipedia.org/wiki/Automata_theory)) to solve our questions 1 and 2.
Moreover, React brings a new UI paradigm that can be rendered just from a state via Redux.

So, in Babylon iOS team, we created [ReactiveFeedback](https://github.com/Babylonpartners/ReactiveFeedback) and [Bento](https://github.com/Babylonpartners/Bento) as their counterparts to solve 1 and 2 that nicely fits on top of existing UIKit framework.

Also, for 3 and 4 (navigation), we defined `Builder` and `FlowController` layers to satisfy the remaining missing pieces.

So, in a nutshell:

1. `ViewModel` (with ReactiveFeedback)
2. `Renderer` (Bento Virtual-View)
3. `Builder`
4. `FlowController`

are the 4 core entities to achieve Babylon iOS Architecture, as well as:

- `Bento.BoxViewController` (universal class for rendering `UITableView`)

that coordinates the real presentation in UIKit.

## Interfaces / Types

### `Builder`

**`Builder` is a screen's entrypoint** that creates `ViewModel`, `Renderer`, `FlowController`, all necessary business logics, and finally creates `ViewController` that collaborates with `ViewModel` and `Renderer` to update the actual `UITableView` / `UICollectionView` with the minimal changes via diffing algorithm by Bento.

Overall structure looks like this:

```
struct Builder
├── class ViewModel: Bento.BoxViewModel
│  ├── Property<State>          // ReactiveFeedback
│  ├── Signal<Route>            // Routing (Output)
│  ├── send: (Action) -> Void   // User Input
│  └── (Business Logic)
│
├── struct Renderer: Bento.BoxRenderer
│  ├── ViewStyleSheet<UIView>
│  └── render: (State) -> Screen<SectionID, ItemID> // creates Virtual View
│     └── Bento.Box             // Virtual View
│
├── struct FlowController
│  └── handle: (Route) -> Void  // shows next screen / presentation
│
└─ class BoxViewController      // (universal, no screen-dependent subclassing)
   └── render: (Screen) -> Void // updates actual UITableView
```

As we see in the next section, `Builder` is responsible for creating `ViewController` with `ViewController (VC) → ViewModel (VM) → FlowController (FC)` retain graph.

And `Builder` is usually created from previous screen's `(Previous)FlowController`.

### `FlowController`

**`FlowController` is the coordinator of current screen and next presentation**.

It inherits `Flow` classes from previous screen which is an abstraction of UI flow (navigation, modal, etc) to present or dismiss the screen that `Builder` is going to create.

For example, let's say "Screen0"'s `Screen0FlowController` will create a next "Screen1" using `Screen1Builder`, which then shows "Screen2" and so on:

```swift
struct Screen0FlowController {
    ...
    func handle(_ route: Route) {
        switch route {
        case ...:
            let screen1ViewController = Screen1Builder(...).make(...)
            navigationFlow.present(screen1ViewController) // accesses `UINavigationController` to push "Screen1"
        }
    }
}

...

struct Screen1Builder {
    ...

    func make(
        navigation: Flow,
        modal: Flow,
        presenting: Flow,
        root: Flow
    ) -> UIViewController {
        // Create ViewModel.
        let viewModel = Screen1ViewModel(
            businessController: dependencies.businessController,
            analytics: dependencies.analytics
        )

        // Create FlowController with attaching next screen as `Screen2Builder`.
        let flowController = Screen1FlowController(
            navigation: navigation,
            modal: modal,
            presenting: presenting,
            root: root,
            nextBuilder: Screen2Builder(dependencies: ...)
        )

        // Connect routing.
        viewModel.routes
            .observe(on: UIScheduler())
            .observeValues(flowController.handle)

        // Finally, create ViewController.
        return BabylonBoxViewController(
            viewModel: viewModel,
            renderer: Screen1Renderer.self,
            rendererConfig: Screen1Renderer.Config(...)
        )
    }
}
```

Please notice that `Screen1Builder` is making `ViewController` with `ViewController (VC) → ViewModel (VM) → FlowController (FC)` retain graph.

And this `ViewController` will be retained by the previous `Screen0FlowController`'s flow operation (rather than `Screen0FlowController` itself).
In above example, `navigationFlow` is used so that the graph will look like this:

```
Window → NavC ──➞ VC0 → VM0 → FC0
           │                   ⇣ (Screen1Builder)
(FC0 Flow) ├────────────────➞ VC1 → VM1 → FC1
           │                               ⇣ (Screen2Builder)
(FC1 Flow) └────────────────────────────➞ VC2 → VM2 → FC2 ...
```

(Note: `FC0 = Screen0FlowController`, `NavC = UINavigationController`)

`FlowController` is not only responsible for presenting the next screen, but also for other temporal presentations such as `Alert` and (semi-)modal that sends back a new data via callback to the original screen.

### `Bento.BoxViewController`

**`Bento.BoxViewController` is the entrypoint of Bento that depends on both `ViewModel` and `Renderer`.**

It observes `ViewModel.state` changes using ReactiveSwift, and creates a set of `Bento.Box` (virtual-`UITableView`) called `Bento.Screen` via `Renderer.render(state:)` per state change.
These virtual-`UITableView`s will be used in `UITableView.render(box)` for diff-reloading.

The interface of `Bento.BoxViewModel` and `Bento.BoxRenderer` will look as follows (extracted):

[https://github.com/Babylonpartners/Bento/tree/635d6d25e9152ba38aba8620e307431a0b8db4dd/BentoKit/BentoKit/Screen](https://github.com/Babylonpartners/Bento/tree/635d6d25e9152ba38aba8620e307431a0b8db4dd/BentoKit/BentoKit/Screen)

```swift
public protocol BoxViewModel: AnyObject {
    associatedtype State
    associatedtype Action

    // `BoxViewModel` to `BoxRenderer` event flow
    var state: Property<State> { get }

    // `BoxRenderer` to `BoxViewModel` event flow (user action from UI)
    func send(action: Action)
}

public protocol BoxRenderer {
    typealias Sink<Action> = (Action) -> Void
    associatedtype State
    associatedtype Action
    associatedtype SectionID: Hashable
    associatedtype ItemID: Hashable

    // `observer` as `BoxRenderer` to `BoxViewModel` event flow (user action from UI)
    init(observer: @escaping Sink<Action>, ....)

    func render(state: State) -> Screen<SectionID, ItemID>
}
```

#### Unidirectional event flow

1. `BoxRenderer.observer` is triggered with a new event
2. `BoxViewModel.send(action:)` is invoked and changes state
3. `state: Property<State>` emits a new state
4. `Bento.BoxViewController` receives a new state, creating virtual view via `BoxRenderer.render(state:)` and apply diffing to real `UITableView`
5. `UITableView` gets reloaded

### `ViewModel`

The minimal `ViewModel` example looks as follows:

```swift
class ViewModel: Bento.BoxViewModel {
    let state: Property<State>
    let routes: Signal<Route, NoError>

    private let eventPipe = Feedback<Event, NoError>.input()

    init(...) {
        self.state = Property( // Defined in ReactiveFeedback
            initial: .initial,
            reduce: ViewModel.reduce,
            feedbacks: [
                eventPipe.feedback,
                ViewModel.whenSubmitting(...)
            ]
        )

        self.routes = self.state
            .filterMap { $0.route } // State to Route conversion
    }

    // User Action from UI
    func send(action: Action) {
        eventPipe.observer(value: .ui(action))
    }

    // MARK: - Reducer

    static func reduce(_ state: State, _ event: Event) -> State {
        switch (oldState, event) {
        case ...:
            return newState
        }
    }

    // MARK: - Feedback

    static func whenSubmitting(...) {
        return Feedback(
            predicate: { $0.status.isSubmitting },
            effects: { state -> SignalProducer<Event, NoError> in
                return self.validate(state: state)
                    .flatMap(.merge) { data in
                        self.fetchNextScreen(data)
                    }
                    .materializeResults()
                    .map(Event.didFinishSubmit)
            }
        )
    }
}
```

- Input: User actions from `Renderer` will be delivered to `func send(action: Action)`, and forwarded as ReactiveFeedback's input.
- Output: All outputs to the external are defined as `route: Signal<Route, NoError>` that triggers the next screen action observed by `FlowController`, and is (mainly) driven by `State` changes.
    - State-driven output is so-called [Moore machine](https://en.wikipedia.org/wiki/Moore_machine)

See [Babylonpartners/ReactiveFeedback](https://github.com/Babylonpartners/ReactiveFeedback) for more examples.

### Renderer

The minimal `Renderer` example looks as follows:

```swift
struct Renderer: BoxRenderer {
    private let observer: Sink<Action>
    ...

    func render(state: State) -> Screen<SectionId, RowId> {
        return Screen(
            title: "Title",
            box: .empty
                |-+ renderSection0(state: state)
                |-+ renderSection1(state: state)
                |-? renderSection2(state: state)
                |-? renderCurrentGP(state: state)
        )
    }

    private func renderSection0(state: State) -> Section<SectionId, RowId> {
        return Section<SectionId, RowId>(id: .section0)
            |---+ Node(
                id: .row0_0,
                component: InputField(
                    title: state.title,
                    placeholder: state.placeholder,
                    image: state.image,
                    didTapImage: { observer(.didTapImage) },
                    accessibilityIdentifier: ...
                )
            )
            |---+ Node(
                id: .row0_1,
                component: ItemPicker(
                    title: state.pickerTitle,
                    didTap: { observer(.didTapPicker($0)) }
                )
            )
    }

    ...
}
```

Please notice that this rendering tree is not so apart from new [SwiftUI](https://developer.apple.com/xcode/swiftui/).

See [Babylonpartners/Bento](https://github.com/Babylonpartners/Bento) for more examples.

## References

[Implementing features with ReactiveFeedback](https://ilya.puchka.me/implementing-features-with-reactivefeedback/) by @ilyapuchka
