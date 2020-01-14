# CRP Implementation Details

One of the command handled by our Babylon Stevenson bot is `/crp`, which aims to create a CRP ticket on JIRA – especially, a specific type of ticket which takes part of our SSDLC (Secure Software Development LifeCycle) process in the company.

This process being quite specific to our SSDLC, we felt like this dedicated documentation would be useful to understand the specifics of this particular command.

## Process description

This part of the SSDLC process consists of the following steps, that our Bots automates:

* Collecting the list of JIRA tickets that will be included as part of the new release.
  * It does that by gathering the `git log` between the last tag of an app flavor and the newly-open release branch of that same app flavor, extracting the references of JIRA tickets from the commit messages
* Create a JIRA ticket on our dedicated "CRP" board in our JIRA instance
  * That ticket should contain the list of links to the JIRA tickets gathered from the previous step, in addition to some other fields
  * That ticket will later go through the validation process, having to be reviewed and approved before we could consider pushing the new version of the app to the Stores
* For each JIRA board which has at least one ticket listed in the CRP:
  * Create a JIRA Release in that board, for the new version about to be released
  * Set the "Fix Version" field of each ticket of this board appearing in the CRP to that new JIRA release, to flag that this ticket was part of that release.

## Implementation details

### Parsing of the command

This part is implemented in `SlackCommand+CRP.swift`. In the `run` closure of this `SlackCommand` we extract the name of the repo (ios or android) and the release branch name from the command, to get a `RepoMapping`
and build a `GitHubService.Release` (deduce the app flavor and version from the branch name)

Then this code will:

* Call `github.changelog(…)` to gather the list of commit messages
* Call `jira.executeCRPTicketProcess` to run the full CRP process using that list of commits and the `Release` object build above
* Post the CRP ticket URL + the report of potential encountered issues as a message in Slack

### Building the Changelog: `github.changelog(…)`

This part is implemented in `GitHubService+Commits.swift`. It does the following:

* Gather the list of GitHub Releases of the repo, using an API call (`releases(in: repo, on: container)`)
* Find the one corresponding to the latest tag for the flavor – i.e. the most recent release whose tag is matching `(release|hotfix)/<appname>/*`
* Gather the list of commit messages between that tag (latest release) and the release branch we are running the CRP process on

This results in an array of commit messages (only using the first line of each commit message) from the last release to the new one

### Executing the CRP process

This is all implemented in `JiraService+CRP,swift`.

The convenience method `executeCRPTicketProcess(…)` is usually the entry point.

* It uses the `document(from [ChangelogSection])` method to build the JIRA document (formatted text field) to be used in the CRP issue we will create
* It then instantiate a `CRPIssue` model object with all fields properly filled, then make the API call in `create(issue:…, on:…)` to actually create the issue in JIRA
* then starts the process to create and set the "Fix Versions" field of all tickets via `createAndSetFixedVersions(…)`.

Note that the `CRPIssue` type is a `typealias` for `Issue<CRPIssueFields`. The `Issue<T>` generic type is defined in the bot's `JiraService.swift` file, and is generic to support any custom fields provided for specific type of issues in JIRA.  
As our CRP board in our JIRA instance uses a lot of custom fields we need to fill, the `CRPIssueFields` structure, being specific to our use case, is declared in `JiraService+CRP.swift` in the app target.

### JIRA `document`

When creating the `CRPIssue` instance (call to `makeCRPIssue(…)`), we need to build the body of the issue descrition from the list of commit messages. This is done by:

* Call `ChangelogSection.makeSections(from: commitMessages, for: release)` to build a `[ChangelogSection]` array from the list of commit messages.
  * This is done by detecting the JIRA ticket references (`[XXX-NNN]`) within commit messages using a RegEx, and triage those messages based on the JIRA board detected
* Then call `JiraService.document(from: [ChangeLogSections]` to build a "JIRA document" (a JIRA format representing a formatted text containing headings, bullet points, links, etc)

This method uses helpers like `formatMessageLine` to transform a commit message into a `FieldType.TextArea.ListItem` – aka a model objet representing a bullet point item in the JIRA formatted text.

