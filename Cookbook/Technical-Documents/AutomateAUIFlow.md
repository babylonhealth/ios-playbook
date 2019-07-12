# Testing Conventions (UI Automation) [DRAFT]

When we work on a story, we will automate the happy path using UI testing XCTest. Explain why here

# Test Scenarios
To begin with we need to decide what flows we want to automate at the UI level. Unit and snap shot tests should be used as much as possible to reduce front end automation, in line with the testing pyramid. Once QA and Dev have agreed to automate a UI flow, the first stage is define the test. The tests are normally defined by QA after discussion with Dev and written in the gherkin.

## Automation Components
Before we start automating a flow, we need to outline the primary components used in automation in order to understand how work is required. For a completely new functional area you will probably need to implement code in the following areas, though additional code may be required. The design pattern selected was based on Cucumber with Page Object Model.

### Feature Files
The feature file contains the test scenarios written using the [Gherkin](https://cucumber.io/docs/gherkin/) syntax. The naming convention for the file itself is normally `functionality` `sub-functionality` *Feature.swift*. For example `AppointmentsFamilyFeature.swift`. These files should contain all test scenarios for the specified area. 

### Step definitions
The steps definitions are used to link the human readable Gherkin to user actions through a screen object. The framework selected is [xctest-gherkin](https://github.com/net-a-porter-mobile/XCTest-Gherkin). The framework use regex to search for the corresponding step and facilitates passing in parameters. It is at this level were we should be asserting the state of the screen or grouping user actions, responses or cross screen actions. A more detailed naming convention for step definitions is [here](https://github.com/Babylonpartners/ios-playbook/blob/master/Cookbook/Technical-Documents/UIAutomation.md).

### Screen Objects
The screen object class should contain public methods that invoke user actions or check the state of the screen. Normally we would not put an assert inside a screen object. The objects themselves will contain multiple methods with single actions or state checks and some private helper methods as needed, in line with the single responsibility principle. In some cases methods can group multiple actions together where no assert is required, for example `enterCredentials` can in turn call both `enterEmail` and `enterPassword`. The object should only be the sole location for defining accessibility identifiers for all XCUIElments contained within the screen, normally stored as a *enum*. A more detailed naming convention for accessibility identifiers can be found [here](https://github.com/Babylonpartners/ios-playbook/blob/master/Cookbook/Technical-Documents/AutomationIdentifiers.md).

### API Calls
The final part may be to create a new API call from automation. The reasoning for this code is that in front end UI automation, there is great deal of repetition in front end testing, especially in common tasks like adding children. If we completed these tasks at the UI level, test execution would be dramatically increased. To mitigate this we utilize the Babylon client and portal API's to put the application and user in the state required for the test scenario. The normal way to do this is to extend `APIInterface` with the request specific to the area under tests `APIInterface+Appointment`

## Test Scenarios

When adding new scenarios they will normally be put in an existing file or a new one created.


# Test Scheme

Maybe explain the test scheme and environments

# Writing your Tests

The first stage is to write your `test scenario` which will either need to be added to an existing feature file or a new one created. Feature files follow the naming convention `feature``sub-feature` Feature.swift 

# writing your step definitions and screen objects if needed

# How and when do we run UI tests




