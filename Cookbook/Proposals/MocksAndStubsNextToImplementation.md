# Put Mocks, Stubs Next to Implementation

* Author(s): Sergey Shulga
* Review Manager: TBD

## Introduction

Put implementationf of mocks next to the implementation of the protocol

## Motivation


- Improves Desccoverability of mocks
- Prevents mocks duplication (Because we usually define mocks in the `FrameworkTests` target which means they can only be used there)
- Easy to change mock implementation once public API changes


## Proposed solution


```swift
public protocol BiometricAuthControllerProtocol {
    var isRegistered: Bool { get }
    var supportedBiometry: BiometryType { get }
    var biometricDataHasChanged: Bool { get }
    
    func register() -> SignalProducer<Never, BiometricAuthError>
    func unregister() -> SignalProducer<Never, BiometricAuthError>
    func signedNonce() -> SignalProducer<Data, BiometricAuthError>
}

public final class BiometricAuthController: BiometricAuthControllerProtocol {
// Implementation
}

#if DEBUG

public final class MockBiometricAuthController: BiometricAuthControllerProtocol {
// Implementation
}

#endif

```

## Impact on existing codebase

This proposal does not break anything, allows gradual migration.

## Alternatives considered

Leave as it is

