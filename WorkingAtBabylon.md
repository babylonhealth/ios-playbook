<p align="center">
<img src="logo.png">
</p>


Working in the iOS team
==================================

TODO

This is more or less modelled after https://github.com/codeOfRobin/Questions-to-ask-your-interviewer-iOS

### Where do we store our code?
We use Github. We have a central repo that hosts the main and white label apps, and a few Open Source projects that we created and rely on.

## Continuous Integration
### How many apps/targets/schemes?
### How big is your Fastfile?
It's around 250 lines of code at the moment, with about 15-20 lanes for beta testing, daily and custom builds, etc.

### Does it have several environment references?
### Can you dry run a lane on your machine right now?
Yes.

### Codesigning?
  
* What architectural patterns are you using to make development easier or more consistent? What problems with your current approach have you come across after settling on one (if you have one)?

## Team/People
### comms - slack?
Slack, as a non-trivial part of the team is remote. Zoom for meetings of more than 2-3 people.

### Do people ever take sick days to get work done?
No.

### When was the last time someone worked a late night/weekend in order to meet a deadline?
TODO

### How many meetings do you have in a day?
It depend on the squad you’re assigned. For Enrolment and Integrity I counted 18 in a typical sprint, so that averages to ~2 a day. Note that quite a few of them are optional.

### Does your calendar look like a losing game of tetris? Do you have large continuous uninterrupted hours?
Most of the meetings are on the first Monday/Tuesday of the sprint.

### Are there any private spaces in your office?
There are very few at the moment.

### Is there a gym/field/court close to your office for physical activity?
There is a commercial gym close by, a park, and a barebones gym in the office. There’s also free yoga twice a week.

### Do people feel comfortable calling attention to systemic issues/heavily “band-aid”-ed systems?
Yes, we have anonymous company level Q&A and peakon surveys. [this is my experience].

### Are any of your engineering managers mobile engineers? Do mobile devs feel like they have to learn backend dev to "prove themselves" / feel like they have a seat at the table?
iOS engineers have to know iOS, and that’s it.

## Designers?
### What’s the handoff process like?
As we work in squads, collaboration with designers, product, and QA is very tight and happens every day. After a ticket has been discussed in discovery and planning, designs are provided on Zeplin (sketch).

### Do you let devs get down and dirty with sketch files?
Not usually, but developers are encouraged to report wrong alignments, spacing, and in general to partecipate in the design/UX discussion.

### Do you focus on making your android and iOS apps look consistent?
There is a drive for consistency with a design system, but platform-specific conventions are taken into account.

### Example of the above: Do you have the “title” of a VC on the left in iOS/on the center in android for consistency? Do you have a modal View Controller presented with a back arrow on the left?
We follow iOS standards, but it's up to every squad.

## Q/A?
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

### Does your marketing org ensure your marketing materials are inclusive (I like to call this the Revolut filter)?
