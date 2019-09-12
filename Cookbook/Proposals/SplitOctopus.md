# Split Octopus codebase

* Author(s): Giorgos Tsiapaliokas
* Review Managers: David Rodrigues, Yasuhiro Inami, Olivier Halligon

## Introduction

From the early versions of the codebase Octopus was the place were features were added.
Unfortunately Octopus hasn't adapted as the rest of the codebase has.
In the iOS codebase we use frameworks in order to organize the code and Octopus isn't one.

## Motivation

In it's current state Octopus is collection of services and features which is consumed
by each target this requires some manual work for each target.

## Proposed solution

We propose to convert Octopus into a framework with the name `BabylonOctopus`.
By having Octopus as a framework it will be easier for each target to make use of Octopus' features and services.
With this proposal there is still the need for splitting Octopus even further which will be addressed by other proposals
in the future.

### Transition Period

Converting Octopus will require some time since it's not trivial.
We propose to  initially create an empty framework and then move each subdirectory of Octopus piece by piece.
This way it will be easier for the team to review the changes.

## Impact on existing codebase

Although this is a breaking change, most likely it won't affect the enginners much.

## Alternatives considered

1. Leave it as is.
2. Convert Octopus to framework at once.
The drawback of this alternative is that the team will have to review a large PR which
is more error prone. Also we will need to maintain a branch with a lot of changes for a
longer period of time.
