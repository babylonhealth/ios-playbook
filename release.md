  
## Release process

### 1. Release engineer as a role

  The release engineer responsibilities are, but not limited to:

 1. Own the entire release process (step-by-step).
 2. Provide visibility, at all stages, of the release to the wider audience (e.g. squad, tribe and iOS chapter lead).
 3. Collaborate with QA by:
    1. Providing visibility to potential blockers to the wider audience.
    2. Escalating abnormal influx of bugs, so the release, as a whole, can be reassessed.
4. Making sure they can dedicate enough time for the release. In case this is not possible (due to other squad commitments), please inform the iOS chapter lead.

### 2. Release step-by-step

**Phase 1: Initiation**
<br/>	*It starts at the end of the sprint (typically when the new sprint starts on Monday)*

1. Cut a release branch:  Create a new branch from develop and push to origin (e.g `release/3.2.0`).
1. Bump the release version by triggering its command (eg. `/release babylon:3.2.0`) in `#ios-build` (you can run the command every time you want to upload a new build).
    * This creates a test Tesflight build (try to make one as early as possible so that you can catch issues like missing/expired certificates or profiles and any other production build errors early).
1. Trigger a hockey build from that branch using its command (eg. `/distribute release/3.2.0:babylon`) in `#ios-build`.
1. Create a board for the release. Use a filter to reduce its scope, eg `project = UA AND affectedVersion = "iOS 3.2.0"`.
1. Create and send the issue list to the Product Manager: In console run `git log --since="2018-11-26" --pretty=format:%s  > issue_list.txt` (use the date when the sprint started).
1. Create a new version in [AppStoreConnect](https://appstoreconnect.apple.com) (login using your own account) / My Apps 
    1. On the sidebar click `+ Version or Platform` and select `iOS`.  
    1. Input the new version number.

**Phase 2: Test and fix bugs**
<br/>	*It starts after the Hockey build has been delivered and it can take several cycles*

1. Testers will then begin their work against the build you just created. 
1. Any hotfix should target that branch, and you, as the release engineer, are responsible for double checking that the hotfix's PR is pointing to the release branch (instead of `develop`).

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

1. Press `Release this version` in App Store Connect
1. Tag the release and upload the binary. (If you're using the automated release command, you can find the binary in the Artifacts top section in the CI build).
1. Merge the changes back to develop.


### 3. Release calendar

The release process starts when the first build is provided to QA and ends when Apple has approved the app. Effort to release should be broken down by:

1. Automated QA effort (e.g. `5h`)
2. Manual QA effort (e.g. `3h`)
3. Delta between the jira ticket being open and marked as `done` or `wont fix`, for Engineering effort. (e.g. `UA-8289: 1h30`)
4. Total effort


| Version                  | Release Engineer(s)              | QA effort              | Engineering effort | Total effort |
|--------------------------|----------------------------------| ---------------------- |--------------------|--------------|
| 3.6.0                    | Viorel Mihalache, Ilya Puchka | Automated: <br>Manual: <br>| `CNMSR-388`<br>`CNMSR-397`<br>`CE-146`<br>`NRX-150`<br>`CNMSR-404`<br>`NRX-149`<br>`UA-8329`<br>`UA-8431`<br>`CNMSR-365`<br>`CNMSR-324`<br>`CNMSR-340`<br>`CE-124`<br> | Total: **8d** |
| 3.5.0                    | Wagner Truppel                   | Automated: `06h47`<br>Manual: `28h`<br>| `CNSMR-82: 1h39m`<br>| Total: **1d12h26m** |
| 3.4.0                    | Martin Nygren                    | Automated: `06h40`<br>Manual: `32h`<br>| `UA-8385: 2h`<br>`UA8381: 4h`<br>`UA-8375 6h`<br>`UA-8374 2h`<br>`UA-8362 1h`<br>`UA-8369 2h`<br>`UA-8372 1h`<br>`MON-3631 2h`<br>`MON-3634 14h`<br>`UA-8359 13h`<br>| Total: **3d9h40min** |
| 3.3.0                    | David Rodrigues                  | Automated: `09h40`<br>Manual: `14h`<br>| `UA-8268: 1h`<br>`UA-8269: 1h30`<br>`UA-8252: 5h`<br>| Total: **1d7h10min** |
| 3.2.0                    | Danilo Aliberti                  | Automated: `12h53`<br>Manual: `10h`<br>| `UA-8166: 4h`<br>`UA-8149: 2d`<br>`UA-8187: 3h`<br>| Total: **3d6h** |
