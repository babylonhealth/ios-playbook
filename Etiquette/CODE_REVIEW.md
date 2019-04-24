Code Review Etiquette
===========

This document describes a general etiquete and code of conduct that every team member should follow, as well as some concrete guidelines and activities we use in the team related to code reviews.
The purpose of these guidelines is to formalise some basic requirements for pull requests and receiving/providing feedback to improve the quality of code reviews and the team work in general.

Note: Guidelines in this document should be considered to be of equal importance

Note: This document is heavily inspired by [this blog post](https://github.blog/2015-01-21-how-to-write-the-perfect-pull-request/)

Everyone
--------

* Be respecful to each other
* Be humble. ("I'm not sure - let's look it up.")
* Don't use hyperbole. ("always", "never", "endlessly", "nothing")
* Don't use sarcasm or trolling
* If you feel annoyed at something/someone don't make it affect your or others work. Talk to a friend, go for a walk, meditate, switch to something else.
* Talk synchronously, e.g. call or in person, prefer not to use chat for that, if there are too many "I didn't understand" or "Alternative solution:" comments. Post a follow-up
  comment summarizing the discussion.
* Avoid selective ownership of code ("mine", "not mine", "yours"). 
* Use "we" instead of "you", unless asking for opinion of specific individual ("What do you think ...?", but "Here we are doing ... What if we ...?",)
* Avoid using terms that could be seen as referring to personal traits. ("dumb",
  "stupid", "insane"). Assume everyone is intelligent and well-meaning.
* Be aware of negative bias with online communication. (If content is neutral, we assume the tone is negative.) Can you use positive language as opposed to neutral?
* When using emojis be aware that their meaning can be different for different individuals - winking smile may not be always innosent
* Same with any other media format you decide to use
* Do not expect your comments to be answered immediately. If you need an answer fast - talk in person (same applies to the Slack messages)
* It's fine to have disagreements and its hard to please everyone.


Creating Pull Request
--------

* Carefully fill in pull request template:
	* title of the PR should follow format `[XXX-123] Description of the change` starting with a ticket number
	* explain the context and motivation, don’t assume familiarity with the history. Highlight how the goal was achived without going too much into details - people tend not to read long descriptions and if the long explanation is needed probably just pull request will be not enough (the change may need to go through proposal process). 
	* don't strip out parts of the template unless it is absolutely unrelevant to the changes (i.e. change in the build script does not need any screenshots as it does not touch UI)
	* don't forget labels (it's better to set them after PR is created as github sometimes fails with 405 status code and we don't know why)
* explicitly request review from or mention team mates you specifically want to involve in the discussion
* Self-review your changes, adding comments where you think you can get questions (it may worth adding these as code or documentation comments). You can use github suggestions and apply them right away
* Keep pull requests small, ideally it shouldn't be more than **800 additions/deletions**
* Create a draft PR for work that is in progress, but only do that if you seek for opinions on your work
* Mark PR with "Blocked" label if it has any dependency that should stop it from being merged (it's fine for pull request be both "blocked" and "ready for review", but it shouldn't be "ready for review" and "wip")
* Give your team mates a reasonable time to review your changes, if the change is critical use "Top priority" label and post it in the team channel
* Do not leave stale pull requests, seek for help/actions or close them (make sure you don't delete your local branch if you may need it later)
* It's our common effort to push product forward and we all do equally valuable work. That in mind when creating PR try to review some PRs, avoid having more than X opened PRs


Reviewing Pull Request
--------

* Accept that many programming decisions are opinions. Discuss tradeoffs, which
  you prefer, and reach a resolution quickly. There are always multiple ways of doing things, and they may be equally acceptable
* Focus not on finding flaws in the code (no one writes perfect code) but on understanding the change in the first place
* Encourage things you like, try not only comment on what you don't like
* Before suggesting to change code think if it brings any real value or if it is just your personal preference. Is this code something you can live with or not?
* Do not try to make everything perfect (it never will be and otherwise we'll never deliver anything), but do not compromise on quality
* Do not comment if you don't have any suggestions to address your comment
* Use github suggestions as much as possible
* If you feel strong against the change - request changes and explain why you are doing that. Do not request changes for typos, missing documentation comments or code style violations, trust your colleagues to address them.
* Approve changes if you are confident
* Comment on the changes if something is not clear to you and needs further clarification or actions
* If you are not familiar with the domain ask for more context (better in person) rather than skipping to something more familiar
* Ask, don't tell. ("What do you think about...?", "How about ...?", "Should we try ...?")
* Be breif but clear in your comments (code review is not about proving who is more correct or knows more)
* Unless explicitly asked for it do not suggest code to be written in a specific way - let the author to find or suggest a solution themselves, they may come up with a better one
* Submit all the comments as a single review, even if there is just one comment
* If you see a stale pull request without any updates - ask for the status update in the comment
* Do not be a blocker - if you requested changes and they were addressed make sure you review it
* Do not merge others pull requests - they may be waiting for some one else review

Responding to feedback
-------------------------

* Wait before answering to the single comments, reviewer may have more (though they should prefer to send all comments at once)
* Be grateful for the reviewer's suggestions. ("Good call. I'll make that
  change.")
* If you disagree with suggestion explain way and avoid template answers like "out of the scope", "thank you for your opinion". If you think that suggestion is a personal preference and does not bring value - say so
* Assume the best intention from the reviewer's comments.
* If a reviewer seems aggressive or angry or otherwise personal, consider if it is intended to be read that way and ask the person for clarification of intent, in person if possible. Do not escalate online discussions.
* If you can't reach agreement seek for more opinions
* Don't be too defensive about your code, someone will rewrite it anyway sooner or later (it might be yourself as well)
* Try to answer all comments. You can review your own code for that instead of sending individual replies
* Add "work in progress" label while addressing review comments
* Re-request review when you addressed the comments (either implementing suggested change or replying to the comment) and label it with "Ready for review" again
* Do not rebase and force-push in your pull request branch after you recieved any comments, use merge intsead. All pull requests are squashed when they are merged into the base branch so the history of your changes won't matter. It's fine to rebase and force-push if there are no comments
* Do no merge pull request with pending requests for changes unless you agreed with their authors that it was addressed
* When you have two approvals and don't wait for review from anyone else - put a "Merge" label for bot to merge your changes.


PR Parties
--------

To improve colloboration every week (on Monday) we take time to review pull request together in small groups, what we call "PR parties"

- Each group should include at least one senior developer. 
- Each group will have few pull requests assigned to them. 
- When done with assigned PRs group is free to review something else (i.e. each other pull requests) or finish the meeting

Pull Assigners
--------

To balance the workload and avoid knowledge silos we use Pull Assigners to assign reviewers.

- Each pull request will be assigned three random reviewers from the team
- Two approvals are enough to merge pull request (there shouldn't be pending requests for changes though)
- Anyone else is still welcome to review any pull request and author can request for reviews from specific team mates
