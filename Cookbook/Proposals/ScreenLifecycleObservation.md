# Generalized Screen Lifecycle Observation

* Author(s): Anders Ha
* Review Manager: Sergey Shulga
* Implementation: [Bento#93](https://github.com/Babylonpartners/Bento/pull/93)

## Introduction

The proposal introduces a generalized mechanism for screen lifecycle observation.

## Motivation

It has been observed that there is an increasing need for the screen interaction logic to react to screen lifecycle changes.

For example:

* A screen might want to emit an analytics event when it is first presented.
* A screen might want to reload its data when it appears on the screen again.
* A screen might want to perform side effects when the screen disappears indefinitely.

## Proposed solution

Introduce a screen lifecycle observing mechanism which BentoKit screens may participate by conforming `BoxViewModel` to `ScreenLifecycleAware`.

```swift
extension ExampleViewModel: BoxViewModel {
    func send(_ event: ScreenLifecycleEvent) {
        if case .didAppear(isPresentedInitially: true) = event {
            analytics.track(ExampleAnalyticsEvent.pageView)
                   
            // [Optional] Screen state machine needs to be aware of certain lifecycle changes.
            actionsObserver.send(value: .screenIsAppearingInitially)
        }
    }
}
```

The event model `ScreenLifecycleEvent` reflects the lifecycle status of a given screen at a given time. The status can be directly mapped to messages emitted by UIKit:

Status | UIKit message | Additional Metadata
--- | --- | ---
`didLoad` | `viewDidLoad` | N/A
`willAppear` | `viewWillAppear` | `isPresentedInitially`
`didAppear` | `viewDidAppear` | `isPresentedInitially`
`willDisappear` | `viewWillDisappear` | `isRemovedPermanently`
`didDisappear` | `viewDidDisappear` | `isRemovedPermanently`

As mentioned in the table, `ScreenLifecycleEvent` also provides contextual metadata representing two critical and unique scenarios of navigation:

* `isPresentedInitially`
   If this is `true`, the screen is being presented by its container for the very first time [1]. Subsequent reappearance, e.g. user having returned from another screen in a navigation flow, would not lead to this being `true`.

* `isRemovedPermanently`
   If this is `true`, the screen is about to be removed from its container **permanently** [2]. Temporarily disappearance, e.g. being covered by another screen in a navigation flow, would not lead to this being `true`.
   
A container of a screen is seeked in the following order:

1. the parent view controller of the screen; or
1. the presenting view controller of the screen; or
1. the presenting view controller of an ancestor of it.

If none of these is satisfied, the screen is considered to be the root view controller of a `UIWindow`, in which case `isPresentedInitially` and `isRemovedPermanently` shall always be true.
   
_[1] This holds until it is removed from its container permanently._
_[2] This holds until it is presented by any container again._ 

### On the difference between `isPresentedInitially` and `viewDidLoad`.

It should be aware that `willAppear && isPresentedInitially == true` is not equivalent to `didLoad`, because:

1. a screen may be presented again by any given container after it is removed from one; and
2. a screen need not be immediately presented after `viewDidLoad`.

## Impact on existing codebase

This is an additive change. Existing custom implementations may migrate to this new mechanism.

## Alternatives considered

No alternative is considered, as this is a channel for the view layer to inform the view model layer that follows established precedence in BentoKit.
