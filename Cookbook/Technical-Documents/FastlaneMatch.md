Fastlane Match
==============

Fastlane match is a tool for managing certificates and provisioning profiles centrally. It downloads certificates and profiles from a GitHub repository or Google Cloud Storage bucket. For safety, centrally stored files are encrypted.

**TL;DR;**

- Please do not use Match with `--readonly false` unless you really need that and you know what you are doing
- Please don't use Xcode code signing capabilities ("Download Manual Profiles" or "Manage Certificates" buttons in Xcode's preferences pane) and don't change automatic code signing in the project settings. Always use Match.
- If you see an error when running Match, make sure you specified the correct parameters. Consult with `fastlane/Matchfile` and `fastlane/Appfile` to inspect defaults

## Installing Certificates and Provisioning Profiles Locally

### Day to day development

First you need to add a developer account to your Xcode settings in `Preferences -> Accounts` menu. For that you should use a shared account (credentials are stored in the 1Password team vault). _Do not download or try to update any code signing documents via "Download Manual Profiles" or "Manage Certificates" buttons to avoid more unneeded certificates on the portal._

To install development certificates locally, run:

```shell
 $ bundle exec fastlane match development --team_id <enterprise team id>
```

On the first run you will be asked a password to decrypt the repository managed by Match. The password is stored in the teams 1Password vault. After you entered the password Match will install latest development certificates for all the app targets listed in the `fastlane/Matchfile` in `app_identifier` function (not scoped to particular lane with `for_lane` function). 
Match checks if the certificates and profiles are valid and will prompt you if there is an issue. By default it is configured to run in readonly mode so it will not regenerate any certificates or profiles if they are not valid.

If you need to build the app locally and run it on a device that is not yet added to the development portal you need to follow these steps:

- register the device manually on the portal. Make sure you do that in the correct team: it should be added to the enterprise team, not to the AppStore team
- run Match to update development certificates and include this new device:

```
bundle exec fastlane match development --team_id XV8PWA37TZ --force_for_new_devices --readonly false
```

This will regenerate the development profiles and certificates, including all new registered devices in them.

Certificates and provisioning profiles for enterprise builds (Hockey App) or release builds (Testflight and the App Store) can also be downloaded. Normally, this is not needed – as those tasks are usually executed on Circle CI and not locally – but might be necessary for some tasks.

### TestFlight & AppStore

To install certificates and provisioning profiles for creating a Testflight or App Store build locally, run the command

```shell
 $ bundle exec fastlane match appstore --git_branch <appstore team id> --team_id <appstore team id> --app_identifier <appstore bundle id>
```

Note: The reason to specify individual app identifiers is that otherwise if AppStore bundle ids are added to the default set of identifiers Match will try to load certificates that may not exist for some apps on the portal, as those apps are registered in different teams.

### HockeyApp builds

```shell
 $ bundle exec fastlane match enterprise --team_id <enterprise team id>
```

