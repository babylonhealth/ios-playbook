# Track Screen Events as Flow Side Effects.

* Author: Martin Nygren
* Review Manager: Anders Ha

## Introduction

There is a push to improve product analytics, both in terms of the technology
stack and coverage. To increase the coverage there is an ambition to post a
screen view event whenever a new screen is rendered. Screen event is a somewhat
loose term but for iOS it is a reasonable default interpretation to say that a
screen event happens when the `view` of `UIViewController` becomes visible.

## Motivation

Since we will have to post a lot of screen events we want it to be easy to add
code to track them.

Posting analytics events should ideally not have any impact
on the business logic. In an ideal world it would always be possible to collect
product analytics data without any impact on the business or user interface
logic, reality tends to be messier but the more analytics events we can collect
without interfering with the business logic the better it is.

It might happen that we get requirements to post some extra data in addition to
the screen name. Although there is an ambition to keep data points consistent
and simple it cannot be guaranteed that all of them will be.

Experimenting with decorating flows with side effects I have arrived at the
conclusion that this approach makes it quite quick to add screen event tracking.

Adding screen event tracking as side-effects make sure that they don't have
any impact on the business logic.

Collecting more complicated data points can be done by decorating the flow
differently or adding a second decoration.

You can check out `martin/flow-struct-experiment` if you want to have a look at
how this would impact our codebase. Screen event tracking has been added to the
GP @ Hand registration journeys. Things are a bit experimental, so would need
some cleaning up but does hopefully show how it would work.

## Proposed solution

Creating a general side-effect that can be used to post the screen name requires
a mechanism for reading the screen name from the view controller. Part one of
this proposal is thus to add define a protocol `ScreenNaming`

```
public protocol ScreenNaming {
    func screenName() -> String?
}

```

with a default implementation for `UIViewController`

```
extension UIViewController: ScreenNaming {
    @objc open func screenName() -> String? { return view.accessibilityIdentifier }
}
```

Using the `accessibilityIdentifier` to store the screen name has been discussed
within the team and was considered a bit risky. I do, however, feel that in
nearly all cases it will be fine to use the same string constant for the screen
name and the accessibility identifier.

It has been discussed that we should add a default mechanism for assigning
accessibility identifiers to Bento components. If this happens we might not want
to use that accessibility identifier as the screen name. In my view adding this
override to `BabylonBoxViewController` offers a convenient way to define a
different screen name for bento style view controllers.

```
open class BabylonBoxViewController<ViewModel, Renderer>: BoxViewController<ViewModel, Renderer, BabylonAppAppearance> {
  ...
  @objc open override func screenName() -> String? {
    if let name = (viewModel as? ScreenNaming)?.screenName() {
        return name
    } else {
        return super.screenName()
    }
  }
}
```

With a solution for defining screen names for view controllers it is now
possible to define a generic mechanism for posting screen views to the analytics
service.

```
enum FlowAnalyticsEvent: AnalyticsEvent {
    case screenView(name: String)
}

extension FlowAnalyticsEvent {
    static func screenViewTracking(
        _ flow: Flow,
        with tracker: AnalyticsTrackingService
        ) -> Flow {

        func trackScreenView() {
            guard let viewController = flow.currentViewController() else { return }

            if let screenName = viewController.screenName(),
                screenName.isNotEmpty {
                tracker.track(FlowAnalyticsEvent.screenView(name: screenName))
            }
        }

        func decoratedPresent(_ viewController: UIViewController, _ animated: Bool, _ completion: (() -> Void)?) {
            flow.present(viewController, animated: animated, completion: completion)
            trackScreenView()
        }

        func decoratedReplace(_ viewController: UIViewController, _ animated: Bool) {
            flow.replace(with: viewController, animated: animated)
            trackScreenView()
        }

        func decoratedDismiss(animated: Bool, _ completion: (() -> Void)?) {
            flow.dismiss(animated: animated, completion: completion)
            trackScreenView()
        }

        return Flow(
            presentViewController: decoratedPresent,
            replaceViewController: decoratedReplace,
            dismissViewController: decoratedDismiss,
            currentViewController: flow.currentViewController)
    }

    static func screenViewTracking(_ flow: Flow) -> Flow {
        return screenViewTracking(flow, with: Current.analyticsService)
    }
}
```

This example uses the `Flow` implementation that has been refactored to a struct
that I have suggested in a previous proposal. Something similar can be done with
the current `protocol` implementation, but to me it feels more natural to use a
struct with function variables. Please note that `currentViewController()` is
needed to post a screen event when a modal is dismissed or the user goes back
in a navigation stack.

Finally, to track screen view events we need to decorate the `Flow`, here is
how to do it for the GP @ Hand Introduction journey

```
private func showNHSIntro() {
        BabylonNavigationController { navigation, modal in
            return builders.nhsOnboarding.make(
                navigation: navigation |> FlowAnalyticsEvent.screenViewTracking,
                modal: modal |> FlowAnalyticsEvent.screenViewTracking,
                parent: self.modal,
                root: self.modal
            )
        } |> modal.present
    }
```

I added this helper function to make `|>` available.

```
static func screenViewTracking(_ flow: Flow) -> Flow {
    return screenViewTracking(flow, with: Current.analyticsService)
}
```

It is important to note that `Flow` instances should only be decorated at the
point when they are created. Otherwise it can be difficult to understand if a
`Flow` already has been or needs to be decorated.

## Impact on existing codebase

This is were I see a major advantage with the proposed solution. Decorating a
flow with a analytics tracking side effect when it is created is a fairly
small change to the code that is easy to read.

Amending view models or view controllers to comply with `ScreenNaming` can be
done in extensions and thus have no impact on existing code.

## Alternatives considered

Implement `viewDidAppear`, or observe `viewController.reactive.signal(for: #selector(UIViewController.viewDidAppear))`,
and post a `FlowAnalyticsEvent.screenView(name: "BestViewControllerEver")` whenever
it is called. In my view this approach is inferior for two reasons:
- Less flexible. By decorating flows it is possible to change the tracking
depending on how the screen has been reached without adding state to the view
controller or view model.
- Smaller amount of code re-use. Decorating flows means fewer changes to the
codebase.

---
* [x] **By creating this proposal, I understand that it might not be accepted**. I also agree that, if it's accepted,
depending on its complexity, I might be requested to give a workshop to the rest of the team. 🚀