Those `FieldType.TextArea` subtypes, used to represent various entities in a formatted text (textarea) in JIRA, are all declared in the bot's framework code in `JiraService+FieldTypes.swift`. Conforming to `Content` (which itself inherits from `Codable`), then can then be transformed into JSON when included in the API call to create the CRP ticket.

### `createAndSetFixedVersions`

This method is declared in `JiraService+CRP.swift` and its goal is to iterate over each  `ChangelogSection` (representing a given board with its associated tickets included in the CRP), and for each board/section that is whitelisted in our static `self.knownProjects` list:

* Create an apptly named JIRA release if a release with that name doesn't already exist; otherwise, reuse the existing one
* Then for each ticket in this `ChangelogSection` (i.e. associated with this board), make an API request to set the `Fix Version` field to this JIRA Release. This is done in `batchSetFixedVersions(…)` and described in the following section

Any section that is not part of the `knownProjects` list (static constant declared in `configure.swift`) will be skipped during this process, i.e. even if the ticket on unknown boards will be included in the CRP ticket's body, there will be no attempt to create a JIRA version on any unknown board nor touch the Fix Version field of those tickets. This whitelist has two main purposes:

1. First to avoid accidentally create releases and touch tickets that are not supposed to be our responsibility and might have been wrongfully detected when parsing the commit messages. For example if a commit message contains a reference to the original ticket but also mentions another ticket from a board we don't own, we don't want to process to detect the latter one and affect the board and ticket we don't own
2. Another reason is because some boards, even if they are supposed to follow the CRP process, are misconfigured in JIRA and use a custom set of fields and custom process instead of using the same fields and configuration than all the other boards. Trying to execute the CRP automation on those boards would end in an invalid API request or worse, some unexpected changes in the tickets, because field IDs would not match the ones expected by the bot.

### `batchSetFixedVersions`

This method is called for each board by `createAndSetFixedVersions`. It is passed the list of tickets for said board, and the JIRA version reference to set on the `Fix Version` field for these tickets.

It mainly consists of a `map` on all the tickets, making an API call to `setFixVersion(version, for: ticket, …)` on each ticket in turn.

### FixedVersionReport

One particularity of `createAndSetFixedVersions` and `batchSetFixedVersions` is that we don't want any API call failure to interrupt the whole process. Instead, in case of any API failure, we gather the error in a report object and continue to the next ticket.

This report is then printed at the very end of the CRP process (as a reply in Slack) to inform the Release Engineer which ticket failed to have their "Fix Version" field updated, to let them update the tickets manually.

Note: The `FixedVersionReport` struct is used to gather messages. It's implemented such as passing multiple `FixedVersionReport` to its `init` will `flatMap` the messages of them all in a single report, allowing us to use constructs like `map(to: FixedVersionReport.self, on: container, FixedVersionReport.init)` on the parallel sequence of API calls setting the version on each ticket in `batchSetFixedVersions` and use a similar construct in `createAndSetFixedVersions` to gather all the reports on each board/`ChangelogSection` into a single report.

### SlowClient

One of the particularity of this process is that it sends a LOT of API calls to JIRA – one for the CRP ticket itself, then one for each board to create a JIRA version, then one for each ticket in the CRP to update their fields. This made us reach the JIRA max API quota and resulted in some API requests to JIRA sometimes failing with timeout.

To limit that effect, instead of using the standard Vapor Client to send those requests, we are using a `SlowClient` – see `SlowClient.swift` in the bot target – which limits the number of API calls pending at once, to avoid sending all the API requests in parallel but instead send them by batch.

You can see this being used in various API calls implenented in `JiraService.swift` – via a call to `container.make(SlowClient.self)` on which the requests are then being sent.

_Despite that SlowClient, we still have some API calls to JIRA sometimes fail with timeout – failing to reply even after 60s. What seems to happen is that JIRA receives the request, processes it (e.g. it properly set the Fix Version field for the ticket as asked by the API request) but never return a response back to the API call. Which leads to the report mentioning there was a timeout in the request, despite the action being done._