More information about available options can be found below and in the fastlane match [documentation](https://docs.fastlane.tools/actions/match/).

## Several Targets and Teams

The recommended practice is to have one branch per team. Enterprise team related certificates (development and distribution) are stored in the develop branch of the certificates repo managed by Match. Appstore releated certificates (distribution) are stored in the branch named by the AppStore team id.

It can happen that code signing certificates for more than one target or type are needed for a build. This can be handled by making several calls to match. This is how it can be done in a Ruby script, note that the `git_branch` argument refers to the branch in fastlane match repository:

```ruby
match(app_identifier: "com.best.app.ever.seriously", type: "adhoc", git_branch: "best_app_ever_ad_hoc_signing")
match(app_identifier: "com.best.app.ever.seriously", type: "development", git_branch: "best_app_ever_dev_signing")
```

The corresponding shell commands would be

```shell
fastlane match adhoc --app_identifier com.best.app.ever.seriously --git_branch best_app_ever_ad_hoc_signing
fastlane match development --app_identifier com.best.app.ever.seriously --git_branch best_app_ever_dev_signing
```

When running the command without any parameters, or with some of them omitted, the remaining values will be loaded from the `fastlane/Matchfile`  and `fastlane/Appfile` files.

## Update Contents Manually

**TL;DR;**

_This is something that you should normally not need to do, except in an extraordinary situation. Consider asking for help and to do it in pair with someone to avoid making things worse. Officially, Fastlane does not recommend this approach. For the original reference for this method visit [fastlane docs](https://docs.fastlane.tools/advanced/other/#manually-manage-the-fastlane-match-repo)._

<details>
<summary>I know! Tell me more!</summary>

Apple does not allow more than two distribution certificates per account, so it can happen that fastlane match cannot create a new distribution certificate and is unable to figure out which existing certificate to link with a new provisioning profile. Fastlane match provides a utility for revoking and deleting all existing certificates and provisioning profiles and replace them with new ones generated by fastlane match. This is, however, not always advisable. Nuking existing enterprise certificates can be a really bad idea as in house apps (that is, hockey app builds) will stop working. It does not affect builds submitted to TestFlight or AppStore in any way.

Since the files in the GitHub repository are encrypted they cannot be updated directly. Fastlane match provides a couple of helper functions. To clone the repository, open a ruby console and call `Match::GitHelper.clone`. Babylon specific credentials can be found in the iOS 1Password vault.

```shell
$ bundle console
irb(main):001:0> require 'match'
=> true
irb(main):002:0> branch = 'build_target'
=> "build_target"
irb(main):003:0> git_url = 'https://github.com/path/to/fastlane/match/repo'
=> "https://github.com/path/to/fastlane/match/repo"
irb(main):004:0> shallow_clone = false
=> false
irb(main):005:0> password = 'long-and-super-secret'
=> "long-and-super-secret"
irb(main):006:0> workspace = Match::GitHelper.clone(git_url, shallow_clone, manual_password: password, branch: branch)
[14:22:10]: Cloning remote git repo…
[14:22:10]: If cloning the repo takes too long, you can use the `clone_branch_directly` option in match.
[14:22:12]: Checking out branch build_target…
[14:22:12]: 🔓  Successfully decrypted certificates repo
=> "/var/folders/8k/r0x0ys_927q8vq5_tq01ntjd2b03m3/T/d20190228-92193-16w4fz2"
```
Open another terminal session and navigate to the folder name returned by `Match::GitHelper.clone`. Once all edits are complete, return to the ruby console. Beware that you must let fastlane match commit the changes that have been made. If you try to commit changes manually they will not be encrypted correctly.

```shell
irb(main):007:0> commit_message = 'Updated provisioning profiles as required.'
=> "Updated provisioning profiles as required.”
irb(main):008:> Match::GitHelper.commit_changes(workspace, commit_message, git_url, branch)
[14:28:44]: 🔒  Successfully encrypted certificates repo
[14:28:44]: Pushing changes to remote git repo…
=> nil
```

It can be convenient to store the password in the environment hash

```shell
irb(main):008:> ENV[“MATCH_PASSWORD"] = 'long-and-super-secret'
```

The password itself can be found in the iOS team 1Password vault. Note that this is the password for the encryption key, not a password for accessing iTunes connect.

Certificates are stored in three folders

```shell
 certs/development
 certs/distribution
 certs/enterprise
```

It might be necessary to manually make a certificate available in both the enterprise and distribution folder. Copying the files did not work (February 2019), but adding a soft link did.

Fastlane match expects the filename for the .p12 and .cer to be `certificate id`.p12 and `certificate id`.cer, whereas manually generated certificates that have been downloaded from the developer portal are named `team id`.cer and `team id`.p12.

## Accessing Apple Developer Portal with fastlane spaceship

Fastlane has a utility for interacting with Apple Developer Portal and the App Store Connect API called [spaceship](https://github.com/fastlane/fastlane/tree/master/spaceship).

The certificate id can be found by inspecting the certificate in the spaceship playground.

```shell
$ fastlane spaceship
…
Username: apple_developer_id@icloud.com
Logging into to iTunes Connect (apple_developer_id@icloud.com)...
Successfully logged in to iTunes Connect
Logging into the Developer Portal (apple_developer_id@icloud.com)...
Successfully logged in to the Developer Portal
---------------------------------------
| Welcome to the spaceship playground |
---------------------------------------
Enter docs to open up the documentation
Enter exit to exit the spaceship playground
Enter _ to access the return value of the last executed command
Just enter the commands and confirm with Enter
[1] pry(#<Spaceship::Playground>)> certificates = Spaceship::Portal.certificate.all
The current user is in 2 teams. Pass a team ID or call `select_team` to choose a team. Using the first one for now.
=> [<Spaceship::Portal::Certificate::Development
        id="CV89FKERTS",
        name="iOS Development",
        status="Issued",
        created=2018-03-05 20:54:38 UTC,
        expires=2019-03-05 20:44:38 UTC,
        owner_type="teamMember",
        owner_name="Latosius Silversong",
        owner_id="BH9RFFETSAS",
        type_display_id="6FG4WEDART",
        can_download=true>,
...
```

Fastlane spaceship will prompt for a password for the apple id to log in to iTunes connect if it is not available.
It seems that fastlane match cannot always figure out when to re-use an existing certificate (February 2019) for a new provisioning profile.

Provisioning profiles are stored in

```shell
profiles/adhoc
profiles/appstore
profiles/development
profiles/enterprise
```

Fastlane match requires that provisioning profiles are named AdHoc_`bundle identifier`.mobileprovision, AppStore_`bundle identifier`.mobileprovision, Development_`bundle identifier`.mobileprovision or InHouse_`bundle identifier`.mobileprovision.

</details>

## Problems and trouble-shooting

- There were some problems (March 2019) with running `bundle exec fastlane spaceship`, it struggled to install the `pry` gem. This might be related to your shell version and a possible workaround is to install manually in the `~/.fastlane` folder.
