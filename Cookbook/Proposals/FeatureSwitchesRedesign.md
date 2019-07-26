# Feature switches redesign

* Author(s): Ilya Puchka
* Review Manager: TBD

## Introduction

This proposal aims to define a unified approach to defining and accessing feature switches comming from various sources in our code base.

## Motivation

Even though feature switches in essens is a trivial thing our current apporach to them suffers from multiple issues of difference importance.

### Root plist and default values

Currently we provide a way to override any feature switch through toggles in the Settings system app. For that we need to include `Root.plist` file in the app bundle. Values of these switches are then written to the user defaults which we use as a source of values. But they are written to the user defaults only after they are interacted at least once. That said if overrides are enabled but you never change the value nothing will be written to the user defaults. This is not affected by default value set in the `Root.plist`, it only affects the intial position of the switch. How we solve it now is by reading these default values from plist and storing them in user defaults when application starts before we read these values (see `registerSettingsDefaults` in `Settings.swift`). Not just it is defined on the wrong type (`Settings` type is used to store some local user state data like if they completed some onboarding, not feature switches and this is not something that we allow to override with `Root.plist` AFAIK), but also this way changing default value in the `Root.plist` will affect all our targets as they all share this file, which makes us to create a second file just for our primary target. This makes it very confusing for developers to understand what they need to do to enable their feature for release so that it does not affect other targets if that's the requirement.

Without this syncing we would have to deal with optionals for all the switches, probably falling back to their defaults, defined in code. That also highlights another issue with `Root.plist`, that we need to repeat default value in the code and in the plist and make sure they allign to avoid confusion.

Another issue caused by using `Root.plist` and overrides in this way is when we move from Local feature switch used during development to Remote feature switch used on a final stage of the feautre rollout we have to remember to move the plist entry for this switch from one section to another. Otherwise there will be no way to override it during testing.

Having a wrong key name in the plist is also the issue that is very easy to miss.


### Firebase switches semantics

ATM we use Firebase Remote Config and A/B Tests features at the same time. While indeed for the client it does not matter if the value of a switch is set as a result of a running A/B test or is simply a remote config flag (in fact Firebase A/B Tests are built on top of Remote Config) there are situations when understanding the difference between flags being used for A/B tests or not when reading code instead of consulting with Firebase console is helpful. Right now all our Firebase switches are expressed as A/B test variants though. That created a lot of confusion when we had to consolidate and remove few feature switches related to the NVL and had to figure out if any of them are actually running A/B tests (as the names were not very helpful to identify if some configs were related to NVL or something else on the screens affected by NVL).


### Point of access

There is no single way of accessing feature switches in code. Local feature switches are defined in one place, Firebase feature switches are defined in another place, we also have static app configurations and consumer network feature switches (in patient details). It does not create a lot of friction but can be cumbersome to replace local feature switch with remote when feature is due to release.
At the same time all these places (local/Firebase feature switches, app configuration) became a dumping ground for the switchies for various features of the app, even when they have their own modules. And its not uncommon to have conflicts between PRs which both introduce Firebase feature switches for different issues.

### App configuration

We use app configuration type (and types related to it) to define "static" feature switches things that are hardcoded in the app and are cuased by different requirements for the products. I.e. one app can define that it should use a new feature flow while another does not use it.
This brings more clarity in what values are defined for what apps, we don't have to consult Firebase config and we don't risk accidently changing the value. We also don't need to wait for firebase config to be fetched and don't risk not having a right value when Firebase fails. At the same time it makes us to repeat all the configurations in each target which is a lot of boilerplate for a simple flag and these configs grew a lot over time, or to use protocol extensions with default values which makes it trickier to understand the actual value for particular target as we need to make sure this default is not overriden anywhere else.

### Debugging

It's not clear what feature switches affect what screens. It's frustrating to go through a complex flow and then realise that the right feature switch was not turned on/off in the Settings app or local overrides were active and to go through the flow again (as we don't ebserve changes in the feature switches in runtime and require application restart).


## Proposed solution

// This section should the answer the `how?`.

## Impact on existing codebase

// This section should explain, assuming this proposal is accepted, how much effort it would require for it to be implemented in our codebase. Other concerns should be raised, if it's a significant deviation from our stack.

## Alternatives considered

// This section describes what other approaches were considered and why this one was chosen.

