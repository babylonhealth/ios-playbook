<p align="center">
<img src="logo.png">
</p>


babylon iOS interview questions
==================================

As described in the iOS recruitment process [main page](https://github.com/Babylonpartners/iOS-Interview-Demo/blob/master/README.md), the face-to-face technical interviews involve us asking candidates a number of technical questions which we have decided to open-source.

Please keep in mind that this document is in a continuous state of flux, with new questions being added, and old ones tweaked or removed.

### GENERAL, CV-related

- Questions related to the information on the candidate's CV
- What technical books and blogs have you read or are reading at the moment?
- What conferences have you been to or plan on attending, if any?
- Questions related to the candidate's open source contributions, if any.
- What questions would you ask during an interview?

### ARCHITECTURE

- What is your opinion on `MVC` in iOS dev, and alternatives such as `MVVM` and `VIPER`?
- What role does the view controller play?
- How do you generally avoid massive view controllers?
- Do you know what the `SOLID` principles are?
- How would you architect the navigation in a complex application with many screens without using storyboards segues?
- Are you familiar with `Design Patterns` and the `Gang of Four` book?
- What is your opinion on the use of the `Singleton` pattern? What are its pros and cons?
- Are you familiar with `Dependency Inversion`? If so, what is it good for?
- Are you familiar with `Dependency Injection`? If so, what is it good for?
- Is immutability a good thing? Why or why not?
- Can you briefly describe 3 design patterns used in iOS development, other than `MVC` and `Singleton`, and what situations they're best suitable for?
- Can you describe the similarities and difference between the `Delegation` and `Observer` patterns?
- What's good and what's bad about this piece of code?
```SWIFT
(void)viewDidDisappear:(BOOL)animated {
    [self retain];
    [sharedDialog release];
    sharedDialog = nil;
    [self performSelector:@selector(presentNextDialog) withObject:nil afterDelay:0];
    [self release];
}
```
- What do you think are the main architectural challenges associated with developing for the iPad, compared to developing for the iPhone?
- Do you have any experience developing for the Apple Watch or tvOS? If so, what's your opinion on the differences and similarities of the various development environments in the Apple development ecosystem?
- How do you handle state in your app(s)?

### FUNCTIONAL REACTIVE PROGRAMMING
- Are you familiar with `Reactive Programming`?
- What's the basic design pattern behind `Reactive Programming`?
- How would you explain reactive programming to a junior developer who knows nothing about it?
- Why not using Future/Promises/Async-await instead of ReactiveSwift/RxSwift?
- What is functional programming? Explain it to a junior.
- Showcase examples of FP usage with clear benefits to a junior.
- Can a FP-oriented codebase be difficult to understand? Why?
- Is Swift a FP-oriented language?
- What is a higher-order function?
- Do you know what Curried Functions are?
- What is the `pipe` (`|>`) operator? Is it different from `map`? How do you propagate errors with it? Would a `flatPipe` operator make sense?
- What is a monad? Have you ever used one? (Related: why do you think FP has so many academic sounding terms?)

### SWIFT

- Can you tell us some of the pros and cons of developing in Swift today?
- What's your opinion on adopting Swift in both legacy projects and green-field projects?
- Can you give us a quick overview of the benefits of Swift over Objective-C? And on how they differ?
- The elevator-pitch question: I'm the CTO of a company thinking of switching from Obj-C to Swift. You have 30 seconds to convince me one way or the other.
- Say that there is a function for which we can define a reasonable default, but we need to define specialised versions for a couple of edge cases. How can we do this in Swift?
- Have you played with Swift Playgrounds? What are its key features and benefits?
- Are you familiar with the latest changes in the Swift language itself? If so, can you elaborate on some of them?
- When overriding an initialiser method in Obj-C, you generally call the super implementation before doing anything else. In Swift, the compiler will complain if you do that in certain situations. Do you know when and why?
- What's your opinion about `Protocol Oriented Programming` as opposed to the more traditional approach we've had on iOS?
- What are the differences between a `protocol` with a default implementation, and a `base class`?
- Is it possible to define an instance method that applies to arrays of integers but *not* to arrays of doubles, or any other type? Can you think of an example when this could be useful? Do you happen to know the syntax?
- What is the Swift embedded runtime?
- What is the difference between `value semantics` and `reference semantics`?
- So, say that you have a struct and one or more of its properties is of a reference type. What happens then? Is the struct still a value type?
- How do the Obj-C and Swift runtime environments manage memory these days?
- How does `ARC` work?
- Do you know what `autorelease pools` are? When are they useful?
- Do you know what retain cycles are? Can you give examples? Is it something to worry about and, if so, what facilities are available in Swift to handle them?
- Do you know what the `weak`, `strong`, and `unowned` keywords are, and when they need to be used?
- What are the differences between `copy`, `strong`, `weak` and `assign` property attributes? When should you use each of them?
- What is the difference between the Swift `nil` and the Obj-C `nil`?
- What storage options do you know for iOS and when should you use them?
- Why is it inherently harder to do static analysis in languages like obj-c compared to languages like swift?
- Do you know what `Protocol Extensions` are?
- What is the `mutating` keyword?
- What is the `@availability` attribute?
- What is the `@objc` keyword used for?
- Do you know what `@autoclosure` and `@escaping` attributes are and when to use them?
- Do you know what `type-erasure` is in the context of Swift generics?
- Why is it that, in swift, you can't have an array of, say, `Equatable`, ie, what's the reason for the compiler error "Protocol 'XXX' can only be used as a generic constraint because it has Self or associated type requirements"?
- Are you familiar with functional-programming methods such as `map`, `filter`, and `reduce`? Can you explain their similarities and differences?
- `Swift Standard Library`: What are `Generator`s, `Sequence`s and `Collection`s?
- What problems do optionals solve?
- Do you use optionals to handle state? If so, how do you model Errors in an Optional context?

### XCODE AND TOOLS

- What are your thoughts on using Storyboards, NIBs/XIBs, and doing all UI in code?
- What is your view and experience in using `Autolayout` and `Adaptive Sizing`?
- Have you used `Instruments`?
- How familiar are you with reading crash reports?
- Are you familiar with `Crashlytics`?
- What analytics frameworks are you familiar with or have used?
- Have you used `TestFlight`? `Fabric`?

### COCOA AND FRAMEWORKS

- What is a `thread`? In which cases would you create your own threads?
- What is a `runloop`? What is a `runloop mode`?
- What do you think of `Grand Central Dispatch`?
- Have you used `dispatch_once`? In broad strokes, how does it work?
- Have you used `dispatch_barrier`? When is it appropriate and useful to use?
- What is a `dispatch_group`?
- Have you used `NSOperationQueue` and `NSOperation`?
- What methods for thread synchronisation do you know on iOS?
- What are the main differences between `GCD` queues and `NSOperationQueue`s?
- What are the advantages and disadvantages of `GCD` and `NSOperationQueue`/`NSOperations`?
- What is `KVO`? Do you know how it works?
- How are objects stored in a collection? Can you store `weak` references in a collection?
- What is `Hashable`? Why does it require `Equatable`?
- Can you list some `communication patterns` used in iOS?
- What are the differences between `frame` and `bounds`?
- Is the `bounds.origin` always zero?
- How would you extend the touchable area of a `UIView`?
- What is the `Responder Chain`?
- Have you used `Core Data`? If so, how do you like it, and why? When would it not be appropriate to use `Core Data`?
- Are you familiar with the `Accelerate` framework?
- What other iOS frameworks are you familiar with?
- Which 3rd party frameworks do you know about or use? Why should you use them?
- Have you heard of or used `Cocoapods`, `Carthage`, and the `Swift Package Manager`?
- Which version control tools do you use? How much experience do you have with `git`? Can you explain what a `rebase` operation is?

### Computer Science 101 (Questions + Knowledge)

- What is a `deadlock`? How do you avoid it?
- What is a `race condition`? How do you avoid it?
- Knowledge about Big O notation
- Knowledge about data structures: graphs, trees, queues, stacks, linked lists, hashtables and others. 
- Knowledge about algorithms: sorting, searching and others. 

#### Thanks for your time! We look forward to hearing from you!
- The [babylon health iOS team](http://github.com/Babylonpartners)
