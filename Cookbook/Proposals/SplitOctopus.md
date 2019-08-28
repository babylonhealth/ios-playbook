# Split Octopus codebase

* Author(s): Giorgos Tsiapaliokas
* Review Managers: David Rodrigues, Yasuhiro Inami, Olivier Halligon

## Introduction

From the early versions of the codebase Octopus was the place were features were added.
Unfortunately Octopus hasn't adapted as the rest of the codebase has.
In the iOS codebase we use frameworks in order to organize the code and Octopus isn't one.

## Motivation

While there is still the need for having a place for small features Octopus has become a massive container which contains both features and services.
Also from a tech POV Octopus is just a folder which is being reused in different targets.
I am sure we can do better than this :)

## Proposed solution

Split Octopus into two different frameworks.
The proposed names are `BabylonFeatures` and `BabylonApp`.

The first framework will be used as a container for features which
- depend only on `BabylonCore`, `BabylonUI`, `BabylonDepedencies` and `BabylonSDK`
- don't depend on any third party SDKs

The second framework will be more flexibile with less restrictions, features in this framework
- can depend on other Babylon framework
- can depend on any third party SDK

In the initial split Octopus will be splitted in the new two frameworks and then it Octopus will be removed from the codebase.
After the initial split it will be up to each squad to decide the appropriate place for their code.

Converting Octopus into two frameworks
- should improve the build time of the app
- will reduce the time which is required for unit tests to be executed
- will allow better code organization
- engineers won't be limited in any way, since two frameworks will exist in order to host features depending on their dependencies

### Transition Period

Splitting Octopus will require some time since it's not trivial.
There are two approaches 

1. Split everything at once
2. Initially create empty frameworks and then move each subdirectory of Octopus piece by piece.

Option 1 has the drawback of keeping everything in a large PR and updating this PR constantly.
Also IMO having such a massive PR will make it more error prone.

Option 2 will be easier for the team to review the changes but it will require better coordination in order to make sure that the two new frameworks will be used instead of Octopus.

Personally I prefer option 2.

## Octopus Analysis

Octopus analysis can be found [here.](https://docs.google.com/spreadsheets/d/1nu7L6vwQcET1fYas1Ccj6vlqHJRtsdaXQ94LaXjvXkQ/edit#gid=0)

## Impact on existing codebase

Although this is a breaking change, most likely it won't affect the enginners much.

## Alternatives considered

Leave it as is.