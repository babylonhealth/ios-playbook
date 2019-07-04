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
TBD

### Edit a key/value
TBD

## How to add a new Locale
TBD

## Pull from lokalise
Check [Lokalise pull guide](https://github.com/Babylonpartners/ios-playbook/blob/master/Cookbook/Technical-Documents/Lokalise.md)

## Commit just your changes
TBD

## Target specific localizable - Lokalise project and `strings` files
TBD

## Lokalise: add comments and screenshots when possible.
TBD
