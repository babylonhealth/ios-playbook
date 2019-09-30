# Debugging Push Notifications

To sucessfully debug Push Notification on your device make sure that you have proper configurations set up as described in this document.

- [PubNub](#pubnub)
- [TLDR](#tldr)

## PubNub

[Pub Nub](https://admin.pubnub.com/) is a service we use to deliver notifications to APNS (apple Push Notifications Service) or FCM (Firebase Cloud Messaging). If you don't have access to Pub Nub yet ask other members of the team to add your work email to our account.

Each application that supports push notifications has a separate configuration on PubNub. Depending on your access level you may have access to all the apps (admin) or to specific apps. All the apps are grouped under `steven.hamblin` account.

Each of the apps configurations contains multiple `key set`s for each of our backend environments, i.e. `dev` is a key set used on our dev environment, and so on. These key sets contain some private API keys that our notifications service uses to communicate with Pub Nub API and they are different for each environment.

Each key set defines configuration for Pub Nub feautures, including push notifications. They contain FCM key (for Android, so ignore it) and push notifications certificate and APNS environment. For all of our non production environments we use enterprise certificate. For production environment we use AppStore certificate as that's the only environment that can be used in AppStore builds and we don't run any enterprise (Hockeyapp) builds against production environment.

Apart from certificate we need to set `APNS Environment`. This is not related to _our_ environments (dev, preprod or prod) but as the name of this setting says to APNS itself. It is possible to set this to Development or Production. Production environment is used to deliver notifications to the apps distributed through Hockeyapp, Testflight or AppStore. Development environment is used to send notifications to the apps deployed to device locally with Xcode.

For iOS we have separate key sets for push and VoIP notifications because PubNub as of Sept 2019 didn't yet support using single certificate for both types of notifications. Key sets for push notifications are prefixed with `ios-push` and are associated with regular push notifications certificate instead of VoIP certificate. All the ceritificates for all the apps can be found in 1Password iOS vault.

## TLDR
When you are testing push notifications make sure that:

- the app is running against exepcted backend environment
- PubNub configuration for this environment set to Production APNS Environment
	- open the key set for this environment
	- tap on "Replace  Certificate" button
	- find the correct certificate PEM file in 1Password iOS vault and upload it
		- for non production environment use Enterprise certificate
		- for production environment only use AppStore certificate (or simply just never change production key set)
	- select proper APNS environment:
		- for local builds (made from Xcode) select Development environment
		- for Hockeyapp builds select Production environment
- make sure you notify in ios slack channel that you are changing PubNub environment
- remember to change this configuration back when you are done and notificy ios channel
- you are on Babylon-Partners WiFi network (West Office)
