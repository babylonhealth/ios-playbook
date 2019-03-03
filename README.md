<p align="center">
<img src="logo.png">
</p>


iOS Playbook 📚
==================================

At Babylon, we firmly believe that **transparency** is a core value that should be present in everything we do. This playbook embodies that value by giving an overview of how we work:

1. [Who's in the team](#1-whos-in-the-team)
2. [Which squad each individual belongs to, and its availability](#2-which-squad-each-individual-belongs-to-and-its-availability)
3. [OSS-maintained projects](#3-oss-maintained-projects)
4. [New hires checklist](#4-new-hires-checklist)
5. [Release process](release.md)
6. [Technical documents and Proposals](/TechnicalDocuments/README.md)
7. [Interview process](/Interview/README.md)
8. [Swift style guide](/Style-guide/README.md)
9. [Code of conduct](/Etiquette/README.md)


## 1. Who's in the team

| Name                    | Contact                                                       |
|-------------------------|---------------------------------------------------------------|
| Adam Borek              | [@TheAdamBorek](https://twitter.com/TheAdamBorek)             |
| Ana Catarina Figueiredo | [@AnnKatFig](https://twitter.com/AnnKatFig)                   |
| Anders Ha               | [@_andersha](https://twitter.com/_andersha)                   |
| Ben Henshall            | [@Ben_Henshall](https://twitter.com/ben_henshall?lang=en)     |
| Danilo Aliberti         |                                                               |
| David Rodrigues         | [@dmcrodrigues](https://twitter.com/dmcrodrigues)             |
| Diego Petrucci          | [@diegopetrucci](https://twitter.com/diegopetrucci)           |
| Giorgos Tsiapaliokas    | [@gtsiap](https://github.com/gtsiap)                          |
| Ilya Puchka             | [@ilyapuchka](https://twitter.com/ilyapuchka)                 |
| Jason Dobo              | [@jasondobo](https://github.com/jasondobo)                    |
| João Pereira            | [@NSMyself](https://twitter.com/nsmyself)                     |
| Martin Nygren           |                                                               |
| Michael Brown           | [@mluisbrown](https://twitter.com/mluisbrown)                 |
| Rui Peres               | [@peres](https://twitter.com/peres)                           |
| Sergey Shulga           | [@SergDort](https://twitter.com/SergDort)                     |
| Viorel Mihalache        | [@viorelMO](https://twitter.com/viorelMO)                     |
| Witold Skibniewski      |                                                               |


## 2. Which squad each individual belongs to, and its availability.

By definition, members work on their respective squad, although they are free to work in different squads if the work load justifies it.


| Squad Name                    | Members                          | Availability |
|-------------------------------|----------------------------------| ------------ |
| SDK                           | Viorel, Martin, Witold           |    2/4       |
| Consultation                  | Ilya                             |    1/2       |
| Booking                       | Witold                           |    1/1       |
| Prescriptions                 | Adam                             |    1/1       |
| Healthcheck                   | Ben, Catarina                    |    2/3       |
| Native/Core                   | Giorgos, Jason                   |    2/6       |
| Professional Services         | Danilo                           |    1/3       |
| GP at Hand                    | Diego                            |    1/1       |
| Core Experience               | Sergey                           |    1/1       |
| Health Management             | David, Joao                      |    2/2       |
| Monitor                       | Anders                           |    1/2       |
| Triage UI                     | Michael                          |    1/1       |


## 3. OSS-maintained projects

| Project name                  | Owner(s)                 | Stars        |
|-------------------------------|--------------------------| ------------ |
| Bento                         | Anders, David, Sergey    | [![GitHub stars](https://img.shields.io/github/stars/BabylonPartners/Bento.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/BabylonPartners/Bento/stargazers/) |
| DrawerKit                     | David, Wagner            |    [![GitHub stars](https://img.shields.io/github/stars/BabylonPartners/DrawerKit.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/BabylonPartners/DrawerKit/stargazers/) |
| ReactiveFeedback              | Anders, Sergey           |    [![GitHub stars](https://img.shields.io/github/stars/BabylonPartners/ReactiveFeedback.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/BabylonPartners/ReactiveFeedback/stargazers/) |
| Style guide                   |                    |    WIP       |

## 4. New hires checklist

Prior to starting, make sure you have a Babylon GitHub account and that you have access to the following repositories:

- [babylon-ios](https://github.com/Babylonpartners/babylon-ios)
- [ios-charts](https://github.com/Babylonpartners/ios-charts)
- [ios-private-podspecs](https://github.com/Babylonpartners/ios-private-podspecs)
- [ios-build-distribution](https://github.com/Babylonpartners/ios-build-distribution)
- [ios-fastlane-match](https://github.com/Babylonpartners/ios-fastlane-match)

Here's how to get the iOS project up and running.

1. Clone the iOS repository: https://github.com/Babylonpartners/babylon-ios
1. Set up Git LFS and pull, according to these instructions: https://github.com/Babylonpartners/babylon-ios/wiki/How-to-install-Git-LFS
1. Globally configure Git to use SSH instead of HTTPS: https://ricostacruz.com/til/github-always-ssh
     ```
     git config --global url."git@github.com:".insteadOf "https://github.com/"
     ```
1. Run `bundle install`
1. Run `pod install`
1. Open `Babylon.xcworkspace` in Xcode (there may be several warnings; they can be ignored)
1. Configure the Xcode **Text Editing -> Editing** preferences as follows:
     - Automatically trim trailing whitespace
     - Including whitespace-only lines
     - Default line endings: macOS / Unix (LF)
     - Convert existing files on save
1. Configure the Xcode **Text Editing -> Indentation** preferences as follows:
     - Prefer indent using: Spaces
     - Tab width: 4 spaces
     - Indent width: 4 spaces
     - Tab key: Indents in leading whitespace
1. Make sure the device selected for testing is iPhone 5s

<img src="iphone-5s.png" height="101" width="388" alt="iPhone 5s" />
