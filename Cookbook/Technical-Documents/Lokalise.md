## Lokalise Service

Lokalise is used for managing texts and translations in our apps.

Strings are edited through the [Lokalise app](https://lokalise.co). 
Create an account using your `@babylonhealth.com` email address and request access to the relevant projects.

To update strings in the app the following `Fastlane` lanes can be used:
```
bundle exec fastlane lokalise_pull             // download all projects
bundle exec fastlane lokalise_pull_babylon     // download the main Babylon

// these download the other apps projects - they are subsets that populates the files `TargetSpecificLocalizable`
bundle exec fastlane lokalise_pull_telus
bundle exec fastlane lokalise_pull_nhs111
bundle exec fastlane lokalise_pull_bupa
```

To add/modify keys/values, when you are in a `Project` on the website, you can use `⌘K` or click the blue button `Add key`…

### Design System translations

We have [separate Lokalise project](https://app.lokalise.com/project/600119985e68c8ed361798.78610565) for translations used inside the Design System components. While editing keys there, keep in mind that they are shared between the apps and UI SDKs so make sure to consult it with the SDK team if it may effect them.

To update strings for the `BabylonDesignLibrary` use the lane:
```
bundle exec fastlane lokalise_pull                // download all projects, including Design System
bundle exec fastlane lokalise_pull_design_library // download only Design System project
```

### UI SDKs translations

Similarly to Design System, we have [separate Lokalise project](https://app.lokalise.com/project/559388585e68a93fd45488.75156497) for translations used inside the UI SDKs. Translations in this project should be only modified by the SDK team.

To update strings for the UI SDKs use the lane:
```
bundle exec fastlane lokalise_pull      // download all projects, including UI SDKs
bundle exec fastlane lokalise_pull_sdks // download only SDK project
```
