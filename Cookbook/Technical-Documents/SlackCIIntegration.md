## Slack CI Integration

From time to time we need to trigger some CI jobs manually, for example to create an App Center or TestFlight distribution build. This can be done easily from Slack Slash Commands powered by our bots, [Stevenson](https://github.com/babylonhealth/Stevenson) and its predecessor Steve.

### Supported commands (Stevenson)

* #### `/testflight` 

Creates a Testflight build in **Release** configuration for AppStore distribution (release candidate). It requires the target name, **as they are defined in the project**, as the first parameter and version as a second parameter:

```
/testflight Babylon version:3.13.0
```

This will trigger the `testflight` lane on the `release/babylon/3.13.0` branch. You can also create a testflight build from arbitrary branch with `branch` option:

```
/testflight Telus version:3.13.0 branch:release/telus/3.13.0
```

Note the names of the targets are following the names in the project.

Tip: `/testflight help` will respond with instructions for this command.

* #### `/appcenter`

Creates an App Center build in **Debug** configuration for App Center distribution (beta). It requires the target name, **as they are defined in the project**, as the first parameter:

```
/appcenter Babylon
```

This will trigger the `appcenter` lane on the `develop` branch. You can additionally specify a branch:

```
/appcenter Babylon branch:ilya/CE-123
```

Tip: `/appcenter help` will respond with instructions for this command.

* #### `/fastlane`

Runs any lane defined in the `Fastfile`. It requires the lane name as the first parameter:

```
/fastlane test_babylon 
```

This will trigger `test_babylon` lane on the `develop` branch. You can additionally specify branch and lane options:

```
/fastlane ui_test_babylon_smoke branch:develop device:"iPhone X"
```

Note that this format is exactly how you would invoke fastlane locally, except of the additional `branch` option.
To see the list of all lanes run locally `bundle exec fastlane lanes`.

Tip: `/fastlane help` will respond with instructions for this command.

* #### `/crp`

This command will create a CRP Jira ticket for the app release. Currently it only supports Babylon app. It requires the name of the platform as the first parameter and a release branch name:

```
/crp ios branch:release/babylon/3.13.0
```

Tip: `/crp help` will respond with instructions for this command.

* #### `/stevenson`

This command will run arbitrary workflow defined in our CircleCI configuration. You can provide a branch parameter to run workflow on a branch unless workflow is configured to be run on specific branches (i.e. only on develop or release branches)

```
/stevenson ui_tests branch:develop
```

When running a workflow you should specify parameters that are required for this workflow, unless they have default values. If a parameter is missing or extra parameters are sent the build will fail and you will get an error message.

To see the list of supported workflows look for `parameters` section in the CircleCI config file.

You can also invoke all other commands using the `/stevenson` command, e.g.:

```
/stevenson fastlane ui_test_babylon_smoke branch:develop device:"iPhone X"
```

Tip: `/stevenson help` will respond with instructions for this command.

## Pull request comments

Alternatively to Slack commands, you can trigger CI workflow on a pull request with a comment. The format of the comment is the same as the Slack commands, except they should be prefixed with the bot's GitHub user name and you don't need to specify the branch (it will always use the branch of the PR)

You can invoke any lane with the following comment:

```
@ios-bot-babylon fastlane appcenter target:Babylon
```

Or you can invoke a workflow defined in our CircleCI config with the following comment:

```
@ios-bot-babylon test_pr
```

To see the list of supported workflows look for `parameters` section in the CircleCI config file.

Note: you won't get any feedback in the PR with the results of the triggered command or whether it was correct or not (yet), but Slack messages with the result will be posted by the bot in #ios-build channel as usual when CI finishes running the jobs.

### Troubleshooting

* ATM we are hosting Stevenson on Heroku so it is being shut down when it is not in use, so sometimes you may see a timeout error when trying to call a Stevenson command (Slack expects apps to respond in 3 seconds). You will still get the response shortly after that when build is triggered. Steve commands may also fail because of timeouts but it may not send the response even if the build actually started. In this case check the CI dashboard to see if the job was actually triggered - it should be if the command was correct.

* You can find Stevenson app in the list of Slack apps and see all of its commands from there.

