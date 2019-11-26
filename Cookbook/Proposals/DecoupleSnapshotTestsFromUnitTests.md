# Decouple Snapshot tests from unit tests
* Author(s): Adam Borek

## Introduction
The purpose of this proposal is to decouple snapshot tests from unit tests to be able to run only unit-tests which takes much less time to execute than snapshot tests.

## Motivation
Right now when we run all unit-tests (by pressing cmd+U) we also run snapshot tests. Right now it takes **14 minutes**(😱) to run all unit+snapshot tests which is very long.\
\
Ideally, it would be nice to be able to run only snapshot tests when we don't work on UI.

## Proposed solution
Decouple snapshot tests from unit test by creating SnapshotTest targets in every framework which has snapshots.

We would also need to create a new scheme like `BabylonUniTestsOnly` which would run only tests targets without snapshot tests targets.

`Babylon` scheme would still remain configuration to run all tests (unit + snapshots).

## Impact on existing codebase

1. We would have more tests targets
2. Once we create any test file we would need to be cautious to add it to the correct test target. Unit tests into `*Tests`, snapshot tests into `*SnapshotTests`
3. We would need to have additional scheme like `BabylonUnitTestsOnly` which would run only unit-tests on `cmd+u`.

## Alternatives considered

- **Xcode's 11 Test plans** - Unfortunately, I haven't found a way to select test files per a configurations. I'm afraid we cannot use test plans.



