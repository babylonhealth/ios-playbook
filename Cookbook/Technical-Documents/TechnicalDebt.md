Inventory of Identified Technical Debt and known Legacy Code.
=============================================================

Technical debt and legacy code has a sad tendency to build up in any software project. As the iOS project has grown both in terms of team members and supported apps we have found that managing technical has become more difficult. Legacy code should be ideally be refactored to clear technical debt when changes are needed. Existing technical debt that should be addressed when working on a new feature should be included in the planning. There is an obvious risk that legacy code is maintained instead of refactored if it is not clear what the technical debt currently is.

## Objective-C code and GatewayManager.

GatewayManager supplies global dependencies to legacy Objective-C code. There was plenty of code in version one and two of the Babylon app that relied heavily on singletons.

| Objective-C view Controllers | Location | JIRA Tickets | Comments |
| ---------------------------- | ---------| -------- | -------- |
| BillingInformationViewController | Clinical Records | CNSMR-930 | |
| EditMembershipCodeViewController | Clinical Records | CNSMR-934 | |
| MembershipTableViewController | Me Tab | CNSMR-926 | |
| SurveyViewController | Clinical Records | CNSMR-937 | |
| InsuranceViewController | Clinical Records | CNSMR-942 | |
| BBAddAdditionalPatientInformationViewControllerV2 | Clinical Records | | Might be dead code but will be deleted as part of CNSMR-947 |

Bento versions that use the design library are currently (July 2019) being worked on. Some have been completed but are still under feature switches.

Some additional information about [BBAddAdditionalPatientInformationViewControllerV2](./BBAddAdditionalPatientInformationViewControllerV2.md)

## Free Standing Swift View Controllers that should be Moved to Bento.

| View Controller | Comments |
| --------------- | -------- |
| InfoViewController | Could be replaced with a Bento Component for scrolling through a couple of info screens. Only used for the GP @ hand on-boarding so could be moved from BabylonUI. Used when `isV4IDVerificationEnabled == false`|
| SegmentedViewController | Currently only used in Healthcheck to show the the two bands with organs and layers. Should probably be moved from BabylonUI. |
| IntroViewController | Could potentially be merged with InfoViewController. |

Both `InfoViewController` and `IntroViewController` can be deleted once the NHS on-boarding journey has been refactored, as of July 2019 this is work in progress.

## View Models and Controllers that use Forms V2.

Forms V2 is no longer maintained and we should refactor these view controllers to use Bento.
Porting these view controllers to Bento will also make it easier to apply an app wide style guide (design library).

