# Tools and Services

## Access to Services

| Service | What for | How to access |
|---|---|---|
| Slack | Chat with whole org. See channels of interest [here](NewHiresCheckList.md#slack). | You should have given access during your mini induction. Log in with your BabylonHealth email and Okta |
| 1Password | Access shared passwords used by various services in the team | [IT Support ticket](https://supportbybabylon.atlassian.net/servicedesk/customer/portal/5/group/12/create/43) Specify in the ticket that access to iOS team vault is needed |
| JIRA | Tickets of tasks and issues on your sprint | You should get an invitation email to join the BabylonPartners team after IT support ticket has been resolved [IT Support ticket](https://supportbybabylon.atlassian.net/servicedesk/customer/portal/5/group/12/create/43) |
| Zeplin | Screen Designs | Ask `@Carlos` or `@adrian` on Slack for access to all the front-end projects |
| GitHub | Repos for the app, the bots, the playbook... | [IT Support ticket](https://supportbybabylon.atlassian.net/servicedesk/customer/portal/5/group/12/create/248) to get added to the org. |
| [Lokalise](https://lokalise.co/projects) | Manage translations used by the app | Use iOS team vault on 1Password to gain access |
| Confluence Spaces (iOS, your Tribe, ...) | Documentation for various processes | [IT Support ticket](https://supportbybabylon.atlassian.net/servicedesk/customer/portal/5/group/12/create/43) – You can also ask your PM or Tribe Lead which Spaces you need to be given access to. (Since we are moving away from Confluence this might not be necessary) |
| Google Team Drives | Access shared documents for which you need multiple people to contribute | Login using your Microsoft account which is used for email – You can also ask your PM / Tribe Lead which Drives you need to be given access to. You should be given access to at least `iOS` and `Consumer Apps Tribe`|
| [zoom.us](https://zoom.us/) | Video Conferences | Create account with BabylonHealth email-Id. You will have access to basic plan (you can join invites without an account but will need one to create conferences)|
| VPN | Remote Access to our intranet and internal domains | [IT Support ticket](https://supportbybabylon.atlassian.net/servicedesk/customer/portal/5/group/12/create/43) |
| [CircleCI](https://circleci.com/gh/Babylonpartners) | See CI jobs and logs | Use your GitHub login |
| [HockeyApp](https://rink.hockeyapp.net/) | see OTA builds sent internally to QA | Ask support engineer in the iOS team channel on Slack to invite you to the org |

## Internal tools

* Xcode templates

  These templates are helpful when implementing new features or adding tests for existing ones. To install them run `Templates/install_xcode_templates.sh`
  
* Git hooks

  If you want you can install additional git hooks which will check for pods and Xcode templates to be in sync when switching branches or pulling from remote. To install them follow instructions in `githooks/README.md`
  
* Slack bots
  
  You can trigger CI jobs from Slack in the `ios-build` channel using slash commands. Check [this guide](TBD) for details.
  

## Optional tools

* [Charles](https://www.charlesproxy.com) is a tool that allows to intercept network trafic from the app

  * Install Charles Proxy
  * Add the desired URL under Proxy > SSL Proxy Settings
  * Install on Simulator via Help > SSL Proxying > Install on iOS Simulator
  * The license for Charles can be found in the iOS team vault on 1Password

* [Insomnia](https://insomnia.rest) is a REST client app that is helpful when working with APIs

* [Fork](https://forkapp.io), [GitUp](https://gitup.co) and [SourceTree](https://www.sourcetreeapp.com) are examples of git clients that some members of the team love
