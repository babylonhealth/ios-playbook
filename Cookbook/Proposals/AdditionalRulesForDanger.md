# Additional rules for Danger and SwiftLint

* Author: João Pereira
* Review Manager: TBD

## Introduction

The goal of this proposal is to introduce several new rules for Danger and/or SwiftLint. These will hopefully raise awareness for a number of problems we frequently see in our day-to-day work.

## Motivation

We have a large and particularly opinionated codebase (one could say "avant-gard" even) with a significant amount of deprecated code to address. New engineers face a somewhat steep learning curve before mastering our practices and the fact that we have at times two or three ways of addressing a particular problem (mostly due to legacy code) only brings more confusion to the mix.

As such, at times it can ben confusing for newcomers to know what to do and what to avoid. Also, even for experienced engineers make mistakes so this proposal aims to lower the cognitive workload by making the rules more explicit and by improving automated issue detection. SwiftLint and Danger are two invaluable tools that we can and should continue to leverage in order to achieve these goals.  All of this will help prevent problems before these reach the `develop` branch. 

The rules I am about to introduce are already known to us - we apply them on our PR reviews on a daily basis, after all - but, nevertheless, why rely on memory alone when we can automate them?

## Proposed solution

We will now go through the list of suggested rules and consider:
    a) if they should be applied to our codebase (at all)
    b) which tool (therefore, which approach) should we use to minimize further occurrences of the problem at hand

### Custom ViewModels in the test suite

Custom ViewModels should not be defined as part of our tests; we should rely on `StubViewModel`s (from `BabylonSnapshotTestUtilities`) instead (although, in theory, setting up custom ViewModels could be useful in particular circumstances).

This rule would be rather simple to enforce via Danger, using the following regex: `class .*ViewModel\W` inside every test file. 
To do so, we should whitelist every file that matched `Tests.*`.

Nevertheless, as of June 7th, 2019, we have 254 occurences of this rule in 251 files. 

As such, I believe this rule should only be enforced via Danger because using SwiftLint to monitor this would trigger 254 new warnings  (obviously). Since we already have a tremendous amount of warnings (~500), we'd have to refactor all of these new warnigs just to get back to our starting point. This would require a rather significant effort for very little benefit.

On the other hand, enforcing the rule with Danger wouldn't cause those issues but we would only be able to detect new occurences of this anti-pattern since Danger will only inspect changes made in pull requests.

### Monitoring ViewController lifecycle directly instead of relying on `ScreenLifecycleEvent`

With the introduction of `ScreenLifecycleEvent`, developers should no longer manually monitor the viewController's lifecycle events.
Instead, this kind of monitoring can now easily be done via the `send(_: ScreenLifecycleEvent)` method.

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
With the exception of the empty space component (even though it has its own NVL equivalent), every other pre-NVL component used inside Renderer should trigger a warning.

The following regex currently yields 1333 results in 216 files: `Component\.(?!EmptySpace)\b`.
The sheer number of warnings immediately excludes SwiftLint; Danger would be our only option.

Nevertheless, this would require that everyone relied exclusively on NVL components and I am not sure this is the case right now.


### Mutating Current in `setUp()` but not restoring it in `tearDown()`

The rule is simple: every object (susceptible to global mutation) that is mutated in `setUp()` must be restored in `tearDown()`.
Mutations in `Current` in particular are the prime suspects of a number of flaky tests that have been recently affecting our test suite.

In order to detect this problem we have to use Danger since SwiftLint only accepts regular expressions.
We would have to whitelist every test file (`.*Tests.*`) and use Danger to manually parse the test line-by-line until the `setUp()` function was found. 

If found, we need to make a counter that increases by one each time a curly bracket and does the reverse when a closing curly bracket appears. Once the counter reaches zero again, then we've successfully delimited the contents of the `setUp()` function and we'd use the following regex to detect changes in Current: `Current\..*\ = `.

The algorithm is then be executed once more but for the `tearDown()` method instead.
If the number of changes inside each function matches, then no issue would be found. If not, then Current appeared to have been mutated but not restored; we'd issue a warning for the lines in which the algorithm detected a change and alert the developers in GitHub.

Nevertheless, this rule is rather naïve because we have no actual way of detecting if Current was reset or not; that would require compiling and runniing the actual Swift code. Therefore, this approach is not a silver bullet or anything remotely similar but it would still be useful for one use case in particular: should the developer forget to restore Current, this rule will alert us of this situation.

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
