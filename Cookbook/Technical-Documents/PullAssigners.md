# How to configure Pull Assigners for Babylon repos

## Introduction

[Pull Panda](https://pullpanda.com/) is a set of tools for automating actions on GitHub Pull Requests and provide some integration with Slack. Amongst those tools, Pull Assigner will allow you to auto-assign people from your team as reviewers of Pull Requests, typically trying to distribute the PRs amongst the team evenly

The aim of this document is to explain how to configure `Pull Assigner` on our Babylon repos in order for it to affect people to PRs automatically

- We will use the `CODEOWNERS` file to make GitHub always assign a special GitHub team (called the proxy team in Pull Assigner's parlance) to all our Pull Requests
- That special GitHub team will in fact be managed by Pull Assigners, which will detect when that team is added as a reviewer
- Pull Assigner will then pick N reviewers from a GitHub team listing all possible reviewers, then unassign the "proxy team"
- Optionally, we could also require each PR of a repository to always have an approval from a subset of people (the ones owning the responsibility of the code) – like we did for our bots repository owned by the Developer Experience squad

## Configure GitHub Teams

### A team to list the reviewers to pick from

1. First you need a GitHub team containing the list of all the people you want Pull Assigner to pick reviewers from.

   * For the iOS repos, we use the team `@Babylonpartners/iOS-Admin` for this, which should contain every iOS developer that are on our team. So if you need the same list of reviewers, you can just use this one instead of creating one.
   * If you need a different list to pick your reviewers from, you'd need to create a team via [this page on GitHub](https://github.com/orgs/Babylonpartners/new-team), and once it's created, go to the team's page and add Members to that new team ([e.g. here for `iOS-Admin`](https://github.com/orgs/Babylonpartners/teams/iOS-Admin/members))

2. Next, **make sure that this GitHub team –containing the people you want as reviewers– has access to your repository**, via the "Repositories" tab in the team's page ([e.g. here for `iOS-Admin`](https://github.com/orgs/Babylonpartners/teams/iOS-Admin/repositories))

### The proxy team to trigger Pull Assigners

1. Now, we will need another, separate, GitHub team –called the "Proxy team" in Pull Assigner's vocabulary– which will be the team that you'll assign to your PRs via `CODEOWNERS` to trigger Pull Assigner on those PRs (†)

   * For the iOS repos, the proxy team we use –to assign people from the `@Babylonpartners/iOS-Admin` to our PRs– is called `@Babylonpartners/iOS-PullAssigner`, so if you are using the same list of people from `iOS-Admin` you can also use the `iOS-PullAssigner` for your proxy team directly without creating a new one
   * If instead you created a separate team because for your case the list of people in `iOS-Admin` wasn't matching the people you wanted to assign PRs for your repo, you'll need to [create a new GitHub team again](https://github.com/orgs/Babylonpartners/new-team), but this time leave it with no member in it (since it will only act as proxy)

2. Next, **make sure that the proxy team has access to your repository**, via the "Repositories" tab in the team's page (e.g. https://github.com/orgs/Babylonpartners/teams/ios-pullassigner/repositories)

> _(†) Side note: This proxy team is not strictly necessary, but if you don't use a proxy team and instead use the team you just declared above directly, that means that everybody will be notified and requested review every time a new PR is created. With proxy team Pull Assigners will automatically replace it with only N people from that team requesting review only from them. This is why using a proxy team without any member in it to trigger Pull Assigner is usually preferrable_

### Configure Pull Assigners with those GitHub teams

If you are reusing the `iOS-Admin` and `iOS-PullAssigner` teams for your repo setup, you have nothing special to configure on https://pullreminders.com as those GitHub teams are already configured in Pull Assigner; so you can skip to the next section.

But if you have created new teams (team listing reviewers + proxy team) you'll need to log in to https://pullreminders.com and add the GitHub teams to Pull Assigner's configuration via [this screen](https://pullreminders.com/installs/6124714/assigner)

 - Click "Add Team"
 - Select the real (not proxy) team you've created before in the dropdown menu
 - Configure the team in the next screen, especially the number of reviewers to assign, the algorithm, but also the proxy team you previously created, and select to delete that (proxy) team review request after assigning reviewers (†).

 (†) Note that if your repository's protected branch is configured with "Require review from Code Owners" checked, then any team in your `CODEOWNERS` will stay assigned as reviewer – which means that your proxy team, being typically part of your `CODEOWNERS` itself, won't be removed from your PR even if you chose "Delete after assigning reviewer(s)" for the "Team review request" setting in your https://pullreminders.com setup. It will only be able to be deleted if the "Require review from Code Owners" setting is unchecked in your repo.

## Update GitHub's PullAssigner app settings

⚠️ This step will require the assistance of someone from `#devops` who has access to the GitHub's *organization* settings.

Ask `#devops` to go to the GitHub organization's settings and under the "Installed GitHub Pages" [here](https://github.com/organizations/Babylonpartners/settings/installations).

From there they should be able to edit the "PullAssigner" app's settings and add your new repo to the list of repositories the PullAssigner GitHub app has access to

## The `CODEOWNERS` file

Now we need to ensure that the proxy team (e.g. `iOS-PullAssigners`) is automatically affected as reviewer on all new PRs.

For this, you just need to create a `.github/CODEOWNERS` file in your repo with the following content (if you have a `CODEOWNERS` file already at the root of your repository, we advise to move it inside a `.github/` directory to clean up your repo root)

```
# Global rule for the whole codebase.
#  - The empty `iOS-PullAssigner` team will act as a proxy for the PullAssigner bot.
#    When a new PR arrives, PullAssigner will be triggered, which will then pick members from the iOS-Admin team

* @Babylonpartners/iOS-PullAssigner
```

Of course, if you created a separate proxy team instead of using our common `iOS-PullAssigner` GitHub proxy team, adapt the content accordingly

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

2. Again, make sure that you add your repository to the ones that new team has access to (e.g. via [this page for `ios-bot-owners`](https://github.com/orgs/Babylonpartners/teams/ios-bot-owners/repositories))
3. Add that new team to your `.github/CODEOWNERS` file, alongside the proxy team you already added:  

    ```
    # Global rule for the whole codebase.
    #  - Every PR needs to be reviewed by at least one member of the `ios-bot-owners` team.
    #  - The empty `iOS-PullAssigner` team will act as a proxy for the PullAssigner bot.
    #    When a new PR arrives, PullAssigner will be triggered, which will then pick members from the iOS-Admin team
    
    * @Babylonpartners/iOS-PullAssigner @Babylonpartners/ios-bot-owners
    ```

4. Go back to your repository's settings in GitHub, under the protected branches (see previous section), and check the checkbox for "Require review from Code Owners"

This way, no PR could be merged unless at least one person from the teams listed in `CODEOWNERS` approves it, and in this case since the `iOS-PullAssigner` team is empty, that means at least one person from `ios-bot-owner` has to approve the PR – even if 2 other people assigned to review by Pull Assigners already approved it
