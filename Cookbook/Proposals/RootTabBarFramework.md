# Modularising Root & TabBar Framework

* Author(s): Yasuhiro Inami
* Review Manager: David Rodrigues

## Introduction

This proposal introduces a new **Root & TabBar Framework (`BabylonRootTab.framework`)** that is first presented in a private team meeting on 15 Aug 2019.

> Slide and Demo:
> https://drive.google.com/drive/u/1/folders/1mzaBL8f_vwFwFRYjOHaIDB2gTwNOdmLq
>
> JIRA: CNSMR-2646

NOTE: Above new architecture proposal was once a bundle of:

1. Global FlowController, Dispatcher, and Arbitrary Navigation mechanism. [#145](https://github.com/Babylonpartners/ios-playbook/pull/145)
2. Unified Root & TabBar (related: flash-launch)

But **this proposal only supports 2**.

## Motivation

As proposed in [#222](https://github.com/Babylonpartners/ios-playbook/pull/222), current `Octopus` is a code dump ground that needs to be split into multiple frameworks.

**Root and TabBar** are among those layers that can be split just like other UI screens.
As their UI state managements become more important (i.e. managing what is current `rootViewController` and what tab is to be selected), it is simpler to start by putting them together in a single separated framework, and do all heavy UI handlings at one place.

By splitting into `BabylonRootTab` and make it more generic, each family app can reuse this core framework without adding each class file as their target membership.

## Proposed solution

1. Extract following classes into `BabylonRootTab`.
    - `SessionViewModel`
    - `RootFlowController`
    - TabBar-related classes (e.g. `ExchangeableTabBuilder`)
    - Many other upper layers (e.g. `RoutingEvent`)
2. Refactor existing TabBar-related logic from other screens (e.g. TabBar-selection via `HomeTabSelectorProtocol`)
    - This is needed because `BabylonRootTab` will be **fully isolated from each screen**, so it can't conform to each screen's protocols. Instead, `Octopus` layer will take care of this bridging.
3. Make some types generic with having `TabItem` type-parameter if needed.

![](https://user-images.githubusercontent.com/138476/64260507-f294df00-cf65-11e9-8185-67b739bdd0c6.png)

See "Slide and Demo" in Introduction section for more details.

## Impact on existing codebase

May require some significant amount of time (including conflict resolution) to decouple before migration.

## Alternatives considered

Keep `Octopus` as is. No Takoyaki cooking.

## References

Slide & Demo: https://drive.google.com/drive/u/1/folders/1mzaBL8f_vwFwFRYjOHaIDB2gTwNOdmLq
