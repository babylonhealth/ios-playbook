# CRP Bot

## What is the CRP process and how does the CRP bot work

Because we're now certified ISO-13485, our SSDLC and the ISO process requires that we track every changes in the codebase and in each release of each flavor of our apps. This means that we need to track which commits (and which corresponding JIRA tickets) have been included in each version of the apps we push to the stores.

In order to comply with that tracking requirement, every time a version of one of the flavors (Babylon UK, Bupa, Telus, Ascension US, ...) is released to one of the stores (AppStore or PlayStore), and the CRP bot is triggered (either using the Slack command – e.g. `/crp ios release/babylon/4.4.0` – or automatically during release cutoff _(soon)_) to handle that part of the release process, the bot will handle the following tasks:

* Gather the CHANGELOG from the list of tickets/commits that will be included in this upcoming release.
  - The list is built by listing the commits between the current release being cut and the last tag / GitHub release for the same flavor (e.g. between tag `telus/4.4.0` and branch `release/telus/4.5.0`) as described in our SSDLC
  - Since each commit is annotated with a reference to the JIRA ticket it is supposed to implement, the list of commits allows to build a list of Jira tickets included in the release
* Create the ticket on the CRP board, with the CHANGELOG (list of affected tickets) previously built
* Create a new JIRA version on each board mentioned in the CHANGELOG (e.g. in CNSMR, NRX, AV, APPTS, … boards) and whitelisted in the bot, named like "iOS Babylon 4.3.0" (same name for each version created on each board).
  - If a release with that exact name already exists in a board, the bot will reuse it instead of creating a new one.
* Add that newly created version to the "Fix Version" field of the tickets found in the CHANGELOG

