# Testing Conventions (UI Automation) [DRAFT]

Testing a story can be completed using different techniques and levels of the test pyramid. The method used is dependant on the functionality being implemented. Given the time and maintenance cost associated with front end UI testing we should endeavour to use unit, integration and snap shots where possible. Though there will alway be cases where front end automation is either the best or only solution, this article explains how we automate these flows.

# Test Scenarios
To begin with we need to decide what flows we want to automate at the UI level. Once QA and Dev have agreed to automate a UI flow, the first stage is define the test. The tests are normally defined by QA after discussion with Dev and written in the gherkin, wit these tests stored in TestRail. 

# Preparation
## Automation Components
Before we start automating a flow, we need to understand the primary components used in automation, in order to understand how we create tests. For a completely new functional area you would be expected implement code in the following areas. The design pattern selected was based on Cucumber with Page Object Model.

### Feature Files
The feature files contain test scenarios written using the [Gherkin](https://cucumber.io/docs/gherkin/) syntax. The naming convention for the file itself is normally `functionality` `sub-functionality` *Feature.swift*. For example `AppointmentsFamilyFeature.swift`. These files should contain all test scenarios for the specified area.

### Step definitions
The steps definitions are used to link the human readable Gherkin to user actions controlled  through a screen object. The framework selected was [xctest-gherkin](https://github.com/net-a-porter-mobile/XCTest-Gherkin). The framework use regex to search for the corresponding step and facilitates passing in parameters. It is at this level where we should be asserting screen states, performing actions or grouping *cross screen* actions. A detailed naming convention for step definitions is [here](https://github.com/Babylonpartners/ios-playbook/blob/master/Cookbook/Technical-Documents/UIAutomation.md).

### Screen Objects
Screen objects contain methods that invoke user actions, check the screen state or group *single screen* actions, in line with the single responsibility principle. State checks should be asserted at the step definition level and not within the screen object itself. When grouping multiple actions it should magic logical sense, for example `enterCredentials` can call both `enterEmail` and `enterPassword`. Accessibility identifiers for XCUIElments should be stored within the corresponding screen object, normally as a *enum*. A detailed naming convention for accessibility identifiers can be found [here](https://github.com/Babylonpartners/ios-playbook/blob/master/Cookbook/Technical-Documents/AutomationIdentifiers.md).

### API Calls
It may be necessary to add support for an API request as part of the test scenario, for example booking an appointment, adding family or prescribing a prescription. The key reasoning for these requests are to streamline automation and reduce user action duplication. This way tests can begin in the desired state, and reduce test execution time. The normal way to do this is to extend `APIInterface` with the request specific to the area under tests `APIInterface+Appointment`

# Automate a flow
For the article we will go through a truncated set of steps necessary to automate a simple login UI flow.

```swift
func test_login_as_uk_user() {
        Given("I tap the login option in the Start up screen")
        And("I enter credentials for a \"United Kingdom\" user")
        And("the password field is secure")
        When("I tap on the password visible icon")
        Then("the password field is not secure")
        When("I tap the login option in the Log in screen")
        Then("the home screen is displayed")
    }
```
## Feature
The first stage will be to choose the feature file to contain the test scenario, in this case we will make use of 'LoginFeature.swift' which already contains a number of sign in tests. 


# Test Scheme

Maybe explain the test scheme and environments

# Writing your Tests

The first stage is to write your `test scenario` which will either need to be added to an existing feature file or a new one created. Feature files follow the naming convention `feature``sub-feature` Feature.swift 

# writing your step definitions and screen objects if needed

# How and when do we run UI tests