| View Model | JIRA tickets | Code Ownership | Comments |
| ---------- | -------- | -------- | -------- |
| AppointmentCancellationViewModel | ~CNSMR-950, CNSMR-951~ | Booking/Native Apps | Will be retired once the iOS part of CNSMR-1737 has been completed. |
| AppointmentConsultationNotesViewModel | ~CNSMR-952, CNSMR-953~ | Booking/Native Apps | Will be retired once the iOS part of CNSMR-1737 has been completed. |
| AppointmentDetailsViewModel | ~CNSMR-954, CNSMR-955~ | Booking/Native Apps | Will be retired once the iOS part of CNSMR-1737 has been completed. |
| AppointmentNotesViewModel | ~CNSMR-956, CNSMR-957~ | Booking/Native Apps | Will be retired once the iOS part of CNSMR-1737 has been completed. |
| AppointmentPrescriptionViewModel | ~CE-30~ | Booking/Native Apps | Will be retired once the iOS part of CNSMR-1737 has been completed. |
| AppointmentReferralViewModel | ~CNSMR-958, CNSMR-959~ | Booking/Native Apps | Will be retired once the iOS part of CNSMR-1737 has been completed. |
| AppointmentReferralsViewModel | ~CNSMR-960, CNSMR-961~ | Booking/Native Apps | Will be retired once the iOS part of CNSMR-1737 has been completed. |
| AppointmentReplayViewModel | ~CNSMR-962, CNSMR-963~ | Booking/Native Apps | Will be retired once the iOS part of CNSMR-1737 has been completed. |
| AppointmentListViewModel | ~CNSMR-964, CNSMR-965~ | Booking/Native Apps | Used when `isNewAppointmentsEnabled == false`. Will be retired once the iOS part of CNSMR-1737 has been completed. |
| BookAppointmentViewModel | ~CNSMR-966, CNSMR-967~ | Booking/Native Apps | Will be retired once the iOS part of CNSMR-1737 has been completed. |
| PractitionerDetailsViewModel | ~CNSMR-968, CNSMR-969~ | Booking/Native Apps | Will be retired once the iOS part of CNSMR-1737 has been completed. |
| ChatHistoryViewModel | CNSMR-970, CNSMR-971 | | |
| MedicalHistoryViewModel | CNSMR-972, CNSMR-973 | | |
| PersonalDetailsViewModel | CNSMR-974, CNSMR-975 | | |
| InfoItemsViewModel | CNSMR-976, CNSMR-977 | | |
| GPDetailsViewModel | CNSMR-978, CNSMR-979 | | |
| AddAddressViewModel | CNSMR-980, CNSMR-981 | | |
| PrivacySettingsViewModel | AV-334 | | |
| ChooseCountryViewModel | AV-338 | | |
| ForgotPasswordViewModel | CNSMR-904 | | Used when `isNewForgotPasswordEnabled == false` |
| NotificationsViewModel | AV-342 | | Used when `isNewNotificationsEnabled == false` |
| SignInViewModel | AV-332 | | Used when `isNewSigninEnabled == false`|
| NHSRegistrationStep1ViewController | NRX-361 | | Used when `isV4NHSRegistrationStep1And2Enabled == false` |
| NHSRegistrationStep2ViewController | NRX-186 | | Used when `isV4NHSRegistrationStep1And2Enabled == false` |
| RedemptionViewModel | CNSMR-921 | | Used when `isNewRedemptionEnabled ==false ` |
| OnboardingViewModel | AV-118 | | Used when `isNewWelcomeScreenEnabled == false` |

## Bento View Controllers that need to be Updated to use the Design Library.

`Bento` and its component library `BentoKit` predates the design library. Consequenly there are a number of `BoxRenderer` classes that need to be refactored to employ the design library.

### Renderers that do not employ the design library

| Renderer | JIRA tickets | Code Ownership | Comments |
| ---------- | -------- | -------- |  -------- |
| PrescriptionRenderer | | | |
| PrescriptionDeliveryOptionsRenderer | | | |
| ChatMenuRenderer | | | |
| SymptomSelectorRenderer | | | |
| MessageReportRenderer | | | |
| PGMConditionDetailsRenderer | | | |
| PGMConditionDetailsRenderer | | | |
| ClinicalRecordsRenderer | | | |
| PGMReportRenderer | | | |
| GPAtHandDetailsRenderer | | | |
| PharmaciesRenderer | | | |
| ClinicalRecordsRenderer | | | |
| MetricDetailsRenderer | | | |
| QuestionnaireRenderer | | | |
| UserFeedbackRatingRenderer | | | |
| MapSearchResultsRenderer | | | |
| PlaceListRenderer | | | |
| ChooseAssessmentRenderer | | | |
| DetailRenderer | | | |
| HealthOverviewRenderer | | | |
| RiskSortMenuRenderer | | | |
| DiseaseRisksRenderer | | | |
| ActionsRenderer | | | |
| AdditionalInfoFormRenderer | | | |
| RatingRenderer | | | |
| ChooseStateRenderer | | | |
| AddressListRenderer | | | |
| ShopConfirmationRenderer | | | |
| ChooseProviderRenderer | | | |
| PaymentPlansRenderer | CNSMR-1739 | Native Apps | |
| SubscriptionConfirmationRenderer | | | |
| SubscriptionsRenderer | | | |
| EligibilityCheckRenderer | | | |
| NHSSwitchV2Renderer | | | |
| NHSConfirmationSwitchRenderer | | | |
| NHSSummaryRenderer | | | |
| NotificationsV2Renderer | | | |
| PaymentRenderer | | | Used when `isNewPaymentsAvailable == false` |
| AddCardRenderer | | | |
| ChoosePaymentMethodRenderer | | | |
| TestsAndKitsKitsInfoRenderer | | | |
| ChooseSponsorRenderer | | | |

### Helpers that are not using the design library

