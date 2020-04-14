# Feature Switches

This document describes the process that should be followed when defining Features Switches.

New features should follow this approach. If you are working on the existing feature that was not yet refactored to this approach please refer to [previous version of this guide](https://github.com/babylonhealth/ios-playbook/blob/d53a63193dffa9cc613a6810b135b87d67189729/Cookbook/Technical-Documents/FeatureSwitches.md).

Depending on the use case we are using different ways to define Feature Switches in our code base. A feature switch is not always some `Bool` value that can be either `true` or `false` (though most of the times it will be), it can be a more complicated type that defines a conditional behaviour.

# Feature Modules

Each module (i.e. Appointments, ChatBot, Healthcheck) should have a "point of configuraiton" (we will further call it Feature Module) that will be used to initialise this module on application startup with values specific to the application flavour. This configuration should define "static" configurations which is anything that is hardcoded in the app, and all the feature switches used by this module. Each configuration point should follow a common pattern, i.e. here it is for MapsUI framework:

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
            // configuraiton properties will go here

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

- ### Backend (consumer network/product config) feature switches

	These feature switches are a kind of remote feature switches and are defined on the backend (in Feature Configurator service) and come as a part of patient details and can be accessed as `patient.metadata.featureSwitches`. Typically such feature swithces depend on some user data, i.e. region or consumer network.
	
	To add a new feature switch on the client add a new property to `BackendFeatureSwitches` struct in `BackendFeatureSwitches.swift` file and code to decode this property in `Decodable.swift`. Of course it needs to be added on the backend as well, that's something the backend dev from your team should be able to help with.
	
	_Product config_ is a new preffered way of managing such feature switches and it's preferable to use it for any new feature switch that defines features per product/partner. To use product config service in code you use `Current.productConfig` and define your flags via extensions to `ProductConfig` type:
	
    ```swift
    extension ProductConfig {
        public var myFeature: ProductConfigKeyPath<MyFeautre> {
	    // define key path using a feature key in a product config manifest
            ProductConfigKeyPath(key: "my_feature")
        }

        public struct MyFeature: ProductConfigProperty {
            public static let defaultValue = ProductConfig.MyFeature(
                myFeatureEnabled: false
            )

            public let myFeatureEnabled: Bool

            // typical Decodable implementation, value can be represented as a nested object 
            // or as a single value, then it should be decoded with a `singleValueContainer`
            private enum CodingKeys: String, CodingKey {
                case myFeatureEnabled = "my_feature_enabled"
            }
        }
    }

    // access feature value as a SignalProducer<Bool, Never>
    Current.productConfig.myFeature.map(\.myFeatureEnabled)
    ```
	
- ### Remote config (A/B test, feature test)

	These feature switches are another kind of remote feature switches and uses a cloud service (such as Optimizely or previously Firebase) as a backend. To add a new remote config you need to declare it in the `FeatureSwitches` struct of the appropriate Feature Module, similarly to local feature switches:

    ```swift
    public struct MapsUI: FeatureModule {
        ...
        public struct FeatureSwitches {
            public enum Keys: String {
                // value should be the same as one defined in service console
                case isMyFeatureEnabled = "is_my_feature_enabled"
            }

            @RemoteFeatureSwitch(key: Keys.isMyFeatureEnabled)
            var isMyFeatureEnabled: Bool
        }
    }
    ```

	You can then refer this property as `Current.maps.isMyFeatureEnabled`.

	**Note that default value is `false` again!** But you can specify a different default value, i.e. `@RemoteFeatureSwitch(key: Keys.isMyFeatureEnabled, defaultValue: true)`
	
	After releasing the feature hidden behind the remote feature switch, make some agreement with your PM when we can stop using this switch. Depending on how your squad works, you may want to create a ticket in the backlog to phase out the feature switch and remove legacy code. Remember that even you've phased out the feature switch from the newest version, there are still older versions that could be using this feature switch for a long time.
	
	For A/B tests, there is a dedicated property wrapper `@ABTest` that makes the separation between regular feature switches and A/B tests more explicit. Also, it's only possible to create an A/B test using an enum with string raw value. Other than that, `ABTest` is identical to `RemoteFeatureSwitch` (and actually uses it as a backing storage)
	
    ```swift
    public struct MapsUI: FeatureModule {
        ...
        public struct FeatureSwitches {
            public enum Keys: String {
                case myTest = "my_test"
            }

            enum MyTest: String { case variation1, variation2 }

            @ABTest(key: Keys.myTest, default: .variation1)
            var myTest: MyTest
        }
    }
    ```
	
Read more: [Working with Optimizely](./Optimizely.md). Refer to the documentation for `RemoteFeatureSwitchDecoder` for more examples.

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

       While still working on the feature, use a Local feature switch; when it is ready for release, convert it to Remote Config
    - No

       Keep it as a Local feature switch if you need one
   
- Q: Does the feature need to behave differently for different apps?
    - Yes

       Use Remote Config with an app bundle id condition. If it's clear that feature will be availbale only for one app and not for others then it can be hardcoded in the AppConfiguration that the switch will be turned off (typically default is `false`) for particular apps. If you don't need a Local feature switch or Remote Config for the feature then use Static configuration to define feature variants for different apps
    - No, it's the same for all the apps

       Use a Local feature switch or Firebase feature switch without app bundle id condition (depending on previous answers)
       
- Q: Does the feature need to behave differently depending on the way user signs up for our services, i.e. through the partnership program or with some code?
    - Yes

       Use Backend feature switch, this way it can depend on the user data, i.e. current consumer network.
    - No

       Use a local or Firebase feature switch (depending on previous answers)
       
- Q: Is there A/B test running for this feature/change?
    - Yes

       Use Remote config
    - No

       Use a Local feature switch or Static configuration (depending on previous answers)

## Phasing out feature switch

This is yet to be defined.

## Dos and don'ts

### Do

- Start new feature development with a local feature switch. When you are going to release the feature convert it to remote feature switch.
- Try to limit the exposure of the feature switch using design patterns like strategy, delegate, facade etc.

### Don't

- Don't change the default value of the flag. We use `false` as default value for all the flags to make their behaviour more predictable and uniform (in opposite to having some flags have it `true` and some have it `false`).
- Don't introduce feature flags that affect each other. Each feature flag increases testing complexity as it introduces new combinations.
- Don't name you feature switch `New XXX`. After couple of month you might end up with `New New XXX`. Try to use specific names when possible.
