# How to deal with Localizations [draft]

In project we can add a new Localization. But that is not in target level. Babylon needs to have a different sets of languages/locales per product.

Babylon:
  - British English
  - Arabic (soon), etc 

NHS111 and Bupa:
  - British English

Telus:
  - Canadian English
  - Canadian French (soon)

Babylon US:
  - American English
  - American Spanish

## Build Settings
### Understanding `app_languages` variable
Given that, we manage our languages in an array in Build Settings in each target.

| Babylon UK | Babylon US | Telus |
|--------|--------|--------|
| `en.lproj/*` | `en-US.lproj/*` `es-US.lproj/*` | `en.lproj/*` |

**I.E we control the languages for each target editing the `APP_LANGUAGES` under _User-Defined_**

### _Excluded Source File Names_ and _Included Source File Names_ under `Build option`
In the _Excluded Source File Names_ we exclude any language (`.lproj/`) previously set:
`*.lproj/*` 

In the _Included Source File Names_ we include the languages (`.lproj/`) set in the above mentioned `app_languages` array:
`${APP_LANGUAGES}` in Babylon US for example it is en-US.lproj/* es-US.lproj/*

## How to add a new or changing an existing key/value
### Add a new key/value
In Lokalise, select the corresponding project. 
Click on the `Add key ⌘K` button
- `key` - Give a name for the key following the bread-crumb style. For example: `add_family_member_email_placeholder`, `biometric_touchid_primer_description` or `biometric_touchid_primer_description`
    
- `Base language value`: The actual string value corresponding to the first language in the list. Placeholders are supported with the `@%` where dynamic values are expected. 

### Edit a key/value
Search and select the key you'd like to update and change any language you need. The languages you may not have the values will be marked as `Not-verified` and the translators will take care.

## How to add a new Locale
- In Lokalise project, click on the `+` plus button beside other flags. Find the desired language on the list, and then add it.
- In the iOS project, in the file `lokalise` (under the fastlane folder), add the language code (`en_US` for example) in the `langs` parameter for the desired target. `langs: 'es_US,en_US'` (comma separated without space). 

## Pull from lokalise
Check [Lokalise pull guide](https://github.com/Babylonpartners/ios-playbook/blob/master/Cookbook/Technical-Documents/Lokalise.md)

## Commit just your changes
Stage just your changes (additions and editions) on git. Don't stage any additions nor change that you don't recognize. It's really nice to be proactive but not in this case. It might cause unspected/premature changes. Yes, discard others's changes.

## Target specific localizable - Lokalise project and `strings` files
TBD

## Lokalise: add comments and screenshots when possible.
Comments and screenshots are important complementary **contexts** for the translators.
Imagine that when the translators started the Arabic work, they saw the call-to-action `Book` for Book an appointment screen. Then without any comment nor screenshot, that has been translated **litterally** as book 📚📖 (the object that has pages that we read). As an Engineer you should understand that context is crucial. A quick comment and screenshot made in 5 minutes, might save hours of back and forward to fix a misunderstanding of meaning throughout engineering, management, translators and in this case, AppStore approval proccess. 