| Renderer | JIRA tickets | Code Ownership | Comments |
| ---------- | -------- | -------- |  -------- |
| InfoRendererV2 | | | |
| RichTextRenderer | | | Uses both the design library and `BentoKit` |
| GetStartedRenderer | | | Uses both the design library and `BentoKit` |
| IntroductionRenderer  | | | Uses both the design library and `BentoKit` |

### Renderers that mixes the design library with BentoKit

Direct references to `BentoKit` components are probably left overs from porting the renderer to use the design library.

| Renderer | JIRA tickets | Code Ownership | Comments |
| ---------- | -------- | -------- |  -------- |
| ManageSyncRenderer | | | |
| DashboardRenderer | | | |
| NHSOnboardingV2Renderer | | | |
| NHSRegistrationStep1V2Renderer | | | |
| TestsAndKitsDetailRenderer | | | |

## App Configuration Files and Shared Content

Content that is currently defined in per target app configuration files will in the future be served dynamically. At this moment in time (July 2019) we don't know how this will impact our codebase.

## Accessing Business Controllers Directly instead of using the SDK.

Some of these business controllers are not defined inside the SDK. Most of them will be moved to the SDK, but some of them will stay in the Babylon project. Once the first, complete version of the SDK has been published there should not be any business controllers left in BabylonCore. Business controllers that are defined outside the SDK should have a documenting comment that explain why they are not part of the SDK.

| Business Controller | Defined In | Accessed From | Comments |
| ------------------- | ------------- | ------------- | ------------- |
| AppointmentBusinessControllerProtocol | BabylonAppointmentsSDK |BabylonAppointmentsUI, Babylon | |
| AddressBusinessControllerProtocol | BabylonCore | BabylonAppointmentsUI, BabylonUI, Babylon | |
| PractitionerBusinessController | BabylonAppointmentsSDK | BabylonAppointmentsUI | |
| PatientBusinessControllerProtocol | BabylonCore | BabylonAppointmentsUI, BabylonClinicalRecordsUI, BabylonChatBotUI, BabylonMonitor, BabylonUI, Babylon | |
| PrescriptionBusinessControllerProtocol | BabylonAppointmentsSDK | BabylonAppointmentsUI, Babylon | |
| PharmaciesBusinessControllerProtocol | BabylonCore | BabylonAppointmentsUI, BabylonClinicalRecordsUI | |
| ImageBusinessControllerProtocol | BabylonCore | BabylonAppointmentsUI, BabylonClinicalRecordsUI, BabylonHealthManagementUI, BabylonMonitor, Babylon | |
| BookAppointmentBusinessControllerProtocol | BabylonAppointmentsSDK | BabylonAppointmentsUI | |
| PrivacyBusinessControllerProtocol | BabylonCore | BabylonAppointmentsUI, BabylonChatBotUI, BabylonUI, Babylon | |
| PublicHealthcareIdentifierBusinessController | BabylonCore | BabylonAppointmentsUI, BabylonClinicalRecordsUI, BabylonUI, Babylon | |
| SearchAssistantBusinessController | BabylonChatBotUI | BabylonChatBotUI | |
| MedicalHistoryBusinessController | BabylonCore | BabylonClinicalRecordsUI | |
| GeolocationBusinessController | BabylonCore | BabylonClinicalRecordsUI, BabylonUI, Babylon | |
| InfoItemsBusinessControllerProtocol | BabylonCore | BabylonClinicalRecordsUI | |
| GPDetailsBusinessController | BabylonCore | BabylonClinicalRecordsUI | |
| HealthcheckReportBusinessControllerProtocol | BabylonMonitor | BabylonMonitor, Babylon | |
| ReferAFriendBusinessControllerProtocol | BabylonCore | BabylonUI, Babylon | |
| RatingBusinessControllerProtocol | BabylonCore | BabylonUI | |
| FamilyBusinessControllerProtocol | BabylonCore | BabylonUI, Babylon | |
| RedemptionBusinessController | BabylonCore | Babylon | |
| RegionBusinessControllerProtocol | Babylon | Babylon | |
| NotificationPayloadBusinessControllerProtocol | Babylon | Babylon | |
| SignInPrivacyBusinessControllerProtocol | BabylonCore | BabylonAppointmentsUI, Babylon | |
| PaymentsBusinessControllerProtocol | Babylon | Babylon | |
| LocationEligibilityBusinessController | Babylon | Babylon | |
| PostCodeEligibilityBusinessControllerProtocol | Babylon | Babylon | |
| SignUpPrivacyBusinessController | BabylonCore | Babylon | |
| ForgotPasswordBusinessControllerProtocol | BabylonCore | Babylon | |
| OnfidoBusinessControllerProtocol | Babylon | Babylon | |
| PDSBusinessControllerProtocol | Babylon | Babylon | |
| NHSBusinessController | Babylon | Babylon | |
| CreditCardsBusinessControllerProtocol | Babylon | Babylon | |
| TestsAndKitsBusinessControllerProtocol | Babylon | Babylon | |
| RedemptionBusinessControllerProtocol | BabylonCore | Babylon | |

