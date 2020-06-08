# SwiftGen and Localization

* Author: Emese Toth
* Review Manager: TBD

## Introduction

In order to modularise our strings we need to triage the existing ones and separate them per feature and possibly mark the unused ones as deprecated. 
The reason for this is that the next time we would like to create a new app, like we did for Brazil, we would only translate a subset of localization which is relevant to that new application.

This work would require us to go through all of the existing keys, so we could consider this as an opportunity to standardize the naming convention of the keys which would help the introduction of Swiftgen in the code base.

The current format we use with underscores:
```swift
healthcheck_actions_feedback_category_nutrition = "nutrition";
```

The new formatting would use dots: module.feature.x.y.z
```swift
healthcheck.actions.feedback_category_nutrition = "nutrition";
```

This would generate us this beautiful structure:
```swift
public enum Healthcheck {
   public enum Actions {
     public static let FeedbackCategoryNutrition = "nutrition"
   }
}
```

# Obsoleting old keys
One of the problems we’ll face is that we have a rule about not deleting old keys in Lokalise. So we’ll need to find a way to rename the existing keys we have in Lokalise so that we can still provide the modularisation we’re aiming for.

# Key referencing

One way could be using Lokalise’s key referencing feature. In Lokalise every key has a unique key_id, with these the translations can be linked to each other to allow the reuse of the existing translations in the new strings.
Example of key referencing:
```swift
general_cancel = "Cancel"  //key_id_1
payments_cancel_action = "[key_id_1] this action."  //key_id_2
```
I believe we can benefit from this feature to create the new key format for Swiftgen’s adoption, while we would keep all the old keys as well. 

The translation would be moved to a new key (key_id_3) and the old key would have a reference to this new key
```swift
payments.cancel_action = "Cancel"  //key_id_3
general_cancel = [key_id_3] //key_id_1
```

If by any chance in the future it’d be decided that we can remove keys from Lokalise, we would only remove the old formatting and the new one would contain the translation we need.

All of the old keys would be marked with a deprecated tag. This way the old keys would be still available in Lokalise as we cannot delete them, but `lokalise_pull` might be modified to filter out the deprecated keys.

# Tags
If we don’t want to change the format of the keys we could simply tag all of the keys with the corresponding vertical’s name so later on when creating a new app we could filter the keys by this name.
Some tags were already introduced so we should create a unique name for example `ios_appointment_vertical` to avoid confusion and to ensure this tag is used by the team and no translators, PMs.

When downloading the keys can be filtered by their tags in order to include or exclude them for the download.

The potential risk here is to have a lot of tags. We already have quite some tags, used by translators themselves it seems, and we want to be sure translators don’t tidy up with our tags accidently (remove or add them themselves). It's also easy to add the wrong tag as Lokalise automatically adds the latest used tag when we create a new entry.

Also, not that this would only solve the problem of categorizing keys by feature, but won’t solve how we would be able to have nice constants when introducing SwiftGen for strings.

Source: https://docs.lokalise.com/en/articles/1475552-tags


# Split into multiple .strings files
Keys can be assigned to one filename per platform. This feature could be used to split up one Localizable.strings file into one per vertical `AppointmentsLocalizable.strings`, etc then include them in the corresponding part of the project.
All the common strings like Cancel, OK, etc. could be included in a separate file.

When downloading the strings they can be filtered by filename so only the keys attributed with the selected files will be downloaded.

Source: https://docs.lokalise.com/en/articles/1400500-downloading-files-and-using-webhooks


# Summary

All of these methods could be used at the same time in the project, or we can decide to use a combination of two of them if using all of them at the same time would cause more complication in the daily work then it would benefit us. 
I would recommend using tagging to mark the deprecated keys in the project.

Pro: easy Swiftgen implementation

Con: the downfall of this method is that the number of keys we have in Lokalise would heavily increase (but the keys in our strings files pulled by `lokalise_pull` might not).
