# Feature Switches

This document describes the process that should be followed when defining Features Switches.

New features should follow this approach. If you are working on the existing feature that was not yet refactored to this approach please refer to [previous version of this guide](https://github.com/babylonhealth/ios-playbook/blob/d53a63193dffa9cc613a6810b135b87d67189729/Cookbook/Technical-Documents/FeatureSwitches.md).

Depending on the use case we are using different ways to define Feature Switches in our code base. A feature switch is not always some `Bool` value that can be either `true` or `false` (though most of the times it will be), it can be a more complicated type that defines a conditional behaviour.

# Feature Modules

Each module (i.e. Appointments, ChatBot, Healthcheck) should have a "point of configuraiton" (we will further call it Feature Module) that will be used to initialise this module on application startup with values specific to the applicaiton flavour. This configuration should define "static" configurations which is anything that is hardcoded in the app, and all the feature switches used by this module. Each configuration point should follow a common pattern, i.e. here it is for MapsUI framework:

```swift
extension World {
    private static var maps: MapsUI!

    public func configureMaps(
        config: MapsUI.Configuration
    ) {
        World.maps = MapsUI(config: config)
    }

    public var maps: MapsUI { Self.maps }

    public struct MapsUI: FeatureModule {
        public let featureSwitches: FeatureSwitches = FeatureSwitches()
        public let config: Configuration

        public struct FeatureSwitches {
            public enum Keys: String {
	             // keys for feature switches will go here
            }

            // feature switches declaration will go here
        }

        public struct Configuration {
            // configuraiton propertis will go here

            public init(...) {
                ...
            }
        }
    }
}
```

Then this configuration point is used in the `AppDelegate`:

```swift
extension SharedAppDelegate {
    static func configureFeatures() {
        Current.configureMaps(config: .init()) // configure maps with default values
        // configuration for other features
    }
}
```

All static configuration properties and feature switches should be declared in this way in each vertical separately.

- ### Local feature switches

	These feature switches are defined in an appropriate Feature Module and are stored in `UserDefaults`. **These feature switches are supposed to be used only during the development of any new feature so that the code for the feature can be integrated into the `develop` branch continuously.** As they are stored in `UserDefaults` they can be overridden during testing with Settings app. To add a new local feature switch do the following:

	1. Declare feature switch in `FeatureSwitches` struct:
	
	```swift
	public struct MapsUI: FeatureModule {
	    ...
	    public struct FeatureSwitches {
	        public enum Keys: String {
		    case isMyFeatureEnabled
		}
		
		@LocalFeatureSwitch(key: Keys.isMyFeatureEnabled)
		var isMyFeatureEnabled: Bool
	    }
	}
	```
	
	2. Add a new entry in the `Root.plist` for a toggle for this feature. The key name should be the same as the raw value of the case in `SettingsKeys` added before. The entry should be added after the `PSGroupSpecifier` item named `✨ Local Feature Switches ✨` and before `✨ Remote Feature Switches ✨` (this will visually group it with other local feature switches in the Settings app)

		1. if the feature is related to the Babylon app only it is enough to add the entry to the plist located at `Babylon/Brand/babylon/Settings.bundle`
		2. if the feature is related to all our apps then the same entry should be added to the plist located at `Babylon/Supporting Files/Settings.bundle` (this bundle is shared by other apps targets)
	
	```xml
	<dict>
		<key>Type</key>
		<string>PSToggleSwitchSpecifier</string>
		<key>Title</key>
		<string>New Feature</string>
		<key>Key</key>
		<string>isNewFeatureEnabled</string>
		<key>DefaultValue</key>
		<false/>
	</dict>
	```
	
	**Note that default values are always `false`!** but you can specify a different default value, i.e. `@LocalFeatureSwitch(key: Keys.isMyFeatureEnabled, defaultValue: true)`
	
	You can then refer this property as `Current.maps.isMyFeatureEnabled`

- ### Static configuration

	Static configuration exists to specify application specific configurations, i.e. if a feature should be enabled or completely disabled for a specific app or if it should use a different content. To define a new static configuration you should add a new property to the `Configuration` struct in the appropriated Feature Module. If the flag is related to a specific feature then it might be better to define it in the dedicated configuration struct/protocol, i.e. if the flag is related to `Appointments` we have `AppointmentsContentProtocol` for this purpose.
	
	```swift
	public struct MapsUI: FeatureModule {
	    ...
	    public struct Configuration {
	        let myConfiguration: Bool
		
		public init(myConfiguration: Bool) {
		    self.myConfiguration = myConfiguration
		}
	    }
	}
	```
	
	You can then refer this property as `Current.maps.myConfiguration`.
	
	A difference with other Feature Switches is that static configuration is used when we know that the configuration is specific to a specific _app_ (not the locale, not the user's region or their consumer network) and other apps should have the same feature configured differently, or we know that these configurations can be simply hardcoded on the client side. Other Feature Switches are not target specific.

- ### Backend feature switches

	These feature switches are a kind of remote feature switches and are defined on the backend (in Feature Configurator service) and come as a part of patient details and can be accessed as `patient.metadata.featureSwitches`. To add a new feature switch on the client add a new property to `BackendFeatureSwitches` struct in `BackendFeatureSwitches.swift` file and code to decode this property in `Decodable.swift`. Of course it needs to be added on the backend as well, that's something the backend dev from your team should be able to help with.
	
- ### Firebase remote config

	These feature switches are another kind of remote feature switches and use Firebase Remote Config as a backend. To add a new Firebase remote config you need to declare it in the `FeatureSwitches` struct of the appropriate Feature Module, similarly to local feature switches:

	```swift
    public struct MapsUI: FeatureModule {
        ...
        public struct FeatureSwitches {
            public enum Keys: String {
                // value should be the same as one defined in Firebase console
                case isMyFeatureEnabled = "is_my_feature_enabled"
            }

            @ABTestVariant(key: Keys.isMyFeatureEnabled)
            var isMyFeatureEnabled: Bool
        }
	}
	```

	Add default value of this feature to `FirebaseABTestingService.init`:
	
	```swift
	let keysAndNSObjectValues = [
	    ...
	    maps.$isMyFeatureEnabled.keyAndDefault,
	]
	```
	
	You can then refer this property as `Current.maps.isMyFeatureEnabled`.

	**Note that default value is `false` again!** But you can specify a different default value, i.e. `@ABTestVariant(key: Keys.isMyFeatureEnabled, defaultValue: true)`

	**Adding a feature switch to Firebase console**

	You need to add a remote config in the [Firebase console](https://console.firebase.google.com) with the same string key. For that navigate to the `Remote Config` page in the `Grow` section of the side menu and tap "Add parameter".

	![](Assets/adding-remote-config-flag.png)

	To control the value of this feature flag we can define values for different "conditions" which are based on the application bundle id and the build version (not the app semantic version number). You can reuse existing conditions (don't mix them with those used for Android app unless you agree to use the same flag for both platforms) or create a new condition on the `Conditions` page. To create a new condition you need to specify the app bundle identifier and optionally a regular expression for build number (you can use [this tool](http://gamon.webfactional.com/regexnumericrangegenerator/) to create it and [this tool](https://regexr.com) to see if your regular expression works). **Remember to start with local feature switch first when working on a new feature**, read next sections of this article for more details.
	![](Assets/adding-remote-config-condition.png)

	**Also note that condition is using a build number, even though the description mentions the app version. Be careful with these conditions when doing a release not from the head of develop branch (but i.e. doing a hot-fix release from the head of previous release) as the build numbers are constantly incremented with each CI run and don't depend on the app version.**
	
	If you want to release a feature, set proper conditions on Firebase **before the release cut off day**. Remember to adjust automation tests to make them work regardless if it's turned on or off. When publishing changes in Firebase Console you might be prompted if you want to force save your changes (that could happen when two people made some changes at the same time). **Never force save your changes** - if you see the prompt, cancel your changes, refresh the console and apply them again.
	
	After releasing the feature hidden behind the remote feature switch, make some agreement with your PM when we can stop using this switch. Depending on how your squad works, you may want to create a ticket in the backlog to phase out the feature switch and remove legacy code. Remember that even you've phased out the feature switch from the newest version, there are still older versions that could be using this feature switch for a long time. After removing it from code, go to the Firebase Console and update description to say which app versions this switch is affecting.

## How to decide what feature flag to use

- Q: Are you working on a bug fix or a new feature/change in the existing feature?
  A: 
    - It's a bug

       You don't need any kind of feature switch
    - It's a feature

        You may need a feature switch, read on

- Q: Have you just started to work on the feature and it will take time to finish it, probably more than one sprint?
  A: 
    - Yes, it will take some time

       Use a local feature switch
    - No, the feature is small and can be finished in one sprint

       You still may or may not need a feature switch, read on
       
- Q: Is the change related to something critical and we may want to be able to switch it back to previous implementation?
    - Yes

       While still working on the feature, use a local feature switch; when it is ready for release, convert it to Firebase Feature Switch
    - No

       Keep it as a local feature switch if you need one
   
- Q: Does the feature need to behave differently for different apps?
    - Yes

       Use Firebase feature switch with an app bundle id condition. If it's clear that feature will be availbale only for one app and not for others then it can be hardcoded in the AppConfiguration that the switch will be turned off (typically default is `false`) for particular apps. If you don't need a local or Firebase feature switch for the feature then just use AppConfiguration to define feature variants for different apps
    - No, it's the same for all the apps

       Use a local feature switch or Firebase feature switch without app bundle id condition (depending on previous answers)
       
- Q: Does the feature need to behave differently depending on the way user signs up for our services, i.e. through the partnership program or with some code?
    - Yes

       Use backend feature switch, this way it can depend on the user data, i.e. current consumer network.
    - No

       Use a local or Firebase feature switch (depending on previous answers)
       
- Q: Is there A/B test running for this feature/change?
    - Yes

       Use Firebase feature switch
    - No

       Use a local feature switch or app configuration (depending on previous answers)

## Phasing out feature switch

This is yet to be defined.

## Dos and don'ts

### Do

- Start new feature development with a local feature switch. When you are going to release the feature convert it to remote feature switch. This way you don't have to use a regular expression on Firebase (if you use Firebase remote config) all the time, only if you need to change the value of the flag _after_ it was released.
- Try to limit the usage of the feature switch using design patterns like strategy, delegate, facade etc.

### Don't

- Don't change the default value of the flag. We use `false` as default value for all the flags to make their behaviour more predictable and uniform (in opposite to having some flags have it `true` and some have it `false`).
- Don't introduce feature flags that affect each other. Each feature flag increases testing complexity as it introduces new combinations.
- Don't name you feature switch `New XXX`. After couple of month you might end up with `New New XXX`. Try to use specific names when possible.

