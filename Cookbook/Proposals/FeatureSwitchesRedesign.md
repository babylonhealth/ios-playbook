# Feature switches redesign

* Author(s): Ilya Puchka
* Review Manager: TBD

## Introduction

This proposal aims to define a unified approach to defining and accessing feature switches comming from various sources in our code base.

## Motivation

Even though feature switches in essens is a trivial thing our current apporach to them suffers from multiple issues of difference importance.

### Root plist and default values

Currently we provide a way to override any feature switch through toggles in the Settings system app. For that we need to include `Root.plist` file in the app bundle. Values of these switches are then written to the user defaults which we use as a source of values. But they are written to the user defaults only after they are interacted at least once. That said if overrides are enabled but you never change the value nothing will be written to the user defaults. This is not affected by default value set in the `Root.plist`, it only affects the intial position of the switch. How we solve it now is by reading these default values from plist and storing them in user defaults when application starts before we read these values (see `registerSettingsDefaults` in `Settings.swift`). Not just it is defined on the wrong type (`Settings` type is used to store some local user state data like if they completed some onboarding, not feature switches and this is not something that we allow to override with `Root.plist` AFAIK), but also this way changing default value in the `Root.plist` will affect all our targets as they all share this file, which makes us to create a second file just for our primary target. This makes it very confusing for developers to understand what they need to do to enable their feature for release so that it does not affect other targets if that's the requirement.

Without this syncing we would have to deal with optionals for all the switches, probably falling back to their defaults, defined in code. That also highlights another issue with `Root.plist`, that we need to repeat default value in the code and in the plist and make sure they allign to avoid confusion.

Another issue caused by using `Root.plist` and overrides in this way is when we move from Local feature switch used during development to Remote feature switch used on a final stage of the feautre rollout we have to remember to move the plist entry for this switch from one section to another. Otherwise there will be no way to override it during testing.

Having a wrong key name in the plist is also the issue that is very easy to miss.


### Firebase switches semantics

ATM we use Firebase Remote Config and A/B Tests features at the same time. While indeed for the client it does not matter if the value of a switch is set as a result of a running A/B test or is simply a remote config flag (in fact Firebase A/B Tests are built on top of Remote Config) there are situations when understanding the difference between flags being used for A/B tests or not when reading code instead of consulting with Firebase console is helpful. Right now all our Firebase switches are expressed as A/B test variants though. That created a lot of confusion when we had to consolidate and remove few feature switches related to the NVL and had to figure out if any of them are actually running A/B tests (as the names were not very helpful to identify if some configs were related to NVL or something else on the screens affected by NVL).


### Point of access

There is no single way of accessing feature switches in code. Local feature switches are defined in one place, Firebase feature switches are defined in another place, we also have static app configurations and consumer network feature switches (in patient details). It does not create a lot of friction but can be cumbersome to replace local feature switch with remote when feature is due to release.
At the same time all these places (local/Firebase feature switches, app configuration) became a dumping ground for the switchies for various features of the app, even when they have their own modules. And its not uncommon to have conflicts between PRs which both introduce Firebase feature switches for different issues.

### App configuration boilerplate

We use app configuration type (and types related to it) to define "static" feature switches things that are hardcoded in the app and are cuased by different requirements for the products. I.e. one app can define that it should use a new feature flow while another does not use it.

This brings more clarity in what values are defined for what apps, we don't have to consult Firebase config and we don't risk accidently changing the value. We also don't need to wait for firebase config to be fetched and don't risk not having a right value when Firebase fails. 

At the same time it makes us to repeat all the configurations in each target which is a lot of boilerplate for a simple flag and these configs grew a lot over time. Or we have to use protocol extensions with default values which makes it trickier to understand the actual value for particular target as we need to make sure this default is not overriden anywhere else.

### Local Feature Switches boilerplate

It takes a lot of boilerplate to define a local feature switch - we need to change the code in several places (in one file though), need to manually add an entry to the `Root.plist` and make sure that it's in the right place and in the write file. We need to make sure we move it to the different section (for remote feature toggles) if we move the flag to the Firebase, otherwise we won't be able to override it in the Settings app and it will always have a default value if we override any other flag.


### Debugging

