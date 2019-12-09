# How to add Labels to a Pull Request


We use labels in our Pull Requests to be able to categorize and prioritize our work. Some are also used to trigger our CI jobs.


## 1. The labels

At the moment our labels can be separated into the following groups:

- [Project horizontals](#project-horizontals)

- [Branding](#branding)

- [Status](#status)

- [Emergency](#emergency)

- [Extra](#extra)

### Project horizontals
A project horizontal corresponds to an area of the project that has an horizontal impact, meaning it has impact in most or all the verticals in the project.

- ![Automation Tests 🤖](https://img.shields.io/static/v1?label&message=Automation%20Tests%20🤖&color=d4c5f9) - introduction of automation tests
- ![Localisation 🌐](https://img.shields.io/static/v1?label&message=Localisation%20🌐&color=fcfc50) - updating localizable strings or working in the localization system of the project
- ![Platform 🔩](https://img.shields.io/static/v1?label&message=Platform%20🔩&color=002360) - work in the iOS Platform, e.g. architecture, infrastructure, tooling, ...

### Branding
We have several projects which contain a subset of functionalities from the main babylon app. These apps also have different flavours in terms of UI. 

The labels to define work that is done in each different project are:

- ![BUPA 🤕](https://img.shields.io/static/v1?label&message=BUPA%20🤕&color=1d76db) - work in the BUPA app
- ![NHS 👩‍⚕️](https://img.shields.io/static/v1?label&message=NHS%20👩‍⚕️&color=0052cc) - work in the GP and hand app
- ![Telus 🇨🇦](https://img.shields.io/static/v1?label&message=Telus%20&color=9746e2)🇨🇦 - work in the Telus app
- ![US 🇺🇸](https://img.shields.io/static/v1?label&message=US%20&color=2f2799) 🇺🇸 - work in the US app

### Stage
Informs in which stage of development the PR is. These labels are used to know which PRs can be reviewed. They are also used to trigger our CI jobs.

- ![Merge](https://img.shields.io/static/v1?label&message=Merge&color=FF7F50) - The PR is ready to be merged. Our bot picks up when this label is added. It will then automatically add the PR in the queue to merge the PRs in order. Once dequeued, it will first merge back develop into the PR, then wait for our CI system to run all the tests. Only if every test has passed the bot will finally merge the PR.
- ![Needs one reviewer 🙏](https://img.shields.io/static/v1?label&message=Needs%20one%20reviewer🙏%20&color=ce3799) - The PR has one approval and is waiting for one more review.
- ![Ready for Review 🚀](https://img.shields.io/static/v1?label&message=Ready%20for%20Review🚀&color=0e8a16) - The work on the PR is finished and it is ready to be reviewed.
- ![Work in progress 🚧](https://img.shields.io/static/v1?label&message=Work%20in%20progress%20🚧&color=fbca04) - The work on the PR is not finished and is not ready to be reviewed.

### Status
Flags if there is something preventing the PR from being merged that is unrelated with review requests or failing builds.

- ![Blocked ✋](https://img.shields.io/static/v1?label&message=Blocked%20✋&color=000000) - the PR is waiting for another task to be complete - this task can be a backend task, a product decision or another PR.
- ![Blocking other PRs 🙅‍♀️](https://img.shields.io/static/v1?label&message=Blocking%20other%20PRs%20🙅‍♀️&color=d93f0b) - the PR is blocking other PRs from resuming their work or from being merged. The PR with this label should have priority over the PRs that are being blocked by this one.

### Emergency
Alerts when a PR is required to be merged. This is used in emergency situations like a hot fix or a piece of work that is mandatory to go in the release that is about to ship.

- ![Feature at risk 🚑](https://img.shields.io/static/v1?label&message=Feature%20at%20risk%20🚑&color=e00000) - A PR that has to go in the next release that will ship in 2 days or less. This PR has priority to be reviewed over all the other PRs that are not in emergency.
- ![Hotfix 🆘](https://img.shields.io/static/v1?label&message=Hotfix%20🆘&color=fcc1ba) - The PR has priority to be reviewed because it has a hot fix targeting the current release branch.

### Extra
These tags are used to give extra context to the PR.

- ![Bug 🐛](https://img.shields.io/static/v1?label&message=Bug%20🐛&color=ff69b4) - The PR fixes a bug.
- ![Housekeeping 🏡](https://img.shields.io/static/v1?label&message=Housekeeping%20🏡&color=c79ee2) - The PR includes some work that won't change any functionality - it just removes clutter from the project.
- ![Refactoring 🏗️](https://img.shields.io/static/v1?label&message=Refactoring%20🏗️&color=bfdadc) - The PR has refactoring work. Refactoring work is usually work that involves rewritting a part of the project that had technical debt. This work usually doesn't have any visual changes (UI/UX changes).
- ![Trivial 👶](https://img.shields.io/static/v1?label&message=Trivial%20👶&color=ce3799) - The PR takes 1-2 minutes to review (an example can be a PR that only involves updading localizable strings).

## 2. The rules

A PR should always have at least one label, representing the review status of the PR. If applicable, other labels can be added to represent what area does the PR touch.

As such, there are a few rules we should consider when applying labels to a PR.

### [**Project horizontals**](#project-horizontals) and [**Branding**](#branding)

Multiple labels from these groups can be added to a PR because a piece of work can have impact in more than one area.

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


