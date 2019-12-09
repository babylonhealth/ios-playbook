# Development Process

Babylon follows the [SSDLC](https://engineering.ops.babylontech.co.uk/docs/standards-ssdlc) when developing our software. To make the process easier, we use a few services to link code changes to tickets.

There are 3 services we use daily:

- Jira: this is where the development begins. Once a ticket has all the necessary details, dev can pick it up and implement it. <!-- TODO: [CNSMR-3230] link to Jira article -->
- GitHub: used for hosting our project
- CircleCI: our continuous integration service to run tests when integrating PRs <!-- TODO: [CNSMR-xxxx] link to CircleCI article -->

## Jira 🎫

- Everything we do must have a ticket
- The first step is to assign the ticket to the engineer. Make sure it has all details and designs attached (if applicable)
- The ticket is moved to `In progress` (this might be automatically done by the bot when branch published, if configured)

## Get started with development 🛠

- Create a branch where this work will live. Please follow this format: `[NAME]/[TICKET]-[DESCRIPTION (optional)]` (E.g. `john/TCKT-123-fix-bug`)
- For new features, add a [local feature switch](https://github.com/babylonhealth/ios-playbook/blob/master/Cookbook/Technical-Documents/FeatureSwitches.md) to avoid getting WIP code into the release. Add the name of this flag (and additional instructions) to the ticket to help QA test it
- Implement all features, changes to satisfy the acceptance criteria defined in the ticket
- If it introduces a new component, add it to the `GalleryApp` and make sure it's included in the Design System

## Testing 🧪 <!-- TODO: [CNSMR-3195] Link to testing article -->

- Make sure:
  - New components, screens have snapshot tests
  - Logic, ViewModels, SDK changes are unit tested
  - Automation tests have been updated or added if the feature will be in the next release
- Build `GalleryApp` and `Babylon` before merging to avoid checks failing

## Creating the PR 📝

- Fill in the PR template and set the title using the following format: `[TCKT-123] Short summary of work`
- [Add labels](https://github.com/babylonhealth/ios-playbook/blob/master/Cookbook/Technical-Documents/LabelsInPRs.md)
- Assign the PR to the engineer(s)
- Move the ticket to `Peer review` on Jira (or it'll be automatically moved if configured)
- If you'd like feedback before the work on the ticket is done, open a draft PR so your peers can leave comments
- To run checks before merging, use the comment `@ios-bot-babylon test_pr` ([more info](https://github.com/babylonhealth/ios-playbook/blob/master/Cookbook/Technical-Documents/SlackCIIntegration.md))

_Note: Sometimes Pull Assigner is not triggered when a new PR is opened. In that case, re-request `ios-pullassigner` to add reviewers from the team._

## Merging PR 🚦

- Once a PR has 2 approvals and no outstanding comments/changes requested, the `Merge` label can be added to begin the merging process
- Our [bot](https://github.com/babylonhealth/Wall-E) will add it to the merge queue and integrate it into the rest of the project
- Once it reaches the front, it's updated with the target branch and CircleCI runs all necessary tests to make sure nothing's failing. _Note: there's no need to trigger checks manually, if there are other PRs in the queue._ <!-- TODO: [CNSMR-3231] link to Wall-E article -->
- If the required checks are passing, the PR is merged and the branch deleted.
- The ticket is moved to `Awaiting build` on Jira by our [bot](https://github.com/babylonhealth/Stevenson). It will be updated to `Ready for QA` when the next App Center build is created. (if configured, otherwise this should be done manually)

## QA 🧑‍💻

- Once the work is in the App Center builds, QA can test it to make sure everything works correctly
- It's important that the engineer assigned to the ticket doesn't QA their own work
- When QA is done with testing, the ticket can be moved to `Done` on Jira

## Release 🚢

- Make sure all local feature flags have been removed **before** the release branch is cut
- During the [release process](https://github.com/babylonhealth/ios-playbook/blob/master/Cookbook/Technical-Documents/ReleaseProcess.md), the ticket is updated with the release version
- Once the app is published, the ticket is done and our users can use it 🚀
