<p align="center">
<img src="../logo.png">
</p>


babylon iOS interview questions
==================================

Please keep in mind that this document is in a continuous state of flux, with new questions being added, and old ones tweaked or removed.

### GENERAL, CV-related

 1. Questions related to the information on the candidate's CV
 1. What technical books and blogs have you read or are reading at the moment?
 1. What conferences have you been to or plan on attending, if any?
 1. Questions related to the candidate's open source contributions, if any.
 1. What questions would you ask during an interview?

### ARCHITECTURE

 1. What is your opinion on `MVC` in iOS dev, and alternatives such as `MVVM` and `VIPER`?
 1. What role does the view controller play?
 1. How do you generally avoid massive view controllers?
 1. Do you know what the `SOLID` principles are?
 1. How would you architect the navigation in a complex application with many screens without using storyboards segues?
 1. Are you familiar with `Design Patterns` and the `Gang of Four` book?
 1. What is your opinion on the use of the `Singleton` pattern? What are its pros and cons?
 1. Are you familiar with `Dependency Injection`? If so, what is it good for?
 1. And what about the `Dependency Inversion` principle?
 1. Is immutability a good thing? Why or why not?
 1. Can you briefly describe 3 design patterns used in iOS development, other than `MVC` and `Singleton`, and what situations they're best suitable for?
 1. Can you describe the similarities and difference between the `Delegation` and `Observer` patterns?
 1. What do you think are the main architectural challenges associated with developing for the iPad, compared to developing for the iPhone?
 1. How do you handle state in your app(s)?

### FUNCTIONAL REACTIVE PROGRAMMING
 1. Are you familiar with `Reactive Programming`?
 1. What's the basic design pattern behind `Reactive Programming`?
 1. What's the `Observable` (in RxSwift) or `Signal` and `SignalProducer` (in ReactiveSwift) or `Publisher` (in Combine)?
 1. How would you explain reactive programming to a junior developer who knows nothing about it?
 1. Why not using Future/Promises/Async-await instead of ReactiveSwift/RxSwift?
 1. What is functional programming? Explain it to a junior.
 1. Showcase examples of FP usage with clear benefits to a junior.
 1. Can a FP-oriented codebase be difficult to understand? Why?
 1. Is Swift a FP-oriented language?
 1. What is a higher-order function?
 1. Do you know what Curried Functions are? How do they differ from Partial Application?
 1. What is the `pipe` (`|>`) operator? Is it different from `map`? How do you propagate errors with it? Would a `flatPipe` operator make sense?
 1. What is a monad? Have you ever used one? (Related: why do you think FP has so many academic sounding terms?)
 1. Are you familiar with the Combine framework?
 1. In what ways does it differ from ReactiveSwift or RxSwift?
 1. Can you explain the concept of backpressure?

