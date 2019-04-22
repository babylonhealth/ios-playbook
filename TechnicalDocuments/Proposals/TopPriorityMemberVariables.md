# Top-priority member-variable and initializer declarations

* Author: Yasuhiro Inami
* Review Manager: Rui Peres

## Introduction

This proposal is to improve code readability for every declared type by **moving member variables (states) and initializers (constructors) to the top of the scope**.

## Motivation

The code becomes hard to read when types are heavily nested, especially when inner type's member variables appear before outer type's variables in the file.

For example, below code shows that we can't immediately figure out which member variables belong to which type, and what kind of constructors are available:

```swift
enum Outer {
    struct Inner {
        func foo() {
            ...
            ...
            ...
        }

        let a: A
        let b: B

        init(a: A, b: B) {
            ...
        }
    }

    func foo() {
        ...
    }

    case c

    var bar: Bar {
        ...
    }

    init?(c: C) {
        ...
    }

    case d(D)
}
```

Since understanding the data structure i.e. product type (member variables a.k.a. states) and sum type (enum cases a.k.a. constructors) are the key to understand the types, architecture, and whole business logic, it is important to organize the code as proposed in the next section.

## Proposed solution

**Move member variables (states) and initializers (constructors) to the top of the scope**, at least manually, and in future, automatically by formatter tool e.g. SwiftSyntax.

For example:

```swift
// Group constructors (enum cases).
enum Outer {
    case c
    case d(D)

    // NOTE: This can be implemented as `extension Outer` as well
    init?(c: C) {
        ...
    }
}

// Methods (non-constructors) should move to extension scope to separate from constructors.
// Or, they can be in the same scope as `enum Outer` but MUST NOT be at the top of its scope.
extension Outer {
    func foo() {
        ...
    }

    var bar: Bar {
        ...
    }
}

// Declare inner types using outer type's extension
// (so that entire scope can be easy to migrate to other file if needed)
extension Outer {

    // Group member variables (struct stored property).
    struct Inner {
        let a: A
        let b: B

        init(a: A, b: B) {
            ...
        }

        // NOTE: This can also be moved to `extension Outer.Inner`.
        func foo() {
            ...
            ...
            ...
        }
    }
}
```

The main idea comes from Rust where [methods are defined under an `impl` block](https://doc.rust-lang.org/rust-by-example/fn/methods.html).
Also, Haskell's `data` / `newtype` declarations allow us to write getters (member variables) and value constructors only.

## Impact on existing codebase

Requires many efforts for manual refactoring and resolving conflicts.

(But we can start applying this rule from new codebase, and can be easily migrated once formatter is supported)

## Alternatives considered

- No alternatives. (Reject this proposal and stay as is)

## Appendix

See [#74](https://github.com/Babylonpartners/ios-playbook/pull/74) for more strict declaration order rule, but it is NOT a part of this proposal.
(This proposal only contains section 0 to 3)

```
Data type declaration (required in declaration scope):
0. type stored properties (NOTE: this rarely appears in practice because singleton is discouraged)
1. instance stored properties (struct), or enum cases
2. designated initializers
3. deinit

(Below order is optional)

In extension (if possible):
4. convenience initializers
5. instance computed properties
6. instance methods

In extension (if possible):
7. type computed properties
8. type methods

In extension (if possible):
9. nested types
```
