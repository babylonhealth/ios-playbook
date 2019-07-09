# Detect usage of Current outside builders

* Author: João Pereira, Olivier Halligon, Danilo Aliberti
* Review Manager: TBD

## Introduction

The goal of this proposal is to minimize abuse from calling Current outside builders and a small subset of files.

## Motivation

`Current` is a very powerful concept whose usage is only allowed in a very restrict number of places. More detailed information about Current can be found [here in our Current Guide](../Technical-Documents/Current-guide.md). As such, we should enable automatic monitoring in order to prevent it from being abused throughout our codebase. Nevertheless, Current is still being used in a lot of places (598 results across 144 files) and we should go through every case individually before commiting to a decision:

`Current` should only be allowed in:
- `AppDelegate.swift`
- `DesignLibrary.swift`
- `World.swift`
- Builders (using the `*Builder(\+.*).swift` regex)
- `*AppConfiguration.swift`
- AppDependencies

In order to detect this, SwiftLint would likely be our best bet since it can easily detect these issues in real-time and warn us.
Here is a possible implementation:

```
custom_rules:
  world_current:
    excluded: # Files in which it's OK to use Current
     - ".*Builder(\+.*)?\\.swift"
     - "World\\.swift"
     - "AppDelegate\.swift"
     - ".*AppConfiguration\.swift"
     - "AppConfiguration.swift" # For depreciation warnings
    name: "Current:World usage"
    regex: "\wCurrent\."
    message: "You should only use Current in Builders"
    severity: warning
```

However, we have numerous cases that need to be analyzed one by one:

 - ReceiptRenderer (locale, tz)

 - *ViewModel
   - CountryCodePickerViewModel (locale)
   - MetricDetailsViewModel (now)
   - AvatarViewModel (default params for init: calendar, now)
   - AddAddressViewModel ( |> analytics.track)
 
 - AdditionalInfoForm
 - VisualDependencies.swift (restrictedAgeDatePickerStyle)
 
  - *FlowController (abTestingService)
   - PrescriptionFlowController
   - HomeFlowController

 - *ViewController:
   - MapViewController
   - IntroViewController
   - FocusedChatViewController (locale)
 
 - Debug*
    - DebugHomeRenderer (renderVisualLanguageSwitch, check current VL)
    - DebugSignUpAccountGenerator

 - Other
   - MockReceiptDTO (locale, tz)
   - BabylonBoxViewController (appearance)
   - OpeningHoursFormatter
   - LocalNotificationService: extension DebugAction, check abTestingService