### SWIFT

 1. Can you tell us some of the pros and cons of developing in Swift today?
 1. What's your opinion on adopting Swift in both legacy projects and green-field projects?
 1. Can you give us a quick overview of the benefits of Swift over Objective-C? And on how they differ?
 1. Say that there is a function for which we can define a reasonable default, but we need to define specialised versions for a couple of edge cases. How can we do this in Swift?
 1. Have you played with Swift Playgrounds? What are its key features and benefits?
 1. Are you familiar with the latest changes in the Swift language itself? If so, can you elaborate on some of them?
 1. When overriding an initialiser method in Obj-C, you generally call the super implementation before doing anything else. In Swift, the compiler will complain if you do that in certain situations. Do you know when and why?
 1. What's your opinion about `Protocol Oriented Programming` as opposed to the more traditional approach we've had on iOS?
 1. What are the differences between a `protocol` with a default implementation, and a `base class`?
 1. Is it possible to define an instance method that applies to arrays of integers but *not* to arrays of doubles, or any other type? Can you think of an example when this could be useful? Do you happen to know the syntax?
 1. What is the Swift embedded runtime?
 1. What is the difference between `value semantics` and `reference semantics`?
 1. Say that you have a struct and one or more of its properties is of a reference type. What happens then? Does the struct still have value semantics?
 1. How does the Swift runtime environment manage memory these days?
 1. How does `ARC` work?
 1. Do you know what `autorelease pools` are? When are they useful?
 1. Do you know what retain cycles are? Can you give examples? Is it something to worry about and, if so, what facilities are available in Swift to handle them?
 1. Do you know what the `weak`, `strong`, and `unowned` keywords are, and when they need to be used?
 1. What are the differences between `copy`, `strong`, `weak` and `assign` property attributes? When should you use each of them?
 1. What is the difference between the Swift `nil` and the Obj-C `nil`?
 1. What storage options do you know for iOS and when should you use them?
 1. Why is it inherently harder to do static analysis in languages like Obj-c compared to languages like Swift?
 1. Do you know what `Protocol Extensions` are?
 1. What is the `mutating` keyword?
 1. What is the `@availability` attribute?
 1. What is the `@objc` keyword used for?
 1. Do you know what `@autoclosure` and `@escaping` attributes are and when to use them?
 1. Do you know what `type-erasure` is in the context of Swift generics?
 1. Why is it that, in swift, you can't have an array of, say, `Equatable`, ie, what's the reason for the compiler error "Protocol 'XXX' can only be used as a generic constraint because it has Self or associated type requirements"?
 1. Are you familiar with functional-programming methods such as `map`, `filter`, and `reduce`? Can you explain their similarities and differences?
 1. `Swift Standard Library`: What are `Generator`s, `Sequence`s and `Collection`s?
 1. What problems do optionals solve?
 1. Do you use optionals to handle state? If so, how do you model Errors in an Optional context?

### XCODE AND TOOLS

 1. What are your thoughts on using Storyboards, NIBs/XIBs, and doing all UI in code?
 1. What is your view and experience in using `Autolayout` and `Adaptive Sizing`?
 1. Have you used `Instruments`?
 1. How familiar are you with reading crash reports?
 1. Are you familiar with `Crashlytics`?
 1. What analytics frameworks are you familiar with or have used?
 1. Have you used `TestFlight`? `Firebase`?

### COCOA AND FRAMEWORKS

 1. What is a `thread`? In which cases would you create your own threads?
 1. What do you think of `Grand Central Dispatch`?
 1. Have you used `dispatch_once`? In broad strokes, how does it work?
 1. What is a `dispatch group`?
 1. What methods for thread synchronisation do you know on iOS?
 1. What are the advantages and disadvantages of `GCD` and `NSOperationQueue`/`NSOperations`?
 1. What is `KVO`? Do you know how it works?
 1. How are objects stored in a collection? Can you store `weak` references in a collection?
 1. What is `Hashable`? Why does it require `Equatable`?
 1. Can you list some `communication patterns` used in iOS?
 1. What are the differences between `frame` and `bounds`?
 1. Is the `bounds.origin` always zero?
 1. How does UIKit know which view is tapped? How would you extend the touchable area of a `UIView`?
 1. What is the `Responder Chain`?
 1. Have you used `Core Data`? If so, how do you like it, and why? When would it not be appropriate to use `Core Data`?
 1. What other iOS frameworks are you familiar with (eg AVFoundation, SceneKit)?
 1. Which 3rd party frameworks do you know about or use? Why would you use them?
 1. Have you heard of or used `Cocoapods`, `Carthage`, and the `Swift Package Manager`?
 1. Which version control tools do you use? How much experience do you have with `git`? Can you explain what a `rebase` operation is?

### Computer Science 101 (Questions + Knowledge)

 1. What is a `deadlock`? How do you avoid it?
 1. What is a `race condition`? How do you avoid it?
 1. Knowledge about Big O notation
 1. Knowledge about data structures: graphs, trees, queues, stacks, linked lists, hashtables and others.
 1. Knowledge about algorithms: sorting, searching and others.

#### Thanks for your time! We look forward to hearing from you!
The [babylon health iOS team](http://github.com/babylonhealth)
