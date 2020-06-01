# How to enable Apple Pay

`ENABLE_APPLE_PAY` must be present in `SWIFT_ACTIVE_COMPILATION_CONDITION` build setting in order Apple Pay to be enabled.
Even if `ENABLE_APPLE_PAY` is present if the device is the simulator then Apple Pay will be disabled.

# Apple Pay Testing

Apple Pay can only be tested in a build which is compatible with App Store.
The normal configuration of the project doesn't allow this, unless we use a `Release` build from `TestFlight`.
There is a lane which can configure the project in order to 
- enable all the debugging mechanisms
- make Apple Pay available

Execute `bundle exec fastlane local_adhoc target:Babylon` and the project is now suitable for testing Apple Pay!

There are some user sandbox accounts in `1Password` that are required when using Apple Pay.

### NOTICE
After the execution of `bundle exec fastlane local_adhoc target:Babylon` the project will be modified, these changes must __not__ 
be added under VCS.

### Code signing

Due to the fact that the project configuration changes after running the lane mentioned above, and the team used is not the same one used for regular builds, you may run into problems running the app on your device.

If this is the case, you'll find Xcode throwing an error that mentions that your device is not available for the provisioning profile used. In order to fix this, and since we currently don't have a lane to handle this scenario, you'll have to manually add the device to the developer portal.

Once this has been done, you'll need to regenerate the provisioning profiles. For this, please refer to the [Fastlane Match](./FastlaneMatch.md) document. In case of doubt, make sure to check with other iOS engineers that can provide help with this before running anything that may regenerate a provisioning profile.
