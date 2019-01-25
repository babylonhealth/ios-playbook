# Restoring developer's efficiency

Code owners are a great functionality to define ownership within a codebase, either for certain parts or the entire codebase. Recently it was re-enabled in our repository to ensure at least one review from the Babylon iOS team before merging any pull request. The intention with this change wasn't to question the good will of anyone but as a formal process we need to establish to ensure all changes are validated and approved by the team.

## Problem

Right now every pull request require a review from the Babylon iOS Team which contains all of us, 17 members, which means 17 people will receive an email requesting a review, at that point you can start reviewing, which conceptually makes you an active reviewer and an interested party in being notified about any activity happening in that pull request, e.g. the author did answer your comments, new commits were pushed, ..., **but even when you did not review that particular pull request you are still a reviewer**, in this case a passive reviewer, which means receiving any activity happening in that pull request. 

Why is that a problem? Considering our dimension we normally have between 10 to 20 pull requests opened at any point in time and consequently anything happening in any of those will mean an email sent to the entire team, every push, every comment, anything will flood the entire team with a series of emails which makes it really hard to track the ones where you are actively participating, either by being a reviewer or author. 

Before enabling code owners we were receiving emails just for pull requests where someone ask our review explicitly or the ones you have reviewed/authored which was much more manageable. It is important to keep track of what's happening in the codebase but having email notifications for every single change in every pull request is not the way to achieve it and seriously undermines your ability to take action in something you are actively participating.

This is even worse because we have Pull Reminders installed and being used which doubles the number of notifications. While it's possible to disable those notifications it only fixes part of the problem.

## Solution

Introduce a new **required** status check to monitor reviews from each pull request the same way we have for CI and disable code owners completely.

```
* ci/circleci: build_X
* ci/circleci: cancel-redundant-builds
* ci/circleci: checkout_code
* ci/circleci: test_Y
* review/team-approval
```

Every protected branch requires all required status checks to pass before merging so by adding this new check which monitors at least one approval from the iOS team we guarantee with the same extent code owners functionality without promoting the entire team to be a reviewer of every pull request.

> ⚠️ NOTE ⚠️ We don't need to restrict merges to be done solely by the merge bot with this approach because only Administrators can merge a pull request without all status checks passing.

## Implementation

Our internal bot will monitor every pull request open to install this check as `failed` and then track any reviews from the iOS Team to change to a `success` state promoting it to be mergeable. We also need to monitor any subsequent synchronizations to re-install the check in the HEAD of the branch since checks are associated with a particular commit (SHA).