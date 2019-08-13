
# Release process

## 1. Release engineer as a role

  The release engineer responsibilities are, but not limited to:

1. Own the entire release process (step-by-step).
2. Provide visibility, at all stages, of the release to the wider audience (e.g. squad, tribe and iOS chapter lead).
3. Collaborate with QA by:
    1. Providing visibility to potential blockers to the wider audience.
    2. Escalating abnormal influx of bugs, so the release, as a whole, can be reassessed.
4. Making sure they can dedicate enough time for the release. In case this is not possible (due to other squad commitments), please inform the iOS chapter lead.
5. General bug fixing for minor regressions and tasks, that are not related to significant changes made by squads for their own features. For more complex ones:
    1. Delegate the bug to the relevant squad/person. 
    2. If the bug is too complex to be fixed within the release window, please toggle off the feature and inform the Product Manager. 

**The objective is to ship the release build as soon as possible whilst maintaining the quality bar and addressing every bug raised by QA**.

When dealing with a particularly complicated bug (one that would require a rather significant effort to address) the release engineer should speak with either Andreea Papillon (Native Apps' Product Manager) or Lilla Szulyovszky (Native Apps' Delivery Manager) as every release is managed and signed-off by the Native Apps squad.  
The bug's corresponding feature should be disabled altogether using its feature switch (if applicable). Such a bug would subsequently be handled by its respective squad.

Release duties have priority over regular squad duties. Please inform your squad of your unavailability before starting to work in the release. As with every other week, twenty percent of your work hours overall are to be allocated towards making the release a reality.

There are usually two release engineers working at any given time. It goes without saying that both engineers need to work together and that constant feedback is vital.

## 2. Release step-by-step

### Phase 1: Initiation
*It starts at the end of the sprint (typically when the new sprint starts on Monday)*

1. Cut a release branch, naming it using the `release/{appname}/{version}` convention (with `{appname}` being one of `babylon`/`telus`/`bupa`/`nhs111`)
   * If you are releasing the main Babylon app, create the new branch from `develop`, and name it `release/babylon/{version}` (e.g. `release/babylon/4.1.0`)
   * If you're releasing another app (e.g. Telus, Bupa, NHS111), since they typically go thru the release process _only_ once the main Babylon app has been signed off by QA, you should create the new branch from the corresponding Babylon release branch that was recently already QA'd and signed off (e.g. `release/babylon/4.1.0`) instead of `develop`, and name your new branch using the same `release/{appname}/{version}` convention (e.g. `release/telus/4.1.0`)
   * Push the branch to `origin`
1. Join the slack channel the QA has created (e.g. `ios_release_4_1_0`) to discuss anything related to this release.
1. Bump the release version by triggering the Slack command (eg. `/testflight Babylon version:4.1.0`) in `#ios-build` (you can run the command every time you want to upload a new build).
   * This creates a TestFlight build (try to make one as early as possible so that you can catch issues like missing/expired certificates or profiles and any other production build errors early).
1. Trigger a hockey build from that branch using its command (eg. `/hockeyapp Babylon branch:release/babylon/4.1.0`) in `#ios-build`.
1. Create the CRP ticket by triggering the Slack command (eg. `/crp ios branch:release/babylon/4.1.0`) in `#ios-launchpad`
   * This will also generate the CHANGELOG automatically (from the list of commits between the `release/{appname}/{version}` branch you mentioned and the tag for the latest version of the same product – i.e. the most recent `{appname}/*` tag) to include it in the CRP ticket
   * Your PM should then be able to see that the CRP ticket has been created, and can further manually complete the CRP ticket with any additional information (clinical risk, etc) from here
