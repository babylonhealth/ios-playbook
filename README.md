<p align="center">
<img src="logo.png">
</p>


iOS Playbook 📚
==================================

At Babylon, we firmly believe that **transparency** is a core value that should be present in everything we do. This playbook embodies that value by giving an overview of how we work:

1. Who's in the team.
2. Which squad each individual belongs to, and its availability.
3. OSS-maintained projects.
4. Release process.
5. Technical documents.
6. New hires checklist.
7. Interview process.
8. Code guidelines, standards and etiquette.


## 1. Who's in the team

| Name                    | Contact                                                       |  
|-------------------------|---------------------------------------------------------------|
| Ana Catarina Figueiredo | [@AnnKatFig](https://twitter.com/AnnKatFig)                   |
| Anders Ha               | [@_andersha](https://twitter.com/_andersha)                   |
| Ben Henshall            |                                                               |
| Danilo Aliberti         |                                                               |
| David Rodrigues         | [@dmcrodrigues](https://twitter.com/dmcrodrigues)             |
| Diego Petrucci          | [@diegopetrucci](https://twitter.com/diegopetrucci)           |
| Ilya Puchka             | [@ilyapuchka](https://twitter.com/ilyapuchka)                 |
| Jason Dobo              | [@jasondobo](https://github.com/jasondobo)                    |
| Martin Nygren           |                                                               |
| Michael Brown           | [@mluisbrown](https://twitter.com/mluisbrown)                 |
| Rui Peres               | [@peres](https://twitter.com/peres)                           |
| Sergey Shulga           | [@SergDort](https://twitter.com/SergDort)                     |
| Viorel Mihalache        | [@viorelMO](https://twitter.com/viorelMO)                     |
| Wagner Truppel          | [@wltrup](https://github.com/wltrup)                         |    
| Witold Skibniewski      |                                                               |


## 2. Which squad each individual belongs to, and its availability.

By definition, members work on their respective squad, although they are free to work in different squads if the work load justifies it.


| Squad Name                    | Members                  | Availability |  
|-------------------------------|--------------------------| ------------ |
| SDK                           | David, Viorel, Martin    |    3/4       |
| Consultation Experience       | Ilya                     |    1/1       |
| Healthcheck                   | Ben, Wagner              |    2/2       |
| Core                          | Witold, Jason            |    2/4       |
| Professional Services         | Danilo                   |    1/1       |
| GP at Hand                    | Diego                    |    1/1       |
| Project Avalon                | Sergey                   |    1/1       |
| Project Minkowski             | Anders                   |    1/2       |
| Project Bayes                 | Michael                  |    1/1       |

## 3. OSS-maintained projects

| Project name                  | Owner(s)                 | Stars        |  
|-------------------------------|--------------------------| ------------ |
| Bento                         | Anders, David, Sergey    | [![GitHub stars](https://img.shields.io/github/stars/BabylonPartners/Bento.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/BabylonPartners/Bento/stargazers/)             |
| DrawerKit                     | David, Wagner            |    [![GitHub stars](https://img.shields.io/github/stars/BabylonPartners/DrawerKit.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/BabylonPartners/DrawerKit/stargazers/)       |
| ReactiveFeedback              | Anders, Sergey           |    [![GitHub stars](https://img.shields.io/github/stars/BabylonPartners/ReactiveFeedback.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/BabylonPartners/ReactiveFeedback/stargazers/)        |

## 4. Release process

### Release engineer as a role

  The release engineer responsibilities are, but not limited to:

 1. Own the entire release process (step-by-step).
 2. Provide visibility, at all stages, of the release to the wider audience (e.g. squad, tribe and iOS chapter lead).
 3. Collaborate with QA by:
    1. Providing visibility to potential blockers to the wider audience.
    2. Escalating abnormal influx of bugs, so the release, as a whole, can be reassessed.
4. Making sure they can dedicate enough time for the release. In case this is not possible (due to other squad commitments), please inform the iOS chapter lead.

### Release calendar

Effort to release should be broken down by:

1. Automated QA effort (e.g. `5h`)
2. Manual QA effort (e.g. `3h`)
3. Delta between the jira ticket being open and marked as `done` or `wont fix`, for Engineering effort. (e.g. `UA-8289: 1h30`)
4. Total effort


| Version                  | Release Engineer(s)              | QA effort              | Engineering effort | Total effort |
|--------------------------|----------------------------------| ---------------------- |--------------------|--------------|
| 3.2.0                    | Danilo Aliberti                  | Automated: `12h53`<br>Manual: `10h`<br>| `UA-8166: 4h`<br>`UA-8149: 2d`<br>`UA-8187: 3h`<br>| Total: **3d6h** |

### Release step-by-step

1. Cut a release branch when the sprint ends (typically when the new sprint starts on Monday). Create a new branch from develop and push to origin (e.g `release/3.2.0`).
2. Bump the release version by triggering its command (eg. `/release babylon:3.2.0`) in `#ios-builds` (you can run the command every time you want to upload a new build).
    1. This creates a test Tesflight build (try to do one as early as possible, so that you can catch issues like missing/expired certificates or profiles and any other production build errors early)
3. Trigger a hockey build from that branch.
4. Testers will then begin their work against the build you just created.
5. Any hotfix should target that branch, and you, as the release engineer, are responsible for double checking that the hotfix's PR is pointing to the release branch (instead of `develop`). 
7. Create a board for the release. Use a filter to reduce its scope, eg `project = UA AND affectedVersion = "iOS 3.2.0"`.
8. Create a new version in AppStoreConnect (login using your own account) / My Apps - on sidebar: + Version or Platform: iOS, input the version number.
    1. Add the release notes and update the release notes document.
    2. Add your release to the calendar.
    3. Check if you need anything from the Marketing Team. (`#MarketingQuestions`)
    4. Send the release notes to `#ClinicsOps`, so they have visibility on the release.
9. Perform a quick exploratory test on the TestFlight build to make sure everything looks okay.
(e.g. verifying that DigitalTwin Assets are visible and are not dropped due to Git LFS issues)
10. By now, QA should be notified that there is a new version in TestFlight.
11. When QA has signed off a particular build, submit the app to Apple.
    1. Make sure the release is Manual.
    2. When submitting to release, you are asked if the app uses the Advertising Identifier (IDFA). The answer is YES. You are then presented with three options please select as followed:
    1. 🚫 Serve advertisements within the app
    2. ✅ Attribute this app installation to a previously served advertisement
    3. ✅ Attribute an action taken within this app to a previously served advertisement
12 Once the app is accepted by Apple
    1. Tag the release and upload the binary. (If you're using the automated release command, you can find the binary in the Artifacts top section in the CI build).
    2. Merge the changes back to develop.
13. Please fill the release calendar.
    1. The process starts when the first build is provided to QA and ends when Apple has approved the app. 


## 5. Technical documents

// Work in progress ⚠️

## 6. New hires checklist

// Work in progress ⚠️

## 7. Interview process

// Work in progress ⚠️

## 8. Code guidelines, standards and etiquette

// Work in progress ⚠️
