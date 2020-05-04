## Testing

Our team is composed by multiple squads which are responsible for specific parts of the product.

Based on that, **each squad is responsible for owning and maintaining their own testing, from unit tests to UI Automation tests**, meaning that **any failure should be investigated and fixed by the squad responsible**.
 
If the squad is unavailable, e.g. holidays, then one of the Release Engineers should take ownership of the failure when we are in the process of releasing a new version of that app; otherwise it should fallback to the Support Engineer.

### Execution

We use [fastlane](https://fastlane.tools) to run most of our common and frequent tasks and UI Automation tests are no exception, we have specific lanes defined for each part of the product and they can be triggered on demand, either by running them locally or on CI from the #ios-build channel.

```
# Trigger a lane to be executed locally from the terminal
$ bundle exec fastlane {lane}

# Trigger a lane to be executed on CI from the #ios-build channel
/fastlane {lane} branch:{branch}
```

Listing all lanes available can be done with `bundle exec fastlane list` in the terminal.

### QA

Each squad has a QA Engineer responsible for testing all the work done by the squad and they should work together with the engineers to make sure we are delivering good and stable features.

Our UI Automation tests take a significant amount of time to run so it's only executed every night, which means we don't detect if some feature breaks with the changes of a pull request automatically. For this reason, **both the iOS and QA Engineers are responsible for checking any potential failure** in any change done within the squad. This can be achieved by triggering the relevant lane for testing and ideally, this should be done during the review of the pull request, to avoid breakage.

When there's a suspicion that the changes may affect other parts of the product, the relevant lanes should be triggered to be tested, or ultimately, the entire suite should be executed to assert that nothing breaks within the product. This can be identified and done by either the iOS Engineer or the QA Engineer.

This also shows how fundamental it is having good communication between the iOS Engineer and the QA Engineer so they can work together effectively and be always in sync.
