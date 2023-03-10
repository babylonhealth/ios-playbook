# Our Swift Style Guide

## Introduction

This style guide is based on the [official raywenderlich.com Swift style guide](https://github.com/raywenderlich/swift-style-guide) but departs from it in several ways, to better accommodate the needs of our team. We would like to thank [Ray and his team](https://www.raywenderlich.com), and all of those who contributed to their style guide, for creating it in the first place.

Our primary goals, like theirs, are **clarity**, **consistency**, and **brevity** but also to achieve a sufficiently stable style guide to configure a linter from. Nonetheless, it's a living document that will evolve as our needs change, as well as alongside the Swift language.

### Fixing Typos

Uncontroversial, non-additive changes such as misspellings, grammar or compiler errors can be fixed by simply issuing a pull request to master. The maintainer will merge the pull request or, if it is deemed "controversial", ask the contributor to open an issue so that other members of our team can participate in the discussion. We thank any and all such contributions in advance!

## Table of Contents

* [Correctness](#correctness)
* [Naming](#naming)
  * [Delegates](#delegates)
  * [Use Type Inferred Context](#use-type-inferred-context)
  * [Generics](#generics)
  * [Class Prefixes](#class-prefixes)
  * [Language](#language)
* [Code Organization](#code-organization)
  * [Protocol Conformance](#protocol-conformance)
  * [Unused Code](#unused-code)
  * [Minimal Imports](#minimal-imports)
* [Spacing](#spacing)
* [Comments](#comments)
* [Classes and Structures](#classes-and-structures)
* [Use of Self](#use-of-self)
* [Protocol Conformance](#protocol-conformance)
* [Computed Properties](#computed-properties)
* [Final](#final)
* [Function Declarations](#function-declarations)
* [Function Calls](#function-calls)
* [Closure Expressions](#closure-expressions)
* [Types](#types)
  * [Constants](#constants)
  * [Static Methods and Variable Type Properties](#static-methods-and-variable-type-properties)
  * [Optionals](#optionals)
  * [Lazy Initialization](#lazy-initialization)
  * [Type Inference](#type-inference)
  * [Syntactic Sugar](#syntactic-sugar)
* [Functions vs Methods](#functions-vs-methods)
* [Memory Management](#memory-management)
  * [Extending Lifetime](#extending-lifetime)
* [Access Control](#access-control)
* [Control Flow](#control-flow)
  * [Ternary Operator](#ternary-operator)
* [Golden Path](#golden-path)
  * [Failing Guards](#failing-guards)
* [Semicolons](#semicolons)
* [Parentheses](#parentheses)
* [Multi-line String Literals](#multi-line-string-literals)
* [Organization and Bundle Identifier](#organization-and-bundle-identifier)
* [Copyright Statement](#copyright-statement)
* [References](#references)
* [SwiftLint rules](#swiftlint-rules)

## Correctness

Strive to make your code compile without warnings. This rule informs many style decisions such as using `#selector` types instead of string literals.

## Naming

Descriptive and consistent naming makes software easier to read and understand. Use the Swift naming conventions described in the [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/). Some key takeaways include:

- striving for clarity at the call site
- prioritizing clarity over brevity
- using `camelCase` (not `snake_case`)
- [using uppercase initials for types (and protocols), lowercase first-initial for everything else](https://swift.org/documentation/api-design-guidelines/#follow-case-conventions)
- [including all needed words while omitting needless words](https://swift.org/documentation/api-design-guidelines/#include-words-to-avoid-ambiguity)
- using names based on roles, not types
- sometimes compensating for weak type information
- striving for fluent usage
- beginning factory methods with `make`
- naming methods for their side effects
  - verb methods follow the -ed, -ing rule for the non-mutating version
  - noun methods follow the formX rule for the mutating version
  - boolean types should read like assertions (`isLoading`, `isHidden`, `isFalse`, etc)
  - protocols that describe _what something is_ should read as nouns
  - protocols that describe _a capability_ should end in _-able_ or _-ible_
  - if protocols are tightly bound to their implementations, it's ok to suffix the protocol name with `Protocol`
- using terms that don't surprise experts or confuse beginners
- generally avoiding abbreviations, although a few well-known ones are allowed, such as, `HTML`, `HTTP`, `URL`, and `ID`.
- String identifiers and integer identifiers should use the `Tagged` approach
- using precedent for names
- preferring methods and properties to free functions
- casing acronyms and initialisms uniformly up or down. Note that we use `ID` when part of a type but `Id` when part of an identifier's name
- giving the same base name to methods that share the same meaning
- avoiding overloads on return type
- choosing good parameter names that serve as documentation
- preferring to name the first parameter instead of including its name in the method name, except as mentioned under [Delegates](#delegates)
- labeling closure and tuple parameters
- taking advantage of default parameters

### Class Prefixes

Swift types are automatically namespaced by the module that contains them and you should not add a class prefix. If two names from different modules collide you can disambiguate by prefixing the type name with the module name. However, only specify the module name when there is possibility for confusion which should be rare.

```swift
import SomeModule

let myClass = MyModule.UsefulClass()
```

### Delegates

When creating custom delegate methods, an unnamed first parameter should be the delegate source. (UIKit contains numerous examples of this.)

**Preferred**:
```swift
func namePickerView(_ namePickerView: NamePickerView, didSelectName name: String)
func namePickerViewShouldReload(_ namePickerView: NamePickerView) -> Bool
```

**Not Preferred**:
```swift
func didSelectName(namePicker: NamePickerViewController, name: String)
func namePickerShouldReload() -> Bool
```

### Use Type Inferred Context

Use compiler inferred context to write shorter, clear code.  (Also see [Type Inference](#type-inference).)

**Preferred**:
```swift
let selector = #selector(viewDidLoad)
view.backgroundColor = .red
let toView = context.view(forKey: .to)
let view = UIView(frame: .zero)
```

**Not Preferred**:
```swift
let selector = #selector(ViewController.viewDidLoad)
view.backgroundColor = UIColor.red
let toView = context.view(forKey: UITransitionContextViewKey.to)
let view = UIView(frame: CGRect.zero)
```

### Generics

Generic type parameters should be descriptive, upper camel-case names. When a type name doesn't have a meaningful relationship or role, use a traditional single uppercase letter such as `T`, `U`, or `V`.

**Preferred**:
```swift
struct Stack<Element> { ... }
func write<Target: OutputStream>(to target: inout Target)
func swap<T>(_ a: inout T, _ b: inout T)
```

**Not Preferred**:
```swift
struct Stack<T> { ... }
func write<target: OutputStream>(to target: inout target)
func swap<Thing>(_ a: inout Thing, _ b: inout Thing)
```

### Language

Use US English spelling to match Apple's API.

**Preferred**:
```swift
let color = "red"
```

**Not Preferred**:
```swift
let colour = "red"
```

## Code Organization

Use extensions to organize your code into logical blocks of functionality. Add `MARK`s if they help with it.

### Declaration Order

Data type declaration must follow the ordering rule 1 to 3:

```
1. instance stored properties (struct), or enum cases
2. designated initializer
3. deinit
4. (others)
```

(Note that rule 1 to 3 are required to be in declaration scope that can't move to `extension`)

For other declarations below, they will go to `4. (others)` and can be in arbitrary order:

```
- convenience initializers
- instance computed properties
- instance methods
- type stored properties (NOTE: this rarely appears in practice because singleton is discouraged)
- type computed properties
- type methods
- nested types
```

See also: [[Proposal] Top-priority member-variable and initializer declarations](https://github.com/babylonhealth/ios-playbook/pull/74)

### Protocol Conformance

In particular, when adding protocol conformance to a type, prefer adding a separate extension for the protocol methods. This keeps the related methods grouped together with the protocol.

**Preferred**:
```swift
class MyViewController: UIViewController {
  // class stuff here
}

extension MyViewController: UITableViewDataSource {
  // table view data source methods
}

extension MyViewController: UIScrollViewDelegate {
  // scroll view delegate methods
}
```

**Not Preferred**:
```swift
class MyViewController: UIViewController, UITableViewDataSource, UIScrollViewDelegate {
  // all methods
}
```

Since the compiler does not allow you to re-declare protocol conformance in a derived class, it is not always required to replicate the extension groups of the base class. This is especially true if the derived class is a terminal class and a small number of methods are being overridden. When to preserve the extension groups is left to the discretion of the developer.

For UIKit view controllers, consider grouping lifecycle, custom accessors, and IBAction in separate class extensions.

### Unused Code

Unused (dead) code, including Xcode template code and placeholder comments should be removed.

**Preferred**:
```swift
override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  return Database.contacts.count
}
```

**Not Preferred**:
```swift
override func didReceiveMemoryWarning() {
  super.didReceiveMemoryWarning()
  // Dispose of any resources that can be recreated.
}

override func numberOfSections(in tableView: UITableView) -> Int {
  // #warning Incomplete implementation, return the number of sections
  return 1
}

override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  // #warning Incomplete implementation, return the number of rows
  return Database.contacts.count
}

```
### Minimal Imports

Import only the modules a source file requires. For example, don't import `UIKit` when importing `Foundation` will suffice. Likewise, don't import `Foundation` if you must import `UIKit`.

**Preferred**:
```
import UIKit
var view: UIView
var deviceModels: [String]
```

**Preferred**:
```
import Foundation
var deviceModels: [String]
```

**Not Preferred**:
```
import UIKit
import Foundation
var view: UIView
var deviceModels: [String]
```

**Not Preferred**:
```
import UIKit
var deviceModels: [String]
```

## Spacing

* Indent using 4 spaces rather than tabs to conserve space and help prevent line wrapping. Be sure to set this preference in Xcode and in the Project settings as shown below:

![Xcode indent settings](screens/indentation.png)

* Method braces and other braces (`if`/`else`/`switch`/`while` etc.) always open on the same line as the statement but close on a new line.
* Tip: You can re-indent by selecting some code (or **Command-A** to select all) and then **Control-I** (or **Editor ▸ Structure ▸ Re-Indent** in the menu). Some of the Xcode template code will have 4-space tabs hard coded, so this is a good way to fix that.

**Preferred**:
```swift
if user.isHappy {
  // Do something
} else {
  // Do something else
}
```

**Not Preferred**:
```swift
if user.isHappy
{
  // Do something
}
else {
  // Do something else
}
```

* There should be exactly one blank line between methods to aid in visual clarity and organization. Whitespace within methods should separate functionality, but having too many sections in a method often means you should refactor into several methods.

* There should be no blank lines after an opening brace or before a closing brace.

* Colons always have no space on the left and one space on the right. Exceptions are the ternary operator `? :`, empty dictionary `[:]` and `#selector` syntax `addTarget(_:action:)`.

**Preferred**:
```swift
class TestDatabase: Database {
  var data: [String: CGFloat] = ["A": 1.2, "B": 3.2]
}
```

**Not Preferred**:
```swift
class TestDatabase : Database {
  var data :[String:CGFloat] = ["A" : 1.2, "B":3.2]
}
```

* Long lines should be wrapped at around 120 characters. A hard limit is intentionally not specified.

* Avoid trailing whitespaces at the ends of lines.

* Add a single newline character at the end of each file.

## Availability qualifiers

Ue `@available(*, unavailable)` when using unimplemented init-with-coder initialisers.

## Comments

In the very rare occasions when they are needed, use comments to explain **why** a particular piece of code does something. Comments must be kept up-to-date, or altogether deleted. Never write comments that tell what the code **does**.

Avoid block comments inline with code, as the code should be as self-documenting as possible. _Exception: This does not apply to those comments used to generate documentation._

Avoid the use of C-style comments (`/* ... */`). Prefer the use of double- or triple-slash.

## TODO comments

`TODO` comments must have a ticket number. When writing the comment, use the following format:

`// TODO: [AAA] (YYYY-MM-DD) [CNSMR-XX] Your todo comment goes here.`

where `AAA` are the author's initials, `YYYY-MM-DD` is the date (if appropriate), and `CNSMR-XX` is the ticket number associated with the comment.

## Classes and Structures

Remember, structs have [value semantics](https://developer.apple.com/library/mac/documentation/Swift/Conceptual/Swift_Programming_Language/ClassesAndStructures.html#//apple_ref/doc/uid/TP40014097-CH13-XID_144). Use structs for things that do not have an identity. An array that contains `[a, b, c]` is really the same as another array that contains `[a, b, c]` and they are completely interchangeable. It doesn't matter whether you use the first array or the second, because they represent the exact same thing. That's why arrays are structs.

Classes have [reference semantics](https://developer.apple.com/library/mac/documentation/Swift/Conceptual/Swift_Programming_Language/ClassesAndStructures.html#//apple_ref/doc/uid/TP40014097-CH13-XID_145). Use classes for things that do have an identity or a specific life cycle. You would model a ViewModel as a class because two ViewModel objects might be in a different state. Although they might represent the same screen, it doesn't mean they have the same state (e.g. `.loading` vs `.loaded([T])`.

## Use of Self

For conciseness, avoid using `self` since Swift does not require it to access an object's properties or invoke its methods.

Use self only when required by the compiler (in `@escaping` closures, or in initializers to disambiguate properties from arguments). In other words, if it compiles without `self` then omit it.

## Computed Properties

For conciseness, if a computed property is read-only, omit the get clause. The get clause is required only when a set clause is provided. For single-expressions where the context is clear, both explicit and implicit returns can be used:

**Preferred**:
```swift
var diameter: Double { radius * 2 }

// Or

var diameter: Double {
  return radius * 2
}
```

**Not Preferred**:
```swift
var diameter: Double {
  get {
    return radius * 2
  }
}
```

## Final

Mark classes or members as `final` when appropriate. In the below example, `Box` has a particular purpose and customization in a derived class is not intended. Marking it `final` makes that clear.

```swift
// Turn any generic type into a reference type using this Box class.
final class Box<T> {
  let value: T
  init(_ value: T) {
    self.value = value
  }
}
```

## Functions

### Declarations

Keep short function declarations on one line including the opening brace:

```swift
func reticulateSplines(spline: [Double]) -> Bool {
  // reticulate code goes here
}
```

For functions with long signatures, more than the recommended length, put each parameter on a new line and add an extra indent on subsequent lines. Note that the closing parenthesis aligns with the f in `func`. This is _not_ how Xcode indents these blocks of code so keep an eye out for violations of this guideline.

```swift
func reticulateSplines(
  spline: [Double],
  adjustmentFactor: Double,
  translateConstant: Int,
  comment: String
) -> Bool {
  // reticulate code goes here
}
```

Don't use `(Void)` to represent the lack of an input; simply use `()`.
Use `Void` instead of `()` for closure outputs.
Don't use `Void` for function outputs as it is redundant.

**Preferred**:

```swift
func updateConstraints() {
  // magic happens here
}

typealias CompletionHandler = (result) -> Void
```

**Not Preferred**:

```swift
func updateConstraints() -> () {
  // magic happens here
}

typealias CompletionHandler = (result) -> ()
```

For single-expression functions where the context is clear, both explicit and implicit returns can be used:

```swift
func encode(character: Character) -> String {
    character.encoded()
}

// Or

func encode(character: Character) -> String {
    return character.encoded()
}
```

### Calls

Mirror the style of function declarations at call sites. Calls that fit on a single line should be written as such:

```swift
let success = reticulateSplines(splines)
```

If the call site must be wrapped, put each parameter on a new line, indented one additional level. Note that the parentheses follow the same rules as braces.

```swift
let success = reticulateSplines(
  spline: splines,
  adjustmentFactor: 1.3,
  translateConstant: 2,
  comment: "normalize the display"
)
```

## Closure Expressions

Use trailing closure syntax only if there's a single closure expression parameter at the end of the argument list. Give the closure parameters descriptive names.

**Preferred**:
```swift
UIView.animate(withDuration: 1.0) {
  self.myView.alpha = 0
}

UIView.animate(withDuration: 1.0, animations: {
  self.myView.alpha = 0
}, completion: { finished in
  self.myView.removeFromSuperview()
})
```

**Not Preferred**:
```swift
UIView.animate(withDuration: 1.0, animations: {
  self.myView.alpha = 0
})

UIView.animate(withDuration: 1.0, animations: {
  self.myView.alpha = 0
}) { f in
  self.myView.removeFromSuperview()
}
```

For single-expression closures where the context is clear, use implicit returns:

```swift
attendeeList.sort { a, b in
  a > b
}
```

Chained methods using trailing closures should be clear and easy to read in context. Moreover, they should go one per line. Example:

```swift
let value = numbers
  .map {$0 * 2}
  .filter {$0 > 50}
  .map {$0 + 10}
```

## Types

Always use Swift's native types and expressions when available. Swift offers bridging to Objective-C so you can still use the full set of methods as needed.

**Preferred**:
```swift
let width = 120.0                                    // Double
let widthString = "\(width)"                         // String
```

**Less Preferred**:
```swift
let width = 120.0                                    // Double
let widthString = (width as NSNumber).stringValue    // String
```

**Not Preferred**:
```swift
let width: NSNumber = 120.0                          // NSNumber
let widthString: NSString = width.stringValue        // NSString
```

In drawing code, use `CGFloat` if it makes the code more succinct by avoiding too many conversions.

### Constants

Constants are defined using the `let` keyword and variables with the `var` keyword. Always use `let` instead of `var` if the value of the variable will not change.

**Tip:** A good technique is to define everything using `let` and only change it to `var` if the compiler complains!

You can define constants on a type rather than on an instance of that type using type properties. To declare a type property as a constant simply use `static let`. Type properties declared in this way are generally preferred over global constants because they are easier to distinguish from instance properties. Example:

**Preferred**:
```swift
enum Math {
  static let e = 2.718281828459045235360287
  static let sqrt2 = 1.41421356237309504880168872
}

let hypotenuse = side * Math.sqrt2

```
**Note:** The advantage of using a case-less enumeration is that it can't accidentally be instantiated and works as a pure namespace.

**Not Preferred**:
```swift
let e = 2.718281828459045235360287  // pollutes global namespace
let sqrt2 = 1.41421356237309504880168872

let hypotenuse = side * sqrt2
```

### Static Methods and Variable Type Properties

Static methods and type properties work similarly to global functions and global variables and should be used sparingly. They are useful when functionality is scoped to a particular type or when Objective-C interoperability is required.

### Optionals

Declare variables and function return types as optional with `?` where a `nil` value is acceptable.

Use implicitly unwrapped types declared with `!` only for instance variables that you know will be initialized later before use, such as subviews that will be set up in `viewDidLoad()`. Prefer optional binding to implicitly unwrapped optionals in most other cases.

When accessing an optional value, use optional chaining if the value is only accessed once or if there are many optionals in the chain:

```swift
textContainer?.textLabel?.setNeedsDisplay()
```

Use optional binding when it's more convenient to unwrap once and perform multiple operations:

```swift
if let textContainer = textContainer {
  // do many things with textContainer
}
```

When naming optional variables and properties, avoid naming them like `optionalString` or `maybeView` since their optional-ness is already in the type declaration.

For optional binding, shadow the original name whenever possible rather than using names like `unwrappedView` or `actualLabel`.

**Preferred**:
```swift
var subview: UIView?
var volume: Double?

// later on...
if let subview = subview,
   let volume = volume {
  // do something with unwrapped subview and volume
}

// another example
UIView.animate(withDuration: 2.0) { [weak self] in
  guard let self = self else { return }
  self.alpha = 1.0
}
```

**Not Preferred**:
```swift
var optionalSubview: UIView?
var volume: Double?

if let unwrappedSubview = optionalSubview {
  if let realVolume = volume {
    // do something with unwrappedSubview and realVolume
  }
}

// another example
UIView.animate(withDuration: 2.0) { [weak self] in
  guard let strongSelf = self else { return }
  strongSelf.alpha = 1.0
}
```

### Lazy Initialization

Consider using lazy initialization for finer grained control over object lifetime. This is especially true for `UIViewController` that loads views lazily. You can either use a closure that is immediately called `{ }()` or call a private factory method. Example:

```swift
lazy var locationManager = makeLocationManager()

private func makeLocationManager() -> CLLocationManager {
  let manager = CLLocationManager()
  manager.desiredAccuracy = kCLLocationAccuracyBest
  manager.delegate = self
  manager.requestAlwaysAuthorization()
  return manager
}
```

**Notes:**
  - `[unowned self]` is not required here. A retain cycle is not created.
  - Location manager has a side-effect for popping up UI to ask the user for permission so fine grain control makes sense here.


### Type Inference

Prefer compact code and let the compiler infer the type for constants or variables of single instances. Type inference is also appropriate for small, non-empty arrays and dictionaries. When required, specify the specific type such as `CGFloat` or `Int16`.

**Preferred**:
```swift
let message = "Click the button"
let currentBounds = computeViewBounds()
var names = ["Mic", "Sam", "Christine"]
let maximumWidth: CGFloat = 106.5
```

**Not Preferred**:
```swift
let message: String = "Click the button"
let currentBounds: CGRect = computeViewBounds()
var names = [String]()
```

#### Type Annotation for Empty Arrays and Dictionaries

For empty arrays and dictionaries, use type annotation. (For an array or dictionary assigned to a large, multi-line literal, use type annotation.)

**Preferred**:
```swift
var names: [String] = []
var lookup: [String: Int] = [:]
```

**Not Preferred**:
```swift
var names = [String]()
var lookup = [String: Int]()
```

**NOTE**: Following this guideline means picking descriptive names is even more important than before.


### Syntactic Sugar

Prefer the shortcut versions of type declarations over the full generics syntax.

**Preferred**:
```swift
var deviceModels: [String]
var employees: [Int: String]
var faxNumber: Int?
```

**Not Preferred**:
```swift
var deviceModels: Array<String>
var employees: Dictionary<Int, String>
var faxNumber: Optional<Int>
```

## Functions vs Methods

Free functions, which aren't attached to a class or type, should be used sparingly. When possible, prefer to use a method instead of a free function. This aids in readability and discoverability.

Free functions are most appropriate when they aren't associated with any particular type or instance.

**Preferred**
```swift
let sorted = items.mergeSorted()  // easily discoverable
rocket.launch()  // acts on the model
```

**Not Preferred**
```swift
let sorted = mergeSort(items)  // hard to discover
launch(&rocket)
```

**Free Function Exceptions**
```swift
let tuples = zip(a, b)  // feels natural as a free function (symmetry)
let value = max(x, y, z)  // another free function that feels natural
```

## Memory Management

Code (even non-production, tutorial demo code) should not create reference cycles. Analyze your object graph and prevent strong cycles with `weak` and `unowned` references. Alternatively, use value types (`struct`, `enum`) to prevent cycles altogether.

### Extending object lifetime

Extend object lifetime using the `[weak self]` and `guard let self = self else { return }` idiom. `[weak self]` is preferred to `[unowned self]` where it is not immediately obvious that `self` outlives the closure. Explicitly extending lifetime is preferred to optional chaining. Note how there is an empty line after the guard block.

**Preferred**
```swift
resource.request().onComplete { [weak self] response in
  guard let self = self else {
    return
  }

  let model = self.updateModel(response)
  self.updateUI(model)
}
```

**Not Preferred**
```swift
// might crash if self is released before response returns
resource.request().onComplete { [unowned self] response in
  let model = self.updateModel(response)
  self.updateUI(model)
}
```

**Not Preferred**
```swift
// deallocate could happen between updating the model and updating UI
resource.request().onComplete { [weak self] response in
  let model = self?.updateModel(response)
  self?.updateUI(model)
}
```

## Access Control

Using `private` and `fileprivate` appropriately adds clarity and promotes encapsulation. Prefer `private` to `fileprivate`; use `fileprivate` only when the compiler insists.

Only explicitly use `open`, `public`, and `internal` when you require a full access control specification.

Use access control as the leading property specifier. The only things that should come before access control are the `static` specifier or attributes such as `@IBAction`, `@IBOutlet` and `@discardableResult`.

**Preferred**:
```swift
private let message = "Great Scott!"

class TimeMachine {
  private dynamic lazy var fluxCapacitor = FluxCapacitor()
}
```

**Not Preferred**:
```swift
fileprivate let message = "Great Scott!"

class TimeMachine {
  lazy dynamic private var fluxCapacitor = FluxCapacitor()
}
```

Use `private`, `fileprivate`, `internal`, and `public` access-level modifiers on each property, type or function declared in an `extension`, rather than having a single access-level modifier for the entire `extension`.

**Preferred**:
```swift
extension TimeMachine {
  fileprivate var fluxCapacitor = FluxCapacitor()
}
```

**Not Preferred**:
```swift
fileprivate extension TimeMachine {
  var fluxCapacitor = FluxCapacitor()
}
```

## Control Flow

Prefer the `for-in` style of `for` loop over the `while-condition-increment` style.

**Preferred**:
```swift
for _ in 0 ..< 3 {
  print("Hello three times")
}

for (index, person) in attendeeList.enumerated() {
  print("\(person) is at position #\(index)")
}

for index in stride(from: 0, to: items.count, by: 2) {
  print(index)
}

for index in (0 ... 3).reversed() {
  print(index)
}
```

**Not Preferred**:
```swift
var i = 0
while i < 3 {
  print("Hello three times")
  i += 1
}


var i = 0
while i < attendeeList.count {
  let person = attendeeList[i]
  print("\(person) is at position #\(i)")
  i += 1
}
```

### Ternary Operator

The Ternary operator, `?:` , should only be used when it increases clarity or code neatness. A single condition is usually all that should be evaluated. Evaluating multiple conditions is usually more understandable as an `if` statement or refactored into instance variables. In general, the best use of the ternary operator is during assignment of a variable and deciding which value to use.

**Preferred**:

```swift
let value = 5
result = value != 0 ? x : y

let isHorizontal = true
result = isHorizontal ? x : y
```

**Not Preferred**:

```swift
result = a > b ? x = c > d ? c : d : y
```

## Golden Path

When coding with conditionals, the left-hand margin of the code should be the "golden" or "happy" path. That is, don't nest `if` statements. Multiple return statements are OK. The `guard` statement is built for this.

**Preferred**:
```swift
func computeFFT(context: Context?, inputData: InputData?) throws -> Frequencies {

  guard let context = context else {
    throw FFTError.noContext
  }
  guard let inputData = inputData else {
    throw FFTError.noInputData
  }

  // use context and input to compute the frequencies
  return frequencies
}
```

**Not Preferred**:
```swift
func computeFFT(context: Context?, inputData: InputData?) throws -> Frequencies {

  if let context = context {
    if let inputData = inputData {
      // use context and input to compute the frequencies

      return frequencies
    } else {
      throw FFTError.noInputData
    }
  } else {
    throw FFTError.noContext
  }
}
```

When multiple optionals are unwrapped either with `guard` or `if let`, minimize nesting by using the compound version when possible. In the compound version, place the `guard` on its own line, then ident each condition on its own line. The `else` clause is indented to match the `guard` keywork and the code is indented one additional level, as shown below. Note that this is not Xcode's way of implementing this. Example:

**Preferred**:
```swift
guard
  let number1 = number1,
  let number2 = number2,
  let number3 = number3
else {
    fatalError("impossible")
}
// do something with numbers
```

**Not Preferred**:
```swift
if let number1 = number1 {
  if let number2 = number2 {
    if let number3 = number3 {
      // do something with numbers
    } else {
      fatalError("impossible")
    }
  } else {
    fatalError("impossible")
  }
} else {
  fatalError("impossible")
}
```

### Failing Guards

Guard statements are required to exit in some way. Generally, this should be simple one line statement such as `return`, `throw`, `break`, `continue`, and `fatalError()`. Large code blocks should be avoided. If cleanup code is required for multiple exit points, consider using a `defer` block to avoid cleanup code duplication.

## Semicolons

Swift does not require a semicolon after each statement in your code. They are only required if you wish to combine multiple statements on a single line.

Do not write multiple statements on a single line separated with semicolons.

**Preferred**:
```swift
let swift = "not a scripting language"
```

**Not Preferred**:
```swift
let swift = "not a scripting language";
```

**NOTE**: Swift is very different from JavaScript, where omitting semicolons is [generally considered unsafe](http://stackoverflow.com/questions/444080/do-you-recommend-using-semicolons-after-every-statement-in-javascript)

## Parentheses

Parentheses around conditionals are not required and should be omitted.

**Preferred**:
```swift
if name == "Hello" {
  print("World")
}
```

**Not Preferred**:
```swift
if (name == "Hello") {
  print("World")
}
```

In larger expressions, optional parentheses can sometimes make code read more clearly.

**Preferred**:
```swift
let playerMark = (player == current ? "X" : "O")
```

## Multi-line String Literals

When building a long string literal, you're encouraged to use the multi-line string literal syntax. Open the literal on the same line as the assignment but do not include text on that line. Indent the text block one additional level and keep the trailing triple quotes indented to match the `let` keyword.

**Preferred**:

```swift
let message = """
  You cannot charge the flux \
  capacitor with a 9V battery.
  You must use a super-charger \
  which costs 10 credits. You currently \
  have \(credits) credits available.
  """
```

**Not Preferred**:

```swift
let message = """You cannot charge the flux \
  capacitor with a 9V battery.
  You must use a super-charger \
  which costs 10 credits. You currently \
  have \(credits) credits available.
  """
```

**Not Preferred**:

```swift
let message = "You cannot charge the flux " +
  "capacitor with a 9V battery.\n" +
  "You must use a super-charger " +
  "which costs 10 credits. You currently " +
  "have \(credits) credits available."
```

## References

* [The Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
* [The Swift Programming Language](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/index.html)
* [Using Swift with Cocoa and Objective-C](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/index.html)
* [Swift Standard Library Reference](https://developer.apple.com/library/prerelease/ios/documentation/General/Reference/SwiftStandardLibraryReference/index.html)

## SwiftLint rules

This is the complete list of rules that are currently enabled on our linter, or will be in the future:
- [ ] generic_type_name
- [ ] duplicate_imports
- [ ] unused_import
- [ ] vertical_whitespace_closing_braces
- [ ] vertical_whitespace_opening_braces
- [x] void_return
- [ ] trailing_comma
- [ ] trailing_semicolon
- [ ] closure_spacing
- [ ] closure_parameter_position
- [ ] comma
- [ ] leading_whitespace
- [ ] let_var_whitespace
- [ ] operator_whitespace
- [ ] return_arrow_whitespace
- [ ] statement_position
- [ ] trailing_newline
- [ ] trailing_whitespace
- [ ] colon
- [ ] multiline_arguments
- [ ] multiline_arguments_brackets
- [ ] multiline_parameters
- [ ] multiline_parameters_brackets
- [ ] multiple_closures_with_trailing_closure
- [ ] multiline_function_chains
- [ ] convenience_type
- [ ] redundant_type_annotation
- [ ] redundant_void_return
- [ ] syntactic_sugar
- [ ] private_over_fileprivate
- [ ] yoda_condition
- [ ] opening_brace
- [ ] control_statement
Hello World
