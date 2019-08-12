# How to add Labels to a Pull Request


We use labels in our Pull Requests to be able to categorize and prioritize our work. Some are also used to trigger our CI jobs.


## 1. The labels

At the moment our labels can be separated into the following groups:

- [Product verticals](#product-verticals)

- [Project horizontals](#project-horizontals)

- [Branding](#branding)

- [Status](#status)

- [Emergency](#emergency)

- [Extra](#extra)


### Product verticals
A product vertical corresponds to a big feature of the product. 

- <span style="background-color:#2BBBBB; color:black; font-weight:600">Health Management 🍄</span> - any work done in the health management vertical
- <span style="background-color:#5319e7; color:white; font-weight:600">Healthcheck 👩‍⚕️</span> - any work done in the healthcheck vertical
- <span style="background-color:#25fcb8; color:black; font-weight:600">Payments 💰</span> - any work done in the payments vertical
- <span style="background-color:#d3cb34; color:black; font-weight:600">Prescriptions 💊</span> - any work done in the prescriptions vertical
- <span style="background-color:#f9d0c4; color:black; font-weight:600">SDK 💸</span> - any work done in the SDK vertical
- <span style="background-color:#006b75; color:white; font-weight:600">Triage UI 🏥</span> - any work done in the Triage UI vertical

### Project horizontals
A project horizontal corresponds to an area of the project that has an horizontal impact, meaning it has impact in most or all the verticals in the project.

- <span style="background-color:#d4c5f9; color:black; font-weight:600">Automation Tests 🤖</span> - introduction of automation tests
- <span style="background-color:#fcfc50; color:black; font-weight:600">Localisation 🌐</span> - updating localizable strings or working in the localization system of the project
- <span style="background-color:#8631bf; color:white; font-weight:600">Infrastructure 🛠</span> - working in the foundation of the project like network layer.
- <span style="background-color:#2fcbe0; color:black; font-weight:600">Tooling 🔨</span> - working in tools like CircleCI, Danger, Linter.

### Branding
We have several projects which contain a subset of functionalities from the main babylon app. These apps also have different flavours in terms of UI. 

The labels to define work that is done in each different project are:

- <span style="background-color:#1d76db; color:white; font-weight:600">BUPA 🤕</span> - work in the BUPA app
- <span style="background-color:#0052cc; color:white; font-weight:600">NHS 👩‍⚕️</span> - work in the GP and hand app
- <span style="background-color:#9746e2; color:white; font-weight:600">Telus 🇨🇦</span> - work in the Telus app
- <span style="background-color:#2f2799; color:white; font-weight:600">US 🇺🇸</span> - work in the US app

### Stage
Informs in which stage of development the PR is. These labels are used to know which PRs can be reviewed. They are also used to trigger our CI jobs.

- <a name="merge"></a><span style="background-color:#FF7F50; color:black; font-weight:600">Merge</span> - The PR is ready to be merged. Our bot picks up when this label is added. It will then automatically add the PR in the queue to merge the PRs in order. Once dequeued, it will first merge back develop into the PR, then wait for our CI system to run all the tests. Only if every test has passed the bot will finally merge the PR.

- <a name="needs_reviewer"></a><span style="background-color:#ce3799; color:white; font-weight:600">Needs one reviewer 🙏</span> - The PR has one approval and is waiting for one more review.
- <a name="ready_review"></a><span style="background-color:#0e8a16; color:white; font-weight:600">Ready for Review 🚀</span> - The work on the PR is finished and it is ready to be reviewed.
- <a name="in_progress"></a><span style="background-color:#fbca04; color:black; font-weight:600">work in progress 🚧</span> - The work on the PR is not finished and is not ready to be reviewed.

### Status
Flags if there is something preventing the PR from being merged that is unrelated with review requests or failing builds.

- <a name="blocked"></a><span style="background-color:#000000; color:white; font-weight:600">Blocked ✋</span> - the PR is waiting for another task to be complete - this task can be a backend task, a product decision or another PR.
- <a name="blocking"></a><span style="background-color:#d93f0b; color:white; font-weight:600">Blocking other PRs 🙅‍♀️</span> - the PR is blocking other PRs from resuming their work or from being merged. The PR with this label should have priority over the PRs that are being blocked by this one.

### Emergency
Alerts when a PR is required to be merged. This is used in emergency situations like a hot fix or a piece of work that is mandatory to go in the release that is about to ship.

- <span style="background-color:#e00000; color:white; font-weight:600">Feature at risk 🚑</span> - A PR that has to go in the next release that will ship in 2 days or less. This PR has priority to be reviewed over all the other PRs that are not in emergency.
- <span style="background-color:#fcc1ba; color:black; font-weight:600">Hotfix 🆘</span> - The PR has priority to be reviewed because it has a hot fix targeting the current release branch.

### Extra
These tags are used to give extra context to the PR.

- <span style="background-color:#ff69b4; color:black; font-weight:600">Bug 🐛</span> - The PR fixes a bug.
- <span style="background-color:#c79ee2; color:black; font-weight:600">Housekeeping 🏡</span> - The PR includes some work that won't change any functionality - it just removes clutter from the project.
- <span style="background-color:#bfdadc; color:black; font-weight:600">Refactoring 🏗️</span> - The PR has refactoring work. Refactoring work is usually work that involves rewritting a part of the project that had technical debt. This work usually doesn't have any visual changes (UI/UX changes).
- <span style="background-color:#bfdadc; color:white; font-weight:600">Trivial 👶</span> - The PR takes 1-2 minutes to review (an example can be a PR that only involves updading localizable strings).

## 2. The rules

A PR should always present at least 2 labels. One label should represent the area of the project and the other should represent the stage of the PR.

There are a few rules we should consider when applying labels to a PR.


### [**Product verticals**](#product-verticals), [**Project horizontals**](#project-horizontals) and [**Branding**](#branding)

A PR should always contain at least one label that belongs to these groups. Multiple labels from these groups can be added to a PR because a piece of work can have impact in more than one area.

### [**Stage**](#stage)

In this group a mixed of rules are applied. 
A PR can:

- be either [ready for review](#ready_review) or still [in progress](#in_progress). These are mutually exclusive. It means the labels representing both these stages can't be present in the same instant.
- have [one reviewer](#needs_reviewer) label only if it is [ready for review](#ready_review).
- have [merge](#merge) label only if it is [ready for review](#ready_review), has two approvals and no changes requested.

### [**Status**](#status)

A PR can have one or both of these labels dependending on the blocking chain. However, it is very unusual and not ideal that a PR is in a situation where it needs both labels at the same time.

There is some specific information that is mandatory to be present in the PR description when using:

- [Blocked](#blocked) - Describe the reason why it is blocked. If it is being blocked by another PR or JIRA Ticket, these should be mentioned.
- [Blocking other PRs](#blocking) - Describe the reason why it is blocking other PRs. It should mentioned which PRs are being blocked by it.

### [**Emergency**](#emergency)

A PR can only have one emergency label.

### [**Extra**](#extra)

A PR can have one or more extra labels at the same time.


