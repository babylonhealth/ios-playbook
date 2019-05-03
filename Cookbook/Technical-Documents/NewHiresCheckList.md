# New Hires Checklist

## GitHub Access

Prior to starting, make sure you have a Babylon GitHub account and that you have access to the following repositories:

- [babylon-ios](https://github.com/Babylonpartners/babylon-ios)
- [ios-charts](https://github.com/Babylonpartners/ios-charts)
- [ios-private-podspecs](https://github.com/Babylonpartners/ios-private-podspecs)
- [ios-build-distribution](https://github.com/Babylonpartners/ios-build-distribution)
- [ios-fastlane-match](https://github.com/Babylonpartners/ios-fastlane-match)

See [access to dev services](ToolsAndServices.md) if you don't have access yet.

## Slack

As an iOS Engineer, you should be in the following Slack channels:

* Public:
	- `#ios`
	- `#ios-build`
	- `#ios-usa-support`
	- `#ios-standup`
	- `#ios-automation`
	- `#ios-crash-reports`
	- `#ios-recruiting`

* Private (ask someone to invite you):
	- `#ios-underground`
	- `#ios-questions`
	- `#ios-sdk`
	- `#ios-oss`

* Others
	- `#demo_frontend`
	- `#developers`

* Slack Apps
	- pull-reminders
	- peakon
	- betterworks

Make sure you also join your Tribe/Squad's Slack channels.

## Install prerequisites

1. Install [Homebrew](https://brew.sh/).

1. Install the correct version of Xcode, along with its command-line tools. (To
   find out the correct version you need for the current build, ask a
   teammate.) Make sure you download and install Xcode from the Apple Developer
   Center, rather than the App Store, to avoid unexpected automatic updates.

1. Install Ruby 2.4. If you don't have Ruby or a version manager, you can use
   RVM to set up Ruby 2.4:

    ```
    \curl -sSL https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm
    rvm install 2.4
    rvm use 2.4
    ```

## Setup Guide

Most of the work to get the iOS project up and running is automated inside a
shell script. Here's how to get the iOS project up and running:

1. [Generate](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key) & add the SSH key to your [GitHub account](https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account)

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

1. It can be useful to create a command line alias for `pod` to `bundle exec pod` so that you are guaranteed to always be running the correct version of Cocoapods.

1. [Install additional tools and ask access for the various services we use](ToolsAndServices.md).

1. Add yourself to the team list in the [playbook](https://github.com/Babylonpartners/ios-playbook) by making your first PR 😉

1. Add shared `iOS Developers` calendar to your calendar on Outlook

1. Don't hesitate to create a PR with an update to this `NewHiresCheckList` or the `ios-onboarding` script if you have spotted something is missing or could be improved.

1. Ask your team lead to be invited to any upcoming/recurring meetings (like PR parties or sprint retros).
   You'll also be invited to the `#newbabylonians` private Slack channel after your induction; feel free to ask there to be invited to recurring company meetings too, like the weekly company standups
