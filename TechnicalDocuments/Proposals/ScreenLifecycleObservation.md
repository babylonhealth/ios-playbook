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

The event model `ScreenLifecycleEvent` reflects the lifecycle status of a given screen at a given time. The status can be directly mapped to messages emitted by UIKit:

Status | UIKit message
--- | ---
`willAppear` | `viewWillAppear`
`didAppear` | `viewDidAppear`
`willDisappear` | `viewWillDisappear`
`didDisappear` | `viewDidDisappear`

`ScreenLifecycleEvent` also provides two extra properties representing two critical and unique scenarios of navigation:

* `isBeingPresentedInitially`
   If this is `true`, the screen is being presented by its container for the very first time [1]. Subsequent reappearance, e.g. user having returned from another screen in a navigation flow, would not lead to this being `true`.
   
    

* `isBeingRemovedIndefinitely`
   If this is `true`, the screen is about to be removed from its container **indefinitely** [2]. Temporarily disappearance, e.g. being covered by another screen in a navigation flow, would not lead to this being `true`.
   
_[1] This holds until it is removed from its container indefinitely._
_[2] This holds until it is presented by any container again._ 


## Impact on existing codebase

This is an additive change. Existing custom implementations may migrate to this new mechanism.

## Alternatives considered

No alternative is considered, as this is a channel for the view layer to inform the view model layer that follows established precedence in BentoKit.
