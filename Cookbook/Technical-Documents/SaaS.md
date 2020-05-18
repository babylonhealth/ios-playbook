SaaS app is effectively a Babylon app with a configurable subset of features. To make this process scalable rather than creating new application targets every time we have a blueprint target, called SaaS, that is used to generate an app based on the configuration file at build time. We also use remote [feature switches](./FeatureSwitches.md) to configure features availablility.

## SaaS config 

SaaS config file is a plain json file that describes some of the applicaiton features that can be configured at build time. These are features that we configure with `AppConfiguration` or [static configurations](./FeatureSwitches.md#static-configuration). This config file also contains various identifiers required for the iOS app, such as bundle identifier, bundle display name, supported languages and platform specific features like HealthKit or push notifications:

```json
{
    "product_name": "Product Name",
    "bundle_display_name": "App Name",
    "app_version": "1.0.0",
    "bundle_ids": {
        "appstore" : "appstore.bundle.id",
        "enterprise" : "enterprise.bundle.id"
    },
    "extensions": [
        "NotificationServiceExtension"
    ],
    "app_center_names" : {
        "release" : "appcenter-release-app-name",
        "develop" : "appcenter-dev-app-name"
    },
    "app_languages": "...",
    "locale": "...",
    "healthkit": false,
    "push_notifications": true,
    "signin_signup": {
        "show_promo_code": true,
        ...
    },
    "brand_colors": {
        "brand_color": "...",
        "brand_secondary_color": "..."
    },
    "environment_keys": {
        "dev": "..."
        "staging": "..."
        "preprod": "..."
        "production": "..."
	}    
	...
}
```

For full list of configurations seee `Brand/SaaS/SaaS.json` file.

Because these configuration values are effectively hardcoded in the app we use this config file to generate source files and metadata files like plist and entitlments files:

```
bundle exec fastlane generate_saas saas:SaaSConfigFileName
```

Running this command will use `Brand/SaaS/SaaSConfigFileName.json` as a source of values for generated files. Files are generated from templates in the `SaaS/Templates` folder and are generated into `Brand/SaaS/Generated` folder.

To create an Appcenter or Testflight build provide a name of config file with a `saas` parameter instead of a target:

```
bundle exec fastlane appcenter saas:SaaSConfigFileName
bundle exec fastlane testflight saas:SaaSConfigFileName
```

Note that `testlfight` lane will use an app version from the configuration file rather than from the lane options.

## Creating a new SaaS project

When creating a new SaaS app follow these steps:

- create a new config file with required configurations
- create a new set of envrionments in the `EnviromentKeyGenerator.playground`, generate the envrionment keys and put them in the config file
- create bundle identifiers for a new app in the developer portal, put them in the config file and run match to create provisioning profiles:

```
bundle exec fastlane match_development saas:SaaSConfigFileName
bundle exec fastlane match_enterprise saas:SaaSConfigFileName
```

- create an asset catalog in `Brand/SaaS/Assets/SaaSConfigFileName` with the required assets (can be empty if no custom assets required)
- create new AppCenter apps and put their identifiers in the config file
- create new Firebase apps and download their plists into the `Brand/SaaS/Firebase/SaaSProductName` folder (note that the folder name should match the value of the `product_name` in the config file, which can be different than the config file name itself)
- generate the app with `bundle exe generate_saas saas: SaaSConfigFileName` and run it
- commit all the new files but **do not commit changes to generated files**.

## Extending configurations

We should strive to minimise amount of compile time configuration and allow runtime configuration instead so whenever possible consider using product config for the feature configuration. If it's not possible and feature is configured in the AppConfiguration or as a static configuration then to being able to configure it for different SaaS projects you need to:

- add the key with the configuration value in the config file. Note that you should add it to all the config files or check if the key is defined in the template
- if the configuraiton is not yet part of the existing templates extract it into a new template or add to the existing one depending on where it fits better
- if the configuration is a part of the static feature configuration then add it as a parameter to the corresponding feature module configuration call in `Brand/SaaS/Templates/SaaSAppDelegate.swift.erb`
- the template files are ERB templates so make sure you use corret [ERB syntax](https://puppet.com/docs/puppet/latest/lang_template_erb.html#concept-5566). So to write the configuration value in the generated file use `<%= cofig_key %>` syntax in the template.
- if you added a new template file add it to the list of template files in the `generate_saas_files` method in the `fastlane/Lanes/saas`
