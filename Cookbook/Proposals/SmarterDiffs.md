# Improving view models' unit tests

* Author(s): Ilya Puchka
* Review Manager: TBD

## Introduction

Our current approach to testing view models is described in [this doc](Cookbook/Technical-Documents/UnitTestingViewModels.md). This approach enforces the tests to follow "arrange-act-assert" pattern. If we forget about ergonomics of closures it works pretty well. But when it comes to assert section we have few options in how it can be implemented each with their own issues.

#### Option 1 - assert states one by one

Example:

```swift
assert: { states in
    expect(states.first?.lastName).to(beNil())
    expect(states.last?.lastName).to(equal("Snow"))
}
```

This approach works fine and makes the test expectations very explicit. But it becomes overly verbose when we have to assert a lot of states one by one. It may be tempting then to make shortcuts like in the example and check for particular elements in the states array and not for all of them which makes such tests incomplete as they will not catch issues when some other state unexpectedly changed or the number of states changed, unless we explicitly test for it. Another possible issue is that if we use index subscript on state array the test run can crash if index goes out of bounds instead of failing assertion and continue running other tests.
At the same time if a single state assert fails it's easier to understand what failed as we are comparing less values at a time.

#### Option 2 - assert all states at once

Example:

```swift
expect(states).to(equal([
    makeState(status: .idle),
    makeState(status: .loading),
    makeState(
        shouldShowNHSBanner: true,
        shouldShowHealthcheckBanner: true,
        shouldShowTestAndKitsBanner: true,
        shouldShowGPAtHandStatusCard: true,
        status: .loaded
    )
]))
```

This eliminates the issue of the first approach when some state changes may be ignored by the test. It comes with a cost of actually creating all the intermediate states that might not be directly related to what test is testing which adds some amount of boilerplate. Another issue is that when this single assert fails it's very hard to extract what actually cuased this failure from the error message until we go and check each states separately. First option also suffers from this issue when each state consists of a lot of properties but it becomes much worse with a single assert.

## Motivation

As demonstrated our current approaches suffer from few issues which result in not ideal developer experience when it comes to debugging test failures.

## Proposed solution

To improve the experience with debugging test failures we propose to use a smarter diffing approach as in [this library](https://github.com/krzysztofzablocki/Difference) by Krzysztof Zabłocki. The idea is that when comparing two instances we will be using `Mirror` type and `dump` function to first get stored properties and then get their textual representation and this way combine a in-memory snapshot of the value. This way we can recursively compare each property and only include those that differ in the final failure message. 

The fact that `Mirror` only provides access to stored properties is not an issue as computed properties are products of stored properties (or in case of enums of the enum cases and thier associated values) and for same stored properties values should return the same result.

Example:

```swift
// equalDiff is a name suggested in the Diffable repo README, we can choose a different one
expect(states).to(equalDiff([
    makeState(status: .idle),
    makeState(status: .loading),
    makeState(
        shouldShowNHSBanner: false, // this value causes failure
        shouldShowHealthcheckBanner: true,
        shouldShowTestAndKitsBanner: true,
        shouldShowGPAtHandStatusCard: true,
        status: .loaded
    )
]))
```

This will result in diff

```
Found difference for child some:
child :
	shouldShowNHSBanner received: "true" expected: "false"
```

instead of

```
expected to equal <[State(firstName: "Brienne", lastName: "Skrilla", shouldShowNHSBanner: false, shouldShowHealthcheckBanner: false, shouldShowTestAndKitsBanner: false, shouldShowGPAtHandStatusCard: false, appointments: [], prescriptions: [], partnerLogoURL: nil, partnerLogoCaption: "", status: Babylon.HomeViewModelV2.Status.idle, isInsuranceValid: true), State(firstName: "Brienne", lastName: "Skrilla", shouldShowNHSBanner: false, shouldShowHealthcheckBanner: false, shouldShowTestAndKitsBanner: false, shouldShowGPAtHandStatusCard: false, appointments: [], prescriptions: [], partnerLogoURL: nil, partnerLogoCaption: "", status: Babylon.HomeViewModelV2.Status.loading, isInsuranceValid: true), State(firstName: "Brienne", lastName: "Skrilla", shouldShowNHSBanner: false, shouldShowHealthcheckBanner: true, shouldShowTestAndKitsBanner: true, shouldShowGPAtHandStatusCard: false, appointments: [], prescriptions: [], partnerLogoURL: nil, partnerLogoCaption: "", status: Babylon.HomeViewModelV2.Status.loaded, isInsuranceValid: true)]>, got <[State(firstName: "Brienne", lastName: "Skrilla", shouldShowNHSBanner: false, shouldShowHealthcheckBanner: false, shouldShowTestAndKitsBanner: false, shouldShowGPAtHandStatusCard: false, appointments: [], prescriptions: [], partnerLogoURL: nil, partnerLogoCaption: "", status: Babylon.HomeViewModelV2.Status.idle, isInsuranceValid: true), State(firstName: "Brienne", lastName: "Skrilla", shouldShowNHSBanner: false, shouldShowHealthcheckBanner: false, shouldShowTestAndKitsBanner: false, shouldShowGPAtHandStatusCard: false, appointments: [], prescriptions: [], partnerLogoURL: nil, partnerLogoCaption: "", status: Babylon.HomeViewModelV2.Status.loading, isInsuranceValid: true), State(firstName: "Brienne", lastName: "Skrilla", shouldShowNHSBanner: true, shouldShowHealthcheckBanner: true, shouldShowTestAndKitsBanner: true, shouldShowGPAtHandStatusCard: false, appointments: [], prescriptions: [], partnerLogoURL: nil, partnerLogoCaption: "", status: Babylon.HomeViewModelV2.Status.loaded, isInsuranceValid: true)]>
```

As can be seen from the diff it does not show in what exact array item the failure happened. This is something that we will need to adjust along with [this issue](https://github.com/krzysztofzablocki/Difference/issues/1). 

Proposed way to integrate this feature is to copy the implementation (with proper author attribution) and adjust it to our needs, optionally we can make pull requests to the original library.

## Impact on existing codebase

This approach can be rolled out gradually and used for new test (Xcode templates will use a new assert) or tests can be refactored in batches by replacing existing assertions with a new assert.

## Alternatives considered

As an alternative we can inforce asserting on individual states insteead of all states which will make diffs less of an issue. But as mentioned before it will not eliminate it.

Another alternative would be to use snapshot testing that we already use for UI tests. It will make our assert just a call to a single `assertSnapshot` function. But at the same time it will mean that all the snapshots will be writtent into the files rather than explicitly stated in the test code. This will decrease the boilerplate we will have to write in tests manually but will make it harder to understand test expectations as as we will need to search through text files to find values we need.
