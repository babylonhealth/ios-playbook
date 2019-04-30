## Tips and tricks

### Errors when pulling code/switching branches
Various errors can occur when pulling code/switching branches. 
Typically all that is needed is running `pod install` and closing
and reopening the project in Xcode. The following directions are
intended to be a more thorough reset to deal with bigger changes.

- Clean Build: Product > Clean (shortcut: cmd + shift + k)
- Close Xcode
- Update bundle: run `bundle install`
- Update pods: `bundle exec pod deintegrate && bundle exec pod install --repo-update`
- Clean DerivedData: can be found at
`~/Library/Developer/Xcode/DerivedData and/or babylon-ios/DerivedData`
- Reopen project in Xcode

### Project file conflicts
When merging develop into your branch, if the project file has been changed in both locations, there may be a conflict. This file can be very difficult to merge manually. You can use the mergepbx tool to handle these conflicts easier.

- The repo can be found here: [link](https://github.com/simonwagner/mergepbx)
- You can install with brew: `brew install mergepbx`
- After it is installed, you can add these lines to your `~/.gitconfig`:
```
#driver for merging Xcode project files
[mergetool "mergepbx"]
	cmd = mergepbx "$BASE" "$LOCAL" "$REMOTE" -o "$MERGED"
```
- Then whenever you run into a project file conflict you can resolve it with:
`git mergetool --tool=mergepbx [Project File]`
ex: `git mergetool --tool=mergepbx Babylon.xcodeproj/project.pbxproj`