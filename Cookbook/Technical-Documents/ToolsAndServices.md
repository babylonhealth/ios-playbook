# Tools and Services

## Access to Services

| Service | What for | How to access |
|---|---|---|
| Slack | Chat with whole org. See channels of interest [here](NewHiresCheckList.md#slack). | You should have given access during your mini induction. Log in with your Babylon email and Okta |
| 1Password | Access shared passwords used by various services in the team | [IT Support ticket](https://servicesupport.babylonhealth.com) Specify in the ticket that access to iOS team vault is needed |
| [Jira](https://babylonpartners.atlassian.net) | Tickets of tasks and issues on your sprint | You should get an invitation email to join the BabylonPartners team after the [IT Support ticket](https://servicesupport.babylonhealth.com) has been resolved |
| Zeplin | Screen Designs | Ask the support engineer in the iOS team channel on Slack for access to the project(s). Depending on your tribe you might need to use Figma |
| [Figma](https://www.figma.com) | Screen Designs | Log in with Google as this should redirect to the Babylon Okta sign in. Depending on your tribe you might need to use Zeplin |
| [GitHub](https://github.com) | Repos for the app, the bots, the playbook... | [IT Support ticket](https://servicesupport.babylonhealth.com) to get added to the org. Make sure you include your GitHub username in the support ticket, and that your Babylon email is added to your account. Find team members with the _Maintainer_ role to add you to the [iOS](https://github.com/orgs/babylonhealth/teams/ios) and [iOS-Devs](https://github.com/orgs/babylonhealth/teams/ios-devs) teams |
| [Lokalise](https://lokalise.co/projects) | Manage translations used by the app | Use iOS team vault on 1Password to gain access |
| Confluence Spaces (iOS, your Tribe, ...) | Documentation for various processes | [IT Support ticket](https://servicesupport.babylonhealth.com) – You can also ask your PM or Tribe Lead which Spaces you need to be given access to. (Since we are moving away from Confluence this might not be necessary) |
| Google Team Drives | Access shared documents for which you need multiple people to contribute | Login using your Microsoft account which is used for email – You can also ask your PM / Tribe Lead which Drives you need to be given access to. You should be given access to at least `iOS` and `Consumer Apps Tribe`|
| [zoom.us](https://zoom.us) | Video Conferences | Log in using Single-Sign-On. If it doesn't work, create an [IT Support ticket](https://servicesupport.babylonhealth.com) to be added to the appropriate Okta group |
| VPN | Remote Access to our intranet and internal domains | [IT Support ticket](https://servicesupport.babylonhealth.com) |
| [CircleCI](https://circleci.com/gh/babylonhealth) | See CI jobs and logs | Use your GitHub login |
| [App Center](http://appcenter.ms/apps) | See OTA builds sent internally to QA | Log in using company sign in. Once you have access to App Center, ask the support engineers in the iOS team channel on Slack to invite you to the org or use the shared credentials to invite yourself if you already have access to 1Password. For more information, there's [documentation](https://github.com/babylonhealth/ios-playbook/blob/master/Cookbook/Technical-Documents/AppCenter.md) focused on this.
| [Firebase](https://console.firebase.google.com) | View crash reports, performance monitoring | Ask `@mobile-chapter-leadz` for access |
| [Test Rail](https://babylonpartners.testrail.net) | Test effort management tool | Use the account shared on the iOS team vault on 1Password |
| [GA 360](https://analytics.google.com) | Analytics for the Babylon UK app | Ask `@Chris Drew` for access |
| [Optimizely](https://www.optimizely.com) | Feature flags | [IT Support ticket](https://servicesupport.babylonhealth.com) to get it added to your Okta account. Ask to be invited as a collaborator by a project admin, and log in using SSO. For more information, check this [document](https://github.com/babylonhealth/ios-playbook/blob/master/Cookbook/Technical-Documents/Optimizely.md) about Optimizely.
| [New Relic](https://one.newrelic.com) | View crash reports, performance monitoring | Create an [IT Support ticket](https://servicesupport.babylonhealth.com) to be added to the appropriate Okta group |

## Internal tools

* Xcode templates

  These templates are helpful when implementing new features or adding tests for existing ones. To install them run `Templates/install_xcode_templates.sh`

* Git hooks

  If you want you can install additional git hooks which will check for pods and Xcode templates to be in sync when switching branches or pulling from remote. To install them follow instructions in `githooks/README.md`

* Slack bots

  You can trigger CI jobs from Slack in the `ios-build` channel using slash commands. Check [this guide](SlackCIIntegration.md) for details.  

## Optional tools

* [Charles](https://www.charlesproxy.com) is a tool that allows to intercept network trafic from the app

  * Install Charles Proxy
  * Add the desired URL under Proxy > SSL Proxy Settings
  * Install on Simulator via Help > SSL Proxying > Install on iOS Simulator
  * The license for Charles can be found in the iOS team vault on 1Password

* [Insomnia](https://insomnia.rest) is a REST client app that is helpful when working with APIs

* [Fork](https://forkapp.io), [GitUp](https://gitup.co), and [SourceTree](https://www.sourcetreeapp.com) are examples of git clients that some members of the team love
