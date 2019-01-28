# Unified Definition for Screen Names

* Author(s): Martin Nygren
* Review Manager: Sergey Shulga

## Introduction

There is ongoing work to improve our product analytics, both in terms of the technology stack and data coverage. We have an upcoming requirement to post a screen view event every time a new screen is shown. This splits naturally into two parts

1. Defining screen names.
2. Observing that the current screen has changed and post its screen name.

This proposal concerns only the first part.

## Motivation

To be able to post screen events for all view controllers we will need to be able to define screen names easily. I also believe that in most cases it will not be a problem to use the same string constant for the screen and accessibility identifier. Adding accessibility identifiers would improve the stability of our UI test suite.

## Proposed solution

Define a protocol

```swift
public protocol ScreenNaming {
	  func screenName() -> String?
}

```

with default implementations for `UIViewController`, `BabylonBoxViewController` and `FormViewController`

```swift
extension UIViewController: ScreenNaming {
    @objc open func screenName() -> String? { return view.accessibilityIdentifier }
}
```

```swift
open class BabylonBoxViewController<ViewModel, Renderer>: BoxViewController<ViewModel, Renderer, BabylonAppAppearance> {
	    ...
	    @objc open override func screenName() -> String? {
	        if let name = (viewModel as? ScreenNaming)?.screenName() {
	            return name
	        } else {
	            return super.screenName()
	        }
	    }
	}
```

```swift
open class FormViewController<F: Form>: UIViewController, UITableViewDelegate {
     ...
     @objc open override func screenName() -> String? {
        if let name = (form as? ScreenNaming)?.screenName() {
            return name
        } else {
            return super.screenName()
        }
    }
}
```

We could, as a fallback, use the class name of the view model as a default value for the screen name.

## Impact on existing codebase

Need to add screen names to view models, or assign accessibility identifiers to the main view throughout the code base.

## Alternatives considered

To not have a default coupling between screen names and accessibility identifiers. In my view we will in most cases be happy to use the same string constant for the screen name and accessibility identifier.

To make adding a screen name for a form or box view model. I believe this will be too much work to be done in one go.

---
* [x] **By creating this proposal, I understand that it might not be accepted**. I also agree that, if it's accepted,
depending on its complexity, I might be requested to give a workshop to the rest of the team. 🚀
