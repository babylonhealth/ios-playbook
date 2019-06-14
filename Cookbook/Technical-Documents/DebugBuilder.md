Debug Builder
======================

[\[CNSMR\-1602\] Add \`DebugAuthenticatedRootBuilder\` for faster UI debugging iteration by inamiy · Pull Request \#7645 · Babylonpartners/babylon\-ios](https://github.com/Babylonpartners/babylon-ios/pull/7645)

Above PR introduces `DebugAuthenticatedRootBuilder` that allows to directly show a target view builder after authentication.

This feature improves overall UI debugging iteration speed.

## How to make a debug-builder

1. Add a new case in `enum DebugBuilderPattern`
2. Create a (mock) builder in `DebugAuthenticatedRootBuilder`
3. Update `Settings.bundle/Root.plist` by adding a new case key
4. Build and launch your app at least once after those changes, so that the Settings app can now discover the new values in the `Root.plist`
4. Set `Settings.bundle`'s userDefaults flag via `Settings.app`
5. Launch the app

## Example

`LocalFeatureSwitches.swift`

```diff
 public enum DebugBuilderPattern: String {
     case disabled
     ...

+    // NOTE: Add a new debug builder case here.
+    case eligibilityCheckBuilder
 }
```

`DebugAuthenticatedRootBuilder.swift`

```diff
 final class DebugAuthenticatedRootBuilder {
     private let dependencies: AppDependencies
     private let syncOrchestrator: SyncOrchestrator

     ...

     func make(
         session: MainUserSession,
         authenticatedPushEvents: Signal<PushEvent, NoError>,
         authenticatedApplicationInvocationEvents: Signal<ApplicationInvocation, NoError>,
         lifecycleEvents: Signal<LifecycleEvent, NoError>
     ) -> UIViewController? {

         switch LocalFeatureSwitches.debugBuilder {
         ...

+        // NOTE: Implement a new mock builder here.
+        case .eligibilityCheckBuilder:
+            let builder = EligibilityCheckBuilder(dependencies: dependencies, session: session)
+            return DesignLibrary.viewControllersBuilder().navigationController(dismissalStyle: .pop) { (navigation, modal) -> UIViewController in
+                return builder.make(
+                    navigation: navigation,
+                    modal: modal,
+                    presenting: modal,
+                    root: modal,
+                    switchFlow: NHSSwitchFlow(
+                        flow: modal,
+                        rootViewController: UIApplication.shared.delegate?.window??.rootViewController!
+                    )
+                )
+            }
+    }
 }
```

`Settings.bundle/Root.plist`

```diff
         <dict>
             <key>Type</key>
             <string>PSMultiValueSpecifier</string>
             <key>Title</key>
             <string>Debug Builder</string>
             <key>Key</key>
             <string>debugBuilder</string>
             <key>DefaultValue</key>
             <string>none</string>
             <key>Values</key>
             <array>
                 <string>none</string>
                 <string>forgotPasswordBuilder</string>
                 ...
+                <string>eligibilityCheckBuilder</string>
             </array>
             <key>Titles</key>
             <array>
                 <string>none</string>
                 ...
+                <string>eligibilityCheckBuilder</string>
             </array>
         </dict>
```
