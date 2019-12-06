# Development Process

Babylon follows the [SSDLC](https://engineering.ops.babylontech.co.uk/docs/standards-ssdlc) when developing our software. To make the process easier, we use tools and services to link code changes to tickets.

There are 3 services we use daily:
- Jira: this is where the development begins. Once a ticket has all the necessary details, dev can pick it up and implement it. <!-- TODO: [CNSMR-3230] link to Jira article -->
- GitHub: used for hosting our project
- CircleCI: our continuous integration service to run tests when integrating PRs <!-- TODO: [CNSMR-xxxx] link to CircleCI article -->

## Jira

- Assign ticket
- Make sure it has all details and designs attached (if applicable)
- Move to `In progress` (will be automatically done when branch published)

## Get started with development

- Branch name
- Add component to `GalleryApp`

## Testing

- New components, screens should have snapshot tests
- Logic, ViewModels, SDK unit tested
- Automation tests updated or written if the new screen will be in the next release
- Build `GalleryApp` and `Babylon` before merging

<!-- TODO: [CNSMR-xxxx] Link to testing article -->

## Creating the PR

- Title: [TCKT-123] Short summary of work
- Fill out PR template
- Add labels (link to article)
- Assign to yourself
- Ticket automatically updated to `Peer review` (if configured)
- If you'd like feedback before the ticket is done, you can open a draft PR so your peers can leave comments

_Note: Sometimes PullAssigner is not triggered. In that case, re-add `ios-pullassigner` to add reviewers._

## Merging PR

Once a PR has 2 approvals and no outstanding comments/changes requested, the `Merge` label can be added to begin the merging process. Our [bot](https://github.com/babylonhealth/Wall-E) will add it to the merge queue and integrate it into the rest of the project. Once it reaches the front, it's updated with the target branch and CircleCI runs all necessary tests to make sure nothing's failing. _Note: there's no need to trigger checks manually, if there are other PRs in the queue._ <!-- TODO: [CNSMR-3231] link to Wall-E article --> If everything's passing, the PR is merged and branch deleted. The ticket is moved to `Awaiting build` on Jira by our [bot](https://github.com/babylonhealth/Stevenson). It'll be updated to `Ready for QA` when the next App Center build is created.

## QA

## Release
