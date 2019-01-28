# Refactor `Flow` to be a Struct

* Author: Martin Nygren
* Review Manager: Anders Ha

## Introduction

This proposal is inspired by the [Pointfree](https://www.pointfree.co) episodes on Witness Oriented design, [33](https://www.pointfree.co/episodes/ep33-protocol-witnesses-part-1), [34](https://www.pointfree.co/episodes/ep34-protocol-witnesses-part-2), [35](https://www.pointfree.co/episodes/ep35-advanced-protocol-witnesses-part-1), [36](https://www.pointfree.co/episodes/ep36-advanced-protocol-witnesses-part-2) and [39](https://www.pointfree.co/episodes/ep39-witness-oriented-library-design).

## Motivation

Currently `Flow` is defined as a `Protocol` and implemented by a couple of helper classes (e.g. `EmptyFlow`, `NavigationFlow`, `ModalFlow`) that are made available as calculated properties (`Flow.empty`, `UINavigationController.navigationFlow`, `UIViewController.modalFlow`). This implementation already indicates that modelling the concept of a `Flow` as struct with function variables is closer to what we want then defining `Flow` as a protocol. We would have preferred to extend various `UIKit` classes if modelling `Flow` as a protocol is a natural choice.

```Swift
extension UIViewController: Flow {
    public func present(_ viewController: UIViewController,
                      animated: Bool,
                      completion: (() -> Void)?) {
        self.present(viewController,
                             animated: animated,
                             completion: completion)
    }

    public func replace(with viewController: UIViewController,
                      animated: Bool) {
        present(viewController, animated: true)
    }

    public func dismiss(animated: Bool,
                      completion: (() -> Void)?) {

        if self.presentedViewController == nil {
            DispatchQueue.main.async { completion?() }
        } else {
            self.dismiss(animated: animated, completion: completion)
        }
    }
}
```

The above example would have several problems. What if we want to have a view controller that defines a flow for embedding one or more view controllers inside subviews? How sure are we that calling the completion block is something that we always want to do?

Another reason to change `Flow` from a protocol to a struct is that it makes it easier to inject side effects without impacting any business logic. One example is a requirement to post screen view events to the analytics service. Another to save user journeys to a local database to support a personalised home screen.

## Proposed solution

Redefine `Flow` like this.

```Swift
/// Represents the root or containing view of a stack of view controllers.
public struct Flow {

    public let presentViewController: (UIViewController, Bool, (() -> Void)?) -> Void

    public let replaceViewController: (UIViewController, Bool) -> Void

    public let dismissViewController: (Bool, (() -> Void)?) -> Void

    public let currentViewController: () -> UIViewController?

    // Initialiser omitted.
}
```

The variable names have been chosen to allow us to keep all existing convenience overrides. The new method `currentViewController` has been added to support side effects that need to record the current screen. It is a piece of state that every `Flow` instance must maintain to work correctly, but it has thus far never been needed by any business logic.

## Impact on existing codebase

We would need to update the implementation of all structs and classes that implement `Flow`, there are eight of them in our code base. A couple of them (I think three or four) would need to use composition with a `Flow` instance in their public interface. With the exception of referencing a flow instance in a small number of places there would be no further changes to our code bases.

## Alternatives considered

Main alternative is, of course, to keep `Flow` as a protocol. Other than being a less flexible design, I believe it would also make it a more difficult and painful to support requirements for posting analytics data. The only alternative to decorating `Flow` instances with a side effect to post screen view events that I can think of is to override, or observe calls to, `viewDidAppear`.
