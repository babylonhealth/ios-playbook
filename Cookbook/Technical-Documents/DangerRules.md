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

_Note: We have an informal limit of 800 lines for PRs, but since it's only informal, we decided to only make Danger put a message if we're more then 50 lines over that informal limit._

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

### Inform if dependencies might have change

> * Function: `check_dependencies_changed`
> * Type: 📖 informative message

This rule is just to inform (informative message, no error nor warning) when the PR contains changes in the `Podfile.lock`, in order to **raise awareness to reviewers about changes in dependencies**.

The goal is to suggest them to take extra care in reviewing why we needed those changes in our dependencies and if they were properly justified.

## SDK Checks

> * Declared in: `danger-ci/sdk.rb`

### Mark changes to SDK with `#SDK` (or `#IgnoreSDKChanges`)

> * Function: `check_sdk_hashtag`  
> * Type: 🚫 failure

This rule is to:

1. Ensure you **identify PRs that contain SDK changes with `#SDK`** – as those would need to be included in the CRP ticket for next SDK release (SSDLC requirement):
  - Note that if the PR is associated with an SDK ticket, and thus contains `[SDK-xxx]` in it's title, then `#SDK` is implied and you don't have to add the hashtag explicitly

2. Remind you to **update the `SDK/CHANGELOG.md` document** (intended for our partners) **when you make a significant change to the SDK**
  - If you made trivial changes to the SDK which you consider don't require to be mentioned in the CHANGELOG for partners, you can add the `#IgnoreSDKChanges` in the PR title to acknowledge that it's ok that the `SDK/CHANGELOG.md` wasn't updated. **When in doubt if a change in SDK needs to be mentioned in the CHANGELOG, ask the `#sdk_squad` in slack**.


Context | Mention in PR title | Commit included in SDK CRP ticket? | New entry in CHANGELOG?
---|---|---|---
This PR didn't touch any (non-test) file in `sdk/*`, nothing related to SDK here | _None_ | 🚫 No | 🚫 No
This PR made significant SDK changes | `#SDK` (or `[SDK-xxx]`) | ✅ Yes | ✅Yes
This PR touched `sdk/*` files but it's a false positive (e.g. we just fixed indentation or a typo in a comment) | `#IgnoreSDKChanges` | 🚫 No | 🚫 No
This PR made SDK changes (which need to appear in CRP) but they are not worth a note in our partner's CHANGELOG | `#SDK ` (or `[SDK-xxx]`) *AND* `#IgnoreSDKChanges` | ✅ Yes | 🚫 No

### Ensure SDK CHANGELOG is updated on PRs releasing the SDK

> * Function: `check_sdk_release_changelog`
> * Type: ⚠️ warning

This rule ensures that, when we do a **PR to make a public SDK release** (i.e. to merge a `release/sdk/*` branch), **the `SDK/CHANGELOG.md` has been updated**.

Especially that in the top section title we **replace `## x.x.x (TBD)` with the actual version number and release date**.

## pbxproj checks

> * Declared in: `danger-ci/pbxproj.rb`

### Warn for unexpected resources in targets

> * Function: `check_unexpected_resource_files`
> * Type: 🚫 failure

This rule ensure that we didn't accidentally add some Xcode-specific files to a target's "Copy Resource Files" phase, as those files are only used by Xcode or for documentation or tests, but that shouldn't end up in the final framework or app.

This rule currently checks for `*.xcconfig`, `*.md`, `*Info.plist` and any file under a `__Snapshots__` directory and fail if they have been added to your target accidentally.

### Warn about `null` references

> * Function: `check_null_references`
> * Type: 🚫 failure (+ inline comments as warnings)

During a merge of Xcode project gone bad, `(null)` references can appear in the `.pbxproj` file.

This rule will trigger when any `(null)` references or `Recovered References` got introduced in the `pbxproj` that your PR touched. Additionally, it will also add inline comments to pinpoint the lines in your `pbxproj` where those null references were found.

When that happens, we need to understand what went wrong during the `pbxproj` merge and fix it properly (and manually) before we can merge the PR.

### Warn about orphan UUIDs

> * Function: `check_orphan_uuids`
> * Type: 🚫 failure (+ inline comments as warnings)

During a merge of Xcode project gone bad, orphan UUDS can appear in the `.pbxproj` file.

_Context: The `pbxproj` format is such that it contains a list of file references (with an associated UUID) listing all the files that are in the pbxproj, then points to those references in the various parts of the `pbxproj` (for example in the "Compile Sources" build phase part, to reference which files are included in that build phase). If a `pbxproj` merge went wrong, sometimes the line declaring the file reference (and its UUID) could be deleted during the bad merge while other lines in the pbxproj referencing that UUID would still remain._

This rule will warn you if any part of the pbxproj reference an UUID that got accidentally removed. (Note: you should see similar warnings when you run `pod install` in your terminal and it warns about an unknown UUID)

When that happens, you need to figure out if the removal of the file was intended as part of your PR (and if so, fix trhe merge by also removing the lines pointing to that now-deleted file reference), or if the removal of the file from the pbxproj was unintented (and if so, restore it). You could do that by editing the `pbxproj` manually, but if possible it's even better if you can fix it in Xcode (e.g. by removing the offending file from the project and add it again)
