## Lokalise Service

Lokalise is used for managing texts and translations in our apps.

Strings are edited through the [Lokalise app](https://lokalise.co). 
Create an account using your `@babylonhealth.com` email address and request access to the relevant projects.

To update strings in the app the following `Fastlane` lanes can be used:
```
bundle exec fastlane lokalise_pull             // download all projects
bundle exec fastlane lokalise_pull_babylon     //download the main Babylon

// these download the other apps projects - they are subsets that populates the files `TargetSpecificLocalizable`
bundle exec fastlane lokalise_pull_telus
bundle exec fastlane lokalise_pull_nhs111
bundle exec fastlane lokalise_pull_bupa
```

To add/modify keys/values, when you are in a `Project` on the website, you can use `⌘K` or click the blue button `Add key`…
