Code Review Etiquette
===========

This document describes a general etiquette and code of conduct that every team member should follow, as well as some concrete guidelines and activities we use in the team related to code reviews.
The purpose of these guidelines is to formalise some basic requirements for pull requests and receiving/providing feedback to improve the quality of code reviews and teamwork in general.

Note: Guidelines in this document should be considered to be of equal importance

Note: This document is heavily inspired by [this blog post](https://github.blog/2015-01-21-how-to-write-the-perfect-pull-request/)

Everyone
--------

* Be respectful to each other
* Be humble. ("I'm not sure - let's look it up.")
* Don't use hyperbole. ("always", "never", "endlessly", "nothing")
* Don't use sarcasm or trolling
* If you feel annoyed at something/someone, don't make it affect your or others' work. Talk to a friend, go for a walk, meditate, switch to something else.
* Talk synchronously, e.g. call or in person, if there are too many "I didn't understand" or "Alternative solution:" comments. Prefer not to use chat for that. Post a follow-up
  comment summarizing the discussion.
* Avoid selective ownership of code ("mine", "not mine", "yours"). Prefer referring to it as `our` code.
* Use "we" instead of "you", unless asking for someone's opinion ("What do you think ...?", but "Here we are doing ... What if we ...?",)
* Avoid using terms that could be seen as referring to personal traits. ("dumb",
  "stupid", "insane"). Assume everyone is intelligent and well-meaning.
* Be aware of negative bias with online communication. (If content is neutral, we assume the tone is negative.) Can you use positive language as opposed to neutral?
* When using emojis be aware that their meaning can be different for different individuals (e.g. a winking smile may not be always innocent)
* Same with any other media format you decide to use
* Do not expect your comments to be answered immediately. If you need an answer fast — talk directly with the person (the same applies to the Slack messages)
* Accept that it's fine to have disagreements and it's hard to please everyone


Creating a Pull Request
--------

* When creating your branches, name them using a format like `<author>/<ticket>` or `<author>/<ticket>-<shortdescription>`
* Carefully fill in the pull request template:
	* the title of the PR should follow the format `[XXX-123] Description of the change`, starting with a ticket number
	* explain the context and motivation, don’t assume familiarity with the history. Highlight how the goal was achieved without going too much into details - people tend not to read long descriptions and if a long explanation is needed, then a single pull request is probably not going to be enough (i.e. the change may need to go through the proposal process or design review). 
	* don't strip out parts of the template unless it is absolutely irrelevant to the changes (i.e. change in the build script does not need any screenshots as it does not touch UI)
	* don't forget labels (note: it's better to set them after the PR is created, as GitHub sometimes fails with 405 status code and we don't know why)
* Explicitly request review from or mention team mates you specifically want to involve in the discussion (in addition to the ones that will be assigned to it automatically by GitHub)
* Self-review your changes, adding comments where you think you can get questions (it may worth adding these as code or documentation comments). Tip: if you spot small issues you can use GitHub suggestions and apply them right away
* Keep your pull requests small, ideally they shouldn't be more than **800 additions** (Danger will make a warning if this exceeds 850 additions)
* Create a draft PR for work that is in progress, but only do that if you seek for opinions on your work
* Mark a PR with the "Blocked" label if it has any dependency that should stop it from being merged (it's fine for pull requests to be both "blocked" and "ready for review", but it shouldn't be "ready for review" and "wip")
* Give other team members a reasonable time to review your changes, if the change is critical use "Top priority" label and post it in the team channel
* Do not leave stale pull requests, seek for help/actions or close them (make sure you don't delete your local branch if you may need it later). If you find one that appears to have been stale for a week, please warn the author. After two weeks it can be closed with a note after a discussion of its current status with the author.
* It's our common effort to push product forward and we all do equally valuable work. Keep that in mind when creating a PR: try to review some of other's PRs, and avoid having more than X PRs opened at the same time


Reviewing a Pull Request
--------

* Accept that many programming decisions are opinions. Discuss tradeoffs, which one
  you prefer, and reach a resolution quickly. There are always multiple ways of doing things, and they may be equally acceptable
* Focus not on finding flaws in the code (no one writes perfect code) but on understanding the change in the first place
* Encourage things you like, try not only comment on what you don't like
* Before suggesting to change code think if it brings any real value or if it is just your personal preference. Is this code something you can live with or not?
* Do not try to make everything perfect (it never will be and otherwise we'll never deliver anything), but do not compromise on quality
* Do not comment if you don't have any suggestions to address your comment
* Use GitHub suggestions as much as possible
* If you feel strong against the change - request changes and explain why you are doing that. Do not request changes for typos, missing documentation comments or code style violations, trust your colleagues to address them.
* Comment on the changes if something is not clear to you and needs further clarification or actions
* If you are not familiar with the domain ask for more context (better directly to the author) rather than skipping to something more familiar
* Ask, don't tell. ("What do you think about...?", "How about ...?", "Should we try ...?")
* Be brief but clear in your comments (code review is not about proving who is more correct or knows more)
* Unless explicitly asked for it do not suggest code to be written in a specific way - let the author to find or suggest a solution themselves, they may come up with a better one
* Submit all the comments as a single review, even if there is just one comment
* Approve changes if you are confident about them.
* If you are the first person to approve the changes, our bot will automatically add the label "Needs one reviewer" after your review.
* If you see a stale pull request without any updates - ask for the status update in the comment
* Do not be a blocker - if you requested changes and they were addressed make sure you review it
* Do not merge others pull requests - they may be waiting for someone else review. In general, the PR author should be the one adding the "Merge" label to merge their own PRs (except rare cases like if the author is on holidays but the PR is otherwise good to go)

Responding to feedback
-------------------------

* Wait before answering to a single comment, the reviewer may be still writing more of them (though they should prefer to send all comments at once)
* Be grateful for the reviewer's suggestions. ("Good call. I'll make that
  change.")
* If you disagree with a suggestion, explain why and avoid template answers like "out of the scope" or "thank you for your opinion". If you think that suggestion is a personal preference and does not bring value - say so
* Assume the best intention from the reviewer's comments.
* If a reviewer seems aggressive or angry or otherwise personal, consider if it is intended to be read that way and ask the person for clarification of intent, in person if possible. Do not escalate online discussions.
* If you can't reach agreement seek for more opinions
* Don't be too defensive about your code, someone will rewrite it anyway sooner or later (it might be yourself as well)
* Try to answer all comments, don't make your colleagues feel like you are ignoring them. You can review your own code for that instead of sending individual replies so that all your answers are posted at once.
* Add "work in progress" label while addressing review comments
* Re-request review when you addressed the comments (either implementing suggested change or replying to the comment) and label it with "Ready for review" again
* Do not rebase and force-push to your pull request branch after you have received any comments, use merge instead. This allows reviewers to view changes on the PR since their last review, rather than re-reviewing a lot of the code they have already reviewed. All pull requests are squashed when they are merged into the base branch so the history of your changes won't matter. It's fine to rebase and force-push if there are no comments.
* Do not dismiss any pending requests for changes unless you agreed with their authors that it was addressed
* When you have two approvals and have no pending questions or requests for changes and don't wait for review from anyone else - put a "Merge" label for bot to merge your changes.


PR Parties
--------

To improve collaboration, we take time to review pull request together in small groups every week. This is what we call "PR parties".

- Each group should include at least one senior developer.
- Each group will have a few pull requests assigned to them
- When done with their assigned PRs, the group is free to review something else (i.e. each other's pull requests) or finish the meeting

Pull Assigners
--------

To balance the workload and avoid knowledge silos we use GitHub's code reviewer assignment feature to automatically assign reviewers.

- Each pull request will be assigned to three reviewers from the team. At the time of writing, reviewers are chosen on a "round robin" basis where assignments are given to those with the least recent review requests.
- Two approvals are enough to merge a pull request (there shouldn't be pending requests for changes though and you should address any other pending questions or comments)
- Anyone else is still encouraged to review any pull request and author can request reviews from specific teammates
