# New Hires Checklist

Prior to starting, make sure you have a Babylon GitHub account and that you have access to the following repositories:

- [babylon-ios](https://github.com/Babylonpartners/babylon-ios)
- [ios-charts](https://github.com/Babylonpartners/ios-charts)
- [ios-private-podspecs](https://github.com/Babylonpartners/ios-private-podspecs)
- [ios-build-distribution](https://github.com/Babylonpartners/ios-build-distribution)
- [ios-fastlane-match](https://github.com/Babylonpartners/ios-fastlane-match)

As an iOS Engineer, you should be in the following Slack channels:
Public:
- #ios
- #ios-build
- #ios-usa-support
- #ios-standup
- #ios-automation
- #ios-crash-reports
- #ios-recruiting

Private (ask someone to invite you):
- ios-underground
- ios-questions
- ios-sdk
- ios-oss
- ios-recruiting

Others
- demo_frontend
- developers

Apps
- pull-reminders
- peakon
- betterworks

Make sure you join your Tribe/Squad's Slack channels.

Here's how to get the iOS project up and running.

1. Clone the iOS repository: https://github.com/Babylonpartners/babylon-ios
1. Set up Git LFS and pull, according to these instructions: https://github.com/Babylonpartners/babylon-ios/wiki/How-to-install-Git-LFS
1. Globally configure Git to use SSH instead of HTTPS: https://ricostacruz.com/til/github-always-ssh
     ```
     git config --global url."git@github.com:".insteadOf "https://github.com/"
     ```
1. Run `bundle install`
1. Run `pod install`
1. Open `Babylon.xcworkspace` in Xcode (there may be several warnings; they can be ignored)
1. Configure the Xcode **Text Editing -> Editing** preferences as follows:
     - Automatically trim trailing whitespace
     - Including whitespace-only lines
     - Default line endings: macOS / Unix (LF)
     - Convert existing files on save
1. Configure the Xcode **Text Editing -> Indentation** preferences as follows:
     - Prefer indent using: Spaces
     - Tab width: 4 spaces
     - Indent width: 4 spaces
     - Tab key: Indents in leading whitespace
1. Make sure the device selected for testing is iPhone 5s

<img src="iphone-5s.png" height="101" width="388" alt="iPhone 5s" />