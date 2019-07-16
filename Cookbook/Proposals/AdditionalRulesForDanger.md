# Additional rules for Danger and SwiftLint

* Author: João Pereira
* Review Manager: TBD

## Introduction

The goal of this proposal is to minimize the mental overhead of both author and reviewers during our PR reviews by improving our automatic issue detection coverage. To do so, I propose introducing several new rules for Danger and/or SwiftLint, as well as marking several methods throughout our codebase as deprecated.

## Motivation

We have a large and particularly opinionated codebase (one could say "avant-gard" even) with a significant amount of deprecated code to address. New engineers face a somewhat steep learning curve before mastering our practices and the fact that we have at times two or three ways of addressing a particular problem (mostly due to legacy code) only brings more confusion to the mix.

As such, at times it can ben confusing for newcomers to know what to do and what to avoid. Also, even for experienced engineers make mistakes so this proposal aims to lower the cognitive workload by making the rules more explicit and by improving automated issue detection. SwiftLint and Danger are two invaluable tools that we can and should continue to leverage in order to achieve these goals. The former should be prioritized since it bestows us with early detection: a developer would type an infraction and SwiftLint would automatically trigger a warning and/or error before the PR was created (unlike Danger). On the other hand, SwiftLint relies on regexes to evalute its own rules and, as such, certain issues cannot be easily mitigated using SwiftLint only.

Danger, on the other hand, is a lot more flexible but it only looks at changes made when opening a PR (and by then it can be too late).

Additionally, we can (and should) also rely on deprecation warnings given their easiness of use and the fact that they clearly show the developer that such a method shouldn't be used before any code is actually written.

All of this will help prevent problems before the PR is merged, thus preventing such bad practices from reaching the `develop` branch. As mentioned, it will also minimize mental overhead for reviewers and authors alike and will lead to a more developer-friendly codebase.

The rules I am about to introduce are already known to us - we apply them on our PR reviews on a daily basis, after all - but, nevertheless, why rely on memory alone when we can automate them?

## Proposed solution

We will now go through the list of suggested rules and consider:
    a) if they should be applied to our codebase (either partially or completely)
    b) which approach should we use to minimize further occurrences of the problem at hand

### Detecting custom ViewModels in snapshot tests

Custom ViewModels should not be defined as part of our snapshot tests; we should rely on generic `StubViewModel`s (from `BabylonSnapshotTestUtilities`) instead. By using custom ViewModels instead of stubbing the ones we already have technically we aren't testing the actual ViewModels, but the ones we've just created for the purpose of this test (which, depending on the actual implementation, may not be the exact same thing).

Still, in theory, setting up custom ViewModels could be useful in some particular circumstances (eg:  when testing a Renderer and we need our ViewModel to hold some value that we cannot define via the initializers and/or easily get the state machine to the point where we need it to be).

Nevertheless, as of July 3rd, 2019, we have 33 occurences of this malpractice.

This rule would be rather simple to enforce via SwiftLint, using the following regex: `class .*ViewModel\W` inside every snapshot test file. Furthermore, we should implement a modified version of `verifyScreenForAllSizesAndVisualLanguages` that accepted only `StubViewModel`s and deprecate the old one. Using these two techniques I believe this malpractice can be expunged from our codebase very quickly.

### Monitoring ViewController lifecycle directly instead of relying on `ScreenLifecycleEvent`

With the introduction of `ScreenLifecycleEvent`, developers should no longer manually monitor the viewController's lifecycle events. Instead, this kind of monitoring can now easily be done via the `send(_: ScreenLifecycleEvent)` method.

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

Given that NVL is scheduled for release within two weeks, using NVL components is pivotal to Babylon's overall look and feel. With the exception of the empty space component (even though it has its own NVL equivalent), every other pre-NVL component used inside Renderer should trigger a warning. Nevertheless, this would require that everyone relied exclusively on NVL components and while I am not entirely sure this is the case right now the future belongs to NVL.

The following regex currently yields 1333 results in 216 files: `Component\.(?!EmptySpace)\b`.

The sheer number of warnings immediately excludes SwiftLint, which leaves us with:
a) marking these methods as deprecated
b) using Danger to raise a comment whenever a PR is raised

In this particular case I believe we could use both approaches actually.


### Mutating Current in `setUp()` but not restoring it in `tearDown()`

~~Every object (susceptible to global mutation) that is mutated in `setUp()` must be restored in `tearDown()`.~~

~~Mutations in `Current` in particular are the prime suspects of a number of flaky tests that have been recently affecting our test suite. [While some mitigations have been implemented to minimize this problem](https://github.com/Babylonpartners/babylon-ios/pull/7806/files#diff-74895f4da31ec40d83d342bf612540b4R17), these are restricted to snapshot tests for the time being. Ideally, this solution should be extended to Unit and UI Test cases but that lies outside the scope of this proposal.~~

~~Until that is implemented, we could alternatively monitor mutations in Current by counting the number of times Current is changed in the `setup()` and `tearDown()` methods. We would have to whitelist every test file with the exception of snapshot tests (see link above) using the regex `\b(?!Snapshot)(.*Tests)` and then use Danger to manually parse the test line-by-line.~~

~~1) Find the `setUp()` function inside the test file. If found, we would determine the boundaries of this function (by counting each time an open curly bracket appears and doing the reverse for closing curly brackets) and we'd use the following regexes to detect changes in Current:
    a) `Current\..*\ = `.
    b) `Current.changeTheme\(.*`
    c) `Current.set\(.*`~~

~~2) Repeat step 1 but for `tearDown()` instead.~~

~~3) Assess if the number of changes inside each function matches.
    a) if so, then no issue would be found
    b) if not, then Current appeared to have been mutated but not restored; we'd issue a warning for the lines in which the algorithm detected a change and alert the developers in GitHub using Danger.~~

~~Nevertheless, this rule is rather naïve because we have no actual way of detecting if Current was reset or not; it would merely indicate that in all likeliness the developer has forgotten to restore Current since the number of changes in both methods does not match.
Additionally, there are plenty of cases through developers could modify Current and easily side-step this rule (eg: if the mutations and resets were made in auxiliar methods instead).~~

~~As such, this approach is not a silver bullet or anything remotely similar; such a feature would require compiling and running the actual Swift code, not to mention that we'd have to make Current conform to Equatable.~~

This rule was rejected.

### Translation errors

Translations are particularly hard to catch during PR code reviews, especially if a lot of new phrases are added at once. While, in theory, we have a fastlane set up to deal with these translations there is always the risk that developers mistype the localization key when setting up a new static var.

As such, I'd like to suggest another rule for Danger that would:
    1. detect new static String variables in every Localizable.swift file.
    2. if we detected a new static variable we would then scan the localization.string files and look for that key; if we didn't find them that would mean that there was probably a typo and the actual translation would never  appear on-screen (only the key itself).

Furthermore, the reverse situation would also be problematic (albeit at a different scale): a key in the `.strings` file without an equivalent constant in its Swift counterpart would likely mean that the developer had added unused strings to the project. This would also be detectable using Danger. 

On the other hand:
- we have no reliable way of mapping the association between each target and their respective strings
- this process should be automated by using SwiftGen instead

We would need to whitelist `Localizable.*\.swift` as well as the `Localizable.string` and its corresponding target-specific files (TargetSpecificLocalizable.strings) in order to implement both rules.


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

Regardless of what we choose, we should still strive to reduce the tremendous amount of warnings our codebase currently has.
