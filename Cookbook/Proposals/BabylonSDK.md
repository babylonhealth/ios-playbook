# BabylonSDK factory for main API interfaces 

* Author(s): Viorel Mihalache Oprea
* Review Manager: ReviewManager

## Introduction

The goal of this proposal is to simplify the way our main API interfaces are created and hide the internal of their initialisation.
An example of such change would be going from this:

```swift
if let context = authAPI.authenticatedContext.value  {
	let notificationsAPI = NotificationsAPI(with: context)	
}
```
to this
```swift 
let notificationsAPI = babylonSDK.notificationAPI
```

## Motivation

The reasons behind this proposal are related to:
- Simplicity:
	Currently, in order to create an API a user must be authenticated through registration, login or from a previous session.
Once authenticated, a valid context instance must be obtained and then injected to create an API. 
With the proposed solution there is no need for user to authenticate in order to create any API.

- Development ergonomics:
	The authenticated context contains some data that can not be used outside the SDKs and it exposes internal implementation details. Also, once the current session is being terminated the API instance loses scope and it can't be reused.
	With the proposed solution the current context entities will be injected internaly at the BabylonSDK level and the same API instance can be used for multiple user sessions. 
	
- Consistency with Android SDK.
The Android allows creating any SDK without passing additional context using singleton pattern.
The proposal is not identical with Android approach but it delivers similar result for creating a SDK without internal context being exposed. 


## Proposed solution

The `BabylonSDK` will be the main entry point for any app that uses the Babylon apis.
`DigitalTwinView` will not change the way it is created and will not be part of the `BabylonSDK`

This interface will be responsible for creating any api.
`BabylonSDK`will need a configuration object and after that an user can create any set of API's.

```swift
class BabylonSDK {
let authAPI: AuthAPI
var clinicalRecordsAPI: clinicalRecordsAPI
var appointmentAPI: AppointmentAPI
var chatAPI: ChatAPI
var healthcheckAPI: HealthcheckAPI
var healthManagementAPI: HealthManagementAPI
var healthRecordsAPI: HealthRecordsAPI just V2
var mapsAPI: MapsAPI
var notificationsAPI: NotificationsAPI
var patientMetricsAPI: PatientMetricsAPI
var userAPI: UserAPI
}
```
`authAPI` is the only constant parameter since an app should only have one instance of that. The rest of API's can be computed variables and it's up to the developer to mange their lifetime. 


## Impact on existing codebase

The current `Auth.Configuration` will need to be injected in the `BabylonSDK` initialiser.
At this level there will be a strong reference to `Auth` instance and all the other API's can be accessed through computed variables.
To achieve this the `CurrentAccessibleProxy`, that provides valid `AuthenticatedAccessible`,  will move to the BabylonSDK and will be injected in all SDK's. This will allow intitilization of tthe API's before user authenticateion was performed. Thsi is the same solution used for `Current`
BabylonClinicalRecords is the only SDK that needs a `PatientID`, so it needs to be refactored to work with a `SignalProducer<PatientID>`

At the app level there also need to be some refactoring. To create and SDK there is no need for the context or for calling directly the `init` method. **Instead all the SDK's will be available through `Current`**


## Alternatives considered

An alternative would be to use singleton pattern in order to provide all SDK's through static methods. This will be identical to Babylon Android SDK but this does not fit with the general arhitecure of the Babylon iOS apps and SDK's.

