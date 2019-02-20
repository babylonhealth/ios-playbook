Splitting `AppMainUserSession` into its Logical Components.
===========================================================

This document describes one possible path for refactoring `AppMainUserSession`. Most likely this a refactoring that will be carried out in steps by different members of the iOS team. It is therefore important that everyone shares their knowledge and thoughts about how to make `AppMainUserSession` SDK friendly and hopefully more manageable in this document.

`AppMainUserSession` implements `Accessible`, `AuthenticatedAccessible`, `ClinicalAccessible`, `UserSession` and `MainUserSession`. `Accessible` provides basic network calls, `AuthenticatedAccessible` adds network calls authenticated by Kong,  `ClinicalAccessible` are for network calls that require extra authentication to access sensitive data. `UserSession` extends the network access with a `LifeTime` and business controllers for the current user, id verification status and image handling. `MainUserSession`, finally, adds support for accessing family account members, biometric authentication, performing extra authentication to access clinical records and finally a for observing the current status of extra authentication.

Needless to say this a rather complicated entity with poor separation of concerns. `AppMainUserSession` was designed in this way to work around a number of legacy problems, among them multiple authentication domains and that version 2 of the Babylon app relied heavily on singletons. It is, however, doing its job reasonably well and would probably not be marked for refactoring if it was not for the fact that it blocks moving our app away from accessing business controllers directly and instead use the APIs in the Babylon SDK.

More background information about what `MainUserSession` is and what we would like it to become can be found in this [deck](https://drive.google.com/drive/u/0/folders/1PVm5ztVYGpOdqLZxTmIl2BXff8ux8MnK), it is a Keynote presentation so you need download and unzip it.

Proposed refactoring is to change AppMainUserSession from being a singular to a composite entity. It will still comply with the current set of protocols, but implement them by forwarding to the relevant component. This can, hopefully, be done in a step by step manner to avoid a high risk gargantuan pull request.

# Step One, Move to the Babylon Main Project.

Both the SessionViewModel, MainUserSession and AppMainUserSession are specific to the Babylon app targets and not needed to implement the SDK. They should thus be moved out of BabylonCore. To move them to the Octopus folder in the main project seems logical, but BabylonDependencies is also technically possible. Moving them to the main project will require minor refactoring to a couple of UI builders that consume MainUserSession directly.

# Step Two, Add an `AuthenticatedContext` Instance.

Serving an `AuthenticatedContext` through the `MainUserSession` interface will allow builders to create instances of all SDK APIs. It should be noted that all our SDK APIs are very lightweight both in terms of memory consumption and time to create. There is thus no need to serve them centrally.

Methods in `MainUserSession` that implement requirements for `AuthenticatedAccessible` will be change to route through the `AuthenticatedContext`.

The `AuthenticatedContext` can be created by the `SessionViewModel` until sign in, sign up and the app boot strap has been refactored to employ the `Auth` SDK.

# Step Three, Add a `ClinicalRecords` Instance.

Although it is technically possible to create `ClinicalRecords` instances on demand this needs be avoided since they hold a stateful authentication for accessing sensitive content. Creating the on demand without sharing the authentication status could result in the user being asked to supply their password or finger-print several times in the same app session.

Services for accessing family accounts, biometric authentication and perform extra authentication provided by `MainUserSession` should be routed through the `ClinicalRecords` instance. This is unlikely to be one to one match so will involve adapting builders and view models that deal with sensitive data.

# Further Steps.

Replace business controllers for the current user, id verification status and image handling with their SDK counterparts.

# Please Add Your Thoughts and Suggestions.

Refactoring `MainUserSession` from a monolith to a composite in the way outlined above is a path that I (Martin Nygren) believes takes us where we want to be in steps that are small enough to be feasible. It is, of course, not the only possibility. Please add any suggestions or insights that you have to this document. 