## BabylonCore should only Contain SDK Related Entities.

BabylonCore is part of the SDK and its public entities should all be relevant for our partners. Ideally this would only be data types that are needed by more than one SDK, but business logic that is re-used in several SDKs might have to be defined in BabylonCore. Below is an incomplete table for what should be moved out. Owing to the fact that we not yet (July 2019) completed all SDKs it is not possible to say exactly what should be moved out of BabylonCore.

| Folder | Comments |
| ------ | -------- |
| Rating | Should probably be defined in BabylonDependencies |
| Bundle | Belongs in the main project |
| Measurement | Possible options are BabylonDependencies or BabylonHealthManagement |
| AdditionalInfo/Monitor | Belongs in the BabylonMonitor project |
| Analytics | Belongs in BabylonDependencies |
| AppDelegate | Belongs in the main project |
| Image | Should probably be defined in BabylonDependencies |
| Notifications | Possible options are BabylonDependencies or the main project |
| Persistence | Belongs in the main project |
| Validation | Probably belongs in BabylonUI |

Please note that suggested destinations are a bit approximate.

What should be done with content in the `Utilities` folder is non-trivial. It contains a lot of useful definitions that we want to use in the SDK. Our clients might, however, prefer their own operator definitions.

## Main Tab Bar and Navigation.

Although much improved since version two was released, there is still a fair amount of confusing legacy code left in the tab bar flow controller and associated builders. Now that all content has been refactored to be based on reactive functional programming, flow controllers and builders it is possible to align `ExchangeableTabBarBuilder` and `TabContentBuilder` entities to follow our general design pattern. For historical reasons some flow controllers acts have logic for building view controllers. The `BabylonTabBarViewModel` should be able to forward all routing events to the appropriate flow controller. Some networking logic should be removed from `BabylonTabBarViewModel`. These deviations from our standard architecture makes it difficult to understand the code and changes often result in long and confusing discussions.

## Retire VisualDependencies and AppDependencies.

Work has been carried out to access common content through `Current` instead of `AppDependencies`. The only entity that currently (July 2019) remains in `AppDependencies` is `VisualDependencies`. This has proven to be a tricky thing to move refactor. Most of the `VisualDependencies` is UI related and should thus not be defined in `BabylonDependencies`.

`VisualDependencies` consists of four parts, `appColors`, `brandColors`, `brandGlobalDefaults` and `styles`. Accessing `appColors` throgh visual dependenies is deprecated in favour of using the design library. Serving the content in `brandGlobalDefaults` via the design library is expected to be straightforward. How `brandColors` should be handled is a non-trival question that is also related to planned services for app and feature configuration.

The last, `styles`, serves look and feel for `Forms` and `FormsV2` and is not needed by the design library. It will thus be dead code once the refactoring to NVL has been completed.

## Move Babylon UK Specific Code from the Main Project.

Currently a lot of the code for handling the NHS registration process and other GP @ Hand related tasks recide in the main app target. There are also some NHS related entities in the `BabylonClinicalRecordsUI` project. NHS related code is obviously not needed for Telus, US or KSA needs to be moved to the `BabylonNHS` project. Before moving some the project initialisations need to be changed to receive either instances or factory methods for business controllers and child builders.

It must be noted that moving NHS related code will be easier to do once the refactoring to employ the design library has been completed. This is currently (July 2019) work in progress.
