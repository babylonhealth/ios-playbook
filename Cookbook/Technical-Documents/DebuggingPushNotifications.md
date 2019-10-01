# Debugging Push Notifications

To sucessfully debug Push Notification on your device make sure that you have proper configurations set up as described in this document.

- [TLDR](#tldr)
- [PubNub](#pubnub)
- [Key sets](#key-sets)
- [APNS certificates and environments](#apns-certificates-and-environments)

## PubNub

[Pub Nub](https://admin.pubnub.com/) is a service we use to deliver notifications to APNS (Apple Push Notifications Service) or FCM (Firebase Cloud Messaging). If you don't have access to Pub Nub yet ask other members of the team to add your work email to our account.

Each application that supports push notifications has a separate configuration on PubNub. Depending on your access level you may have access to all the apps (admin) or to specific apps. All the apps are grouped under `steven.hamblin` account.

## Key Sets

Each of the apps configurations contains multiple `key set`s for each of our backend environments, i.e. `dev` is a key set used on our dev environment, and so on. These key sets contain some private API keys that our notifications service uses to communicate with Pub Nub API and they are different for each environment. Each key set defines configuration for Pub Nub feautures, including push notifications. They contain FCM key (for Android, so ignore it) and push notifications certificate and APNS environment.

## APNS certificates and environments

For PubNub to be able to deliver notifications to APNS correct and valid (not expired) certificate needs to be added to each key set. For all of our non-production environments we use enterprise certificates. For production environment we use AppStore certificates as that's the only environment that can be used in AppStore builds and we don't run any enterprise (Hockeyapp) builds against production environment.

For iOS apps we have separate key sets for push and VoIP notifications because PubNub doesn't support using single certificate for both types of notifications (as of Sept 2019). Key sets for push notifications are prefixed with `ios-push` and are associated with regular push notifications certificate instead of VoIP certificate. All the ceritificates for all the apps can be found in 1Password iOS vault.

Apart from certificate we need to set `APNS Environment` in each key set. This is not related to _our_ environments (dev, preprod or prod) but as the name of this setting suggests to APNS itself. It is possible to set this to Development or Production. Production environment is used to deliver notifications to the apps distributed through Hockeyapp, Testflight or AppStore. Development environment is used to send notifications to the apps deployed to device locally with Xcode.

Example 1: to test notifications locally on pre-prod environment APNS environment for `preprod` and `preprod-ios-push` key sets should be set to `Development`
Example 2: to test notifications on Hockeyapp build on pre-prod environment APNS environment for `preprod` and `preprod-ios-push` key sets should be set to `Production`

## TLDR
When you are testing push notifications make sure that:

- The app is running against expected backend environment
- PubNub configuration for this environment set to correct APNS Environment
	- open the key set for this environment
	- tap on "Replace  Certificate" button
	- find the correct certificate PEM file in 1Password iOS vault and upload it
		- for non-production environment use Enterprise certificate
		- for production environment only use AppStore certificate (or simply just never change production key set)
	- select proper APNS environment:
		- for local builds (built from Xcode) select Development environment
		- for Hockeyapp builds select Production environment
- make sure you notify in ios slack channel that you are changing PubNub environment
- REMEMBER to change APNS environment back to production when you are done and notify ios slack channel. This is so that testers can continue testing notifications on AppCentre builds.
- you are on Babylon-Partners WiFi network (if you are in the West Office)
