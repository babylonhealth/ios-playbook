<p align="center">
<img src="logo.png">
</p>


Working in the iOS team
==================================

This document is modelled after Robin Malhotra's [Questions to ask your iOS interviewer](https://github.com/codeOfRobin/Questions-to-ask-your-interviewer-iOS). It aims to provide a few answers to how we work at Babylon and our process is structured.

### Where do we store our code?

We use Github. We have a central repo that hosts the main and white label apps, and a [few Open Source projects](https://github.com/search?q=topic%3Aios+org%3ABabylonpartners+fork%3Atrue) that we created and rely on.

## Continuous Integration
### What Continuous Integration service do you use?

We currently run on CircleCI

### How many apps/targets/schemes?

We have the main app and a few white-label apps.

We use a modular architecture, so our app workspace is split into 9 Xcode projects for modules and apps, 3 projects for test utilities and shared features, and 4 projects related to our SDK, not counting the Pods project (and our OSS projects)

Each module project has 2 targets on average: one for the framework, one for the tests (Unit, UI, Snapshot). The app project has 2 targets (6*2) given our white-labelling variants.
### How big is your Fastfile?
It's around 250 lines of code at the moment, with about 15-20 lanes for beta testing, daily and custom builds, etc. This file however includes multiple other files, especially in fastlane/Lanes and fastlane/Actions too, making the code dedicated to fastlane quite bigger.

### Can you dry run a lane on your machine right now?
Yes.

## Team/People
### comms - slack?
Slack, as a non-trivial part of the team is remote. Zoom for meetings of more than 2-3 people.

### Do people ever take sick days to get work done?
No.

### When was the last time someone worked a late night/weekend in order to meet a deadline?
It's very rare, honestly. Most people that work late do so on their own accord. The office is pretty empty after 6pm.

### How many meetings do you have in a day?
It depends on the squad you’re assigned to. For Enrolment and Integrity I counted 18 in a typical sprint, so that averages to ~2 a day. Note that quite a few of them are optional. Not all of the meetings, though, are the "let's discuss x" type of meetings. For example, we hold a PR party weekly where we, in groups, try to speed up the review process.

Interviews, sometimes, can take up some time. It's usually, at maximum, one hour per week. Reviewing tests is also part of your day-to-day duties. Every engineer, including juniors, is involved in this (both interviewing and reviewing tests).

### Does your calendar look like a losing game of tetris? Do you have large continuous uninterrupted hours?
It depends a lot on the squad. For Enrolment and Integrity, for example, most meetings are on the first Monday and Tuesday of the sprint. For Triage and Health Management this is not the case and are more spread out.

### Are there any private spaces in your office?
There are very few at the moment.

### Is there a gym/field/court close to your office for physical activity?
West: there is a commercial gym close by, a park, and a barebones gym in the office. There’s also free yoga twice a week and a weekly 5-a-side football game.
East: commercial gym close by.

### Do people feel comfortable calling attention to systemic issues/heavily “band-aid”-ed systems?
Yes, we have anonymous company level Q&A and peakon surveys. [this is my experience].

### Are any of your engineering managers mobile engineers? Do mobile devs feel like they have to learn backend dev to "prove themselves" / feel like they have a seat at the table?
iOS engineers have to know iOS and general programming practices, and that’s it.

## Designers?
### What’s the handoff process like?
As we work in squads, collaboration with designers, product, and QA is very tight and happens every day. After a ticket has been discussed in discovery and planning, designs (made in Sketch) are imported to a common (per-platform) Zeplin project.

### Do you let devs get down and dirty with sketch files?
Not usually, but developers are encouraged to report wrong alignments, spacing, and in general to participate in the design/UX discussion.

### Do you focus on making your Android and iOS apps look consistent?
There is a drive for consistency with a design system, but platform-specific conventions are taken into account.

### Example of the above: Do you have the “title” of a VC on the left in iOS/on the center in Android for consistency? Do you have a modal View Controller presented with a back arrow on the left?
We follow iOS standards, but it's up to every squad.

## QA?
### What’s the handoff-to-QA process like?
Same answer as with designers. Collaboration is frequent as there is a QA per squad. A build is triggered from the main branch every night (with custom builds trigger-able at any time), and in the morning the QA starts testing against it.

## Learning
### Do you sponsor conference tickets?
We have a set `training` budget that can be used at the person's discretion.

### Books/online resources?
We have a set `training` budget that can be used at the person's discretion.

## Product
### Do devs get access to support tickets?
### How involved are devs in product decisions?
There is usually a product person in each squad that leads this, but everyone is encouraged to contribute and/or raise concerns.

### Do you consider the societal impact of the products you’re making?
Yes. We wouldn't be here otherwise.