1. Ask the `#ios-launchpad` channel for the expected release notes from each squad if they are releasing anything.
1. Create a new version in [AppStoreConnect](https://appstoreconnect.apple.com) (login using your own account) / My Apps
  1. On the sidebar click `+ Version or Platform` and select `iOS`.
  1. Input the new version number.

### Phase 2: Test and fix bugs
*It starts after the Hockey build has been delivered and it can take several cycles*

1. Testers will then begin their work against the build you just created.
1. Any hotfix should target that branch, and you, as the release engineer, are responsible for double checking that the hotfix's PR is pointing to the release branch (instead of `develop`). The issue for the hotfix should be added to the release JIRA board.

### Phase 3: Submit TestFlight builds to App Store Connect
*It starts after all opened issues had been adressed and can take several cycles until QA's approval*

1. Triger a new release build in the `#ios-build` channel
1. Obtain the release notes from the Product Manager and update them in the [AppStoreConnect](https://appstoreconnect.apple.com). Be aware that the release notes (and all the App Record) has 2 localized versions: English UK (which contains references to the NHS) and another English (Australian by August/2019) for the other territories. Paste the release notes on both. 
1. Enable the new release version in [AppStoreConnect](https://appstoreconnect.apple.com).
1. Perform a quick exploratory test on the TestFlight build to make sure everything looks okay. (e.g. verifying that DigitalTwin Assets are visible and are not dropped due to Git LFS issues) ❗️ NOTE: Remember to submit compliance info for that build.
1. By now, QA should be notified that there is a new version in TestFlight.

### Phase 4: Submit for release in App Store Connect
*It starts after QA has signed off a particular build and can take several cycles until Apple's approval*

1. Make sure *Manually release this version* is selected in `Version Release`.
2. When submitting to release, you are asked if the app uses the Advertising Identifier (IDFA). The answer is YES. You are then presented with three options please select as followed:
	1. 🚫 Serve advertisements within the app
	2. ✅ Attribute this app installation to a previously served advertisement
	3. ✅ Attribute an action taken within this app to a previously served advertisement

### Phase 5: Closure
*It starts after the app is accepted by Apple and final internal approval*

1. Send the build to TestFlight Beta (external testing). Select the `External Testers` group.
1. Press `Release this version` in App Store Connect
1. Create a tag named `{appname}/{version}` (e.g. `babylon/4.1.0`) on the release commit and create a GitHub release for that new tag
   * Make sure you create separate tags (and GitHub releases) for each app released on the AppStore (eg. Babylon 4.1.0 and Telus 4.1.0 would each have their own `babylon/4.1.0` and `telus/4.1.0` tags)
   * Set the body of the GitHub release to the content of the Release Notes for the app
   * Attach the zipped `xcarchive` as an artefact to the GitHub release (if you're using the automated release command, you can find the `*.xcarchive.zip` in the Artifacts top section in the CI build).
1. Merge the changes back to develop.
1. Update the [release calendar](#release-calendar)

## 3. SDK Release

1. Ask SDK team (#sdk_squad) about the SDK version number.
1. Cut a release branch for the SDK from the app release branch, using the `sdk/{version}` naming convention (eg. `sdk/0.5.0`)
1. Create a CRP ticket by triggering its command (eg. `/crp ios branch:release/sdk/0.5.0`) in Slack
   * This will create the CRP ticket for the SDK, only including in the CHANGELOG field of the CRP the commits messages containing `[SDK-xxx]` or `#SDK` – filtering out the other commits, that are considered app-only changes if not containing those tags
   * See also the [Internal SDK Release Process](https://engineering.ops.babylontech.co.uk/docs/cicd-deployments/#mobile-sdk-releases-ios-android) for more info.
1. Create PR and update the SDK changelog `SDK/CHANGELOG.md` to add the release version and date
   * this document will be distributed alongside the SDK and used to document changes to SDK consumers, so the list of changes here could be worded differently from the CHANGELOG used in the CRP ticket if necessary
1. Trigger a hockey build from that branch using its command (eg. `/fastlane distribute_sdk version:0.5.0 branch:release/sdk/0.5.0`) in `#ios-build`.
1. Update the Sample app to point to the latest SDK release and ensure it still compiles

## 4. Release calendar

### 4a. App Release calendar

The release process starts when the first build is provided to QA and ends when Apple has approved the app. Effort to release should be broken down by:

1. Automated QA effort (e.g. `5h`)
2. Manual QA effort (e.g. `3h`)
3. Delta between the jira ticket being open and marked as `done` or `wont fix`, for Engineering effort. (e.g. `UA-8289: 1h30`). Consider only tickets that were raised during the release period, checking that their creation dates were after the release branch cut. 
4. Total effort

| Version | Release Engineer(s)  | QA effort   | Engineering effort          | Total effort  | Cut-off date  | Release date  |
|---------|----------------------|-------------|-----------------------------|---------------|---------------|---------------|
| 4.4.0 |Danilo Aliberti <br> Sergey Shulga | Automated: Parallel execution: 1 hour 28 minutes<br> Serial execution: 10 hours 15 minutes <br><br>Manual: 22 Hours 45 Minutes | `CNSMR-2521: 5days`, <br>`NRX-790: backend issue not resolved`, <br>`CNSMR-2515: 19 hours`, <br>`AV-910: 2days`, <br>`CNSMR-2509: 1day`, <br>`CNSMR-2506: 1day, 5hours`, <br>`CNSMR-2503: 1day, 1hour 10minutes`, <br>`CNSMR-2502: 6days and an hour`, <br>`CNSMR-2506: 1day, 5hours`| Total: **17days 31hours 10minutes** | 05.08.2019 | 12.08.2019 |
| 4.3.0  | Julien Ducret <br> Diego Petrucci | Automated<br><br> Parallel execution: `1h 54min` Serial execution: `8h 41min`<br><br>Manual: `24h 50min`| `CE-517: 30min`<br> `CNSMR-2143: 2days`<br> `CNSMR-2395: 0.5day`<br> `CNSMR-2333: 30min`<br> `CNSMR-2334: 30min`<br> `MON-4916: 30min`<br> `MON-4916: 30min`<br> `MON-4964: 30min`<br> `CE-512: 3hrs`<br> `CNSMR-2363: 1hr 30min`<br> `CNSMR-2338: 30min`<br> `CNSMR-2337: 60min`<br>  | Total: **44h 01min** | 22.07.2019 | 30.07.2019 |
| 4.2.0  | Viorel Mihalache <br> Joshua Simmons | Automated: `8h 41min`<br>Manual: `24h 30min`| `AV-852: 3h`<br>`CNSMR-2173: 2h`<br>`NRX-724: 30min`<br>`CNSMR-2147: 8h`<br>`NCSMR-2167: 30min`<br>`NRX-720: 30min`<br>`CNSMR-2164: 30min`<br>`CNSMR-2162: 30min`<br>`AV-843: 30min`<br> | Total: **49h 11min** | 08.07.2019 | 15.07.2019 |
| 4.1.0  | Martin Nygren <br> Adam Borek | Automated: `8h 57min`<br>Manual: `24h 15min`| `NRX-686 and NRX-687: 8h`<br> `CNSMR-1947: 1.5h`<br>`CNSMR-1952: 2h`<br>`Other release duties: 9.5h` | Total: **54h25m** | 24.06.2019 | 01.07.2019 |
| 4.0.1  | Ilya Puchka | Automated: - <br>Manual: `1h 30min`| `GW-668: 16h` | Total: **17h30m** | 20.06.2019 | 21.06.2019 |
| 4.0.0  | Anders Ha <br> Ilya Puchka | Automated: `8h 21m`<br>Manual: `37h 00min`| `AV-519: 17h` <br> `NRX-649: 2h` <br> `AV-677: 3h` <br> `CNSMR-1811: 1h` <br> `AV-704: 1.5h` <br> `AV-701: 16h` <br> `AV-737: 1.5h` <br> `AV-736: 2.5h` <br> | Total: **90h** | 10.06.2019 | 18.06.2019 |
| 3.17.0  | Witold Skibniewski <br> Viorel Mihalache Oprea | Automated: `8h 15m`<br>Manual: `26h 45min`| `CNSMR-1690: 1h` | Total: **36h** | 28.05.2019 | 30.05.2019 |
| 3.16.0  | David Rodrigues <br> Ben Henshall | Automated: `6h 50m`<br>Manual: `19h 35min`| `CNSMR-1556: 2h30m` <br> `CNSMR-1537: 3h` <br> `CNSMR-1525: 1h` <br> `CNSMR-1438: 1h` <br> `CNSMR-1437: 2h` <br> `CNSMR-1555: 1h` <br> `CNSMR-1540: 4h` | Total: **40h55m** | 13.05.2019 | 16.05.2019 |
| 3.15.0                   | Sergey Shulga <br> Joao Pereira <br> Michael Brown | Automated: `7h 37m`<br>Manual: `24h 15 min`| `CNSMR-1449: 1h` <br> `CNSMR-1443: 12h` <br> `CNSMR-1381: 2h` <br> `CNSMR-1438: 30min` <br> `CNSMR-1430: 30min` <br> `CNSMR-1413: 20min` <br> `CNSMR-1412: 20min` <br> `CNSMR-1375: 20min` <br> `CNSMR-1391: 15min` | Total: **49h07m** | 29.04.2019 | 07.05.2019 |
| 3.14.0                   | Giorgos Tsiapaliokas <br>Yasuhiro Inami | Automated: `07h28m`<br>Manual: `24h10m`| `NRX-506: 2h` <br> `NRX-495: 30m` <br> `NRX-501: 30m` <br> `CNSMR-1323: 30m` | Total: **35h08m** | 15.04.2019 | 23.04.2019 |
| 3.13.0                   | Anders Ha <br> Viorel Mihalache | Automated: `07h`<br>Manual: `19h`| `CNSMR-1183: 3h` <br> `CNSMR-1181: 2h` | Total: **31h** | 1.04.2019 | 4.04.2019 | 
| 3.12.0                   | Ben Henshall<br> Danilo Aliberti | Automated: `07h16m`<br>Manual: `22h`| `MON-4225: 3h`| Total: **32h16m** | 18.03.2019 | 21.03.2019 | 
| 3.11.0                   | Adam Borek<br> Ilya Puchka | Automated: `07h17m`<br>Manual: `19h30m`| `CNSMR-894: 6h`<br>`CNSMR-913: 2h`<br>`CE-262: 2h`<br>`CE-261: 2h`<br> `Expired certificates: 3h`| Total: **41h47m** | 04.03.2019 | 11.03.2019 | 
|  3.10.0                   | Martin Nygren, Witold Skibniewski | Automated: `07h30m`<br>Manual: `28h`<br> | `CNSMR-814: 30m` | Total: **36h00m** | 18.02.2019 | 21.02.2019 |
| 3.9.1                    | Michael Brown | Automated: `04h00m`<br>Manual: `14h`<br>| `CNSMR-705: - 30m`<br>`AV-312: - 30m`| Total: **19h00m** | 11.02.2019 | 13.02.2019
| 3.9.0                    | Michael Brown, Giorgos Tsiapaliokas | Automated: `07h25m`<br>Manual: `24h`<br>| `CNSMR-680: - 2h`<br>| Total: **33h25m** | 04.02.2019 | 08.02.2019
| 3.8.0                    | Sergey Shulga, Diego Petrucci | Automated: `07h30m`<br>Manual: `33h`<br>| `CE-125: - 2h`<br>`CNSMR-538: 1h`<br>`AV-243: 1h`<br>`CNSMR-556: 2h`<br>`NRX-229: 1h`<br>`NRX-232: - 1h`<br> `CNSMR-554: 1h` <br> `NRX-229: 5h`<br> `NRX-232: 3h` <br>| Total: **57h30m** | 21.01.2019 | 24.01.2019
| 3.7.0                    | Ben Henshall, David Rodrigues | Automated: `06h58m`<br>Manual: `32h`<br>| `MON-3855: 2h`<br>`MON-3857: 1h`<br>`AV-207: 1h`<br>`NRX-190: 3h`<br>`CNSMR-493: 3h`<br>`CNSMR-477: 3h`<br> | Total: **2d3h58mh** | | |
| 3.6.0                    | Viorel Mihalache, Ilya Puchka | Automated: `06h50m`<br>Manual: `32h` <br>| `CNSMR-388: 2h`<br>`CNSMR-397: 1h`<br>`CE-146: 2h`<br>`NRX-150: 8h`<br>`CNSMR-404: 1h`<br>`NRX-149: 4h`<br>`UA-8329: 3h`<br>`UA-8431: 1h `<br>`CNMSR-365: 1h`<br>`CNSMR-324: 2h`<br>`CNSMR-340: 3h`<br>`CE-124: 2h`<br> | Total: **2d20h50min** | | |
| 3.5.0                    | Wagner Truppel                   | Automated: `06h47`<br>Manual: `28h`<br>| `CNSMR-82: 1h39m`<br>| Total: **1d12h26m** | | |
| 3.4.0                    | Martin Nygren                    | Automated: `06h40`<br>Manual: `32h`<br>| `UA-8385: 2h`<br>`UA8381: 4h`<br>`UA-8375 6h`<br>`UA-8374 2h`<br>`UA-8362 1h`<br>`UA-8369 2h`<br>`UA-8372 1h`<br>`MON-3631 2h`<br>`MON-3634 14h`<br>`UA-8359 13h`<br>| Total: **3d9h40min** | | |
| 3.3.0                    | David Rodrigues                  | Automated: `09h40`<br>Manual: `14h`<br>| `UA-8268: 1h`<br>`UA-8269: 1h30`<br>`UA-8252: 5h`<br>| Total: **1d7h10min** | | |
| 3.2.0                    | Danilo Aliberti                  | Automated: `12h53`<br>Manual: `10h`<br>| `UA-8166: 4h`<br>`UA-8149: 2d`<br>`UA-8187: 3h`<br>| Total: **3d6h** | | |

### 4b. SDK Release calendar

| Version | Associated App Version | Release Engineer(s)  | Engineering effort          | Total effort  | Cut-off date  | Release date  |
|---------|------------------------|----------------------|-----------------------------|---------------|---------------|-------------------|
| 0.7.0 | 3.16.0 | David Rodrigues <br> Ben Henshall | CNSMR-1589: 3h (Involved a lot of waiting due to dependency on DevOps)<br>Expired GitHub token issue: 2h | 4h30m | 17.05.2019 | 21.05.2019 |

## 5. Post-mortem

If the release did not go as expected, request a meeting with the iOS team so that the reasons for this failure are analyzed and addressed in order to minimize similar problems in the future.

