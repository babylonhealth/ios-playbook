# Enable multiline rules in SwiftLint

* Author(s): Adam Borek
* Review Manager: Diego Petrucci

## Introduction
The motivation to create this proposal is to not waste time fixing violations of a SwfitLint rule which we maybe wouldn't like to have, considering all pros & cons.

## Motivation
In our [StyleGuide](https://github.com/Babylonpartners/ios-playbook/tree/master/Cookbook/Style-guide#function-declarations) we have a section about multiline arguments & parameters. Multiline function declaration or function calls should have their brackets in separate lines. To reduce our time spent on fixing such nits we can use SwiftLint to warns us about such issues.

## Proposed solution
Turn on the following SwiftLint rules:
```
- multiline_arguments
- multiline_arguments_brackets
- multiline_parameters
- multiline_parameters_brackets
```
The documentation of these rules, with examples, can be found [here](https://github.com/realm/SwiftLint/blob/master/Rules.md#multiline-arguments).

## Impact on existing codebase
After adding these rules to our codebase, Xcode reports about 2500+ violations. That would need to be solved before merging to develop. More than the half of the work can be automated by using SwiftFormat to automatically format files. After running [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) there are around ~900 issues to be fixed manually.

In my opinion the impact on the codebase will be very positive, however it will also add few changes which are not defined in our style guide. I think it's acceptable price to make it possible to resolve nits quicker which would decrease a time when a PR is open.

However, the given set of rules goes a step further. `multiline_arguments_brackets` rule makes it possible achieve what we want — which is, having a trailing bracket at a function call in the new line. However, this rule **always** requires to put the trailing bracket `)` in a newline if the function takes more than just one line to be invoked. Even if it's only one argument. What I mean by that is explained below.

The following example is the style we want to have based on the StyleGuide:
```swift
func reticulateSplines(
  spline: [Double],
  adjustmentFactor: Double,
  translateConstant: Int,
  comment: String
) -> Bool {
  // reticulate code goes here
}

let success = reticulateSplines(
  spline: splines,
  adjustmentFactor: 1.3,
  translateConstant: 2,
  comment: "normalize the display"
)
```
This is all about having parameters/arguments in separate lines when we define/call multiple parameters/arguments functions.

This time, the following examples show what else triggers the rule and how this can be fixed. Keep in mind that this is a list of changes which are not defined in the `Function Definition` or `Function Call` sections of the [StyleGuide](https://github.com/Babylonpartners/ios-playbook/tree/master/Cookbook/Style-guide#function-declarations), and so the style guide will need to be updated accordingly. I would say sometimes the code before a fix is more readable than after SwiftLint's fix.

 1. **Trailing closure argument**:
```swift
AppsFlyerTracker.shared()?.continue(userActivity, restorationHandler: { restoring in
        restorationHandler(restoring?.compactMap({ $0 as? UIUserActivityRestoring }))
})
```
The fix:
```swift
AppsFlyerTracker.shared()?.continue(
    userActivity,
    restorationHandler: { restoring in
        restorationHandler(restoring?.compactMap({ $0 as? UIUserActivityRestoring }))
    }
)
```

 2. **Inlined array argument**:
```swift
NSLayoutConstraint.activate([
    imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -viewModel.viewSpec.secondaryLogoDistanceFromBottom),
    imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
])
```
The fix:
```swift
NSLayoutConstraint.activate(
    [
        imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -viewModel.viewSpec.secondaryLogoDistanceFromBottom),
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ]
)
```
or:
```swift
NSLayoutConstraint.activate(
    [imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -viewModel.viewSpec.secondaryLogoDistanceFromBottom),
     imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
)
```

 3. **Multiline inner argument**:
```swift
return accessible.access(InsuranceDetailsService.saveInsuranceDetails(
    membershipId: membershipId,
    selectedProvider: selectedProvider,
    patientId: patientId
))
```
The fix:
```swift
return accessible.access(
    InsuranceDetailsService.saveInsuranceDetails(
        membershipId: membershipId,
        selectedProvider: selectedProvider,
        patientId: patientId
    )
)
```

More examples of changes that would need to be added can be found in [the sample PR](https://github.com/Babylonpartners/babylon-ios/pull/7246/files) I've created against develop. It's not ready to be merged. It's a result of running [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) & couple of manual changes.

## The question to be asked when reviewing this proposal
Is it worth to have an automatic function parameters/arguments nits checking for the price of few additional changes in our style? 
 
## Alternatives considered

There are few alternatives:

- Drop the one of those four rules — the `multiline_arguments_brackets`. However, doing so will allow to have such a function call, which is against our style guide:
```swift
makeAutoFillFormAction(with: formProperties,
    genders: genders,
    continueAction: continueAction)
```

- Write a custom rule to swiftlint which would satisfy our needs. We could consider creating a PR to the SwiftLint repo. This however will be more time consuming to do.
