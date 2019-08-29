<p align="center">
<img src="logo.png">
</p>


iOS Playbook 📚
==================================

At Babylon, we firmly believe that **transparency** is a core value that should be present in everything we do. This playbook embodies that value by giving an overview of how we work:

1. [Who's in the team 👨‍👩‍👧‍👦](#1-who-are-we)
2. [OSS-maintained projects 🚀](#2-oss-maintained-projects)
3. [The Cookbook 👩‍🍳](/Cookbook/README.md)
4. [Interview process 📝](/Interview/README.md)
5. [Code of conduct ❤️](/Etiquette/README.md)
6. [Code review etiquette](/Etiquette/CODE_REVIEW.md)

## 1. Who are we? 

We're organised in Squads. Each squad can be composed of people from Engineering (iOS, Android, Web, Backend), Design and Product.

Some of the roles are transverse to all the squads:

<!-- begin:roles -->
<!--
  DO NOT EDIT MANUALLY: This table has been auto-generated.
  TO UPDATE THIS TABLE:
   - update scripts/squads.yml
   - run `scripts/squads.rb` to update the `README.md` sections
-->

<table>
  <thead><th>Role</th><th>Engineer</th><th>GitHub</th><th>Twitter</th></thead>
    <tr><td rowspan='1' valign='top'><strong>Engineering Manager</strong></td>
      <td>Rui Peres</td><td><a href='https://github.com/RuiAAPeres'>@RuiAAPeres</a></td><td><a href='https://twitter.com/peres'>@peres</a></td></tr>
    <tr><td rowspan='2' valign='top'><strong>Chapter Leads</strong></td>
      <td>Ana Catarina Figueiredo</td><td><a href='https://github.com/AnnKatF'>@AnnKatF</a></td><td><a href='https://twitter.com/AnnKatFig'>@AnnKatFig</a></td></tr>
      <tr><td>David Rodrigues</td><td><a href='https://github.com/dmcrodrigues'>@dmcrodrigues</a></td><td><a href='https://twitter.com/dmcrodrigues'>@dmcrodrigues</a></td></tr>
    <tr><td rowspan='1' valign='top'><strong>Squad Tech Leads</strong></td>
      <td>Michael Brown</td><td><a href='https://github.com/mluisbrown'>@mluisbrown</a></td><td><a href='https://twitter.com/mluisbrown'>@mluisbrown</a></td></tr>
</table>
<!-- end:roles -->

The rest of the iOS Engineers work in the following squads:

<!-- begin:squads -->
<!--
  DO NOT EDIT MANUALLY: This table has been auto-generated.
  TO UPDATE THIS TABLE:
   - update scripts/squads.yml
   - run `scripts/squads.rb` to update the `README.md` sections
-->

<table>
  <thead><th>Squad</th><th>Engineer</th><th>GitHub</th><th>Twitter</th></thead>
    <tr><td rowspan='1' valign='top'><strong>Booking</strong><br/>Face to face appointment booking.</td>
      <td>Witold Skibniewski</td><td><a href='https://github.com/mr-v'>@mr-v</a></td><td></td></tr>
    <tr><td rowspan='2' valign='top'><strong>Consultation</strong><br/>Flows for all the consultation like prescriptions and video consultation.</td>
      <td>Adrian Śliwa</td><td><a href='https://github.com/adiki'>@adiki</a></td><td><a href='https://twitter.com/adiki91'>@adiki91</a></td></tr>
      <tr><td>Chitra Kotwani</td><td><a href='https://github.com/chitrakotwani'>@chitrakotwani</a></td><td><a href='https://twitter.com/chitrakotwani'>@chitrakotwani</a></td></tr>
    <tr><td rowspan='4' valign='top'><strong>Onboarding and navigation</strong><br/>General user experience in the app.</td>
      <td>Emese Toth</td><td><a href='https://github.com/emeseuk'>@emeseuk</a></td><td></td></tr>
      <tr><td>Giorgos Tsiapaliokas</td><td><a href='https://github.com/gtsiap'>@gtsiap</a></td><td></td></tr>
      <tr><td>Sergey Shulga</td><td><a href='https://github.com/sergdort'>@sergdort</a></td><td><a href='https://twitter.com/SergDort'>@SergDort</a></td></tr>
      <tr><td>Yuri Karabatov</td><td><a href='https://github.com/karabatov'>@karabatov</a></td><td><a href='https://twitter.com/karabatov'>@karabatov</a></td></tr>
    <tr><td rowspan='5' valign='top'><strong>Native Apps Platform</strong><br/>Engineering work like tooling, CI and development processes.</td>
      <td>David Rodrigues</td><td><a href='https://github.com/dmcrodrigues'>@dmcrodrigues</a></td><td><a href='https://twitter.com/dmcrodrigues'>@dmcrodrigues</a></td></tr>
      <tr><td>Ilya Puchka</td><td><a href='https://github.com/ilyapuchka'>@ilyapuchka</a></td><td><a href='https://twitter.com/ilyapuchka'>@ilyapuchka</a></td></tr>
      <tr><td>Yasuhiro Inami</td><td><a href='https://github.com/inamiy'>@inamiy</a></td><td><a href='https://twitter.com/inamiy'>@inamiy</a></td></tr>
      <tr><td>Martin Nygren</td><td><a href='https://github.com/zzcgumn'>@zzcgumn</a></td><td></td></tr>
      <tr><td>Olivier Halligon</td><td><a href='https://github.com/AliSoftware'>@AliSoftware</a></td><td><a href='https://twitter.com/aligatr'>@aligatr</a></td></tr>
    <tr><td rowspan='1' valign='top'><strong>GP @ Hand</strong><br/>End to end journey for NHS registration.</td>
      <td>James Birtwell</td><td><a href='https://github.com/jimmybee'>@jimmybee</a></td><td></td></tr>
    <tr><td rowspan='2' valign='top'><strong>Healthcheck</strong><br/>Overview of your health using a 3D body model (avatar).</td>
      <td>Ben Henshall</td><td><a href='https://github.com/Ben-Henshall'>@Ben-Henshall</a></td><td><a href='https://twitter.com/ben_henshall'>@ben_henshall</a></td></tr>
      <tr><td>Julien Ducret</td><td><a href='https://github.com/brocoo'>@brocoo</a></td><td></td></tr>
    <tr><td rowspan='5' valign='top'><strong>Monitor</strong><br/>Monitoring health metrics like activity, blood, urine, ...</td>
      <td>Anders Ha</td><td><a href='https://github.com/andersio'>@andersio</a></td><td><a href='https://twitter.com/_andersha'>@_andersha</a></td></tr>
      <tr><td>Daniel Haight</td><td><a href='https://github.com/Daniel1of1'>@Daniel1of1</a></td><td></td></tr>
      <tr><td>Daniel Spindelbauer</td><td><a href='https://github.com/sdaniel55'>@sdaniel55</a></td><td><a href='https://twitter.com/sdaniel55'>@sdaniel55</a></td></tr>
      <tr><td>Diego Petrucci</td><td><a href='https://github.com/diegopetrucci'>@diegopetrucci</a></td><td><a href='https://twitter.com/diegopetrucci'>@diegopetrucci</a></td></tr>
      <tr><td>Joshua Simmons</td><td><a href='https://github.com/j531'>@j531</a></td><td></td></tr>
    <tr><td rowspan='2' valign='top'><strong>Prescriptions</strong><br/>Precriptions functionality.</td>
      <td>Adam Borek</td><td><a href='https://github.com/TheAdamBorek'>@TheAdamBorek</a></td><td><a href='https://twitter.com/TheAdamBorek'>@TheAdamBorek</a></td></tr>
      <tr><td>Konrad Muchowicz</td><td><a href='https://github.com/konrad-em'>@konrad-em</a></td><td></td></tr>
    <tr><td rowspan='1' valign='top'><strong>Partnerships Squad</strong><br/>Updating and maintaining the Telus app.</td>
      <td>Simon Cass</td><td><a href='https://github.com/scass91'>@scass91</a></td><td><a href='https://twitter.com/codercass'>@codercass</a></td></tr>
    <tr><td rowspan='1' valign='top'><strong>SDK</strong><br/>Develop and maintain the SDK frameworks.</td>
      <td>Viorel Mihalache</td><td><a href='https://github.com/viorel15'>@viorel15</a></td><td><a href='https://twitter.com/viorelMO'>@viorelMO</a></td></tr>
    <tr><td rowspan='1' valign='top'><strong>Tenancy & Features</strong><br/></td>
      <td>Anil Puttabuddhi</td><td><a href='https://github.com/anilputtabuddhi'>@anilputtabuddhi</a></td><td></td></tr>
    <tr><td rowspan='1' valign='top'><strong>Test Kits</strong><br/>Managing everything related to Babylon do-at-home tests.</td>
      <td>Michał Kwiecień</td><td><a href='https://github.com/MichalTKwiecien'>@MichalTKwiecien</a></td><td><a href='https://twitter.com/kwiecien_co'>@kwiecien_co</a></td></tr>
    <tr><td rowspan='2' valign='top'><strong>Triage</strong><br/>Chatbot functionality.</td>
      <td>Danilo Aliberti</td><td><a href='https://github.com/daniloaliberti'>@daniloaliberti</a></td><td></td></tr>
      <tr><td>Michael Brown</td><td><a href='https://github.com/mluisbrown'>@mluisbrown</a></td><td><a href='https://twitter.com/mluisbrown'>@mluisbrown</a></td></tr>
    <tr><td rowspan='3' valign='top'><strong>US Professional Services</strong><br/>Features for app in the US.</td>
      <td>Greg Bryant</td><td></td><td></td></tr>
      <tr><td>Patrick Westmeyer</td><td><a href='https://github.com/bh-pwestmeyer'>@bh-pwestmeyer</a></td><td></td></tr>
      <tr><td>Sam Francis</td><td><a href='https://github.com/SamFrancis-Babylon'>@SamFrancis-Babylon</a></td><td></td></tr>
</table>
<!-- end:squads -->

## 2. OSS-maintained projects

| Project name                  | Owner(s)                 | Stars        |
|-------------------------------|--------------------------| ------------ |
| [Bento](https://github.com/Babylonpartners/Bento)                         | Anders, David, Sergey    | [![GitHub stars](https://img.shields.io/github/stars/BabylonPartners/Bento.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/BabylonPartners/Bento/stargazers/) |
| [DrawerKit](https://github.com/Babylonpartners/DrawerKit)                     | Inami, Ben               |    [![GitHub stars](https://img.shields.io/github/stars/BabylonPartners/DrawerKit.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/BabylonPartners/DrawerKit/stargazers/) |
| [ReactiveFeedback](https://github.com/Babylonpartners/ReactiveFeedback)              | Anders, Sergey           |    [![GitHub stars](https://img.shields.io/github/stars/BabylonPartners/ReactiveFeedback.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/BabylonPartners/ReactiveFeedback/stargazers/) |
| [Wall-E](https://github.com/Babylonpartners/Wall-E)                        | David, Rui               |    [![GitHub stars](https://img.shields.io/github/stars/BabylonPartners/Wall-E.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/BabylonPartners/Wall-E/stargazers/)    |
| [Stevenson](https://github.com/Babylonpartners/Stevenson)                     | Ilya, Olivier                     |    [![GitHub stars](https://img.shields.io/github/stars/BabylonPartners/Stevenson.svg?style=social&label=Star&maxAge=2592000)](https://GitHub.com/BabylonPartners/Stevenson/stargazers/) |
| Style guide                   | Diego                    |    WIP       |
