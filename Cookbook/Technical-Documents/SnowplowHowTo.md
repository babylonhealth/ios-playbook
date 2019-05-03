# Posting Analytics Events to Snowplow

Snowplow is a data centric analytics platform that combines flexibility with reasonable type safety. This is achieved by verifying incoming events against a user defined schema before storing them. The same schema definitions are used to define database tables for storing analytics events. These events are stored in well defined database tables making it possible to match front end analytics with backend log data. The downside is that becomes slightly more complicated to post front end analytics events.

Snowplow has published a schema with two frequently used event types. The first is for screen views and the other is based on the fields in a Google Analytics event. In Snowplow lingo they are referred to as screen view event (`SPScreenView`) and structured events (`SPStructered`). Events with a bespoke definition are referred as unstructured events (`SPUnstructured`)

# Posting Screen View Events from the iOS Client

View controllers that are created with [BentoKit](https://github.com/Babylonpartners/Bento) and use the Babylon specialisation of [BoxViewController](https://github.com/Babylonpartners/Bento/blob/master/BentoKit/BentoKit/Screen/BoxViewController.swift) will post screen view events if the view model conforms to `ScreenNaming`.

```swift
final class AwesomeRenderer: BoxRenderer {
  ...
}

extension HomeRenderer: ScreenNaming {
     static var AwesomeRenderer: String { return ScreenNames.BestFeatureEver.awesome }
}
```

Screen names should be inside the `ScreenNames` namespace to avoid name clashes. Declaring the view model to conform to `ScreenNaming` will also assign the screen name as the default accessibility identifier.

View controllers that are not based on `BentoKit` should post a `ScreenEvent` in `viewWillAppear`.

```swift
class MassiveViewController: UIViewController {
...
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)

        Current.analyticsService.track(ScreenEvent.viewWillAppear(screen: ScreenNames.OldSchoolFeature.massive))
    }
...
}
```

# Posting Action Events from the iOS Client.

These events are typically posted for specific user actions. Typically they should be posted as side-effects to the signal producer that carries out the work triggered by the action. The event type should be declared inside the `ActionEvents` namespace.

```swift
extension Tracking.ActionEvents {
  enum AchievementUnlocked: AnalyticsEvent {
    case honorReward(name: String, honor: Int)
    case moneyReward(name: String, gold: Int)
  }
}
```

The event type needs to conform to `UnstructuredEventConvertable`:

```swift
extension Tracking.ActionEvents.AchievementUnlocked: UnstructuredEventConvertable {

    // NOTE: 
    // This is a schema for "specific" event.
    // Schema for "generic" event is already defined internally.
    var specificEventSchema: String { 
        return "iglu:com.thegame/achievement/jsonschema/1-0-0"
    }
    
    var specificEventDictionary: [String: Any] {
        switch self {
        case let .honorReward(_, honor):
            return ["honor": honor]
        case let .moneyReward(_, gold):
            return ["money": gold]
        }
    }

    var genericEventDictionary: [String: Any] {
        let action: String

        switch self {
        case let .honorReward(name, _):
            action = name
        case let .moneyReward(name, _):
            action = name
        }
        return [
            "category": "achievement",
            "action": action
        ]
    }
}
```

The generic event dictionary may also contain `label`, `property` and `value` where `label` and `property` are strings and `value` is a double. The `specificEventDictionary` dictionary must be consistent with the JSON defined by `specificEventSchema`. Finally, the event type needs to be added to the dispatch table.

```swift
fileprivate func makeDispatcher() -> AnalyticsEventDispatcher {
    let dispatcher = AnalyticsEventDispatcher()
        .forward(ActionEvents.AchievementUnlocked.self, to: SnowplowTracker.track)
}

extension SnowplowTracker {
    func track(_ event: ActionEvents.AchievementUnlocked) {
        realTracker.trackUnstructuredEvent(event)
    }
}
```

## Unit tests for Snowplow events

**(03 May 2019 TODO: Below is old document)**

There should be unit tests that verify that the unstructured event content is correct.

```swift
class AchievementUnlockedEventTests: XCTestCase {
    var mockEnvironment = MockSnowplowTrackingEnvironment()
    var mock: MockSnowplowTracking { return mockEnvironment.mockSnowplowTracking }

    override func tearDown() {
        mockEnvironment.reset()
    }

    func testConvertHonorAwarded() {
        var correctCall = false
        mock.trackUnstructuredEventAssertion = { unstructered in
            guard let json = unstructered.json else { return }

            expect(json.contains("honor")).to(beTrue())

            correctCall = true
        }

        mockEnvironment.analyticesService.track(ActionEvents.AchievementUnlocked.honorReward(name: "Unit Test Written", honor: 50))
        expect(correctCall).to(beTrue())
    }
```

How detailed the content verification needs to be is a judgement call.

## UI Tests for Snowplow Events

That the events are fired with the correct generic content should be verified by UI tests. For performance reasons it is preferable to add analytics verification to an existing UI test.

```swift
class AchievementUnlockedTests: BaseFeature {

    override func setUp() {
        super.setUp()
        self.enableMockSnowplowServer()
    }

    override func tearDown() {
        XCTAssert(snowplowServer.verifySnowplowEvents(), "Expected analytics events were not posted")
        super.tearDown()
    }

    let achievementSchema = "iglu:com.thegame/achievement/jsonschema/1-0-0"

    func test_honor_achievement_awarded() {
        self.snowplowServer.expectedSnowplowEvents = [
            .screenView(name: "achievement"),
            .unstructuredEvent(schema: achievementSchema, category: "achievement", action: "UI test written", label: nil)
        ]
        Given("I that I have completed the write UI test quest")
        ...
    }
```

This works by installing a mock server that receives the Snowplow traffic and verifies its content. It is likely that we can improve the stability and ergonomics of the mock server, but until we have a fuller picture of how it will work it is not possible to say how it should be improved.

## References
- [Snowplow Technical Documentation](https://github.com/snowplow/snowplow/wiki/SnowPlow-technical-documentation)
- [Snowplow iOS Documentation](https://github.com/snowplow/snowplow/wiki/iOS-Tracker)
- [Snowplow iOS Client Source Code](https://github.com/snowplow/snowplow-objc-tracker)
- [IGLU and schema detection](https://github.com/snowplow/iglu/wiki/Iglu-technical-documentation)
- [Event and schema definitions (Internal)](https://github.com/Babylonpartners/com.babylonhealth-schema-registry)
