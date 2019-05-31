# Refactoring TabBar and Navigation Framework

* Author(s): Yasuhiro Inami
* Review Manager: Rui Peres

## Introduction

This proposal introduces a new arbitrary Navigation Framework by adding following changes:

1. Refactor `RootFlowController` to allow arbitrary navigation depending on user's session
    - All routing logic will be gathered in one-stop `RootFlowController`, which will be migrated from existing implementation in child `FlowController`s
    - `RootFlowController` will need to observe `SessionViewModel.state` for more precise state management
2. Add `Current.sendToRoot: (SendToRootRequest) -> SignalProducer<SendToRootResponse, RootError>` (one-stop `Action.apply`) to send message from bottommost screen back to `RootFlowController`
    - This is a generalisation of `SessionViewModel.authenticate` (login), `AppMainUserSession.logout`, `Current.changeTheme`, `BabylonTabBarSelector`, etc
    - `Current.sendToRoot` is equivalent to `NotificationCenter.post`, but its observer is hidden from `Current` and guaranteed to be only `RootFlowController` at initial setup
    - Instead of every child `ViewModel` asking its next route to its `FlowController`, `ViewModel` always calls `Current.sendToRoot` to ask `RootFlowController` for next route
    - `Current.sendToRoot` may send error if `RootFlowController` (or `SessionViewModel`) is busy, or may pend the operation (like RAS's `concat` strategy)

Expected scenarios and behaviors are:

- Show any screen from anywhere at anytime (user-action or system/server-trigger) via modal, navigation push, with/without tab-switching
- Be able to add or remove tabs at anytime (e.g. server-provided or user-customizable tabs)
- Show debug-builder screen for faster UI debugging iteration (enhancement of [Babylonpartners/babylon-ios#7645](https://github.com/Babylonpartners/babylon-ios/pull/7645))
- Some over-expected scenarios
    - Dismiss current screen at anytime (user-action or system-triggered)
    - Show "logout" button from anywhere and handle properly
    - Show "change NVL version" button from anywhere (enhancement of supported in `DebugHome` though)

NOTE: Making functional routing approach e.g .`(Signal<LifeCycle>, Signal<Session>, AppConfiguration, ...) -> Signal<Root Screen Builder>` is excluded from this proposal.

## Motivation

Currently (as of ver 3.17.0), every screen is generated and navigated by its parent `FlowController`.
For example, when screen A is followed by B, `A_FlowController` is responsible of calling `B_Builder.make()` (creates `B_VC -> B_VM -> B_FC` chain) and presents `B_VC` via `Flow` which is derived from `A_VC` or upper view stack:

```
Window -> NavCon1 -> A_VC -> A_VM -> A_FC
                                      ⇣ *1
                          NavCon1 -> B_VC -> B_VM -> B_FC

(*1: `B_Builder.make()` is called and then pushed to the same navigation stack using `NavigationFlow`)
(VC = ViewController, VM = ViewModel, FC = FlowController)
```

In this process, `B_FlowController` will also be created, so there will be an implicit `FlowController` chain (or tree) structure.
But since `B_FC` doesn't know about its parent `A_FC`, there is no way of delegating the unhandlable flow to the parent, in contrast to Cocoa's Responder Chain system.
A new Navigation Framework requires Cocoa-like mechanism to always be able to handle arbitrary navigation by asking parents if needed.
However, letting every parent to have various routing logic often causes the system too complex and some logic duplication might occur, so having a **centralised router i.e. `RootFlowController` with universal routing event type `RoutingEvent` will be sufficient**.
Currently, `RoutingEvent` is created from either VoIP push notification or deeplink, and we will extend this type to also be able to convert from `SendToRootRequest`.

A simple example usage is "logout", where we currently pass `AppMainUserSession` (lives inside `SessionViewModel`) all the way down to the current presenting screen, and finally calls `signIn` method.
If we extend the idea of "arbitrary navigation" to "arbitrary logout", we should be able to send "logout" at anytime.
To do so, current argument-relaying approach is too cumbersome, and we can mitigate this problem by using `Current` and let only `RootFlowController` talk to `SessionViewModel` instead.

## Proposed solution

TBD (More detail from Introduction)

## Impact on existing codebase

TBD

## Alternatives considered

TBD
