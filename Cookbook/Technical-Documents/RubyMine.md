# RubyMine

If you have to work with Ruby, i.e. to update our fastlane setup, you better use an IDE that comes with some quality of life tools other than syntax higlighting.
We are extensively using JetBrains products in the company so our license includes such Ruby IDE as RubyMine.

To install it, go to the [JetBrains website](https://www.jetbrains.com/ruby/download/#section=mac) to download the macOS app.
When asked about license enter the address of our license service. The service address is in 1Password. This service is only available from the office network or via VPN.

![](Assets/RubyMineLicense.png)

Then open the root folder of our project. As most of the files are not in Ruby, the IDE will spend a lot of time trying to index files we don't need.
To avoid that, go to **Preferences -> Project Structure** and select all the folders except `fastlane` as **excluded**.

![](Assets/RubyMinePreferences.png)

This will allow RubyMine to discover Ruby Gems that we have defined in the Gemfile in the root directory and only index fastlane files.

Now RubyMine will give you a hand with code completion for standard Ruby functions. It will understand imports of gems with `require`, suggest you fixes for syntax errors 
, and other common errors like missing parameters. If you enable scanning with RuboCop, it can also lint your code style.

NOTE: still couldn't find a way for it to understand imports of Fastlane types, i.e. `include FastlaneCore`, and to provide code completion on other fastlane internal types.
