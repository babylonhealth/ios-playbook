# Application Distribution
This document is for Babylon iOS developers who want to distribute our applications internally, to other Babylon employees, or externally, to our partners.

## How to gain access to iOS applications
Requests to grant access must be made through the #ios slack channel - the person making the request should also inform you which specific app they are hoping to gain access to.

### External distribution
* External distribution **must** be done via Testflight
* External partners are only eligible to receive their specific target of the application

### Internal distribution
* Internal distribution can be done either via Testflight or App Center

## Distribution of iOS applications
### Distributing via App Center
* Ask the person who is requesting access for their `@babylonhealth.com` email address
* Follow [this guide](https://github.com/babylonhealth/ios-playbook/blob/simon/cnsmr-3226/Cookbook/Technical-Documents/AppCenter.md#adding-people-to-the-organisation) to invite them to our App Center builds

### Distributing via Testflight
* **Please ensure external partners only receive testflight builds, do not send App Center builds externally**
* Ensure the external partner has [testflight](https://developer.apple.com/testflight/) installed on their device
* Within [AppstoreConnect](https://appstoreconnect.apple.com/) (login details within 1Password), add the user(s) to the relevant distribution group
* Within the user distribution group in Testflight on AppstoreConnect there will be a link to invite the user to our build, once they are added to the relevant group, please use this link to invite them to install our build via Testflight

![](https://i.imgur.com/apFTvzj.png)
