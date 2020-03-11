# How to configure Pull Assigners for Babylon repos

## Introduction

The aim of this document is to explain how to configure GitHub's automatic code review assignment in our Babylon repos in order for it to assign people to PRs automatically.

- We will use the `CODEOWNERS` file to make GitHub always assign a GitHub team to all our Pull Requests.
- GitHub will then pick N reviewers from that team and unassign the team itself.
- Optionally, we could also require each PR of a repository to always have an approval from a subset of people (the ones owning the responsibility of the code) – like we did for our bots repository owned by the Developer Experience squad.

## Configure GitHub Teams

### A team to list the reviewers to pick from

1. First, you need a GitHub team containing the list of all the people you want GitHub to pick reviewers from.

   * For the iOS repos, we use the team `@babylonhealth/iOS-Devs`, which should contain every iOS developer at Babylon. So if you need the same list of reviewers, you can just use this one instead of creating one.
   * If you need a different list to pick your reviewers from, you'd need to create a team via [this page on GitHub](https://github.com/orgs/babylonhealth/new-team), and once it's created, go to the team's page and add Members to that new team ([e.g. here for `iOS-Devs`](https://github.com/orgs/babylonhealth/teams/iOS-Devs/members))

2. Next, **make sure that this GitHub team –containing the people you want as reviewers– has access to your repository**, via the "Repositories" tab in the team's page ([e.g. here for `iOS-Devs`](https://github.com/orgs/babylonhealth/teams/iOS-Devs/repositories))

## The `CODEOWNERS` file

Now we need to ensure that the right team (e.g. `iOS-Devs`) is automatically assigned as reviewer on all new PRs.

For this, you just need to create a `.github/CODEOWNERS` file in your repo with the following content (if you have a `CODEOWNERS` file already at the root of your repository, we advise to move it inside a `.github/` directory to clean up your repo root).

```
# Global rule for the whole codebase.
#  - The empty `iOS-PullAssigner` team will act as a proxy for the PullAssigner bot.
#    When a new PR arrives, PullAssigner will be triggered, which will then pick members from the iOS-Admin team

* @babylonhealth/iOS-Devs
```

## Enabling GitHub's code review assignment

Once the team and `CODEOWNERS` file has been created, we can go ahead and enable GitHub's reviewer assignment feature.

1. Head to the organisation's [home page](https://github.com/babylonhealth).
2. Go to the "Teams" tab and search for your team ([e.g. here for `iOS-Devs`](https://github.com/orgs/babylonhealth/teams/ios-devs)).
3. Go to the "Settings" page (to access / edit your team's settings you'll need to have the `Maintainer` team role).
4. In "Settings" go to "Code review assignment".
5. Tick "Enable auto assignment" and configure the settings as desired. 

**Note:** You'll probably want to tick "If assigning team members, don't notify the entire team" to prevent the entire team from getting notifications for every PR, even if they haven't been individually assigned to it.

Please see [GitHub's documentation](https://help.github.com/en/github/setting-up-and-managing-organizations-and-teams/managing-code-review-assignment-for-your-team) for more in-depth details around configuring these settings.

#### In summary

Now that we have a team of reviewers, your project has a `CODEOWNERS` file and GitHub code review assignment is enabled, the following will happen when you create a PR:

1. The team defined in `CODEOWNERS` will be automatically assigned as a reviewer.
2. GitHub will instantly pick N reviewers and assign them to the pull request (number of reviewers is configured in the "Code review assignment" settings).
3. The team will be unassigned.

Congratulations, you now have reviewers for your PR and you didn't need to lift a finger.

#### Excluding yourself from auto assignment

There are some scenarios where you'd like to prevent yourself from being automatically assigned as a reviewer, e.g. holidays. To do this, simply click your avatar in the top right of GitHub, click "Set status", tick "Busy" then confirm by clicking "Set status". Busy team members will not be automatically assigned as reviewers.

## GitHub PRs configuration (protected branches)

In all our repos, we configured GitHub to have the main branch (`master` in most repositories, `develop` in the main app's repository) be a protected branch. To ensure that we also require at least 2 approvals, go to your repository's settings, under the "Branches" tab on the left, then edit the rules for the protected branch (use "Add rule" if you don't have a protected branch already) and ensure you have:

 - Require pull request reviews before merging
   - Required approving reviews: 2

## Additional possibilities

### If you want to always require at least one review from specific list of owners

If you want to enforce your PRs to always be approved by someone from a smaller, fixed list of people (like the "main owners of the repo"), in addition to the people Pull Assigner will assign randomly to all new PRs, you could also add a team of those people as code owners of your repo by adding it to `CODEOWNERS` file, and use "Require review from Code Owners" on your protected branch.

That's what we use for our bot repos `Stevenson` and `Wall-E`, as we want to always have at least one person from the Developer Experience squad –who is responsible for maintaining the bots– to approve PRs in those repositories, in addition to Pull Assigner randomly assigning other people from the rest of the iOS team to distribute review work.

To achieve a similar setup for your repository:

1. Create a GitHub team containing the owners of your repository's codebase (i.e. add to that team the members from which you want at least one approval on all the PRs).  
   _For example, for our bot repositories `Stevenson` and `Wall-E`, we created a team called `ios-bot-owners` containing the people from the Developer Experience Squad_

2. Again, make sure that you add your repository to the ones that new team has access to (e.g. via [this page for `ios-bot-owners`](https://github.com/orgs/babylonhealth/teams/ios-bot-owners/repositories))
3. Add that new team to your `.github/CODEOWNERS` file, alongside the proxy team you already added:  

    ```
    # Global rule for the whole codebase.
    #  - Every PR needs to be reviewed by at least one member of the `ios-bot-owners` team.
    #  - The empty `iOS-PullAssigner` team will act as a proxy for the PullAssigner bot.
    #    When a new PR arrives, PullAssigner will be triggered, which will then pick members from the iOS-Admin team
    
    * @babylonhealth/iOS-PullAssigner @babylonhealth/ios-bot-owners
    ```

4. Go back to your repository's settings in GitHub, under the protected branches (see previous section), and check the checkbox for "Require review from Code Owners"

This way, no PR could be merged unless at least one person from the teams listed in `CODEOWNERS` approves it, and in this case since the `iOS-PullAssigner` team is empty, that means at least one person from `ios-bot-owner` has to approve the PR – even if 2 other people assigned to review by Pull Assigners already approved it
