# Introduce "fish" operator (Kleisli composition)

* Author: Ilya Puchka
* Review Manager:TBD

## Introduction

This proposal it to suggest to use new operator that will allow us to compose functions returning optional values, which is not currently possible.

## Motivation

Since introduction of `>>>` operator it was widely adopted throughout the code base and became an important tool in our tool set. But there are some cases where it's not enough. 

One of these cases is when first item returns optional, which makes us to jump through the hoops:

```swift
didTap: helpText.map { ^Action.didTapWhatDoesThisMean($0) >>> observer }
```

## Proposed solution

To handle such case [Prelude](https://github.com/pointfreeco/swift-prelude) defines "fish" operator (with a help of free curried `flatMap` function):

```swift
infix operator >=>: ForwardComposition

public func >=> <A, B, C>(lhs: @escaping (A) -> B?, rhs: @escaping (B) -> C?) -> (A) -> C? {
  return lhs >>> flatMap(rhs)
}

public func flatMap<A, B>(_ a2b: @escaping (A) -> B?) -> (A?) -> B? {
  return { a in
    a.flatMap(a2b)
  }
}
```

This is called [Kleisli composition](https://blog.ssanj.net/posts/2017-06-07-composing-monadic-functions-with-kleisli-arrows.html)

With this we can convert example code above to much simpler form:

```swift
didTap: ^helpText >=> Action.didTapWhatDoesThisMean >=> observer
```

When we will look into types we will see the following:

```swift
(() -> String?) >=> ((String) -> Action?) >=> ((Action) -> Void)
```

This will not compile though as Swift treats `() -> A` and `(()) -> A` as different types. And even if it would treat them the same the final function that would be created by this chain will have signature `() -> Void?` which is not the same as `() -> Void`.

To solve that we can wrap the whole chain in a closure:

```swift
didTap: { ^helpText >=> Action.didTapWhatDoesThisMean >=> observer <| () }
```

Alternatively we could use a regular composition and write it as following:

```swift
didTap: { helpText ?|> Action.didTapWhatDoesThisMean >>> observer }
```

The value of Kleisli cmposition is that it allows composition on functions which will not be composed with regular composition `>>>` because one of them returns optinal. This can be most usefull to replace chains of optional unwraping:

```swift
// (A) -> B?
func doSomething(_ value: A) -> B? {
  guard let a = a,
    let thing = someOptionalThingFromA(a)
    else { return nil }
  
  return maybeCreateBfromThing(thing)
}

let b: B? = a |> doSomething
```

With Kleisli it can be written much simpler:

```swift
// (A) -> B?
let doSomething = someOptionalThingFromA >=> maybeCreateBfromThing

let b: B? = a |> doSomething
```

## Impact on existing codebase

As it is a new operator and not an overload of existing `>>>` operator there will be no inpact on exicting code.

## Alternatives considered

- We can leave things as they are.
- Instead of free `flatMap` function we can use `{ $0 ?|> rhs }`
- Instead of passing `()` into composed function or using closure with regular composition (`>>>`) we can have a funiton, somthing like `runLazy` that wraps the side effect into function and discards the result (which is the nature of user action callbacks anyway) (lazy because just `run` will imply that side effect will be performed right away, rather than wrapped in a function to be performed later):

```swift
func runLazy<A>(_ f: @escaping () -> A) -> () -> Void {
    return { _ = f() }
}

didTap: ^helpText >=> Action.didTapWhatDoesThisMean >=> observer |> runLazy
```

Though just using closure with regular composition (`>>>`) seems to be the best option.

## Reference

https://github.com/Babylonpartners/babylon-ios/blob/c26fcec05dddafa71552cac970f18577fee0a1f1/BabylonChatBotUI/BabylonChatBotUI/Chat/MessageMenu/MessageMenuRenderer.swift#L98
https://github.com/pointfreeco/swift-prelude/blob/master/Sources/Prelude/Optional.swift#L91


---
* [ ] I will send a meeting invitation, using this [template](Template_Proposal_Meeting_Invitation.MD), scheduled for 2 weeks after this proposal is made, so an agreement can be reached.
* [x] **By creating this proposal, I understand that it might not be accepted**. I also agree that, if it's accepted,
depending on its complexity, I might be requested to give a workshop to the rest of the team. 🚀
