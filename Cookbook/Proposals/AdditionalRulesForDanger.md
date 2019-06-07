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
To do so, we should whitelist every file that matched `Tests.*`.

Nevertheless, as of June 7th, 2019, we have 254 occurences of this rule in 251 files. 
As such, I believe this rule should only be enforced via Danger because using SwiftLint to monitor this would:
a) trigger 254 new warnings
b) mean that we'd have to refactor all of them to get rid of the already tremendous amount of warnings we currently have (~500); this would require a rather significant effort for very little benefit.

Enforcing the rule with Danger wouldn't cause those issues but we would only be able to detect new occurences of this anti-pattern since Danger will only inspect changes made in pull requests.

Therefore, I would suggesting using Danger to enforce it.

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

`\.signal\(for: \#selector\(UIViewController\.`

We'd have to restrict this rule to Builders and FlowControllers only, therefore we'd have to whitelist filenames that matched `.*Builder.swift` and `.*FlowController.swift`.

This rule could be enforced with either tool but I'd recommend using SwiftLint for this since due to the low number of warnings it would trigger in the current state of our database. Also, I believe we should try to use Danger for particularly important warnings in order not to spam the pull request with comments.


### Deprecated calls of DesignLibrary components (aka pre-NVL components)

Given that NVL is scheduled for release within two weeks, using NVL components is pivotal to Babylon's overall look and feel.
With the exception of the empty space component (even though it has its own NVL equivalent), every other pre-NVL component should trigger a warning.

The following regex currently yields 1333 results in 216 files: `Component\.(?!EmptySpace)\b`.
The sheer number of warnings immediately excludes SwiftLint; Danger would be our only option.

Nevertheless, this would require that everyone relied exclusively on NVL components and I am not sure this is the case right now.


### Mutating Current in `setUp()` but not restoring it in `tearDown()`

This principle applies not only to Current but actually to every other object as well: everything mutated in `setUp()` must necessarily be restored in `tearDown()`. Nevertheless, mutations to `Current` are the prime suspect for a number of flaky tests so it would make sense to try and address this first.

To do so, we'd
1. start by whitelisting every test file (`.*Tests.*`)
2. use the following regex to detect cahnges: `Current\..*\ = `.
(...)

<WIP> this is going to be hard to do :/ need to rethink this </WIP>

### Translation errors

Translations are particularly hard to catch during PR code reviews, especially if a lot of new phrases are added at once.
While, in theory, we have a fastlane set up to deal with these translations there is always the risk that developers mistype the localization key when setting up a new static var.

As such, I'd like to suggest another rule for Danger that would:
    1. detect new static String variables in every Localizable.swift file.
    2. if we detected a new static variable we would then scan the localization string file (`Babylon/Supporting Files/Localization/en.lproj/Localizable.strings`) and look for that key

We would need to whitelist `Localizable.*\.swift` in order to make this work.

### Feedbacks must have the `when` prefix

Feedbacks should use the `when` prefix in their names.
In order to detect violations of this practice, we could use the following regex `static func (?!when).* -> Feedback<State,`.
Regarding the whitelist, we'd apply this rule to every ViewModel.

Currently, our codebase contains 38 occurences spread across 29 files which makes it a good candidate for SwiftLint. 

In any case, this rule's usefulness is limited once we consider the fact that our feedback functions are usually spread across multiple lines. The regex's complexity would increase a lot and, to be entirely honest, I'm unsure the benefits outweight the downsides.

## Impact on existing codebase

While our codebase itself would not suffer any impact at all, our code review process would now have additional comments that would warn us of a particular situation. Should a PR contain numerous anti-patterns that break our rules the bot could potentially spam the PR with these warnings, depending on the way Danger's rules are implemented.

Furthermore, we would be increasing Danger's processing time - although for the time being this is nearly negligible (roughly 4 seconds) - so this is a minor drawback that we could easily live with, in my honest opinion.

## Alternatives considered

* Implement a subset of those rules (and determine the most adequate tool to detect infractions for each rule).

* Don't implement these rules at all
