## Tips and tricks

### Errors when pulling code/switching branches
Various errors can occur when pulling code/switching branches. Typically all that is needed is running `pod install` and closing and reopening the project in Xcode. The following directions are intended to be a more thorough reset to deal with bigger changes.

- Clean Build: Product > Clean (shortcut: cmd + shift + k)
- Close Xcode
- Update bundle: run `bundle install`
- Update pods: `pod repo update && pod deintegrate && pod install`
- Clean DerivedData: can be found at ~/Library/Developer/Xcode/DerivedData and/or babylon-ios/DerivedData
- Reopen project in Xcode
