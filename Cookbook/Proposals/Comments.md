# Comments

* Author(s): Adam Borek
* Review Manager: TBA

## Introduction

I'd like to extend what our style guide says on comments. Right now it says very little and I think that can be improved extended. Currently it says:


> Comments

> In the very rare occasions when they are needed, use comments to explain why a particular piece of code does something. Comments must be kept up-to-date, or altogether deleted. Never write comments that tell what the code does.

> Avoid block comments inline with code, as the code should be as self-documenting as possible. Exception: This does not apply to those comments used to generate documentation.

> Avoid the use of C-style comments (/* ... */). Prefer the use of double- or triple-slash.


## Motivation

I think we sometimes overuse comments. Because our StyleGuide doesn't say much on comments, we have different opinions whether a comment is worth to be added or not.

I think comments are rather bad than good because of 2 following reasons: 

1. Comments eventually starts to lie.
2. Usage of comments gives a false-positive feeling to the author that the code is readable.

Look at this comment:
```swift
/// consultation method, will be either 'phone' or 'video'
public let consultationMethod: ConsultationMethod
```

Few lines below there's the enum declaration:
```swift
public enum ConsultationMethod: String {
    case phone
    case video
    case faceToFace = "face to face"
}
```
At the beginning the `ConsultationMethod` had indeed 2 cases. This may be trivial here without big consequences however that not always a case and a lie may cost us many of hours.

In our Pull Requests I've seen sometimes unnecessary
```swift
extension AppointmentDTO {
    public enum State: String, Codable {
        /// waiting for payment
        case pending
        /// user failed to pay for appoitment withing 10 min after the booking
        case timedOut = "timed_out"
        /// canceled by user or doctor
        case cancelled
        /// paid by user
        case paid
        /// doctor finished adding notes on the portal
        case completed
        /// patient did not answer the doctor's call
        case noShow = "no_show"
    }
}
```
Can be simplified without any lose in understanding what the code represents to:

```swift
extension AppointmentDTO {
    public enum State: String, Codable {
        /// waiting for payment
        case waitingForPayment = "pending"
        /// timeout == 10 min
        case paymentTimedOut = "timed_out"
        case cancelledByUserOrDoctor = "cancelled"
        case paidByUser = "paid"
        case doctorFinishedAddingNotesOnThePortal = "completed"
        case patientDidntAnswerTheCall = "no_show"
    }
}
```

Moreover, commented code is not only longer but it is also fragile to become a lie at some point. When a comment contain an information from other scope (other file) in our codebase. When a developer changes something when particular action is used, he may even don't think he should change the comment as he won't see it until he enters the file. Will he enter the file? Sometimes there's no such a need.

## Proposed solution

### Our approach 
The most important thing is to define our approach to comments as currently it isn't said clearly. Moreover, it would be nice to have a common way how we comment our code when we are forced to add them. 

In my opinion, our approach should insist on writing always a **self-documented code**. It should be our goal. However, writing self-documented code **doesn't** mean we shouldn't use comments. It means, that commenting our code is a **necessary evil**:

> The proper use of comments is to compensate for our failure to express ourself in code. Note that I used the word failure. I meant it. Comments are always failures. We must have them because we cannot always figure out how to express ourselves without them, but their use is not a cause for celebration.
	// Robert C. Martin - "Clean Code"
	
I think that adding the above section to our style guide would make it clear what's our approach to comments.

### What is a good comment?

To make our StyleGuide be more verbose we can also add a list of what kind of comments we think are "good".

**Good comments**:

- **Doc headers for public API**
- **TODO comments**
- **Explanation of Intent/Clarification**
	It's a kind of comment when a developer try to explain what he's trying to achieve when code is not verbose enough. Example: Math code, sometimes parsing.
- **Warning of Consequences**
	If we had a test which takes an hour to run, it would be nice to have a comment warning about it.
- **Amplification**
	Sometimes some piece of a code seem to be less important than it really is. In such cases, it's worth to mark it.
- **Reference to external sources**
	For example, ISO 639 for country codes.

The above list is what defines a good comment. **However**, we still have to remember that **every** comment **is our failure** to name our code better. If someone gives you a good hint how to remove a comment without sacrificing readability **we should go for it**.

### How can we replace a comment?
In case of a **what** comments usually it is very easy to replace a comment. Usually it's all about taking what comment says and create a variable or function with such a name.


### How do we comment.
Even with the approach explain above we will be forced to comment our code. I would like to propose a way of doing it. The biggest difficulty for me when I read a comment (especially a long one, explaining "why") is to understand to what scope the comment refers to. I think that we should always try to export commented code into a separate method and put the comment as a header to this method.

The above solution have 2 benefits:

1. It's visible to what part of a code comment refers.
2. It improves readability for a developer who doesn't need to know why particular piece of code is written. Sometimes, during debugging for example, what you need to know is **what** happens, not **why**.

To illustrate point `2.`. If there is an UIKit bug, with dismissing a modal screen which is ugly but works just fine, all we care about is the fact that the code has been dismissed. During a debuting we now we can go just further without a need to understand how `dissmissing` is handled.

[This](https://github.com/Babylonpartners/babylon-ios/blob/2f815529362b03c316bf19bedc839a9028a6eab3/BabylonMapsUI/BabylonMapsUI/SearchResults/MapSearchResultsViewController.swift#L44) shows what is a good comment. Ideally, it could be exported to `self?.setDrawerState(drawerState)` to not disturb a reader when it's not necessary.
 


## Impact on existing codebase
It doesn't have any impact on existing codebase as this is about adding new rule to our StyleGuide. What will change is during code reviews we may have more comments how to replace a comment with a code.


## Alternatives considered
1. Leave the StyleGuide as it is, aka. reject this proposal.
2. Modify the list of good comments.
