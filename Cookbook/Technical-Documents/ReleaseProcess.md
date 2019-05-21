
## Release process

### 1. Release engineer as a role

  The release engineer responsibilities are, but not limited to:

 1. Own the entire release process (step-by-step).
 2. Provide visibility, at all stages, of the release to the wider audience (e.g. squad, tribe and iOS chapter lead).
 3. Collaborate with QA by:
    1. Providing visibility to potential blockers to the wider audience.
    2. Escalating abnormal influx of bugs, so the release, as a whole, can be reassessed.
4. Making sure they can dedicate enough time for the release. In case this is not possible (due to other squad commitments), please inform the iOS chapter lead.

**The objective is to ship the release build as soon as possible whilst maintaining the quality bar and addressing every bug raised by QA**.
When dealing with a particularly complicated bug (one that would require a rather significant effort to address) the release engineer should speak with either Andreaa Papillon (Native Apps' Product Manager) or Lilla Szulyovszky (Native Apps' Delivery Manager) as every release is managed and signed-off by the Native Apps squad.
The bug's corresponding feature should be disabled altogether using its feature switch (if applicable). Such a bug would subsequently be handled by its respective squad.

Release duties have priority over regular squad duties. Please inform your squad of your unavailability before starting to work in the release. As with every other week, twenty percent of your work hours overall are to be allocated towards making the release a reality.

There are usually two release engineers working at any given time. It goes without saying that both engineers need to work together and that constant feedback is vital.

### 2. Release step-by-step

**Phase 1: Initiation**
<br/>	*It starts at the end of the sprint (typically when the new sprint starts on Monday)*

1. Cut a release branch:  Create a new branch from develop and push to origin (e.g `release/3.2.0`).
1. Bump the release version by triggering its command (eg. `/release babylon:3.2.0`) in `#ios-build` (you can run the command every time you want to upload a new build).
    * This creates a test Tesflight build (try to make one as early as possible so that you can catch issues like missing/expired certificates or profiles and any other production build errors early).
1. Trigger a hockey build from that branch using its command (eg. `/distribute release/3.2.0:babylon`) in `#ios-build`.
1. Create and send the issue list to the Product Manager: In console run `git log --since="2018-11-26" --pretty=format:%s  > issue_list.txt` (use the date when the sprint started).
1. Create a new version in [AppStoreConnect](https://appstoreconnect.apple.com) (login using your own account) / My Apps
    1. On the sidebar click `+ Version or Platform` and select `iOS`.
    1. Input the new version number.

**Phase 2: Test and fix bugs**
<br/>	*It starts after the Hockey build has been delivered and it can take several cycles*

1. Testers will then begin their work against the build you just created.
1. Any hotfix should target that branch, and you, as the release engineer, are responsible for double checking that the hotfix's PR is pointing to the release branch (instead of `develop`). The issue for the hotfix should be added to the release JIRA board.

**Phase 3: Submit TestFlight builds to App Store Connect**
<br/>	*It starts after all opened issues had been adressed and can take several cycles until QA's approval*

1. Triger a new release build in the `#ios-build` channel
1. Obtain the release notes form the Product Manager  and update them in the [AppStoreConnect](https://appstoreconnect.apple.com)
1. Enable the new release version in [AppStoreConnect](https://appstoreconnect.apple.com).
1. Perform a quick exploratory test on the TestFlight build to make sure everything looks okay. (e.g. verifying that DigitalTwin Assets are visible and are not dropped due to Git LFS issues) ❗️ NOTE: Remember to submit compliance info for that build.
1. By now, QA should be notified that there is a new version in TestFlight.

**Phase 4: Submit for release in App Store Connect**
<br/>	*It starts after QA has signed off a particular build and can take several cycles until Apple's approval*

1. Make sure *Manually release this version* is selected in `Version Release`.
2. When submitting to release, you are asked if the app uses the Advertising Identifier (IDFA). The answer is YES. You are then presented with three options please select as followed:
	1. 🚫 Serve advertisements within the app
	2. ✅ Attribute this app installation to a previously served advertisement
	3. ✅ Attribute an action taken within this app to a previously served advertisement

**Phase 5: Closure**
<br/>	*It starts after the app is accepted by Apple and final internal approval*

1. Send the build to Testflight Beta (external testing). Select the `External Testers` group.
1. Press `Release this version` in App Store Connect
1. Tag the release commit and create a GitHub release. Attach the binary as an artefact to the GitHub release (if you're using the automated release command, you can find the binary in the Artifacts top section in the CI build).
1. Merge the changes back to develop.

### 3. SDK Release

1. Ask SDK team (#sdk_squad) about the SDK version number.
2. Follow the [Internal SDK Release Process](https://engineering.ops.babylontech.co.uk/docs/cicd-deployments/#mobile-sdk-releases-ios-android) to open a CR ticket on the CRP board.
3. Cut a release branch for the SDK from the app release branch (eg. `sdk/0.5.0`)
4. Create PR and udpate the SDK changelog `SDK/CHANGELOG.md` to add the release version and date
5. Trigger a hockey build from that branch using its command (eg. `/fastlane distribute_sdk_v2 version:0.5.0 branch:release/sdk/0.5.0`) in `#ios-build`.
6. Update the Sample app to point to the latest SDK release

### 4. Release calendar

The release process starts when the first build is provided to QA and ends when Apple has approved the app. Effort to release should be broken down by:

1. Automated QA effort (e.g. `5h`)
2. Manual QA effort (e.g. `3h`)
3. Delta between the jira ticket being open and marked as `done` or `wont fix`, for Engineering effort. (e.g. `UA-8289: 1h30`)
4. Total effort

| Version | Release Engineer(s)  | QA effort   | Engineering effort          | Total effort  | Cut-off date  | Release date  |
|---------|----------------------|-------------|-----------------------------|---------------|---------------|---------------|
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


### 5. Post-mortem

If the release did not go as expected, request a meeting with the iOS team so that the reasons for this failure are analyzed and addressed in order to minimize similar problems in the future.
