# Danger Configuration

We've configured [Danger](https://danger.systems/ruby/) in our main repository to help us prevent some mistakes we saw happening in the past and to assist us during code review.

The purpose of this file is to document all the rules we wrote in our `Dangerfile`, what they mean and how to react to them when they are triggered.

If you plan to add a new Danger rule:

 * Please follow the naming convention of starting the functions implementing the rules with `check_`
 * Make sure you keep the main `Dangerfile` clean: the main file is supposed to only call `check_*` functions defined in other files, not to contain actual rule implementations
 * Make sure you document the new rule here

## Danger documentation updates

> * Declared in: `danger-ci/danger.rb`
> * Function: `check_danger_config_changed`
> * Type: 📖 informative message

This rule simply reminds us to update this very documentation when the Danger configuration is changed (when any file in `danger-ci/*` is modified), so that we keep the documentation in sync with the actual rules.

## PR Size

> * Declared in: `danger-ci/pr_size.rb`
> * Function: `check_pr_size`
> * Type: ⚠️ warning

This rule warns us if the number of inserted lines in the PR is above 850.

ℹ️ Binary files are counted as "1 line changes" for the purpose of this rule, in order to count as changes to be reviewed but only count as 1 single change.  
This means that the number of insertions/deletions reported by GitHub on your PR might slightly differ from the "number of lines" considered by this Danger rules if you have binary files in your PR.

_Note: We have an informal limit of 800 lines for PRs, but since it's only informal, we decided to only make Danger put a message if we're more then 50 lines over that informal limit._

If this rule is triggered, an table is also added showing some stats (the table is hidden behind a disclosure triangle) about the number of changes per various categories of content (Feature Code, Test Code, pbxproj, Binary files, ...). Thoe goal of this table is to better understand how the code of the PR is distributed, hopefully giving the author and reviewers some ideas on how to split the PR if needed (e.g. one PR with just the code for the Builder separated from the PR adding the VM)

This rule is only a warning because we don't want it to block PRs, as there are some rare exceptions where we allow the limit to be exceeded, as long as it's justified by the author (e.g. a refactoring PR)

## Podfile Checks

> * Declared in: `danger-ci/pods.rb`

### Check that Podfile.lock has been properly committed

> * Function: `check_podfile_lock_committed`
> * Type: 🚫 failure

This rule is to alert us if we **forgot to commit the changes made in `Podfile.lock`**. This can happen if:

 - We modified the `Podfile` but forgot to do `bundle exec pod install` afterwards
 - We modified the `Podfile` and ran `pod install` but forgot to include the `Podfile.lock` in the commit
 - We modified the `Podfile` once, ran `pod install` and committed the `Podfile.lock` changes for that first modification in one commit… but then later re-modified the `Podfile` and forgot to commit the second change to `Podfile.lock` (which means that the PR will contain changes in `Podfile.lock`, but not the expected ones)

### Inform if dependencies might have changed

> * Function: `check_dependencies_changed`
> * Type: 📖 informative message

This rule is just to inform (informative message, no error nor warning) when the PR contains changes in the `Podfile.lock`, in order to **raise awareness to reviewers about changes in dependencies**.

The goal is to suggest them to take extra care in reviewing why we needed those changes in our dependencies and if they were properly justified.

## SDK: Mark changes to any of our SDKs with `#SDK` hashtag

> * Declared in: `danger-ci/sdk.rb`
> * Function: `check_sdk_hashtag`  
> * Type: 🚫 failure

This rule is to ensure that you identify **PRs containing changes to any files in our SDKs** by **adding `#SDK` to the PR title**.
This applies to any changes done in files in the `SDK/` and `UI SDK/` folders – except for files related to tests.

Note that if the PR is already associated with ticket from one of the SDK board, and thus contains `[SDK-xxx]` or `[SDKS-xxx]`
in its title, then `#SDK` is implied and you don't have to add the hashtag explicitly.
The hashtag is only needed for Pull Requests addressing tickets from non-SDK boards but still touching the SDK files.

_This is needed because of the Change Request Process (CRP) from our sSDLC requirement: any ticket touching code in the SDK needs to be included in the CRP ticket for next SDK release, and that hashtag will allow us to include those tickets automatically._

