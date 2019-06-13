# Danger Rules for pbxproj

* Author: Olivier Halligon
* Review Manager: TBD

## Introduction

This proposal suggests to add some Danger rules checking for `xcodeproj` consistenty.

It is a follow-up on [#110 - Integrate Danger](https://github.com/Babylonpartners/ios-playbook/pull/110).

## Motivation

`pbxproj` project format is hard to parse, which means it's easy to miss some mistakes that could happen when an Xcode project has changed during a PR.

This means that some mistakes have ended up in `develop` in the past, like:

* `(null)` references and `"Recovered References"` groups in `pbxproj` files
* Invalid or Orphan UUIDs in `pbxproj` files (†)
* Files being added as part of a target membership while they shouldn't:
  * Snapshot files
  * xcconfig files
  * Info.plist files
* Files expected to be in a target but are not (especially tests that we might forget to include and are thus not run)

(†) For example this is the kind of warnings we can see when running `bundle exec pod install` and the projects manipulated by CocoaPods contain some invalid UUIDs:

```
`<PBXGroup path=`Tests` UUID=`F26256AC222EC21500DD5E7B`>` attempted to initialize an object with an unknown UUID. `5FFC934E2296E0980088BFAA` for attribute: `children`. This can be the result of a merge and  the unknown UUID is being discarded.
`<PBXGroup path=`DesignLibrary` UUID=`F26256A8222EC21500DD5E7B`>` attempted to initialize an object with an unknown UUID. `5F76D723229456BA00EC6CBC` for attribute: `children`. This can be the result of a merge and  the unknown UUID is being discarded.
`<PBXSourcesBuildPhase UUID=`A65543DE1F50510600BAABE4`>` attempted to initialize an object with an unknown UUID. `5F76D724229456BA00EC6CBC` for attribute: `files`. This can be the result of a merge and  the unknown UUID is being discarded.
`<PBXSourcesBuildPhase UUID=`58E92B48208799C90037BD6A`>` attempted to initialize an object with an unknown UUID. `5FFC934F2296E0980088BFAA` for attribute: `files`. This can be the result of a merge and  the unknown UUID is being discarded.
```

Some of those mistakes, especially `(null)`, "Recovered References" and invalid UUIDs in `pbxproj`, are generally the result of merge conflicts; so their appearances during a PR could be an indicator that something else could have gone wrong during the merge of the pbxproj file. It's generally a good incentive to double-check that there was no other side effect from the pbxproj merge.

Other mistakes like unexpected files in target membership could lead to files ending up in the final bundle uploaded to the AppStore, and in addition to being useless in the final `ipa`, bloat the app size for no reason.

## Proposed solution

We propose to use Danger rules to analyze the pbxproj and find all those issues during review:

All those rules listed below, if implemented in the `Dangerfile`, will help us:

* Keep the Project files sanitised and avoid commiting invalid pbxproj files, which are often the result of merge conflicts.
* Be aware of potential higher risks of a merge gone wrong on a pbxproj file, to avoid commiting a corrupted pbxproj (e.g. one that could still be readable by `xcodebuild` but in which a reference to an image file got removed from the pbxproj due to a bad merge, making the app crash at runtime)
* Avoid including large chunk of unrelevant resources (like test snapshots) in the final bundle

### Null / Recovered References

We can use a simple "find" in every `*.pbxproj` for the strings `/* (null) */` and `name = "Recovered References";`, and make Danger generate an inline comment on the found line(s) if any

This can be done pretty easily with Ruby, conceptually this will look like the logic below:

```ruby
pbxprojs = git.modified_files.select { |f| f.end_with?('pbxproj') }
pbxprojs.each do |filename|
  File.foreach(filename).with_index do |line, line_num|
    warn("null reference found in pbxproj", file: filename, line: line_num) if line.include?('/* (null) */') }
    warn("recovered references found in pbxproj", file: filename, line: line_num) if line.include?('name = "Recovered References";') }
  end
end
```

### Invalid UUIDs

This is about detecting orphan or invalid UUIDs in the projects, which are printed by to STDERR when parsing the project using `xcodeproj`:

```
<PBXGroup path=`Tests` UUID=`F26256AC222EC21500DD5E7B`>` attempted to initialize an object with an unknown UUID. `5FFC934E2296E0980088BFAA` for attribute: `children`. This can be the result of a merge and  the unknown UUID is being discarded.
```

We can intercept the warnings printed by `xcodeproj`, and transform them into warnings in the Danger comment, using this kind of snippet that we just have to declare before even using the `Xcodeproj::Project.open(...)` we use for all other rules:

```ruby
module Xcodeproj::UserInterface
  def self.warn(message)
    Danger.warn message
  end  
end
```

We could even go one step further and parse the warnings for those invalid UUIDs in order to then detect on which line that UUID is in the related `pbxproj` file and make the warning comment be inline.

### Unexpected Resources in Target

Using the `xcodeproj` gem (which is already part of our dependencies as it's used by `cocoapods`), we can also quickly analyze the structure of the project and detect resources that shouldn't have been added to build phases.

The draft ruby code below would for example loop on all `pbxproj` files modified by the PR, and for each of those Xcode projects, loop on all their targets to check if the "Resources Build Phase" of each target contain any of the files we want to forbid there:

```ruby
pbxprojs.each do |project_file|
  proj = Xcodeproj::Project.open(project_file)
  proj.targets.each do |target|
    rsrc_files = target.build_phases
      .find { |p| p.is_a?(Xcodeproj::Project::Object::PBXResourcesBuildPhase) }
      .files_references.map(&:path)
    rsrc_files.each do |path|
      fail("#{path} should be removed from #{project_file}:#{target.name}" if path.end_with? '.xcconfig'
    end
  end
end
```

We can use this logic to warn about those type of files/folders added to targets' resource phases by mistake:
 - `.xcconfig` files
 - `Info.plist` 
 - `__Snapshots__` directories
 - `.md` files (especially we have one `README.md`, maybe more in the future)

### Detect tests not added to scheme

We could once again use the `xcodeproj` gem to detect if any new tests file is properly added to a test target, and that the corresponding test is enabled in the test action in the scheme, to ensure that no tests are skipped.

## Impact on existing codebase

This would not impact the source code of our project at all.

This would only impact our code review process by providing additional informal messages to make us aware of potential risks or issues we could have otherwise missed.

Only possible impact would be in the time taken by the `Danger Checks` step on CI, but it only takes 4 seconds for now and is run in parallel of all the other jobs (`test_babylon` & co), so even if it takes a few more seconds, it wont impact the total time for all checks to finish, and if that could help us detect risk of merge conflicts and prevent bugs, it's still worth it.

## Alternatives considered

* Don't implement those rules at all. We believe the cost of adding those rules is quite small for a useful gain via automated feedback on those though.

* Only implement a subset of those rules. Given that they are closely related and that their logic is similar, small and focused, we don't see the benefit of not implementing one if we start implement the others. Especially if we already use `Xcodeproj` to dig into the structure of each modified pbxproj, we might as well do all those checks while we are there.

* Use an external tool to lint the pbxproj files
  * There are a couple of projects on GitHub that are aimed to lint pbxproj files consistency ([xcprojectlint](https://github.com/americanexpress/xcprojectlint), [ProjLint](https://github.com/JamitLabs/ProjLint), ...)
  * But all of those seems to have pretty basic rules and would not cover the cases we want to check
  * Also, using and installing them as dependencies might be overkill when simple scripting using less than 10 lines of ruby and a dependency we already have in our `Gemfile.lock` (`xcodeproj`) does the same job, if not better and more flexible
 
