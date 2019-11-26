# Decouple Snapshot tests from unit tests
* Author(s): Adam Borek

## Introduction
The purpose of this proposal is to decouple snapshot tests from unit tests to be able to run only unit-tests which takes much less time to execute than snapshot tests.

The goal of this proposal is to make it possible to run only unit-tests **locally** in Xcode. Improving CI run time is not a goal of this proposal.

## Motivation
Right now, when we trigger all unit-tests (by pressing cmd+U), the snapshot tests are also run.  It takes **14 minutes** to run all unit+snapshot tests which is very long. Those 14 minutes doesn't include the build time 😱.

Unit-tests should run as quickly as possible, so we can have a quick feedback about our changes that break tests.\
\
Ideally, it would be nice to be able to run only unit-tests when we don't work on UI. Unit-tests in separation take about ~2% of the execution time.

## Proposed solution
Decouple snapshot tests from unit test by creating `*SnapshotTests` targets in every framework which has snapshots.

We would also need to create a new scheme like `BabylonUnitTests` which would run only tests targets without snapshot tests targets.

`Babylon` scheme would still remain configuration to run all tests (unit + snapshots).

## Impact on existing codebase

1. We would have more tests targets
2. Once we create any test file we would need to be cautious to add it to the correct test target. Unit tests into `*Tests`, snapshot tests into `*SnapshotTests`
3. We would need to have additional scheme like `BabylonUnitTestsOnly` which would run only unit-tests on `cmd+u`.

## Alternatives considered

- **Xcode's 11 Test plans** - TestPlans won't help us in context of this proposal. We would still need to have 2 tests targets, even if we use test plans. Admittedly, TestPlans do have a possibility to include only a subset of tests. unfortunately, when we create a new testfile it would be automatically enabled in every testplan which uses corresponding test target. To exlude snapshot test being run in unit-test TestPlan we would need to manually untick the snapshot in this TestPlan. This is too errorprone and additional manuall step. Since TestPlans are not necessary and doesn't make this proposal any simpler, I don't think we should enable them as part of the proposal.
