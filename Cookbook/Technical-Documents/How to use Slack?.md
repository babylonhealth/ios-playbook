# How to use Slack?

In Babylon we try to be as much remote friendly as we can.
Slack is a tool we rely on a lot to help us communicate with everyone without having to be physically present.
On the first day at Babylon, one of the first things you have automatically access is to your Slack account.
Although this is a pretty straightforward instant messaging tool, there a few rules and tips everyone should be aware.

## Which channels to join?

### #ios
The public channel for any babylonian to reach to the iOS Team. This channel should be regularly checked by the iOS support engineers.

### #ios-underground
The private channel for the iOS Team. It's the place to raise problems, have discussions, make the team aware of your whereabouts or just to say "Good morning 👋".

### #ios-meeting-outcomes
The private channel to post the outcomes from the iOS team meetings.
Each message represents a meeting and should have the following format:

```
**<title>, <date>**
<what was discussed>
Recording: <recording link>
```
Example:

```
**Retro, 11th Nov 2019**
Board: https://trello.com/b/8OC8ahZz/retro-11th-nov-2019
Actions: For @catarina to change the PR Party documentation to address the changes in the process that were discussed.
Recording: https://babylonhealth.zoom.us/recording/share/2q99Zb7Oxg0Kk7yIAVITuGUZVCs2_eV7Vge2Ppmjq3WwIumekTziMw
```

### #ios-pedia
A private channel used to make announcements or to open discussions on broader topics within the iOS Team.
Each announcement or discussion should be just one message and the discussion should happen within that message thread.
To understand the status of a message we tag the messages following:

- In discussion 💬
- No outcome ❎
- With outcome ✅
- Announcement ⚠️

To be easier to identify the topic of the message we use:
 `[<topic of the message>] message`

Example: 

```
[Peakon] Please make sure you feel the Peakon survey frequently and give as much feedback as you can. Please do not ever think your feedback is not relevant enough to write it down. I can guarantee you every feedback is important for us and it will always help us get better at what we do.
Your help is very much appreciated!
Thank you :thanks:
```

### #ios-questions

A private channel where the iOS engineers can post any technical question and it will be answered by anyone in the iOS Team.
The questions should be a message in a channel and the reply should be withing the message's thread.
Ideally follow the stackoverflow approach and state what you tried.

The question should follow the format:
`[<topic of the question>] question`

Example:
```
[RAF] What is an example with the newest style for a page where a child triggers some events in a parent? What is best to inject, and from where?
```

### #ios-build

A public channel where we usually trigger CI workflows like Testfligh/AppCenter builds or UI Automation Tests.
The UI Automation Tests run every night and the results are published in this channel by the bot.
To check how to trigger the workflows check [Slack CI Integration](/SlackCIIntegration.md)

## How to manage notifications?

Slack notifications are great to make sure we don't miss anything important. However, when they are very frequent they can disturbe our work and our productivity.

There are a few tips to try to reduce the number of notifications to the ones that really matter to you:

### Global notification preferences

To reduce overall number of notifications we can configure the notifications on Slack doing the following:

1. Go to Slack > Preferences > Notifications
2. Configure your notifications with:

<img src="Assets/onboarding/slack-notification-preferences.png">

3. Go to `My keywords` and define the keywords to be used to trigger notifications. These can be your nicknames and variations of your name.

4. In the `Do Not Disturb` you can set the time interval you don't want to receive any Slack notification. Ideally this should enabled during your non-working hours.

On the day to day basis, if you want some quiet time, you can mute notifications temporarly by selecting the notifications icon next to your Slack organization name followed by selecting one of the options.

<img src="Assets/onboarding/slack-notification-muted.png">

### Leave the channel

When you leave a channel you can no longer open it unless you join it again. Also, when someone shares a thread from that channel with you, you will have to join the channel to be able to read it.
When the channel is private, if you leave it you will have to be invite by one of the members to join it again.

You should leave a channel when:

 - You haven't open it in the last month.
 - The subject is no longer relevant or obsolet.

### Mute the channel

Muting a channel means you will have access to it but you won't be notified if you are mentioned individually or with `@channel` or `@here`.

You should mute a channel when:

 - The subject is not your main focus but you like to keep yourself updated on what is happening.
 - It is a private channel and you don't want to loose access to it but you don't check it on a day to day basis.


## How to communicate my schedule?

Your status on Slack should be a way to communicate what is your current status. This can be used to indicate you are working remotely, you are in a meeting or any other status.

### Connect Slack with Outlook

You can integrate your Slack account with your Outlook account. This will give permission for Slack to:
- notify you of your calendar events
- change your status to `In Meeting` when you have meetings scheduled in your calendar

To connect the Outlook Calendar app:

- Go to Apps in Slack
- Search for Outlook Calendar
- Open a conversation with Outlook Calendar
- Connect your account
- Configure your preferences

### Not available

When we are not available on Slack it is advised to change your Slack status so the person who wants to reach you knows why you are unnavailable.
You can configure your own status however, for some common situations it is better to use the pre-defined ones:

- [Holidays](/OutOffOfficeRequest.md#holidays-) 🌴
- [Working from home](https://github.com/babylonhealth/ios-playbook/blob/catarina/CNSMR-3278/Cookbook/Technical-Documents/OutOffOfficeRequest.md#working-from-home-) 🏡
- Off sick 🤒
- Focused 💭 - A few of us turn-off notifications or turn-off Slack when we want time to focus on a certain task.

Scheduling time slots to focus on a task are encourage to be used because they help our productivity. When booking these please be mindful of when and for how long you are unnavailable. It is always better to schedule these slots when you have no meetings in your calendar and are not involved in conversations that are active at that time.
