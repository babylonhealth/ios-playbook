# Match UI test with implementation

* Author(s): Sergey Shulga
* Review Manager: Ilya Puchka, David Rodrigues, Olivier Halligon

## Introduction

The goal is to match the implementation of a feature with a corresponding UI test so we could run it on CI

## Motivation

Lately we had quite a lot of UI automation test failures which decrease the speed which we can make a release and distracts automation QAs to do this unnecessary work.

## Proposed solution

I believe that we can achieve that by marking some kind of mark comments that can be recognized by Danger which would  be able to trigger corresponding UI test
e.g

```swift
// UITestCase: SomeFeature
final class SomeViewModel {}

// UITestCase: SomeFeature
final class SomeRendere { }
```

And if `OnBoardingFeature` is missing or spell wrong then it would fail on CI for example.

## Impact on existing codebase

No impact on the existing codebase can be achieved gradually by having a Danger rule to remind people to mark `ViewModel` and `Renderer` files with `UITestCase` marker.

## Alternatives considered

N/A