## pbxproj checks

> * Declared in: `danger-ci/pbxproj.rb`

### Warn for unexpected resources in targets

> * Function: `check_unexpected_resource_files`
> * Type: 🚫 failure

This rule ensures that we didn't accidentally add some Xcode-specific files to a target's "Copy Resource Files" phase, as those files are only used by Xcode or for documentation or tests, but that shouldn't end up in the final framework or app.

This rule currently checks for `*.xcconfig`, `*.md`, `*Info.plist` and any file under a `__Snapshots__` directory and fail if they have been added to your target accidentally.

### Warn about absolute paths

> * Function: `check_absolute_paths`
> * Type: 🚫 failure (inline comments)

This rule ensures that we didn't accidentally reference files using absolute paths in our Xcode projects.

It will add inline comments on each lines in the `pbxproj` where an absolute path was detected.

### Warn about `null` references

> * Function: `check_null_references`
> * Type: 🚫 failure (+ inline comments as warnings)

During a merge of Xcode project gone bad, `(null)` references can appear in the `.pbxproj` file.

This rule will trigger when any `(null)` references or `Recovered References` got introduced in the `pbxproj` that your PR touched. Additionally, it will also add inline comments to pinpoint the lines in your `pbxproj` where those null references were found.

When that happens, we need to understand what went wrong during the `pbxproj` merge and fix it properly (and manually) before we can merge the PR.

### Warn about orphan UUIDs

> * Function: `check_orphan_uuids`
> * Type: 🚫 failure (+ inline comments as warnings)

During a merge of Xcode project gone bad, orphan UUIDs can appear in the `.pbxproj` file.

_Context: The `pbxproj` format is such that it contains a list of file references (with an associated UUID) listing all the files that are in the pbxproj, then points to those references in the various parts of the `pbxproj` (for example in the "Compile Sources" build phase part, to reference which files are included in that build phase). If a `pbxproj` merge went wrong, sometimes the line declaring the file reference (and its UUID) could be deleted during the bad merge while other lines in the pbxproj referencing that UUID would still remain._

This rule will warn you if any part of the pbxproj references an UUID that got accidentally removed. (Note: you should see similar warnings when you run `pod install` in your terminal and it warns about an unknown UUID)

When that happens, you need to figure out if the removal of the file was intended as part of your PR (and if so, fix the merge by also removing the lines pointing to that now-deleted file reference), or if the removal of the file from the pbxproj was unintented (and if so, restore it). You could do that by editing the `pbxproj` manually, but if possible it's even better if you can fix it in Xcode (e.g. by removing the offending file from the project and add it again)

## Detect Missing Feedbacks

> * Declared in: `danger-ci/feedbacks.rb`
> * Function: `check_feedbacks_in_viewmodels`
> * Type: ⚠️ warning

This rule analyses any `*ViewModel.swift` file created or modified in the PR, and try to determine if any `Feedback` static method was declared but not called.
This is typically to catch cases when you declare a new `Feedback` in your code but forgot to then add it to the state machine.

This rule uses `sourcekitten` to dump the structure of the Swift code. It uses it to finds all the `static func` returning a `Feedback` declared in your code, then searches for all the method calls in your code to see if that list contains calls to all the `Feedback` methods declared. If it finds a `static func … -> Feedback<…>` method that is never called, it emits a warning.

Note that this rule can have false positives in rare cases. Especially if you use constructs like `obj.map(Self.whenBlah)`, it doesn't detect `whenBlah` as a method call because it is encapsulated inside a `map`. This is why this rule is only a warning.
(If still detects `Feedbacks` called conditionally though –like `if (cond) { feedbacks += Self.whenBlah() }`– and should still catch the most common cases of forgiving to add a newly-created `Feedback` to the state machine.

## swiftlint

> * Declared in: `danger-ci/swiftlint.rb`
> * Function: `check_swiftlint_violations`
> * Type: ⚠️ inline warning

This will report swiftlint violations as inline comments (warnings) in the Pull Request.

Only `.swift` files that are part of the PR are linted by this rule; so only violations in files that were added/modified/renamed by the PR will be reported. This is to ensure that we don't introduce new violations, and that we fix existing violations on any file we touch or update.