You can find an example of [a CRP ticket dedicated to an iOS release for Babylon UK 4.4.0 here](https://babylonpartners.atlassian.net/browse/CRP-4578).

> Note: for documentation about how the CRP is _implemented_ in the code of our Stevenson bot, see [this companion document](CRP-Bot-ImplementationDetails.md)._

## Projects whitelist

To avoid accidentally creating JIRA versions on boards others than the ones we own, or messing with boards that don't follow the same schema/template as the one expected by the bot, the CRP bot has a whitelist of boards on which it will be allowed to create JIRA versions and set Fix Versions fields.

* This provides some security against any `[XXX-NNN]` that might be contained in a commit message to reference a JIRA ticket on some board that we don't own (e.g. a ticket from BackEnd), for which we don't want our bot to act
* This also allows us to not whitelist some of our boards, for which we ideally would want the CRP bot to work on, but which sadly don't use the official JIRA template that the bot expects – which means that they might not have the same fields in their JIRA tickets, or have different field IDs in the JIRA API for some fields (and sending requests to update a given Field ID would mean accidentally update the wrong field)

This is why some of the boards are still not whitelisted. This is tracked in [IOSP-101](https://babylonpartners.atlassian.net/browse/IOSP-101)

Note that the whitelist only affects the creation of JIRA releases and update of "Fix Version" field on those boards. A link to the tickets will still be included in the description/body of CRP ticket (listing all tickets found in the changelog messages) even for tickets belonging to a non-whitelisted board.

## Running the CRP bot

Currently, the CRP bot can be triggered by a slack command `/crp <platform> <branch>` (e.g. `/crp ios release/babylon/4.4.0`) in the `#ios-launchpad` slack channel.

In the near future, it will likely be automatically triggered by the script doing the release cut every second Friday.

## JIRA API limitations

Given some quota limitations with the JIRA API – which makes JIRA not respond to some requests if we send too many requests in parallel – the CRP bot uses some throttling mechanism to only make API calls to set the "Fix Version" field of each ticket by batches, instead of all at once. This improves the behavior of the JIRA API, but that API still sometimes fail with timeout on some requests – often the JIRA server seem to have processed the request and updated the Fix Version field as requested by the API call, but never returns an HTTP response to the client to let it know it succeeded.

As of January 2020, since the default timeout for network requests is 60s, every time JIRA decides not to respond to one of our API requests, that request takes 60s to finally fail. This means that on those occasions, the CRP process can take as much as N minutes where N is the number of timeout failures on which JIRA API decided not to reply to our requests.  
This can accumulate to quite some time in total before the CRP ends up sending the calls for all the tickets for the release (e.g. on some recent invocations it had 20 API calls fail with timeouts, leading to the whole process taking around **20 minutes in total** in spite of those requests having been processed by JIRA since the corresponding tickets still had their Fix Version field properly updated…).

This situation is clearly not ideal, but since we don't have much control on the JIRA API failures, and as far as our understanding of this limitation goes, there's not much we can do (other than reducing the timeout) to improve that situation so far.

## CRP command report

Once the CRP command has finished running, it will deliver a report message to indicate if any error or warning occurred during the process.

Those errors and warnings can include:

* warnings about boards that are not whitelisted. This is not an error (i.e. nothing failed): it is only to remind us that since said board is not in our whitelist of supported boards (see above), no JIRA release was created nor Fix Version field was updated for this board
  - either this is a misdetected board (e.g. a commit message contained something that resembled a JIRA ticket but was in fact not a real reference), in which case that warning can be ignored
  - or it's a real board (but which is not using the official JIRA issue templates so is not compatible with the bot), in which case the release manager is supposed to create the JIRA versions and update the Fix Version on those tickets manually
* errors about API timeouts
  – these are reported as `Error setting FixedVersion for <ticket> - ⚠️ [ThrowError.URLError: The operation could not be completed. (NSURLErrorDomain error -1001.)]`
  - those are instances of the JIRA API limitation described in the previous paragraph, when JIRA happens not to reply to some ouf our API requests and times out
  - most often times the request will have been processed by JIRA and the "Fix Version" field would already be correct – it just didn't send the success HTTP response back – so there's nothing to be done; but on occasion the request might not have been processed by JIRA at all, in which case the release manager should update the field manually for those tickets


## Additional Considerations

### Impact on "Fix versions" vs app flavors (US/UK/...)

One consequence of that process is that – because we use a monorepo both on Android and iOS (i.e. the codebase is shared amongst all the app flavors for iOS, and similar for Android) – **JIRA tickets that are implementing a feature for one flavor (e.g. Telus or Ascension) will (also) be marked with versions for other flavors (e.g. "iOS Babylon 4.4.0")** which also include that commit

This could be surprising at first, but is in fact totally normal and expected:

* This allows us to track that the commit (and thus changes in the code) that implemented that feature ended up being merged in the develop branch before we cut the release for Babylon UK and thus the code would be included in what ends in the UK app in the stores.
* This is important to track even if the ticket in question is supposed to only affect the US app, because ISO and SSDLC is about tracking – including being able to locate when a regression has been introduced and in which releases it might have been shipped – and it could happen that the **commit implementing that feature for the US app accidentally had unforeseen side-effect on the UK** app (e.g. changing something in a module that is used by both flavors).
* Even if that side effect is unintentional, we need to know that it ended up shipped in the UK release. (Even if admittedly in the ideal case the ticket should not have affected the UK release, but bugs and unintended side-effects happen)

Note however that even if a US ticket will be flagged with e.g. "iOS Babylon 4.5.0" (if corresponding PR was merged before the UK 4.5.0 release), it will eventually also be flagged with e.g. the "iOS Ascension 1.1.0" version in JIRA too once it's actually shipped as part of the US release.

This means that a ticket will ultimately end up with multiple versions in its "Fix Versions" field (typically for different flavors and platforms), allowing us to know all the released versions in which the code related to that ticket ended up, even if it was dormant/inactive/disabled for some flavors.

Again, this might seem surprising at first, but this is expected and on purpose.

### Impact on "Fix versions" vs feature flags

Another impact of that process is that **even features that are gated by a local feature switch** (hardcoded as being turned off in code) and end up still being disabled when we release the app **will still be flagged with the released version in their "Fix Version"**.

This is because – similar to what was described above with the example of unwanted side effects of a US feature on the UK app – the implementation of a feature that is theoretically supposed to be disabled by a feature flag can accidentally introduce bugs or have some of the code not protected behind the feature flag like it should have been. So since the code is present in the final app anyway – even if it's supposed to be disabled – the corresponding JIRA ticket will still have the version set in its "Fix Version".

This isn't really an issue in the end since usually we'll end up having a separate ticket to enable the feature switch and the feature in the future. So that new JIRA ticket about turning the feature on will have its own "Fix Version" telling us when it was enabled.

Still, this is a behavior to be aware of to understand the real meaning we put behind that "Fix Version" field (i.e. "the code implementing this feature ended up in the codebase shipped on the store for this version, even if supposedly disabled").

### "Fix versions" and planning versions ahead

Some squads might want to use JIRA releases to plan ahead, at the beginning of a sprint, which tickets they hope to be part of a future release.

Since there's no guarantee that those tickets will actually make it in time in the planned release when the corresponding release branch is cut, we need to differentiate a ticket that is just _planned_ from a ticket that _actually made that release_.

As JIRA releases handled by the CRP bot are dedicated to mark tickets that _actually shipped_ in a release (i.e. that are in the corresponding release branch), **you should never use those `"<platform> <app> <version>"` JIRA releases to mark planned tickets** via the `Fix Version` field. Otherwise that will mess up with our SSDLC requirement about tracking which tickets actually shipped with which version.

Instead, you should use JIRA Versions with a name that doesn't conflict with the ones used by the bot.  
We recommend naming those JIRA releases for _planned_ roadmaps something like **"<Platform> <Flavor> RC <Version>"** – e.g. "iOS Babylon RC 4.10.0". "RC" here meaning "Release Candidate", it will help differentiate that kind of planned JIRA versions from the version used by the bot when the ticket is actually released.
