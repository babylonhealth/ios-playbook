# Additional rules for Danger and SwiftLint

* Author: João Pereira
* Review Manager: TBD

## Introduction

The goal of this proposal is to introduce several new rules for Danger and/or SwiftLint. These will hopefully raise awareness for a number of problems we frequently see in our day-to-day work.

## Motivation

We have a large and particularly opinionated codebase (one could say "avant-gard" even) with significant deprecated code to address.
New engineers face a somewhat steep learning curve before mastering our practices and even experienced engineers make mistakes, so these rules would surely benefit everyone. These rules are already known to us - we apply them on our PR reviews on a daily basis, after all - but, nevertheless, why rely on memory alone when we can automate them?

## Proposed solution

We will now go through the list of suggested rules and consider:
    a) if it should be applied to our codebase at all
    b) which tool should be we use to minimize further occurrences of the problem at hand

### Custom ViewModels in the test suite

Custom ViewModels should not be defined as part of our tests; we should rely on `StubViewModel`s (from `BabylonSnapshotTestUtilities`) instead (although, in theory, setting up custom ViewModels could be useful in particular circumstances).

This rule would be rather simple to enforce via Danger, using the following regex: `class .*ViewModel\W` inside every test file. 
To do so, we should whitelist every file that matched `.*Tests.*`.

Nevertheless, as of June 7th, 2019, we have 254 occurences of this rule in 251 files. 
As such, I believe this rule should only be enforced via Danger because using SwiftLint to monitor this would:
a) trigger 254 new warnings
b) mean that we'd have to refactor all of them to get rid of the already tremendous amount of warnings we currently have (~500); this would require a rather significant effort for very little benefit.

Enforcing the rule with Danger wouldn't cause those issues but we would only be able to detect new occurences of this anti-pattern since Danger will only inspect changes made in pull requests.

### Mutating Current in `setUp()` but not restoring it in `tearDown()`


### Monitoring ViewController lifecycle directly instead of relying on `ScreenLifecycleEvent`

With the introduction of `ScreenLifecycleEvent`, developers should no longer manually monitor the viewController's lifecycle events.
Instead, this kind of monitoring can now easily be done through `BoxViewModel`'s that conform to `ScreenLifecycleAware` via `send(_: ScreenLifecycleEvent)`.

Here's a brief example of how it was typically done in both Builders and FlowControllers:

```swift
viewController
            .reactive
            .signal(for: #selector(UIViewController.viewWillDisappear))
            .discardValues()
            .observeValues(dismiss)
```

Nowadays, this can be done much more elegantly (thanks Anders!):

```swift
func send(_ event: ScreenLifecycleEvent) {
        switch (event, state.status) {
        case (.didAppear, .showing):
            runSomething()
        default:
            break
        }
    }
```

As of June 7th, 2019, we still have 16 results in 13 different files.

In order to detect this, we could simply monitor occurences of the following regex:

`.*signal(for: #selector(UIViewController`

We'd have to restrict this rule to Builders and FlowControllers only, therefore we'd have to whitelist files that matched `.*Builder.swift` and `.*FlowController.swift`.

This rule could 


### Deprecated calls of DesignLibrary components (aka pre-NVL components)

### Translation errors

### Feedbacks must have the `when` prefix

## Impact on existing codebase

While our codebase itself would not suffer any impact at all, our code review process would now have additional comments that would warn us of a particular situation. Should a PR contain numerous anti-patterns that break our rules the bot could spam the PR with these warnings.

Furthermore, we would be increasing Danger's processing time (although for the time being it is nearly negligible) so this is a minor drawback that we could live with, in my honest opinion.

## Alternatives considered

* Implement a subset of those rules (and determine the most adequate tool to detect infractions for each rule).

* Don't implement these rules at all
