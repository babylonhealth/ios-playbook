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
| InfoViewController | Could be replaced with a Bento Component for scrolling through a couple of info screens. |
