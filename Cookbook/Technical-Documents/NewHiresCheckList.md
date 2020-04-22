# New Hires Checklist

## Access to services

You can find the list of services you'll need and how to get access to them in [Tools and Services](ToolsAndServices.md).

## GitHub Access

Prior to starting, make sure you have a GitHub account (either your personal or a new one for Babylon) and that you are added to the [iOS](https://github.com/orgs/babylonhealth/teams/ios) and [iOS-Devs](https://github.com/orgs/babylonhealth/teams/ios-devs) teams. This will give you access to all the appropriate repositories and will include you in GitHub's automatic code reviewer assignments.

Once you've done that, double check that you have access to the following repositories:

- [babylon-ios](https://github.com/babylonhealth/babylon-ios)
- [ios-charts](https://github.com/babylonhealth/ios-charts)
- [ios-private-podspecs](https://github.com/babylonhealth/ios-private-podspecs)
- [ios-build-distribution](https://github.com/babylonhealth/ios-build-distribution)
- [ios-fastlane-match](https://github.com/babylonhealth/ios-fastlane-match)

See [section above](#access-to-services) if you don't have access yet.

## Slack

As an iOS Engineer, you should be in the following Slack channels:

* Public:
	- `#ios`
	- `#ios-build`
	- `#ios-usa-support`
	- `#ios-automation`
	- `#ios-crash-reports`
	- `#ios-recruiting`

* Private (ask someone to invite you):
	- `#ios-underground`
	- `#ios-questions`
	- `#ios-sdk`
	- `#ios-oss`
	- `#ios-meeting-outcomes`
	- `#ios-pedia`
	- `#ios-support-info`

* Others
	- `#demo_frontend`
	- `#developers`

And add yourself to the `@ios-team` user group. (You can do this under the 3 dot more menu > `User groups`)

Make sure you also join your Tribe/Squad's Slack channels, groups.

## Install prerequisites

1. Install [Homebrew](https://brew.sh/).

1. Install the correct version of Xcode, along with its command-line tools. (To
   find out the correct version you need for the current build, ask a
   teammate.) Make sure you download and install Xcode from the Apple Developer
   Center, rather than the App Store, to avoid unexpected automatic updates.

1. Install Ruby 2.6.4. If you don't have Ruby or a version manager, you can use
   RVM to set it up:

    ```
    \curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
    rvm install 2.6.4
    rvm use 2.6.4
    ```

## Setup Guide

Most of the work to get the iOS project up and running is automated inside a
shell script. Here's how to get the iOS project up and running:

1. [Generate](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key), add the SSH key to your [GitHub account](https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account) and [authorise](https://help.github.com/en/articles/authorizing-an-ssh-key-for-use-with-a-saml-single-sign-on-organization) it for use with single sign on.

1. Run the `ios-onboarding` Bash script inside the `scripts` directory of this
   repo. It requires a `CODE_DIRECTORY` argument which is the parent directory
   where you want the `babylon-ios` repo cloned into. See the documentation
   inside the script for example usage.

1. Open `Babylon.xcworkspace` in Xcode (there may be several warnings; they can be ignored). You can use `xed .` on the command line at the root of the project to open the workspace.

1. Configure the Xcode **Text Editing -> Editing** preferences as follows:
     - Automatically trim trailing whitespace
     - Including whitespace-only lines
     - Default line endings: macOS / Unix (LF)
     - Convert existing files on save
     - Page guide at column: 120 characters

1. Configure the Xcode **Text Editing -> Indentation** preferences as follows:
     - Prefer indent using: Spaces
     - Tab width: 4 spaces
     - Indent width: 4 spaces
     - Tab key: Indents in leading whitespace

1. Compile the project 🎉

## What's next?

1. Refer to the [Fastlane Match](FastlaneMatch.md#day-to-day-development) document if you want to run the app on your own iOS devices.

1. It can be useful to create a command line alias for `pod` to `bundle exec pod` so that you are guaranteed to always be running the correct version of CocoaPods.

1. Add yourself to the team list in the [playbook](https://github.com/babylonhealth/ios-playbook) by making your first PR 😉
   You can do this by editing `scripts/squads.yml` and then running `ruby scripts/squads.rb` which will update the list

1. Add shared `iOS Developers` calendar to your calendar on Outlook

1. Don't hesitate to create a PR with an update to this `NewHiresCheckList` or the `ios-onboarding` script if you have spotted something is missing or could be improved.

1. Ask your team lead to be invited to any upcoming/recurring meetings (like PR parties or sprint retros).
   You'll also be invited to the `#newbabylonians` private Slack channel after your induction; feel free to ask there to be invited to recurring company meetings too, like the weekly company standups
