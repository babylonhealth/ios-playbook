# Danger Rules for pbxproj

* Author: Olivier Halligon
* Review Manager: TBD

## Introduction

This proposal suggests to add some Danger rules checking for `xcodeproj` consistenty.

It is dependent on [#110 - Integrate Danger](https://github.com/Babylonpartners/ios-playbook/pull/110) being accepted first.

## Motivation

`pbxproj` project format is hard to parse, which means it's easy to miss some mistakes that could happen when an Xcode project has changed during a PR.

This means that some mistakes have ended up in `develop` in the past, like:

* `(null)` references in `pbxproj` files
* Files being added as part of a target membership while they shouldn't:
  * Snapshot files
  * xcconfig files
  * Info.plist files

Some of those mistakes, especially `(null)` references, are generally the result of merge conflicts; so their appearances during a PR could be an indicator that something else could have gone wrong during the merge of the pbxproj file. It's generally a good incentive to double-check that there was no other side effect from the pbxproj merge.

Other mistakes like unexpected files in target membership could lead to files ending up in the final bundle uploaded to the AppStore, and in addition to being useless in the final `ipa`, bloat the app size for no reason.

## Proposed solution

* We can use a simple "find" in every `*.pbxproj` for the string `/* (null) */`, and make Danger generate an inline comment on the found line(s) if any

This can be done pretty easily with Ruby, conceptually this will look like the logic below:

```ruby
pbxprojs = git.modified_files.select { |f| f.end_with?('pbxproj') }
pbxprojs.each do |filename|
  File.foreach(filename).with_index do |line, line_num|
    warn("null reference found in pbxproj", file: filename, line: line_num) if line.include?('/* (null) */') }
  end
end
```

* Using the `xcodeproj` gem (which is already part of our dependencies as it's used by `cocoapods`), we can also quickly analyze the structure of the project and detect resources that shouldn't have been added to build phases.

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

* We can use a similar logic to warn about `Info.plist` files added to targets' resource phases by mistake.
* We can also use a similar rule to prevent `__Snapshots__` directories be added in resources... and even to be added as reference to any `xcodeproj` at all.



All those rules listed above, if implemented in the `Dangerfile`, will help us:

* Keep the Project files sanitised and avoid commiting invalid pbxproj files, which are often the result of merge conflicts.
* Be aware of potential higher risks of a merge gone wrong on a pbxproj file, to avoid commiting a corrupted pbxproj (e.g. one that could still be readable by `xcodebuild` but in which a reference to an image file got removed from the pbxproj due to a bad merge, making the app crash at runtime)
* Avoid including large chunk of unrelevant resources (like test snapshots) in the final bundle

## Impact on existing codebase

This would not impact the source code of our project at all.
This would only impact our code review process by providing additional informal messages to make us aware of potential risks or issues we could have otherwise missed.

## Alternatives considered

* Don't implement those rules at all. We believe the cost of adding those rules (once/if a `Dangerfile` has been introduced by [#110](https://github.com/Babylonpartners/ios-playbook/pull/110) that is) is quite small for a useful gain via automated feedback on those though.

* Only implement a subset of those rules. Given that they are closely related and that their logic is similar, small and focused, we don't see the benefit of not implementing one if we start implement the others. Especially if we already use `Xcodeproj` to dig into the structure of each modified pbxproj, we might as well do all 3 checks while we are there.

* Use an external tool to lint the pbxproj files
  * There are a couple of projects on GitHub that are aimed to lint pbxproj files consistency ([xcprojectlint](https://github.com/americanexpress/xcprojectlint), [ProjLint](https://github.com/JamitLabs/ProjLint), ...)
  * But all of those seems to have pretty basic rules and would not cover the cases we want to check
  * Also, using and installing them as dependencies might be overkill when simple scripting using less than 10 lines of ruby and a dependency we already have in our `Gemfile.lock` (`xcodeproj`) does the same job, if not better and more flexible
 
