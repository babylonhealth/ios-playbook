# JIRA 
### Overview
JIRA is the project management tool we use in all development squads at Babylon. Sometimes we make use of other tools like Trello for certain purposes but always one common thing between squads is JIRA. 
JIRA is a really powerful and customisable tool - how we use depends on the squad. Some squads use a simple setup with few statuses, others use advanced workflows with custom fields and many statuses. Although we allow customisation, there are a couple of things that remain shared across all projects which will be covered by the next sections. **One very important thing common for all the squads is that JIRA is our main source of truth and we should keep it as clean and up-to-date as possible**.

### How we’re using it
We don’t have one common methodology (Scrum, Kanban etc) so selecting one depends on the squad. Each squad sets its own rules of working so make sure to familiarise yourself with those when you join your squad.

Even that each project can be different we share some of the statuses between each of them to allow our automation to do the hard work of moving tickets between columns (setting up this automation requires some work - check `Automation` section for details). Keep in mind that even we have automation in place, sometimes we have to do it manually.

Common statuses:
* To Do / Ready For Development 
* In Progress
* Peer Review
* Awaiting Build
* QA

### SSDLC and JIRA
Babylons follows [Secure Software Development Lifecycle (SSDLC)](https://engineering.ops.babylontech.co.uk/docs/standards-ssdlc/) document that describes how software is built and run. One of the important rules is to have a JIRA ticket for all code changes we make. To ensure that, we do have `babylon/ssdlc-jira`  check for each PR we open. The only thing we have to do to comply with this requirement is to insert JIRA ticket in the Pull Request title on GitHub. Thanks to this, our tooling we’ll be able to pick up all merged pull requests between releases and create [CRP ticket](https://engineering.ops.babylontech.co.uk/docs/cicd-deployments/) with all JIRA tickets linked there when necessary.

Bot described above also fills a field called `Fix versions` with a version of the app where the work described by this ticket will be released. Thanks to this, you and your squad can make use of the  `Releases`  panel to track what and when was released. It’s important to try to only open one PR for one ticket whenever possible due to those automation. Talk with your PM to decide how to achieve this keeping in mind that we have PR size limits. Usually, subtasks is the answer but it depends on the squad.

### Common JIRA projects
As an iOS Engineer, there are a couple of projects (other than your squad one) that you should familiarise yourself with:
* [Consumer Apps](https://babylonpartners.atlassian.net/browse/CNSMR) - Shared project across iOS and Android. Contains tickets that don’t fit specific squad projects. It’s divided in a couple of boards. As an iOS Engineer you’ll be interested in: `iOS Engineering`, `iOS Goals`, `Release Board`.
* [iOS Platform](https://babylonpartners.atlassian.net/browse/IOSP) - Project used by the platform squad. For people outside the platform squad, there’s an epic called BAU (Business as usual) that contains work to be done if someone has time. If there’ s not enough work in your squad, that’s the place to look for work.

### Automation
To save some time and keep things up-to-date we have tooling that moves ticket between statuses automatically when actions take place on GitHub. If you want to add automation to your project, you’ll need to familiarise yourself with [fastlane/Actions/jira](https://github.com/babylonhealth/babylon-ios/blob/develop/fastlane/Actions/jira) and [ios-build-distribution](https://github.com/babylonhealth/ios-build-distribution).

In a nutshell:
* [fastlane/Actions/jira](https://github.com/babylonhealth/babylon-ios/blob/develop/fastlane/Actions/jira) moves tickets between `Awaiting Build`  and  `QA` 
* [ios-build-distribution](https://github.com/babylonhealth/ios-build-distribution) moves tickets between `In Progress`, `Peer Review`  and  `Awaiting Build`

To set it up, follow these instructions:
1. In [ios-build-distribution/Sources/AppCore/Models/Constants.swift](https://github.com/babylonhealth/ios-build-distribution) create static constant with your project transition IDs from JIRA. To get transition ids for your project, you need to open in your web browser this URL: `https://babylonpartners.atlassian.net/rest/api/2/issue/{issue-number}/transitions` (replace `{issue-number}` with a ticket from the project you’re trying to automate).
2. Add your constant to `jiraProjects` array below and open Pull Request.
3. In [fastlane/Actions/jira](https://github.com/babylonhealth/babylon-ios/blob/develop/fastlane/Actions/jira)** add your project prefix and QA status transition to `jira_projects` variable and open Pull Request.
