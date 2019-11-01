

# Functional operators in our codebase

## `|>` - Application (Pipe forward)

The pipe forward operator is used to feed a value into a function.

### Form
Pipe forward is of the form `((A), (A -> B)) -> B`. It takes a value of type A, as well as a function of type A to B and returns a value of type B.

### Usage
```swift
func toString(_ integer: Int) -> String { 
    return "\(integer)"
}

let stringified = 5 |> toString // Produces "5"
```
This example is equivalent to performing:
`let stringified = toString(5)`

But, why? What's the point in this?

Well, let's use an example from our codebase.

```swift
error                               // NetworkError
    |> AlertError.make              // (NetworkError) -> AlertError
    |> Route.showAPIErrorAlert      // (AlertError) -> Route
    |> routesObserver.send          // (Route) -> Void
```

Here we take an error and apply several transformations to it, before emitting it through `routesObserver`. 

This is the same logic, but without pipe:
```swift
// Version 1
routesObserver.send(Route.showAPIErrorAlert(AlertError.make(error)))

// or

// Version 2
let alertError = AlertError.make(error)
let route = Route.showAPIErrorAlert(alertError)
routesObserver.send(route)
```

In the first version, readability is much lower compared to the piped version. It's difficult to immediately realise what transformations are happening and what the "source" value is.

The second version is more readable, but I'd argue not as much as the piped version.
The piped version clearly displays an uninterupted flow of data. The result of each individual step cannot be re-used or mutated during the chain of functions. 
Version 2, however, leaves the variables available to re-use. This can be an advantage, but also tends to clutter the local scope more.

### Variants

#### `<|` - Backwards pipe
`<|` is the reversed version of `|>`. It takes applies a value from the right-hand side to a function on the left-hand side. This can occasionally help with readability.

#### `?|>` - Optional pipe
`?|>` applies the left-hand side value to the right-hand side function *if* the value is not nil. If the value is nil, the chain is broken and the chain of functions stops.

### Further reading

https://www.pointfree.co/episodes/ep1-functions#t141

## `>>>` - Compose forward

Both the compose forward / compose backward operators are used to "glue" functions together to create larger functions.

### Form
Compose forward is of the form `((A) -> B), (B) -> C) -> (A) -> C`. It takes the output of the first function and plugs it into the second function.

### Usage
```swift
func toString(_ integer: Int) -> String { 
    return "\(integer)"
}

func last(_ string: String) -> Character? {
    return string.last
}

// Version 1
let getLastCharacter: (Int) -> Character? = toString >>> last
[303, 808, 909]
    .map(getLastCharacter) // Produces Array<Character>["3", "8", "9"]
```
This example is equivalent to performing:
```swift
// Version 2
[303, 808, 909]
    .map(toString)
    .map(last)      // Produces Array<Character>["3", "8", "9"]
```

What's most notable in this comparison is that version 1 is able to perform two functions in the same place as one. In the case of an array, this isn't a major effect as we can immediately map over the result, but there are situations where this isn't possible. A common usage of composition is when interacting with buttons.

Imagine a scenario where, when a button is tapped, we do the following:
1. Take some current integer value
2. Increment it
3. Convert it to a string
4. Display the string on the screen

```swift
struct Button {
    let didTap: () -> Void

    func tap() {
        didTap()
    }
}

func getCurrentValue() -> Int {
    return 303 // Example value
}

func incr(_ integer: Int) -> Int {
    return integer + 1
}

func toString(_ integer: Int) -> String {
    return "\(integer)"
}

// Version 1
let convertAndUpdate: () -> Void = getCurrentValue >>> incr >>> toString >>> updateText
let button = Button(didTap: convertAndUpdate)
button.tap()

// Version 2
let secondButton = Button(didTap: {
    let currentValue = getCurrentValue()
    let newValue = incr(currentValue)
    let stringified = toString(newValue)
    updateText(stringified)
})
secondButton.tap()
```

Version 1 is superior in this situation for several reasons:

1. More difficult to introduce side effects in. If the developer is building small, re-usable, [pure functions](https://en.wikipedia.org/wiki/Pure_function) then these functions will also be pure when combined together.
Version 2, on the other hand, has plenty more oppurtunity to accidentally add side effects. What if we called updateText twice by adding another function call inside the closure? This wouldn't be possible in version 1, as the function signatures would not match up.
This logic also applies to capturing self, which can be rather troublesome and easy to do using closures in Swift.

2. Semantically, version 1 clearly displays that a transformation of data is occuring. 
This is not the case with version 2, as version 2 is a collection of statements rather than a single expression.

3. For a similar reason to pipe forward, readability.
 We can clearly follow the function names that describe the sequence of transformations that are happening to the input to return our output. Version 2 is a little harder to follow due to having intermediate variables. (Also, more intermediate variables = more chance to accidentally use the wrong value, such as using `currentValue` where `newValue` should have been used.)

### Variants

#### `<<< ` - Backwards composition
`<<<` is the reversed version of `>>>`. It combines a function from the right-hand side with a function on the left-hand side. This can occasionally help with readability.

#### `>=>` - Kleisli composition
Ilya has already provided a great explanation of its usage in [this proposal!](https://github.com/babylonhealth/ios-playbook/blob/2e08f62675e00a84612b0315c909ce352137e464/Cookbook/Proposals/Fish_Operator.md)
>The value of Kleisli composition is that it allows composition on functions which will not be composed with regular composition >>> because one of them returns result wrapped in some container (it can be Optional, Either or other kind of type that wraps value of another type in some way).

### Further reading

https://www.pointfree.co/episodes/ep1-functions#t537

## `^` - Function lifting

The `^` (caret) operator is used to lift values to become functions.

### Form
There are two overloads for this specific operator:

1. `(A) -> () -> A`
This variant "lifts" a provided value into a function. 

2. `(KeyPath) -> (Root) -> Value`
This variant is used to pull out some property of the Root object by providing a KeyPath.

### Usage

1. "Lifting"
```swift
enum Event {
    case didPressButton
}

struct Button {
    let didTap: () -> Void

    func tap() {
        didTap()
    }
}

func processEvent(_ event: Event) {
    print("Processed \(event)")
}

// Version 1
Button(didTap: ^Event.didPressButton >>> processEvent)

// Version 2
Button(didTap: { processEvent(Event.didPressButton) })
```

The ability to lift functions here is powerful as we no longer need to open a closure just to use a provide some value that will never change.

2. Combination with keyPath operator

```swift
func toString(_ integer: Int) -> String { 
    return "\(integer)"
}

func last(_ string: String) -> Character? {
    return string.last
}

// Version 1
let getLastCharacter: (Int) -> Character? = toString >>> ^\.last
[303, 808, 909]
    .map(getLastCharacter) // Produces Array<Character?>["3", "8", "9"]
```
This example is equivalent to performing:
```swift
// Version 2
[303, 808, 909]
    .map(toString)
    .map { $0.last }     // Produces Array<Character?>["3", "8", "9"]
```

What's great about this approach is that we can use properties of Root objects just like functions. In this previously seen example, we're now able to swap out the function `last` for a `KeyPath`- more reusable code!

Again, the main benefit here is not having to open up additional closures. When we avoid closures, we enforce the rule that our chain of functions must follow the correct shapes. Its stricter than several statements done sequentially in a closure. It also encourages developers to build up smaller, more modular functions rather than using one-use closures everywhere.

### Further reading

https://www.pointfree.co/episodes/ep8-getters-and-key-paths#t1289
