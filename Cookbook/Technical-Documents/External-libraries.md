# External libraries policy


If you are looking to add a new service in our app or adding an external framework to improve our code and tooling, then the procedure below must be followed.
1. [Exploration](#exploration)
1. [Implementation](#implementation)
1. [Release](#release)

## Exploration
Even if the decision of using this framework has been already taken (for example this is a service that must adopted by your squad for all mobile platforms) this step is still mandatory. 

 - Create a spike and build a proof of concept. Some of the things you should achieve during this initial evaluation: 
	 - Learn in detail about the framework features.
	 - Record various metrics about performance, size, build times, etc.
	 - Evaluate the impact on our codebase.
	 - Estimate the work to integrate
 - [Create a proposal](https://github.com/babylonhealth/ios-playbook/blob/master/Cookbook/Technical-Documents/WritingAProposal.md). Beside the spike results the proposal should contain:
	- The reasons behind using this framework
	- Limitations, alternatives considered
	- Rollout plans 
 
## Implementation
During implementation following aspects should be considered:
* Include the framework in the `Podfile`:
	If the framework is shared acrross all targets then use the `shared_pods` section.
	For example AppsFlyer,  Facebook, Mixpannel and Snowplow are included in all targets.

```ruby
def shared_pods
	pod 'FBSDKLoginKit', '~> 5.4.1'
	pod 'Mixpanel-swift', '~> 2.5'
	pod 'AppsFlyerFramework'
	pod 'SnowplowTracker', '~> 1.1'
```

If the framework is specific to particuar apps then add it the relevant targets only.
Below is the example of `Appboy-iOS-SDK` framework included in the Babylon app.
```ruby
	target 'Babylon'  do
		project 'Babylon.xcodeproj'
		shared_pods
		pod 'ZDCChat'
		pod 'SwiftLint'
		pod 'SwiftGen', '~> 6.0'
		pod 'Appboy-iOS-SDK'
	end
```

 - If the framework isn't included in all targets then use `canImport` directive when using the framework features.
Using the same framework as in the example above in the source code we can have: 
 ```swift
 #if  canImport(Appboy_iOS_SDK)
	import Appboy_iOS_SDK
#endif
...
 #if  canImport(Appboy_iOS_SDK)
	if  Current.abTestingService[.isBrazeEnabled] {
		braze = BrazeServiceBuilder.make(
			lifecycleEvents: lifecycleEvents,
			pushEvents: pushNotificationsService.pushEvents
		)
	}
#endif
```
 - Use the framework through an abstraction. If this is not possible then the proposal should mention that.
 ```swift
 protocol  BrazeAPIProtocol {
	func changeUser(_ userID: String)
	func registerDeviceToken(_ deviceToken: Data)
}

extension  Appboy: BrazeAPIProtocol {}
 ```

## Release
- Write an article and add it to our [documentation](https://github.com/babylonhealth/babylon-ios/blob/develop/Documentation/README.md)
- Book a meeting for training or presenting to the team how to use the Framework 
- If this framework is for an external service then:
	- If the service needs a master account that controls the team access then make sure you use the [master login email](https://github.com/babylonhealth/babylon-ios/blob/develop/Documentation/to-use-daily/iOSTeamEmails.md#login-account)
	- make sure that the document contains details on how to create an account and how to get access to the service dashboard for the Babylon associated project. Okta should be considered.
	- Training should contain the usage of the service dashboard
- If the development was behind a feature flag then make sure that is removed and remove the legacy solution if any.