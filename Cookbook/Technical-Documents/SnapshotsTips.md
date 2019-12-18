# Snapshot Testing tips

## What are snapshot tests?

We're testing the visual layer of our apps with snapshot tests. In our case snapshots are images of screens and UI components. They are stored in PNG files.

We're using the [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library from pointfree to record and compare our snapshots.

This kind of tests helps us catching any regressions in visual appearance. For example they are very useful when working on a component which might be used on many screens.

## Tips

### Building UI

Until we adopt [SwiftUI previews](https://nshipster.com/swiftui-previews/), snapshots are the fastest way to work iteratively on new UI. 
Using snapshot tests as feedback mechanism when building UI is much faster than compiling, launching the full app, reaching the desired page and state, and verifying appearance only then.

An example of a workflow for adding a new screen:

1. Initial setup
      - Add files for a new screen with "Bento Box" template. To get renderer test file tick "Include Tests" box there or add it separately with "Bento Renderer Snapshot Test" template.
    -  Set `recordMode` to `true` in the snapshot test case - you'll be making a lot of changes.
2. Build the UI in the [`Renderer`](https://github.com/babylonhealth/ios-playbook/blob/master/Cookbook/Technical-Documents/Architecture.md#renderer) from the current `State`, by 🔁 **repeating the following steps until done**:
    - Make some small changes.
    - Run the snapshot tests to record any changes (the "[Test again](https://github.com/babylonhealth/ios-playbook/blob/1a88e2e0090aee3128df70f84dddb7c038f7f15b/Cookbook/Technical-Documents/XcodeTips.md#testing)" hotkey is very handy here).
    - Verify the results by manually checking the newly recorded snapshots. You'll find them in the `__Snapshots__` folder next to the tests file.
3. Once ready, set `recordMode` back to `false` in the snapshot test and make sure to commit image for reference.


### Reviewing snapshot tests in PRs

It's important for us to review new snapshots and snapshot changes during code reviews. GitHub UI doesn't make it easy - PNG images with snapshot files are by default collapsed when you're viewing PR changes. Here's a handy bookmarklet* you can use to open all those snapshots at once.

1. Drag the link to your bookmarks bar.

[[GitHub] show rich diffs](https://github.com/babylonhealth/ios-playbook)

2. Update its address with this JS snippet:

```js
javascript:Array.from(document.getElementsByClassName('btn%20btn-sm%20BtnGroup-item%20tooltipped%20tooltipped-w%20rendered%20js-rendered')).forEach(function(button)%7Bbutton.click()%7D);
```


To test it you can check this [PR](https://github.com/babylonhealth/ios-playbook/pull/303/files), as it contains a few images with diagrams.

*Looks like GitHub doesn't allow JS links, that's why instruction has two steps.

### Testing with localization

It's possible to use snapshot tests to verify that screens look correct with real world data and localized copies.

On one hand it means that snapshot tests will fail when we update a copy, on the other hand it makes sure that someone will check whether this screen still looks correct after a copy change.

To do that you'll need to have copies available in tests. Setting this up involves:

- Adding a **reference** to strings file ("Localizable.strings") in test target (instead of making a hard copy of the file). This way the strings file used by the app can be referenced by multiple test bundles.
- Switching bundle(s) in tests, for example see `TestAppointmentLocalizationBundleUpdater`.

### Testing configurations

Before adding a snapshot test consider if it's worth it to test all possible device combinations for a given state.

Let's say that we implement 2 secondary states for a new screen - loading and error state. 3 devices x 2 states x 2 visual styles = 12 new snapshots. It's often the case that the secondary screens only display screen's title, a loading or empty state component, maybe a few components which are already tested in primary state snapshots.

The lower-level components for loading and error states are already well-tested, so sometimes a single snapshot per device for a state like this may be enough. In this example the number of snapshots would go from 12 to 4 and we could still be pretty confident that the UI looks fine in those states.

Keep in mind that number of snapshots can explode very quickly and can harm running time of tests. If you record a lot of snapshots, then it's also possible that not all of them will be checked during code reviews.
