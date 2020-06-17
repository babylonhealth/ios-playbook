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
        featureSwitches: MapsUI.FeatureSwitches = .init(withDefaultOverrides: nil),
        config: MapsUI.Configuration
    ) {
        World.maps = MapsUI(config: config)
    }

    public var maps: MapsUI { Self.maps }

    public struct MapsUI: FeatureModule: WithDebugDefaults {
        public let featureSwitches: FeatureSwitches
        public let config: Configuration

        public struct FeatureSwitches {
            public enum Keys: String {
	        // keys for feature switches will go here
            }

            // feature switches declaration will go here
            
            public init() {}
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

	These feature switches are defined in an appropriate Feature Module and are stored in `UserDefaults`. **These feature switches are supposed to be used only during the development of any new feature so that the code for the feature can be integrated into the `develop` branch continuously.** When feature is realeased the flag should be either moved to the static configuration or to remote configuration.
	
	To add a new local feature switch declare feature switch in `FeatureSwitches` struct:
	
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
	
	**Note that default values are always `false`!** but you can specify a different default value, i.e. `@LocalFeatureSwitch(key: Keys.isMyFeatureEnabled, defaultValue: true)`
	
	You can then refer this property as `Current.maps.isMyFeatureEnabled`

- ### Static configuration

	Static configuration exists to specify application specific configurations, i.e. if a feature should be enabled or completely disabled for a specific app or if it should use a different content.
	
	To define a new static configuration you should add a new property to the `Configuration` struct in the appropriated Feature Module. If the flag is related to a specific feature then it might be better to define it in the dedicated configuration struct, i.e. if the flag is related to `Appointments` we have `AppointmentContent` for this purpose.
	
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
	
	A difference with other Feature Switches is that static configuration is used when we know that the configuration is specific to a specific _app_ (not the locale, not the user's region or their consumer network) and other apps should have the same feature configured differently, or we know that these configurations can be simply hardcoded on the client side. Also unlike local or remote feature switches these values can't be changed at runtime.

- ### Backend (product config/consumer network) feature switches

	_Product config_ is a new preferred way of managing such feature switches and it's preferable to use it for any new feature switch that defines features per product/partner. It also aims to replace static configurations and Optimizely (except for its usage for A/B tests and feature experiments) as it can target different applications. 
	
	To add a new product config feature switch use a `ProductConfigFeatureSwitch` property wrapper instead of `RemoteFeatureSwitch` (as demonstrated later).
	
	Read more about how to define product config flags [here](https://github.com/babylonhealth/manifests/tree/master/product-config#what-is-product-config)
	
	Consumer network feature switches are a kind of remote feature switches and are defined on the backend (in Feature Configurator service) and come as a part of patient details and can be accessed as `patient.metadata.featureSwitches`. Typically such feature swithces depend on some user data, i.e. region or consumer network.
		
	To add a new feature switch on the client add a new property to `BackendFeatureSwitches` struct in `BackendFeatureSwitches.swift` file and necessary code to decode this property in `Decodable.swift`. Of course it needs to be added on the backend as well, that's something the backend dev from your team should be able to help with.
	
	### Product Config and Consumer Networks
	
	Product config does not have a notion of preffered consumer networt which is one that user have currently selected through the app. That's why selecting different consumer network does not affect product config. On the other hand joining a consumer network, i.e. by adding a membership code, is translated to adding patient to a specific contract/partner/plan and so patient can be assigned multiple contracts/partners/plans by using multiple membership codes. That said as soon as patient adds the code they will have the features available to them that are targeted to the contract/partner/plan corresponding to this code. It is possible to target product config values to specific contracts/partners/plans and exclude other contract/partners/plans as well as resolve conflicting settings. To know more about how product config values are computed read [this doc](https://github.com/babylonhealth/manifests/tree/master/product-config#how-is-config-computed).

- ### Remote config (A/B test, feature test)

	These feature switches are another kind of remote feature switches and uses a cloud service (such as Optimizely or previously Firebase) as a backend. To add a new remote config you need to declare it in the `FeatureSwitches` struct of the appropriate Feature Module, similarly to local feature switches:

    ```swift
    public struct MapsUI: FeatureModule {
        ...
        public struct FeatureSwitches: WithDebugDefaults {
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
        public struct FeatureSwitches: WithDebugDefaults {
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
	
## Overriding default values

Sometimes it's needed to provide different default values for feature switches in different flavours. Typically for remote feature switches we only do that for debug builds. In debug builds these values will override actual values from product config or Optimizely. This way we can test features easir during development as we don't have to go to debug window every time to change the value.

For local feature switches we do that when we want an ability to change the value in runtime with a debug window but we wont to enforce a different value for the application like we would with a static configuraiton. Typically local feature switches shouldn't be long lived and should be replaced with a static configuration or product config feature switch but sometimes it's valuable to be able to change them while using the app without rebuilding it.

To change the default values of feature switches you should initialise feature switches in the corresponding targets AppDelegate. Note that default values of remote feature switches are only mutable in DEBUG configuration (this is enforced by compiler) but local feature switches should be changed for all configuration to take effect in production app as well.

```swift
Current.configureAppointments(
    featureSwitches: .init {
        #if DEBUG
        $0.$someRemoteFeatureSwitch.defaultValue = true
        #endif
        
        $0.$someLocalFeatureSwitch.defaultValue = true
    },
    config: .init(appointmentContent: .babylon)
)

```

## Debugging feature switches

Feature switches (remote & local) can be inspected in the application debug window. You can see the remote value (if applicable) and the current value and override individual feature switches or reset them alltogether. ATM it's overrides are only available for boolean or enum values.

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

       While still working on the feature, use a Local feature switch; when it is ready for release, convert it to Remote Feature Switch; when feature is stable consider moving it to Product Config
    - No

       Keep it as a Local feature switch if you need one
   
- Q: Does the feature need to behave differently for different apps?
    - Yes

       Use Product Config. If it's clear that feature will be availbale only for some apps and not for others then it can be defined as a static configuraiton where the switch will be turned off/on (typically default is `false`) for particular apps. If you don't need a Local feature switch or Remote Config for the feature then use Static configuration to define feature variants for different apps
    - No, it's the same for all the apps

       Use a Local feature switch or static configuration (depending on previous answers)
       
- Q: Does the feature need to behave differently depending on the way user signs up for our services, i.e. through the partnership program or with some code?
    - Yes

       Use Product Config, this way it can depend on the user data, i.e. partner id.
    - No

       Use a Local feature switch or static configuration (depending on previous answers)
              
- Q: Is there A/B test or "feature experiment" running for this feature/change?
    - Yes

       Use Remote feature switch
    - No

       Use a Local feature switch or Static configuration (depending on previous answers)

## Phasing out feature switch

This is yet to be defined.

## Dos and don'ts

### Do

- Start new feature development with a local feature switch. When you are going to release the feature convert it to remote feature switch.
- Try to limit the exposure of the feature switch using design patterns like strategy, delegate, facade etc.
- Migrate feature switches from Optimizely to Product Config when they are out of experimentation or active development.

### Don't

- Don't change the default value of the flag. We use `false` as default value for all the flags to make their behaviour more predictable and uniform (in opposite to having some flags have it `true` and some have it `false`).
- Don't introduce feature flags that affect each other. Each feature flag increases testing complexity as it introduces new combinations.
- Don't name you feature switch `New XXX`. After couple of month you might end up with `New New XXX`. Try to use specific names when possible.
