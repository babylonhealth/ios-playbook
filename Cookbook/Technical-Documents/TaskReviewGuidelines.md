
# Technical test reviewer guidelines

This document describes the guidelines for reviewing technical task assignments that candidates work on during the recruitment process.
Every question is attributed with **S/M/J** or a combination of those, defining what level it relates to.

- **S** (expected of a senior-level task)
- **M** (expected of a mid-level task)
- **J** (expected of a junior-level task)

## General:

### Basics
- Does it have clear instructions on how to run the project? (SMJ)
- Are there any compile time issues? (SMJ)
- Does it meet functional requirements? (SMJ)
- Are there any run time issues? (SM)
- Does it have descriptive README? (SM)

### Good practices

- Is it testable? (S, some for M)
- Does it conform to the SOLID principles? (S, some for M)
- Does it use dependency injection? (S, some for M)
- Does it use descriptive naming? (SM)
- Is the code clean? (no dead code) (SM)
- Does it use encapsulation? (SM)
- Are there any warnings in the codebase? (SM)
- Are modules loosely coupled? (S)
- Does it use higher order functions? (bonus point)
- Side effects pushed to the edge? (bonus point)
- Is it modularized? (bonus point)

## Architecture:

### Networking
- Does it use `Codable`? (SMJ)
- Is it well abstracted? (S, some for M)
- Is it open for extensions? (like authorization, different routes and HTTP methods) (SM)
- Are errors propagated? (SM)
- Are requests cancelable? (S)

### Persistence
- Is it well abstracted? (it does not leak implementation details to other layers) (S)

### UI-Business logic
- Does `UIViewController` has only its clear responsibilities? (SM, some for J)
- Is the navigation abstracted? (SM)
- Is business logic state management done within UI state/actions? (bonus point)
- Is there a layer in between (Persistence & Networking) and ViewModel/Presenter/ViewController? (S)
- Does it use unidirectional data flow? (bonus point)
- Is there an abstraction of `UITableViewDataSource`/`UICollectionViewDataSource` (bonus point)

### UI
- Is the Auto Layout used? (SMJ)
- If Auto Layout is done in InterfaceBuilder, are constraints correct and not ambiguous? (SM)
- If Auto Layout is done in code, is it readable? (S)
- Are there any Auto Layout warnings in the console? (S)
- Are views composable? (S)
