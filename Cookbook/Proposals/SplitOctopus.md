# Split Octopus codebase

* Author(s): Giorgos Tsiapaliokas
* Review Manager: TBD

## Introduction

From the early versions of the codebase Octopus was the place were  features were added.
Unfortunately Octopus hasn't adapted as the rest of the codebase has.
In the iOS codebase we use frameworks in order to organize the code and Octopus isn't one.

## Motivation

While there is still the need for having a place for small features Octopus has become a massive container which contains both features and services.
Also from a tech POV Octopus is just a folder which is being reused in different targets.
I am sure we can do better than this :)

## Proposed solution

Split Octopus into two different frameworks.
The proposed names are `BabylonFeatures` and `BabylonApp`.

The first framework will be used as a container for small features and it should depend only on `BabylonCore`, `BabylonUI`, `BabylonDepedencies` and `BabylonSDK`.

The second framework will contain anything else which was in Octopus.
This framework can depend on any other framework.


## Impact on existing codebase

Although this is a breaking change, most likely it won't affect the enginners much.

## Alternatives considered

Leave it as is.