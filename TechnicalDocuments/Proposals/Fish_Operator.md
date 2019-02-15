# Introduce "fish" operator

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

With this we can convert example code above to much simpler form:

```swift
didTap: ^helpText >=> Action.didTapWhatDoesThisMean >=> observer
```

When we will look into types we will see the following:

```swift
() -> String? >=> (String) -> Action >=> (Action) -> Void
```

This will not compile though as Swift treats `() -> A` and `(()) -> A` as different types. And even if it would treat them the same the final function that would be created by this chain will have signature `() -> Void?` which is not the same as `() -> Void`.

To solve that we can introduce few overload of `>=>` operator to handle these special cases:

```swift
public func >=> <A, B>(lhs: @escaping () -> A?, rhs: @escaping (A) -> B?) -> () -> B? {
    return lhs >>> flatMap(rhs)
}

public func >=> <A, B>(lhs: @escaping (A) -> B?, rhs: @escaping (B) -> Void) -> (A) -> Void {
    return lhs >>> flatMap(rhs)
}

public func >=> <A>(lhs: @escaping () -> A?, rhs: @escaping (A) -> Void) -> () -> Void {
    return lhs >>> flatMap(rhs)
}

public func flatMap<A>(_ a2b: @escaping (A) -> Void) -> (A?) -> Void {
    return { a in
        a.flatMap(a2b)
    }
}
```

Comparing with original implementation based on `Optional.map` this approach gives a bit different result in the sense that it always creates a closure, that niside will terminate on `nil` values, whether `Optional.map` will produce `nil` value for a closure if mapped value is `nil`. This is an insignificant change though, unless semantics requires to pass `nil` instead of closure that contains a terminatable chain of calls. In this case the original approach can be still used. (But personally I'd prefer us to avoid using optional closures unless it is required by API semantics, which is usually not the case)

## Impact on existing codebase

As it is a new operator and not an overload of existing `>>>` operator there will be no inpact on exicting code.

## Alternatives considered

- We can leave things as they are.
- Instead of free `flatMap` function we can use `{ $0 ?|> rhs }`
- Instead of overloading `>=>` for `Void` type we can introduce a separate operator, i.e. `>->` just to compose functions with `Void` on either side.

## Reference

https://github.com/Babylonpartners/babylon-ios/blob/c26fcec05dddafa71552cac970f18577fee0a1f1/BabylonChatBotUI/BabylonChatBotUI/Chat/MessageMenu/MessageMenuRenderer.swift#L98
https://github.com/pointfreeco/swift-prelude/blob/master/Sources/Prelude/Optional.swift#L91


---
* [ ] I will send a meeting invitation, using this [template](Template_Proposal_Meeting_Invitation.MD), scheduled for 2 weeks after this proposal is made, so an agreement can be reached.
* [x] **By creating this proposal, I understand that it might not be accepted**. I also agree that, if it's accepted,
depending on its complexity, I might be requested to give a workshop to the rest of the team. 🚀
