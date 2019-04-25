# Standardise Setup of Models in Tests

* Author: Witold Skibniewski
* Review Manager: TBD

## Introduction

Goal of this proposal is to standardise and simplify test setup when it comes to models. At the moment we already have a few patterns in place to do this and it's not always clear which one to use.

Another goal related to this is for setup code to contain only values relevant to the tested logic. This would improve experience of setting up state in tests and maintenance later on.

## Motivation

<!-- // This section should the answer the `why?`. -->

<!-- Describe the problems that this proposal seeks to address. If the
problem is that some common pattern is currently hard to express, show
how one can currently get a similar effect and describe its
drawbacks. If it's completely new functionality that cannot be
emulated, motivate why this new functionality would help Swift
developers create better Swift code. -->

Well-structured test code has a few distinct sections. One way to split them is to use Arrange, Act, Assert pattern. This proposal focuses on improving the initial Arrange stage of the test. First improvment is to make writing setup part as easy as possible. Second is to make this code easy to understand to help with readability and maintanance.

So far the most used pattern for setting up values in tests is to add enum for namespacing and introduce `make` test helper method. Enumeration's name follows "`MockSomeNameDTO`" pattern, so for example tests  call `MockPatientDetailsDTO.make()`. There are a few issues with this approach:

- Values passed to model's initializer are hidden inside the helper method and you don’t have any knowledge and control over them.
- `Mock` prefix doesn’t really fit models. Most often models are just data with some limited behaviour. Naming of the namespace is misleading and to work with value types you don't really need mocks.
> The term "mock" has a precise definition as well, as a specific sub-type of test double. A mock object asserts that certain invocations are made on itself, and will raise exception as soon as any unexpected interactions take place. [[source](https://github.com/testdouble/contributing-tests/wiki/Mock#precise-use)]

- Naming of namespacing enums is inconsistent e.g. `MockPatientDetailsDTO` for `PatientDTO`.
- Sometimes there are multiple `make` helpers to maintain. See more details about issues with this in "Object Mother" section in "Altenratives considered".

In our codebase there are multiple implementations of this pattern with variations in naming and functionality, e.g.

- `MessageTestData.makeMessages`,
- `MessageTestData.makeMessageResponse`,
- `MockPatientDetailsDTO.makeWithPartner`,
- `MockAddressDTO.make`,
- `CoreSessionDTO.mock`.

On top of that some tests create value type by directly calling the initializer.

Those inconsistencies cause friction when trying to setup state in tests. It's hard to discover existing test helpers. Usage of unparametrized factory methods (e.g. `MockAddressDTO.make()`) makes it hard to understand on what data the test depends.

## Proposed solution

<!-- // This section should the answer the `how?`. -->
<!-- Describe your solution to the problem. Provide examples and describe
how they work. Show how your solution is better than current
workarounds: is it cleaner, safer, or more efficient? -->

Proposed approach is similar to what we often do by the convention with `MockSomeNameDTO.make` pattern. It aims to improve current situation by introducing a few important rules.

1. Helpers for models should be defined as an **extension of the model type** in a test target or framework with test utilities.
1. Helper method should be named `fixture` to signify that it's part of the tests.
1. Helpers should use parameters that mirror model's initializer.
1. All of helper method parameters should have default value. This will make relevant data stand out and irrelevant data will be provided by defaults.

Let's see sample implementation. First define extension on an existing type, instead of introducing extra type for namespacing.

```swift
// Example for points 1. and .2

struct Foo {
    let a: Int
    let b: String
}

// add extension in test target or test utilities framework:

extension Foo {
    static func fixture() -> Foo {
        return Foo(a: 1, b: "xyz")
    }
}
```

Building upon this, use the same arguments in `fixture` factory method as in the models's initializer. Provide a default value for each argument. Those values should be "reasonable defaults", e.g. for identifier it can be `"1"` value. Example of adjusted `Foo.fixture` method:

```swift
// Example for points 3. and .4

extension Foo {
    static func fixture(a: Int = 1, x: String = "xyz") -> Foo {
        return Foo(a: a, x: x)
    }
}
```

This provides necessary customization point and allows to skip setup of irrelevant data. The values used to put test subject in the initial state stand out more thanks to this and make test easier to understand.

If the type of argument is another model, you can use its `.fixture()` helper to provide default value.

```swift
struct Bar {
    let foo: Foo
    let c: String
}

extension Bar {
    static fixture(foo: Foo = .fixture(), c: String = "any") -> Bar {
        return Bar(foo: foo, j: c)
    }
}
```

Following example illustrates how those helpers can nicely compose and how only single value of `x` argument is customized (and thus relevant to the test code that would follow).

```swift
let bar = Bar.fixture(foo: .fixture(x: "value relevant to test"))
```

---

Benefits of proposed solution:

- Discoverable test helpers: enter the type you need and follow with `.fixture` to see whether the method is available.
- Clear setup of automated test: only the relevant values are passed to `.fixture` and thanks to this test is more readable.
- Single place to maintain test helper code.

## Impact on existing codebase

<!-- // This section should explain, assuming this proposal is accepted, how much effort it would require for it to be implemented in our codebase. Other concerns should be raised, if it's a significant deviation from our stack. -->


1. Naming the helper `fixture` will ensure no conflicts with production code. It might not be the case if helper was named `make`.

2. Updating existing code

The `MockPatientDetailsDTO.make` helper is a stand out with 92 occurences. Next is `MockRegionDTO.make` with just 9 occurences. I propose to first update existing methods which match most common patterns , e.g. `Mock\w+\DTO\.\w+` regular expression. Other helper methods, which aren't that straightforward to find (see inconsistencies mentioned in "Motivation" section), could be updated on the go as we work with tests that use those old-style helpers. If change is more involved, ticket could be created and change would be scheduled separately.

3. Adopting in new tests

All new tests should adopt `fixture` convention. If the extension is not there, developer should add one. Besides outliers mentioned in 2., existing helper methods are used at most in 2 places, so updating existing code which uses old-style helpers should also be considered.

## Alternatives considered

<!-- // This section describes what other approaches were considered and why this one was chosen. -->

### Standardize usage of `Mock` prefix and `mock` name factory method

```
enum MockFoo {
    static func mock(a: Int = 1, x: String = "xyz") -> Foo {
        return Foo(foo: foo, bar: bar)
    }   
}
```

Why not:

- For each value you'd like to setup in test, you need to introduce new type just for namespacing purposes. When refactoring it would be easy for those names to diverge and limit discoverability of test helper.
- "Mock" is misleading. Term "mock" is very overloaded, so let's set on this short definition first (["TestDouble", martinfowler.com](https://martinfowler.com/bliki/TestDouble.html)):

> Mocks are pre-programmed with expectations which form a specification of the calls they are expected to receive. They can throw an exception if they receive a call they don't expect and are checked during verification to ensure they got all the calls they were expecting.

It's clear that "mock" doesn't fit the issue we're dealing with in this proposal. Using "mock" term also may wrongly give the idea that returned value is a test double, while in fact it's a type used production.

### Use Object Mother pattern to setup test data

What's an Object Mother? To quote [Nat Pryce](http://natpryce.com/articles/000714.html):

> An Object Mother is a class that contains a number of (usually static) Factory Methods that create objects for use in tests. For example, we could create an Object Mother for invoices we want to use in tests:
 >
> ```java
> Invoice invoice = TestInvoices.newDeerstalkerAndCapeInvoice();
> ```
> An Object Mother helps keep tests readable by moving the code that creates new objects out of the tests themselves and giving clear names to the objects being constructed. It also helps maintain the test data by gathering the code that creates new objects together into the Object Mother class and allowing it to be reused between tests.

This nicely fits the problem I'm aiming to fix with this proposal.

Let's consider some points against this approach. In our codebase we already have something similar, e.g.

```swift
public enum MockPatientDetailsDTO {
    public static func makeWithPartner() -> PatientDTO { ... }
    public static func makeUpdated() -> PatientDTO { ... }
    public static func makeMinor() -> PatientDTO { ... }
    public static func makeEphemeralMinor() -> PatientDTO { ... }
}
```

This kind of setup obscures what's going on and it's very hard to tell which data is changed to achieve end result. It's also impractical when we'd like to use similar data to one returned from existing helper, but with slight variation. We can't adjust the returned value, since our models have immutable properties. We could tweak data by adding parameters to those methods, but then we would end up with approach similar to proposed `fixture` helper. Model creation for tests would still be scattered across multiple places. Other solution would be to add another factory method on Object Mother, but this would get even less maintenable with time.

If we encounter case where there are many instances of passing the same parameters to the `fixture` method, then we could consider adding methods like this on case by case basis, rather than making it a default.

Another argument against widespread usage of Object Mothers is that when type's initializer changes, there will be many places in tests that need updating. In case of `fixture` approach there always will be just single helper to update: `fixture`'s arguments and initilizer call in `fixture` body.


### Use Test Builders to setup test data

Following comes from  [Test Data Builders: an alternative to the Object Mother pattern
](http://natpryce.com/articles/000714.html) blog post:

> If you are strict about your use of constructors and immutable value objects, constructing objects in a valid state can be a bit of a chore.

As you can see that post deals with the same issue we're facing here. Here's an example of the implementation (it's Java code from 2007):

```java
public class InvoiceBuilder {
    Recipient recipient = new RecipientBuilder().build();
    InvoiceLines lines = new InvoiceLines(new InvoiceLineBuilder().build());
    PoundsShillingsPence discount = PoundsShillingsPence.ZERO;

    public InvoiceBuilder withRecipient(Recipient recipient) {
        this.recipient = recipient;
        return this;
    }

    public InvoiceBuilder withInvoiceLines(InvoiceLines lines) {
        this.lines = lines;
        return this;
    }

    public InvoiceBuilder withDiscount(PoundsShillingsPence discount) {
        this.discount = discount;
        return this;
    }

    public Invoice build() {
        return new Invoice(recipient, lines, discount);
    }
}
```

Issue with this solution is that it introduces yet another type that I'd like to avoid (see our enum for namespacing described above). Another problem is that it requires a lot of boilerplate to write and in Swift a more elegant solution is possible by using default values of the arguments. For comparision see above example adopted to Swift and `fixture` helper method.


```swift
    extension Invoice {
    
        static func fixture(
            recipient: Recipient = .fixture(),
            lines: InvoiceLines = .fixture(),
            discount: PoundsShillingsPence = .zero
        ) ->  Invoice {
            return Invoice(recipient: recipient, lines: lines, discount: discount)
        }
    }
```

## References / Credits

- [Testing iOS Apps ("Use type-inferred factories" section)](http://merowing.info/2017/01/testing-ios-apps/#use-type-inferred-factories), Krzysztof Zabłocki.
- [Test Data Builders: an alternative to the Object Mother pattern](http://natpryce.com/articles/000714.html), Nat Pryce.
- Thanks to @ilyapuchka for steering me in right direction with naming of helper method. Now it nicely fits together.

---