It's not clear what feature switches affect what screens. It's somtimes frustrating to go through a complex flow and then realise that the right feature switch was not turned on/off in the Settings app or local overrides were active and to go through the flow again (as we don't observe changes in the feature switches at runtime and require application to restart).


## Proposed solution

To address these issues we suggest the following changes in our feature switches architecture:
	
1. Feature toggles and static configurations related to the particular feature should be defined in this feature module instead of shared module or in the app. This follows interface segregation principle and goes along with improving modularisation - one won't need to change common module with feature switches and recompile all of it (and potentially everything else) when they only need to recompile module that uses this feature switch. This way we also configure our frameworks the same way as we configure any other 3rd party framework and can use the similar infrastrauctore for that (i.e. dedicated instances responsibule for configuring each feature rather than doing that all in the app delegate).

2. Replace `AppConfigurationProtocol` and all related protocols with structs. This will decrease amount of boilerplate we have to write when adding new application configuration. Application configuration will be only concerned with application level configurations which are not directly related to any feature module.

3. All feature switches access points should be moved to the `Current` and consequentially should be only used by builders - view models, flow controllers and renderers should have them injected through their constructors.

4. Root.plist should be generated based on the code that declares feature switches.

	
	
## Detailed design
	
### Module specific feature switches

Each type of feature switch will be implemented with it's own type to make its semantics clear. We will need `LocalFeatureSwitch` and `RemoteFeatureSwitch` types. When later we introduce a new produt configurator service we defined new type `ProductFeatureSwitch`. They all will have a common `value` property and each provider will have a `get(valueForKey: String)` method and should store their properties in a dictionary.

```swift
// In BabylonDependencies

public struct RemoteFeatureSwitch<T> {
	let provider = Current.abTestingService
	var value: T {
		return provider.get(valueForKey: self.key)
	}
  	// Name to be used to generate entries for Root.plist using SwiftSyntax
	let name: String
	// key to query the value from provider and key for UserDefaults
	let key: String
}

public struct LocalFeatureSwitch<T> {
	let provider = Current.userDefaults
	var value: T { ... }
	let name: String
	let key: String
}

public struct ProductFeatureSwitch<T> {
	let provider = Current.productConfigurator
	var value: T { ... }
	let name: String
	let key: String
}
```


Using dedicated switch types we will be also able to explicitly specify what remote feature switches are A/B tested and which not:

```swift
typealias ABTest = RemoteFeatureSwitch
```

Remote Feature Switches we fetch from Firebase all together and under the hood they are just abstract key-value pairs. So to access them in a module the module should be initialised with this abstract collection of key-value pairs (or access it via `Current` as in examples) so that it can get from it values it cares about and store them for later use.

These feature switches should be separate from static configuration (implemented ATM via `AppConfiguration`) but both should be defined and stored inside the module. This way we break up the monolythic `AppConfiguration` and allow static configuration be configured separately from dynamic feature switches which get their values at runtime.
	
With patient details situation is a bit different because this data is associated with a `PatientDTO`. We can refactor it so that `PatientDTO` stores abstract key-value pairs and pass it to the frameworks after patient details are retrieved similarly with Firebase remote config (or similarly access it via `Current` when these patient details will be moved there). But we suggest to address this type of feature switches separately as this work depends on other work related to how the app works with patient details. In future these feature switches can become just a new type of switch like `PatientFeatureSwitch` which will use `Current.patient.details` as their provider.
	
Inside the module we can extend `World` with a module specific namespace and keep its feature switches and configurations separate from the rest of `World` properties.

```swift
// In the feature framework
extension Current {
	private static private(set) var someFeature: SomeFeatureModule!
	
	// way for the app to set static configurations for the feature
	public func configureSomeFeature(
		config: SomeFeatureModule.Configuration
	) {
		World.someFeature = SomeFeatureModel(config: config)
	}
	
	public var someFeature: FeatureModule {
		return World.someFeature
	}
	
	public struct SomeFeatureModule {
	   
		public let featureSwitches: FeatureSwitches
	
		// dynamic feature switches
		public struct FeatureSwitches {
			public let isNewFeatureEnabled = RemoteFeatureSwitch<Bool>(
				name: “New feature”,
				key: “is_new_feature_enabled”
			)
			public let inProgressFeatureEnabled = LocalFeatureSwitch<Bool>(
				name: “Another feature”,
				key: “is_another_feature_enabled”
			)
		}
		
		// static configurations
		public let config: Configuration
		
		public struct Configuration {
			public let someAppSpecificConfiguration: Bool // can have a default value
		}
	}
}
```

This way feature switches will be accessed in the feature builders via `Current.someFeature.featureSwitches` or `Current.someFeature.config`.

If the type of the switch changes (i.e. from local to remote switch) we change it in a single place where it is defined rather in every place where it is used. To abstract away difference between static configuration and dynamic switches we can use a key-path based getters or subscripts:

```swift
extension World.SomeFeatureModule {
	public func get<T>(_ keyPath: KeyPath<RemoteFeatureSwitch<T>, World.SomeFeatureModule.FeatureSwitches>) -> T {
	    return featureSwitches.keyPath[keyPath].value
	}
	
	public func get<T>(_ keyPath: KeyPath<T, World.SomeFeatureModule.Configuration>) -> T {
	    return config.keyPath[keyPath]
	}	
}
```

With Swift 5.1 we can improve this a bit with property wrappers which will allow us to use `isNewFeatureEnabled` directly rather than with `isNewFeatureEnabled.value`:

```swift
@RemoteFeatureSwitch(
	name: “New feature”,
	key: “is_new_feature_enabled”
)
var isNewFeatureEnabled: Bool
```

Also we will be able to use `dynamicMemberLookup` with keypaths instead of custom getters or subscripts so that we wil be able to access dynamic feature switches or static configuration as `Current.someFeature.isNewFeatureEnabled` instead of `Current.someFeatures.get(\.isNewFeatureEnabled)`
	
### "Сoncretize" app configurations

We already moved `AppConfigurationProtocol` to `BabylonDependencies` so that the instance of app configuration is a part of `Current`. But that does not solve all the issues with amount of boilerplate we have to write to add a new configuration and discoverability of values.
	
To solve these issues we propose to replace `protocol AppConfigurationProtocol` with concrete `struct AppConfiguration` defined in `BabylonDependencies` and initialise it with application specific values in a target specific code. This will reduce amount of boilerplate to write, but will still require us to change code multiple times in each target when something changes in this struct. I.e. when we add a new feature switch to `AppConfiguration` we will need to add it to the paramters that we pass to it's initializer in each target. We can use default values where possible to avoid that. For that we should agree that default values are always `false` so that we can definetely know what is the value if it is not passed to the constructor. Protocol and default protocol implementations achive the same result but with much more boilerplate (remember point-free issue about using value types instead of protocols)
	
All feature specific configuration should be moved to the corresponding feature frameworks and should use concrete structs instead of protocols that then `AppConfiguration` extends. `AppConfiguration` should only be concerned with application level configurations (i.e. enabled tabs or privacy notices urls).

3. All feature switches access points should be moved to the `Current` and consequentially should be only used in builders - view models, flow controllers and renderers should have them injected through their constructors. Currently we only have `Current.abTestingService` but we have global `LocalFeatureSwitches`

4. Root.plist should be generated based on the code that declared feature switches.

For that we can use SwiftSyntax to analyze the content of the files which define feature switches (based on the file naming convetion) and generate entry in the plist for each of them. This way we don't have to deal with plist manually and have a single source of thruth for defining feature switches. The plist will be ignored by git and will be generated as part of build step only in DEBUG configuration, so we don't have to strip it from release builds.


## Impact on existing codebase

Currently used types for feature switches should be deprecated and either replaced with a new approach in one go or gradually. We can keep `ABTestingService` related types but repurpose them to serve as providers of the feature switches rather than 

## Alternatives considered

- Keep all the feature switches in one place in the `BabylonDependencies`. The main downside of this approach if that it goes against modularity - we will need to change flags in the `BabylonDependencies` and rebuild it instead of changing it just in the feature framework and rebuilding only it. It can also trigger rebuild of all other frameworks depending on the `BabylonDependencies` as we know how Xcode incremental builds are unrelyiable.

- Provider can be a parameter of generic `FeatureSwitch` type instad of having separate types for each provider:

```swift
let isNewFeatureEnabled = FeatureSwitch(
	name: “New feature”,
	key: “is_new_feature_enabled”,
	provider: Current.abTestingService,
)
```

With that we loose the ability to explisitly specify flags for A/B tests.

