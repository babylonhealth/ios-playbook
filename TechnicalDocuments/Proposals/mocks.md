# <Title>

* Author(s): Author1, Author2
* Review Manager: ReviewManager

## Introduction

Our current state of mocks/stubs/fixture is a mess. There is no standard for naming or even whether or not we should create mocks when we create new objects (eg models or businessControllers).

## Motivation

As the team grows, having set standards and processes becomes more and more important. This helps engineers being able to faster navigate (and use) the codebase, and improves productivity.

## Proposed solution

1. From now on, every mock/stub will be an extension of the object itself, sitting in the unit tests target. It will be created by calling `object.fixture()`.

2. We require *every* model and business controller created to have at least one mock in the PR where it is created.

## Impact on existing codebase

As we've done in the past, to avoid having someone spend too much time on rewriting old tests, it is proposed that we adopt these changes from now on. Legacy code will be handled when it is subject to a rewrite.

## Alternatives considered

// This section describes what other approaches were considered and why this one was chosen.

--- 
* [ ] **By creating this proposal, I understand that it might not be accepted**. I also agree that, if it's accepted,
depending on its complexity, I might be requested to give a workshop to the rest of the team. 🚀
