# How to enable Apple Pay

`ENABLE_APPLE_PAY` must be present in `SWIFT_ACTIVE_COMPILATION_CONDITION` build setting in order Apple Pay to be enabled.
Even if `ENABLE_APPLE_PAY` is present if the device is the simulator then Apple Pay will be disabled.

# Apple Pay Testing

Apple Pay can only be tested in a build which is compatible with App Store.
The normal configuration of the project doesn't allow this, unless if we test a `Release` build on `TestFlight`.
There is a lane which can configure the project in order to 
- enable all the debugging mechanisms
- make Apple Pay available

Just execute `bundle exec fastlane setup_babylon_for_apple_pay_testing` and the project now is suitable for testing Apple Pay!

Also there some user sandbox accounts in `1Password`.

### NOTICE
After the execution of `bundle exec fastlane setup_babylon_for_apple_pay_testing` the project will be modified, these changes must __not__ 
be added under VCS.


