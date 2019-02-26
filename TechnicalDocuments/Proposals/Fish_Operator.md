# Introduce "fish" operator (Kleisli composition)

* Author: Ilya Puchka
* Review Manager: David Rodrigues

## Introduction

This proposal it to suggest to use new operator that will allow us to compose functions returning optional values, which is not currently possible.

## Motivation

Since introduction of `>>>` operator it was widely adopted throughout the code base and became an important tool in our tool set. But there are some cases where it's not enough. 

or use verbose optional unwrapping chains with if-let or guard-let. 

## Proposed solution

To handle such case [Prelude](https://github.com/pointfreeco/swift-prelude) defines "fish" operator (with a help of free curried `flatMap` function):

```swift
infix operator >=>: ForwardComposition

public func >=> <A, B, C>(lhs: @escaping (A) -> B?, rhs: @escaping (B) -> C?) -> (A) -> C? {
  return lhs >>> flatMap(rhs)
}

public func >=> <A, B>(lhs: @escaping (()) -> A?, rhs: @escaping (A) -> B?) -> () -> B? {
    let f = lhs >>> { b in b.flatMap(rhs) }
    return { f(()) }
}

public func flatMap<A, B>(_ a2b: @escaping (A) -> B?) -> (A?) -> B? {
  return { a in
    a.flatMap(a2b)
  }
}
```

This is called [Kleisli composition](https://blog.ssanj.net/posts/2017-06-07-composing-monadic-functions-with-kleisli-arrows.html) and is very common in functional programming. The `Void` overload is needed to avoid having `(()) -> T?`  as result of composition when its first argument accepts `Void`. We already have a simialr overload for `>>>` for the same reason.

The value of Kleisli composition is that it allows composition on functions which will not be composed with regular composition `>>>` because one of them returns result wrapped in some container (it can be `Optional`, `Either` or other kind of type that wraps value of another type in some way).

This can be usefull to replace chains of optional unwraping:

```swift
// (A) -> B?
func doSomething(_ value: A) -> B? {
  guard let thing = someOptionalThingFromA(value)
    // possibly more failable operations here...
    else { return nil }
  
  return maybeCreateBfromThing(thing)
}

let a: A = ...
let b: B? = a |> doSomething
```

With Kleisli it can be written much simpler:

```swift
// (A) -> B?
let doSomething = someOptionalThingFromA >=> maybeCreateBfromThing

let b: B? = a |> doSomething
```

Another possible application is in `filterMap` operator that has `(A) -> B?` signature. For example this code:

```swift
let avatarSelection = avatarSelection.producer.filterMap { image in
    return image
        |> PatientUpdateRequest.prepareAvatar
        ?|> Event.userDidSelectAvatar
}
```

can be rewritten into this using Kleisli:

```swift
let avatarSelection = avatarSelection.producer.filterMap(
   PatientUpdateRequest.prepareAvatar >=> Event.userDidSelectAvatar
)
```

In this case `>=>` is a way to replace closure and `?|>` operator, the same way as `>>>` is a way to replace closure and `|>` operator.

Similarly to `filterMap` Kleisli can be useful when defining feedbacks that should be active only in particular states and depend on the associated values of this state. With a help of some method (let's call it `patternMatch`) that will pattern match enum cases (subject to a separate proposal) we can rewrite this code:

```swift
return Feedback { state -> Signal<Event, NoError> in
    guard
        let loaded = state.loadedState,
        let selecting = loaded.selectingDeliveryMethodState,
        case let .selectingDeliveryOption(address) = selecting else {
            return .empty
    }
```

into something like this:

```swift
return Feedback(filterQuery:
    ^\.loadedState
        >=> ^\.selectingDeliveryMethodState
        >=> patternMatch(SelectingDeliveryMethodState.selectingDeliveryOption)
) { (address) -> Signal<Event, NoError> in

// patternMatch<T, A>(_ `case`: @escaping (A) -> T) -> (T) -> A?
```

Here we are replacing the `quard` with a chain of optional unwrapping with a Kleisli composition. If it still does not look  ergonomic enough we can improve it by adjusting `Feedback` constructor to something like this:

```swift
init<A, Control, Effect>(
  filterQuery: (State) -> Control?, 
  patternMatching: (A) -> Control, 
  effects: @escaping (Control) -> Effect
)
```

so that we can use it like this:

```swift
return Feedback(
    filterQuery: ^\.loadedState >=> ^\.selectingDeliveryMethodState,
    patternMatching: SelectingDeliveryMethodState.selectingDeliveryOption
) { (address) -> Signal<Event, NoError> in
```

## Impact on existing codebase

As it is a new operator and not an overload of existing `>>>` operator there will be no impact on exicting code.

## Alternatives considered

- We can leave things as they are.
- Instead of free `flatMap` function we can use `{ $0 ?|> rhs }`
- Instead of passing `()` into composed function or using a closure with regular composition (`>>>`) we can have a function, something like `runLazy`, that wraps the side effect into a closure that discards the result (which is the nature of user action callbacks anyway). It is lazy because just `run` will imply that side effect will be performed right away, rather than wrapped in a closure to be performed later.

```swift
func runLazy<A>(_ f: @escaping () -> A) -> () -> Void {
    return { _ = f() }
}
```

Such function will solve the issue of `Void?` return type, but we still will have the issue with `Void` input type. For that we either can adjust this function to be `runLazy<A>(_ f: @escaping (()) -> A) -> () -> Void`, or we can intrduce an overload version of `>=>` operator:

```swift
public func >=> <A, B>(lhs: @escaping (()) -> A?, rhs: @escaping (A) -> B?) -> () -> B? {
    let f = lhs >>> { b in b.flatMap(rhs) }
    return { f(()) }
}
```

With that the final result will look like this:

```
didTap: ^helpText >=> Action.didTapWhatDoesThisMean >=> observer |> runLazy
```

Though just using closure with regular composition (`>>>`) seems to be the best option (in this particular case).

## Reference

https://github.com/Babylonpartners/babylon-ios/blob/c26fcec05dddafa71552cac970f18577fee0a1f1/BabylonChatBotUI/BabylonChatBotUI/Chat/MessageMenu/MessageMenuRenderer.swift#L98
https://github.com/pointfreeco/swift-prelude/blob/master/Sources/Prelude/Optional.swift#L91
https://www.pointfree.co/episodes/ep2-side-effects


---
* [x] I will send a meeting invitation, using this [template](Template_Proposal_Meeting_Invitation.MD), scheduled for 2 weeks after this proposal is made, so an agreement can be reached.
* [x] **By creating this proposal, I understand that it might not be accepted**. I also agree that, if it's accepted,
depending on its complexity, I might be requested to give a workshop to the rest of the team. 🚀
