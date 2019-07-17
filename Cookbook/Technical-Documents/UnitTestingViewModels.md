## Unit testing view models

### What do we test in the view model unit tests?

- view model state changes
- routing events
- analytics events

### Creating a new test case

To create a test case for a view model use the Xcode template `BentoViewModelTests` and provide the view model name (without `ViewModel` suffix). This template will create a basic structure for the test case that you will need to adjust to your specific implementation.

E.g: your feature is called `MyFeature` and it has a `MyFeatureViewModel`. You just need to name the file `MyFeature`, the template will automatically add the proper suffix making it `MyFeatureViewModelTests`.

### Writing a test

When implementing a test use the `perform(stub:when:assert:)` helper method from `BabylonTestUtilities`.

Example:

```swift
perform(
    stub: { scheduler in
        self.makeViewModel(scheduler: scheduler)
    }
    when: { viewModel, scheduler in
        viewModel.send(action: ...)
        scheduler.advance()
        viewModel.send(action: ...)
        scheduler.advance()
    },
    assert: { states in
        expect(states).to(equal([
            makeState(status: .initial, intent: nil),
            makeState(status: .loading, intent: nil),
            ...  
        ]))
    
        expect(analytics.accumulatedEvents).to(equal([
            AnyEquatable(Tracking.ActionEvents.event),
        ]))
    }
)
```

- `stub` parameter is used to create a view model and provide it its stubbed dependencies via `makeViewModel` method. It accepts a `scheduler` parameter that you must pass to the view model constructor. This scheduler is an instance of a `TestScheduler`, it allows to control signals events displatch via it's `advance` method later in the `when` closure.

- `when` closure is where the actual interaction with view model should happen. To "interact" with a view model you should call it's `send` method and provide an action. This effectively simulates user interaction with a screen managed by this view model. 
After sending an event you will need to call `scheduler.advance()`. Until this method is called at least once no events will be produced by any signal in the view model state machine. As soon as `advance` is called it will "release" the first event and so on. 
It is also possible to advance scheduler by specific time interval with `advance(by:)` method instead of using `sleep`. This is useful when any signal in the view model state machine uses timer (i.e. with `delay` operator)

- `assert` closure is where all the assertions happen. You usually assert aggregated states ensuring that view model's state machine goes through expected transitions. You can as well assert that expected routes were produced using the `routeObserver` (created by the template) and analytics events using `analytics.accumulatedEvents`

