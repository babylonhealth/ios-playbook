Inventory of Identified Technical Debt and known Legacy Code.
=============================================================

Technical debt and legacy code has a sad tendency to build up in any software project. As the iOS project has grown both in terms of team members and supported apps we have found that managing technical has become more difficult. Legacy code should be ideally be refactored to clear technical debt when changes are needed. Existing technical debt that should be addressed when working on a new feature should be included in the planning. There is an obvious risk that legacy code is maintained instead of refactored if it is not clear what the technical debt currently is.

## Objective-C code and GatewayManager.

GatewayManager supplies global dependencies to legacy Objective-C code. There was plenty of code in version one and two of the Babylon app that relied heavily on singletons.

| Objective-C view Controllers | Location | Comments |
| ---------------------------- | ---------| -------- |
| BillingInformationViewController | Clinical Records | |
| EditMembershipCodeViewController | Clinical Records | |
| MembershipTableViewController | Me Tab | |
| SurveyViewController | Clinical Records | |
| InsuranceViewController | Clinical Records | |
| BBAddAdditionalPatientInformationViewControllerV2 | Clinical Records | Might be dead code |

## Free Standing Swift View Controllers that should be Moved to Bento.

| View Controller | Comments |
| --------------- | -------- |
| InfoViewController | Could be replaced with a Bento Component for scrolling through a couple of info screens. Only used for the GP @ hand on-boarding so could be moved from BabylonUI. |
| SegmentedViewController | Currently only used in Health Check to show the the two bands with organs and layers. Should probably be moved from BabylonUI. |

## View Models and Controllers that use Forms V2.

| View Model | Comments |
| ---------- | |
| AppointmentCancellationViewModel | |
| AppointmentConsultationNotesViewModel | |
| AppointmentDetailsViewModel | |
| AppointmentNotesViewModel | |
| AppointmentPrescriptionViewModel | CE-30 |
| AppointmentReferralViewModel | |
| AppointmentReferralsViewModel | |
| AppointmentReplayViewModel | |
| AppointmentListViewModel | |
| BookAppointmentViewModel | |
| PractitionerDetailsViewModel | |
| ChatHistoryViewModel | |
| MedicalHistoryViewModel | |
| PersonalDetailsViewModel | |
| InfoItemsViewModel | |
| GPDetailsViewModel | |
| AddAddressViewModel | |
| PrivacySettingsViewModel | |
| ChooseCountryViewModel | |
| ForgotPasswordViewModel | |
| NotificationsViewModel | |
| ProfileViewModel | |
| SignInViewModel | |

## Accessing Business Controllers Directly instead of using the SDK.


| Business Controller | Accessed From |
| ------------------- | ------------- |
| AppointmentBusinessControllerProtocol | BabylonAppointmentsUI, Babylon |
| AddressBusinessControllerProtocol | BabylonAppointmentsUI, BabylonUI, Babylon |
| PractitionerBusinessController | BabylonAppointmentsUI |
| PatientBusinessControllerProtocol | BabylonAppointmentsUI, BabylonClinicalRecordsUI, BabylonUI, Babylon |
| PrescriptionBusinessControllerProtocol | BabylonAppointmentsUI, Babylon |
| PharmaciesBusinessControllerProtocol | BabylonAppointmentsUI, BabylonClinicalRecordsUI |
| ImageBusinessControllerProtocol | BabylonAppointmentsUI, BabylonClinicalRecordsUI, BabylonMonitor, Babylon |
| BookAppointmentBusinessControllerProtocol | BabylonAppointmentsUI |
| PrivacyBusinessControllerProtocol | BabylonAppointmentsUI, BabylonChatBotUI, BabylonUI |
| PublicHealthcareIdentifierBusinessController | BabylonAppointmentsUI, BabylonClinicalRecordsUI, BabylonUI, Babylon |
| SearchAssistantBusinessController | BabylonChatBotUI |
| MedicalHistoryBusinessController | BabylonClinicalRecordsUI |
| GenderBusinessControllerProtocol | BabylonClinicalRecordsUI, BabylonUI, Babylon |
| GeolocationBusinessController | BabylonClinicalRecordsUI, BabylonUI |
| InfoItemsBusinessControllerProtocol | BabylonClinicalRecordsUI |
| MapsBusinessControllerProtocol | BabylonClinicalRecordsUI |
| GPDetailsBusinessController | BabylonClinicalRecordsUI |
| HealthcheckReportBusinessControllerProtocol | BabylonMonitor, BabylonUI, Babylon |
| ReferAFriendBusinessControllerProtocol | BabylonUI, Babylon |
| RatingBusinessController | BabylonUI |
| FamilyBusinessControllerProtocol | BabylonUI |
| RedemptionBusinessController | Babylon |
| RegionBusinessControllerProtocol | Babylon |
| EligibilityCheckBusinessControllerProtocol | Babylon |
| NotificationPayloadBusinessControllerProtocol | Babylon |
| SignInPrivacyBusinessControllerProtocol | Babylon |
| PaymentsBusinessControllerProtocol | Babylon |
| PDSQueueBusinessControllerProtocol | Babylon |
| LocationEligibilityBusinessController | Babylon |
| PostCodeEligibilityBusinessControllerProtocol | Babylon |
| SignUpBusinessController | Babylon |
| ForgotPasswordBusinessControllerProtocol | Babylon |
| FamilyBusinessControllerProtocol | Babylon |
| OnfidoBusinessControllerProtocol | Babylon |
| PDSBusinessControllerProtocol | Babylon |
| NHSBusinessController | Babylon |

Some of these business controllers are still defined in BabylonCore.

## Main Tab Bar and Navigation.
