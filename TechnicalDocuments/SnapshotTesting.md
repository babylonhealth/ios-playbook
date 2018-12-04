Improved Snapshot Testing
=========================

## Introduction

This proposal is to replace the library that we use for snapshot testing ([`iOSSnapshotTestCase`](https://github.com/uber/ios-snapshot-test-case/)) with [`SnapshotTesting`](https://github.com/pointfreeco/swift-snapshot-testing).

## Motivation

### Cons of `iOSSnapshotTestCase`
* `iOSSnapshotTestCase` is an old library written in Objective-C that can only snapshot a `UIView` or `CALayer`.
* It has on occasion seemed to be quite fragile, reporting diffs when nothing changed, to the extent that we have had to increase the failure tolerance to quite a high value, and have even on a couple of occasions considered dropping snapshot testing altogether.
* it stores all references images in a single folder for all tests
* you have to manually find the failure images and diffs to see what went wrong (or use an app like FBSnapshotsViewer)
* You always have to explicitly set `recordMode` to `true` even if the test has no reference images yet.

### Pros of `SnapshotTesting`
* `SnapshotTesting` is a brand new library written in Swift by the [Pointfree](pointfree.co) duo. It's a great example of a protocol based API using struct based protocol witnesses as explained in the Pointfree videos on the subject.
* It supports snapshotting anything, not just `UIView` or `CALayer`. For example, you could snapshot a `URLRequest` instead of having to laboriously type out the expected values by hand.
You can snapshot anything as a text representation, for example, a view hierarchy, a Bento render tree, a struct, or a JSON dictionary.
* It is easy to extend the library to add explicit support for snapshotting of other types, instead of just using the `Any` strategy.
* Snapshots are stored in a `__Snapshots__` folder in the same folder hierarchy as the test source. This makes it easy to find relevant snapshots.
* It uses `XCTAttachment`s to store failure snapshots and diffs, which makes these available directly from the Xcode test report navigator, without requiring any other software or needing to hunt for them.
* It is fully Linux compatiable. Allowing snapshot testing to be used on projects that are not iOS or macOS (eg our merge bot).
* Even if `record` is set to `false` it will still record reference snapshots if none currently exist, so you only have to set it to `true` when updating snapshots becuase of changes.

### Cons of `SnapshotTesting`
* ~~It's a very new library and in active development. The developers themselves state *"This library should be considered alpha, and not stable. Breaking changes will happen often."* However, provided we stick to a specific version or commit in the Podfile, this should not be a big issue.~~

   `SnapshotTesting` is now [released at 1.0](https://www.pointfree.co/blog/posts/23-snapshottesting-1-0-delightful-swift-snapshot-testing) so this point no longer applies.

### Benchmarks
I used `BabylonChatBotUI` for running some rudimentary benchmarks between the two libraries as it seems to have the most snapshot tests and, more importantly, it seems to have *only* snapshot test so nothing else would pollute the times.

Average times for running `Cmd+U` on my machine in Xcode for `BabylonChatBotUI`:

iOSSnapshotTestCase | SnapshotTesting
-------------------|-----------------
11 seconds | 15 seconds

So, it would seem that `SnapshotTesting` is roughtly 36% slower than `iOSSnapshotTestCase` 😞 .

I have no idea where the speed difference is. Could well be just that unoptimized Swift is slower than Objective-C 🤷🏼‍♀️ . Still, I don't think this is a reason to reject the benefits of `SnapshotTesting`.


## Implementation

All our snapshot tests currently extend `SnapshotTestCase` which is itself an extension of `FBSnapshotTestCase`. Our tests don't call any `FBSnapshotTestCase` methods directly, they all use abstractions in `SnapshotTestCase`.

This means that it is easy to re-write the methods in `SnapshotTestCase` to use the functions in `SnapshotTesting` so there will be little or no change to our snapshot test cases and the change will be transparent to the team.

`assertSnapshot` is the entrypoint into the `SnapshotTesting` library and it is just a global free function, so there is actually no need to use an `XCTestCase` sub-class, but since we are using `SnapshotTestCase` as an abstraction we can continue to do so.
