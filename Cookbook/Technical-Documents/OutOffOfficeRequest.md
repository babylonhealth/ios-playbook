# Requesting and Notifying Out Of Office time

Someone who is Out Of Office means that they are not in their usual work place at their usual working hours. This can be when someone goes on holidays or when someone that usually works in the office is working from somewhere else.

OOO time has to be requested and approved by your Line Manager and your Project Manager.

There are different types of OOO and each one of them have different requirements for requesting and for being notified.

## Holidays 🌴

As per contract, we (contractors excluded) are entitled to 25 holiday days per year. You can book your holidays at your convience, you might just need to sync first with your Squad, including the iOS engineers in it, to see if every one is OK with it. 

Ideally, you should give at least 2 weeks notice before taking any holiday but there are exceptions for emergency situations. If you want to book more than 5 consecutive days you ideally should give 4 weeks notice.

### Request

1. Check with the iOS Engineers in your squad that the work is covered during you absence.
1. Ask for approval from your PM - only if approved you can proceed to the next steps.
1. Communicate it to your line manager and mention your PM approval
1. Request in Bamboo

### Notify

1. [Send an event](#steps-to-configure-the-outlook-event) to the iOS Team Calendar and to your Squad email group
1. Update the [Team Plan document](https://docs.google.com/spreadsheets/d/1kdY3edy_TeqIGH_7VnZzElxgVo_qD2z4EF-arWNShyw/edit?usp=sharing) 
1. Notify the iOS Team and your Squad via Slack on the working day before you go on holidays.
1. [Enable automatic reply message](#steps-to-configure-automatic-reply) in your Babylon Outlook account.
1. At the end of your last working day before going on holidays change your Slack status to 🌴**On holiday** and set to clear after your last holiday day. 

If there is a big impact in the iOS Team or in your Squad due to you being away, please communicate a few days before in the team specific slack channel and do a handover if needed.

#### Steps to Configure the Outlook event
1. Open Outlook 
1. Select Calendar
1. Select Meeting
1. To: `<iOS calendar email group>`, `<your squad email group>`
1. Subject: `<Your name>` Holidays 🌴
1. Duration: All-day event
1. Show as: Free
1. Reminder: None
1. Select Save & Close

#### Steps to Configure automatic reply
1. Open Outlook 
1. Select Tools
1. Select Out of Office
1. ✔️ Send automatic replies for account `<your outlook account>`
1. Reply once to each sender with: `<Define a message mentioning the period you are on holidays>`
1. ✔️ Only send replies during this time period
1. Start time: First day of your holiday 
1. End time: Last day of your holiday

### Before leaving

When we leave on holidays we should make sure we leave our work either finished or delegated to someone else. There are a couple of steps we should perform to reduce the impact of your absence.

1. Try to finish any work in progress you have before you go.
1. Resolve the reviews you have on your opened PRs and try to get them merged.
1. In the event of not being able to complete 1. and/or 2. please sync with another iOS Engineer, ideally someone from your squad, and do a hangover. When hanging over an opened PR please make sure you add the iOS Engineer as `Assignee`.
1. Add yourself to the PullReminder exclusion list to prevent you to be added as a PR reviewer while you are away. Follow the steps to do it:
	1. Go to [pullreminders.com](https://pullreminders.com)
	1. Sign in
	1. Select Babylonpartners organization
	1. Select iOS-PullAssigners team
	1. Add yourself to the Excluded team members
1. You have to remove yourself from the PullReminder exclusion list once you get back. Adding a Slack reminder (`/remind me to reactivate PullReminder on <date>`) before you leave might help you not to forget.

## Working from Home 🏡
This section is only valid for non-remote employees.

Working from home is a benefit and should be seen as such. 
At the moment it is accepted that an engineer, once settled in the iOS Team processes, project, and squad is allowed to work from home 1-2 days per week. 
The number of days may very depending on your personal situation and your squad’s way of working. These should be discussed and agreed with your Line Manager and your PM.

When working from home you should notify in the the iOS team Slack channel when you are away and when are you expecting to come back.

### Request

1. Ask for approval from your PM - only if approved you can proceed to the next steps.
2. Communicate it to your line manager and mention your PM approval
3. Request in Bamboo

### Notify

1. Notify the iOS Team and your Squad via Slack on the working day before you are working from home. Emergencies might happen that require you to work from home and only notify on the same day. That will be acceptable if there is a plausible reason for it.
2. On the day you are working from home change your Slack status to 🏡 **Working remotely**.
