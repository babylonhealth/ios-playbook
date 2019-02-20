# Further Comments on BBAddAdditionalPatientInformationViewControllerV2

`BBAddAdditionalPatientInformationViewControllerV2` is now only used for date of birth input via `BaseModel`. Screens: `EditMembershipCodeViewController` and `SurveyViewController`. If those are still in use, then first step could be to refactor `BBAddAdditionalPatientInformationViewControllerV2` to be used just for date of birth input. Cases other than `DateOfBirth` can be removed along with related code (e.g. `HeightAndWeightConverter`).

Also related to this (couldn't find a fitting section):
There was a transition period when two versions of Additional Info Bento existed. `AdditionalInfoViewModel`, which is no longer in use, along with related types can be removed. After this `AdditionalInfoViewModelV2` can be renamed to `AdditionalInfoViewModel`.

Witold Skibniewski, 2019-02-19
