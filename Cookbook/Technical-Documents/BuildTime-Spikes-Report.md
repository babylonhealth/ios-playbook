# Improving our Build Times

Build Times in Swift are known to be quite slow, but we could still try to find ways to reduce them. So far we've tried the following different tactics to reduce our build times especially on CI and clean builds:

 - [➥](#helping-the-type-checker)
   Rewrite parts of our code differently to help the type-checker  
   [ [CNSMR-1313](https://babylonpartners.atlassian.net/browse/CNSMR-1313)
   / [CNSMR-2595](https://babylonpartners.atlassian.net/browse/CNSMR-2595)
   / [CNSMR-2604](https://babylonpartners.atlassian.net/browse/CNSMR-2604)
   / [CNSMR-2608](https://babylonpartners.atlassian.net/browse/CNSMR-2608) ]
 - [➥](#removing-useless-downloads-from-ci)
   Ensure our CI jobs didn't spend too much time downloading useless things (e.g. `cocoapods-master`)  
   [ [CNSMR-1517](https://babylonpartners.atlassian.net/browse/CNSMR-1517) ]
 - [➥](#migrating-to-cocoapods-binary)
   Investigate the possibility of migrating to `cocoapods-binary` to use pre-compiled Pods on CI  
   [ [CNSMR-484](https://babylonpartners.atlassian.net/browse/CNSMR-484)
   / [CNSMR-1513](https://babylonpartners.atlassian.net/browse/CNSMR-1513) ]
 - [➥](#try-caching-the-deriveddata-for-pods)
   Try to cache the products from `DerivedData` between runs for tests run on feature PRs  
   [ [CNSMR-2847](https://babylonpartners.atlassian.net/browse/CNSMR-2847) ]



## Helping the type-checker

We've installed two Xcode warnings on all our projects to warn us if the type-checker took:

 - More than 150ms on type-checking single expressions (`-Xfrontend -warn-long-expression-type-checking=150`)
 - More than 200ms on type-checking entire functions (`-Xfrontend -warn-long-function-bodies=200`)

We found a lot of those across the codebase. Most common causes were mainly:

* **Long chains of expressions**, due to our heavily-functional codebase, like `x.map(...).flatMap(...).filter(...)` and similar. Those were in fact essentially coming from:
  * our use of `Bento` to render screens by composing various rows via `|---+` and `|-+` operators
  * our use of ReactiveSwift/ReactiveCocoa which tend to create long chains like those
* **Custom operators, especially heavily-overloaded ones and ones that rely on generics**
  * Especially `Bento` and `Functional.swift` declare a lot of operators that could lead to these usages at point of use, when we have expressions composed with those operators
  * But also uses of `+` in many places (yes, just `+`). For example `["a","b","c"].joined()` compiles way faster than `"a" + "b" + "c"`. This is probably both caused by `+` being heavily overloaded, by generic implementations nonetheless, but also by the existence of types conforming to `ExpressibleByStringLiteral` that become candidates that the type-checker has to consider during its analysis in these kind of expressions
* Expressions involving **generics** that sometimes required to specify the type specialization to help the compiler
* **Usages of `reduce` in some places where `map` is more efficient** (and faster to type-check). Especially some usages of `x.reduce([]) { a,e in a.append(f(e)) }.flatMap(id)` instead of `x.flatMap(f)` directly
* Also **breaking long expressions into smaller ones** and extracting part of those nested or long expressions into private functions (or nested function) helped a lot

Surprisingly, providing explicit types instead of relying on type inference didn't help that much, or at least not as much as the other techniques mentioned above.



## Removing useless downloads from CI

We observed that our CI pipeline did some actions that were not always needed.

One significant of those was that **we downlowded the _master specs repo_ of CocoaPods** (or more accurately, a daily snapshot of it provided by CircleCI) on our workflows **unconditionally, especially even when we didn't need to make changes on `Pods/` at all** (which is the case for most of our PRs)

Since we don't commit our `Pods/` folder but it's still cached on CI, that cache of `Pods/` is restored between CI jobs and runs if the checksum of `Podfile.lock` didn't change; which means if there's no pod being updated since last time that cache was generated, we won't even need that _master specs repo_ to begin with.

We managed to win a couple of minutes for all our workflow runs just by only downloading the _master specs repo_ snapshot *only* if the checksum of the `Podfile.lock` file changed and the `Pods/` cache was thus invalidated (which is the only time requiring to `pod install` and to have that _master spec repo_ set up on the VM first).



## Migrating to CocoaPods-binary

`cocoapods-binary` is a *3rd-party CocoaPods plugin* that theorically allows you to *turn pods based on source code into pods based on pre-compiled versions* of that code.

### How it (is supposed to) work

The plugin uses the hooks provided by `cocoapods` during `pod install` to let it install the Pods as usual (which include creating targets for each pods, containing their source code if they are based on OpenSource code), but then the plugin:

 * triggers `xcodebuild` to ask Xcode to build the `Pods.xcodeproj` and generate its build products – especially the `.framework` generated by those Pods targets for each pod.
 * then saves those built `.framework` aside
 * then builds an alternate `.podspec` for each pod based on the original `.podspec` but changing its definition so it relies on the `.framework` that has been built instead of the `s.source` list of source files. So that the pods are now locally defined as relying on those pre-built products of the pods instead of their source files
 * finally, re-launch the `pod install` process to ask CocoaPods to generate the `Pods.xcodeproj` again but this time using the modified `.podspecs`

The result is a `Pods.xcodeproj` for which each Pod target is already a pre-built framework which doesn't have to be re-compiled from sources on every clean build.

### Spike's slow iterations cycle

There have been several issues when trying to use `cocoapods-binary` on our project, that required mulitple iterations to try to make some progress.

This spike involved some on-and-off work (as we often had to interrupt it to work on more urgent tickets) but mainly ran around summer of 2019. The tests were done using the lastest version of `cocoapods-binary` at that time, which was `0.4.4`.

This spike was quite long to test and investigate, since:

 * After every change to fix an issue, it required to re-run `pod install` which, not only re-generated the `Pods` project like a normal `pod install` would do, but also – by definition and purpose of `cocoapods-binary` – would clean-build all the Pods from scratch to generate the pre-built frameworks.
 * It also required trying to solve `cocoapods-binary`'s own issues
 * It required solving some issues or inconsistencies with our own project

Which basically meant that we had to do a *clean* build on every single change to test said change… only to realise that there was another bug waiting along the way or that there was a colon missing in the gem code… and end up not being able to have a very fast iteration cycle.

### Issues encountered

#### Compatibility with the various Pods

`cocoapods-binary` is **only compatible with Swift pods which rely on source files**.

Also, the way `cocoapods-binary` deals with **pods containing resources** is quite unreliable, depending on how each pod chose to declare and structure those internal resources. Some resources are not translated properly and lead to being inaccessible once the framework is pre-built (see also below section about snapshot tests)

When we tried to configure it at the top-level of our `Podfile` to apply the logic of `cocoapods-binary` to _all_ our pods, it failed on various pods, especially the ones that already are pre-compiled closed-source pods, like Firebase and similar. Which means we had to enable it selectively on each pod using `:binary => true`

#### Transitive dependencies and opt-in behavior

Because `cocoapods-binary` doesn't handle transitive dependencies automatically, if you have a `pod A` which depends on a `pod B` and you enable `cocoapods-binary` on `pod A, :binary => true`, you will have to  also explicitly add `pod B, :binary => true` in your `Podfile` (even if it would otherwise automatically be infered by CocoaPods as a dependency from `pod A`) just to declare the `:binary => true` flag on it.

This is both unfortunate because it leads to a more complicated `Podfile`, especially in our case, but it also means that if `pod B` is not compatible with `cocoapods-binary` for some reason, then we can't even make `pod A` a precompiled binary either.

For that reason, a lot of pods were not possible to be turned into precompiled binaries because of their transitive dependencies and this cascading effect

#### Non-modular headers

`cocoapods-binary` is not compatible with non-modular headers like `#include "..."`.

Unfortunately, we still have some of those, especially in legacy code like the old `ios-monitor`. We were able to fix it in our own codebase but it required some changes in build settings on various projects to continue make the whole workspace working

#### Project configuration consistency

Some of our targets were integrating some of their 3rd party dependencies manually instead of using the `Podfile` for that.

But for consistency, `cocoapods-binary` requires that if one library is integrated via CocoaPods in one target, it needs to be integrated with CocoaPods on all the targets that needs that same dependency. i.e. we can't have a library that is integrated via CocoaPods on one target and manually on another.

That makes sense because otherwise the target configuring the dependency manually would not benefit from the pre-built version of the Pod and would still be pointing to the path where the framework is stored by Xcode after being built from source (`$BUILD_PRODUCTS`) while the pre-built framework generated by `cocoapods-binary` is stored elsewhere once it has been initially built (`Pods/Generated Frameworks`) so that it's not deleted during clean builds.

Especially, `BabylonDependencies` was integrating RAS and RAC manually in the `xcodeproj` instead of using Pods, so we had to change the configuration of that project to migrate that and also to make it use the `Framework.xcconfig` we use on other targets.

Also, some configuration of our own projects were depending on hardcoded values for `FRAMEWORK_SEARCH_PATHS` pointing to `PODS_CONFIGURATION_BUILD_DIR` while, when using `cocoapods-binary`, the built frameworks are stored in a separate place than when the Build Products

#### Snapshot tests

After enabling `cocoapods-binary` even on a single pod, the Snapshot tests all failed. This seemed to be cause by the fact that when using the merged pre-built binary frameworks containing both architecture slices (`lipo`'d binary) generated slightly different screenshot, possibly because they based their rendering of some embedded assets based on the device version of the asset and not the simulator version.

This also led me to question how `cocoapods-binary` merged ressources on pods containing images and assets. It seemed to me that the various `traits` (`@2x`, `@3x`, etc) of each asset didn't get merge properly by `cocoapods-binary` when building the fat framework, which didn't bring much confidence on that point either.

#### Bitcode support

Because `cocoapods-binary` was merging different architectures of a framework into one `lipo`'d framework and generating pre-build framework with fixed Build Settings, there was an incompatibility with BitCode when trying to archive and sign the app. That was likely due to `cocoapods-binary` not taking the BitCode build setting into account when building the binary framework.

#### CocoaPods versions compatibility

`cocoapods-binary` is not compatible with CocoaPods 1.7 and above as of today. It seems that the issues that have been opened on GitHub to ask for that compatibility have been stale for a while, making us think that the repo might not really be very active nor maintained anymore.

* Currently, our project is still using CocoaPods 1.6, and we planned on migrating but postponed the migration in order to test `cocoapods-binary` first.
* But that meant that if that spike were successful, it would have locked us on CocoaPods 1.6 until `cocoapods-binary` was updated to support CocoaPods 1.7 and ever 1.8
* And according to the activity on the `cocoapods-binary` repo, it seems that this plugin is not regularely maintained anymore

I also tried to fork the project and point to my fork to fix the issues I've encountered, including the handling of resources, transitive dependencies, and 1.7 compatibility. But every workaround I tried led to separate issues on other parts and led me nowhere.

#### Issue handling min deployment target

The latest stable and the `master` versions of `cocoapods-binary` both failed to correctly handle the "Minimum Deployment Target" set in our `Podfile` and the pods' `podspecs`, making it fail during the step when `cocoapods-binary` was invoking `xcodebuild` to compile the pods to pre-built binaries.


This one was hard to debug and pick up because there was no log at first about this `xcodebuild` step made by `cocoapods-binary` so that was silent and we ended up with an obscure compilation error.

I ended up forking the repo and digging into the gem source code and its usage of both `cxcodebuild` and `fourflusher` (the dependency to handle installed iOS simulators, manipulate `xcrun simctl` from Ruby, and build a proper `-destination` parameter for the simulator build), to fix this issue.


### Spike Outcome

Even after trying to fix all the issues mentionned above, there were still compilation issues in our project; basically every time we tried to enable `:binary => true` for another Pod, we encountered new compilation issues.

After all those various investigations and trials, we decided that, given the effort it took to only try to resolve half of the issues, and not even managing to end up with a project that were even just compiling despite fixing some intermediate issues along the way, this plugin was proven to be not ready to handle our project and our dependencies.

Even if we decided to continue trying to fix the remaining issues we'd continue to encounter and if we managed to end up with a workspace that compiled with `cocoapods-binary` being enabled on at least some of the Pods, given the effort it took to fix the existing issues we're not confident that the result would be stable or trustable enough.

Besides, this current state of the plugin didn't inspire confidence in maintainability (the project seems to slowly be abandonned / unmaintained), and raised a high level risk of requiring more maintenance on our project as we would add more dependencies or modules in our project or as we were required to move to more up-to-date versions of CocoaPods itself.

Lastly, adopting `cocoapods-binary` would prevent us from upgrading CocoaPods itself to 1.7 or 1.8 – which might be needed for supporting upcoming Xcode versions at some point – and the hope for the plugin to be updated quickly after a new release of CocoaPods itself seemed very slim given the low maintenance of the plugin.

All those reasons made us decide, despite that effort and the high hopes we had for winning precious minutes on CI, to drop the idea anyway.

## Try caching the DerivedData for Pods

After the decision to abort the spike on `cocoapods-binary`, the next idea to try to re-use the compiled version of the pods was to cache the Pods build products directly on the CI. That basically meant trying to cache the `DerivedData` related to Pods.

Given that caching too much, especially `DerivedData`, can quickly become unstable and unreliable, the idea was only:

* to use that `DerivedData` cache on the `test_pr` workflow – while still doing clean builds for `develop` or `release` branches or for `hockeyapp`/`testflight` builds.
* to only cache from `DerivedData` the products concerning the `Pods` – which mostly never change as long as the `Podfile.lock` don't change – but not the products concerning the app targets – which are suggest to change way more often and for which relying too much on the cache might become harmful.

[CircleCI Build](https://circleci.com/gh/Babylonpartners/babylon-ios/176204)

### Steps tested

1. We first tried to cache all of `DerivedData/` related to `Pods`, especially `DerivedData/Debug/Babylon/Build/Intermediates.noindex/Pods.build` + an exhaustive list of `DerivedData/Debug/Babylon/Build/Products/Debug-iphonesimulator/<PodName>` for each pods.  
  But after a few trials and errors (don't forget to also update your cache key when you make a change to the paths being cached…) we discovered that the total amount of data in those folders exceeded the CircleCI max cache size (`Error uploading archive: MetadataTooLarge: Your metadata headers exceed the maximum allowed metadata size`)

1. Then we tried to only cache `DerivedData/Debug/Babylon/Build/Intermediates.noindex/Pods.noindex` (without caching anything from `DerivedData/Debug/Babylon/Build/Products/Debug-iphonesimulator/` anymore) but that also exceeded CircleCI max cache size

1. So we then tried the opposite, i.e. only caching all the `DerivedData/Debug/Babylon/Products/Debug-iphonesimilator/<PodName>` folders, and that did fit the cache size… But then Xcode ended up rebuilding everything from scratch anyway, despite those build products in `DerivedData` being present. Which meant that caching this part of `DerivedData` was useless after all (maybe Xcode wouldn't have rebuilt everything from scratch if we also included `Intermediates.noindex`, but as doing this exceeds the CircleCI cache size limit, we won't be able to test it anyway)

### Spike Outcome

So in the end it seems like caching even the most that CircleCI can allow us will not help avoiding a full rebuilding of the Pods from scratch in any case. Which is why we aborted this Spike too.
