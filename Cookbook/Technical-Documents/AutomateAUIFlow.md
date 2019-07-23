

# Testing Conventions: Automating a UI Flow [DRAFT]
When testing a story, functionality can normally be tested at multiple levels of test pyramid and nearly always at the UI level. *So the question becomes were do we want to test and why*. As a geneal rule to lower in the testing pyramid you can test the more efficent and resource inespensive a test is, for example unit or inegration or snapshot tests.

Testing at the UI level should be utilised for funciotnality that can't be fully tested at other levels or to test a end to end flow or requires subjective evaulation i.e. video. Once we have decided to create a UI test, the next stage is to decide if we should automate the test scenareo and should be agreed between QA and Dev. 

UI automation facilitates regular regression testing and earlier identification of bugs prior to a release. This article explains how we automate a UI flow for a iOS applciaiotn.

# Test Scenarios
Once QA and Dev have agreed to automate a UI flow, we will define the test sceanrio. Tests are normally defined by QA after discussion with Dev and written in the [gherkin](https://cucumber.io/docs/gherkin/), with the test stored in TestRail.

# Preparation
## Automation Components
Before starting, we need to understand the components used in automation, in order to understand how to create tests. For completely new functional you will be expected to implement code in the following areas. The design pattern selected was based on Cucumber and the Page Object Model.

### Feature Files
Feature files contain the test scenarios written in [Gherkin](https://cucumber.io/docs/gherkin/) syntax. The naming convention for the file itself is normally `functionality` `sub-functionality` *Feature.swift*. For example `AppointmentsFamilyFeature.swift`. These files should contain all test scenarios for the specified area in roder to facilitate targted testing of fucntional areas.

### Step definitions
Steps definitions are used to link the human readable Gherkin to user actions, implmented in screen objects. The framework selected was [xctest-gherkin](https://github.com/net-a-porter-mobile/XCTest-Gherkin). The framework uses regex to search for the corresponding step and facilitates passing in upto two parameters. 

It is at this level where we should be asserting screen states, performing actions or grouping *cross screen* actions. A detailed naming convention for step definitions is defined [here](https://github.com/Babylonpartners/ios-playbook/blob/master/Cookbook/Technical-Documents/UIAutomation.md).

### Screen Objects
Screen objects contain the code that controls the user interface, check screen states or in limited cases groups *single screen* actions. Scrren objects should adher to the single responsibility principle. 

#### State Checks
State check functions are intended to *evaluate* the screen under tests and return a value. In pratise these fall, into three categories but are not limited to these. Code to check if something is displayed ```func isScreenDisplayed() -> Bool``` or ```func isCardDisplayed(for card: HomeScreenCards) -> Bool```. The paramater being passed in can come from the feature file or the stepdefinition. The third common one is to retrieve a value or count from the screen ```func pharmaciesCount() -> Int```. The return value should be evaluated at the step level and the passed or failed based on the result.

#### Interface Interactions
Interactions are intended to cover user actions on the screen, if we look at the login screen we would find functions like ```func enterEmail(_ email: String)``` or ```func enterPassword()```. We can also group common actions so long as they are within the scope of the screen and make logical sense, staying with the login screen we could have a ```func enterCredentialsAndLogin(email: String)```

#### Accessibility identifiers
Accessibility identifiers for **XCUIElement** should be stored within the screen object, normally in a *enum* for each element type. And then referenced from the functions using ```Cells.passwordField```. This ensure that idenfiers are only stored once in the code and can be updated with a single change.

A detailed naming convention for accessibility identifiers can be found [here](https://github.com/Babylonpartners/ios-playbook/blob/master/Cookbook/Technical-Documents/AutomationIdentifiers.md).

### API Calls
In order to optimise test scenarios and exeuction times, we utilise API calls to control the state of the applicaiton under test. For example when testing family appointments we can use the API to add family memebers of any type to a users account or prescribe medication. The reasoning for this is to speed up the tests and reduce duplicate through the removal of common actions. This way the test can begin in controled state. This is normally done through extending `APIInterface` with the request specific to the area under tests `APIInterface+Appointment`

# Automate a flow
We will now go through a abridged set of development tasks necessary to automate a simple login UI flow.

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
The first stage will be to choose the feature file for the test scenario, in this example will use 'LoginFeature.swift' which already contains a number of sign in tests. Please **note** *that if you add a new Feature file, Xcode will automatically add the file to the Unit Test run, you will have to manually exclude it, or your PR will fail*. To begin with copy the test into the feature file ensuring you follow the `XCTest-Gherkin` formatting. 

## Step Definitions
### Existing Step
We need to identify if the step already exists, either with the same step name or alternative. The easiest way is to work backwards from the screen objects. For example `("I tap the login option in the Start up screen")` is interacting with the **StartUpScreen**. Navigate to the screen object and find the `func` that presses login, in this case it's the function **startLoginJourney**, then search for any steps which call it. This identify any steps we can use in the test, even though the text may differ, if this is the case we'll have to update the feature file. So long as the action is the same we can use the preexisting step or if none exist we will create one.

### New Step
For this example we will assume `("I enter credentials for a \"United Kingdom\" user")` does not exist. First identify an appropriate steps file, normally steps file contain a broad series of step definitions, relating to a functional area of the application, in this case we'll use `LoginStepe.swift` and add the following code.

```swift
        step("I enter credentials for a \"(.*?)\" user") { (user: String) in
            // TODO
        }
```
Before we continue it's worth looking at the documentation for [XCTest-Gherkin](https://github.com/net-a-porter-mobile/XCTest-Gherkin/blob/master/README.md) to understand how steps definitions work.

#### Paramaters
For this example we will pass in the *country* as a parameter, we need to write a regex capture group and define the data type. This part of of the step `\"(.*?)\"` will capture the parameter, I user `\"` as a method to demote the boundary of the parameter though this is not technically needed. We can also as per the pod specify only certain parameters, or restrict the value. For this step we will take any value and define it as a `String`. 
 
## Screen Objects
Screen objects are intended to contain all the code and identifiers relating to the screen. Fcuntions will normally fall into 3 main types, checking the state fo the screen, interacting with a element or gourping multiple actions that are contain wiithin the scope of the screen. For the article we will define three functions 

```swift
    func enterCredentialsFor(email: String) {
        enterEmail(email)
        enterPassword()
    }

    private func enterEmail(_ email: String) {
        let emailField = app.tables.textFields[Cells.emailField]
        typeInto(element: emailField, withText: email)
    }

    private func enterPassword() {
        let passwordField = app.tables.secureTextFields[Cells.passwordField]
        typeInto(element: passwordField, withText: UserConstants().password)
    }
    
    func tapLogin() {
        let loginButton = app.tables.buttons.matching(identifier: Buttons.logInButton).firstMatch
        loginButton.tap()
    }
```

At the heart of iOS automation are XCUIElement and XCUIElementQuery, before we can interact with anything on screen we need to find the element we want to interact with. The first thing to do is put a break point in your func and print the view hierarchy in console. Here is a simplified example.

```python
    Window (Main), 0x600000d9cee0, {{0.0, 0.0}, {375.0, 812.0}}
        NavigationBar, 0x600000d9d0a0, {{0.0, 44.0}, {375.0, 44.0}}, identifier: 'Log in'
          Button, 0x600000d9d180, {{0.0, 44.0}, {44.0, 44.0}}, label: 'Back'
          Other, 0x600000d9d260, {{164.0, 55.7}, {47.3, 20.3}}, label: 'Log in'
        Other, 0x600000d9d340, {{0.0, 0.0}, {375.0, 812.0}}
          Other, 0x600000d9d420, {{0.0, 0.0}, {375.0, 812.0}}
            Other, 0x600000d9d6c0, {{0.0, 0.0}, {375.0, 812.0}}, identifier: 'login'
              Other, 0x600000d9d500, {{0.0, 0.0}, {375.0, 812.0}}
                Table, 0x600000d9d5e0, {{0.0, 0.0}, {375.0, 812.0}}
                  Other, 0x600000d9d7a0, {{0.0, 88.0}, {375.0, 8.0}}
                  Cell, 0x600000d9dce0, {{0.0, 187.7}, {375.0, 71.0}}
                    TextField, 0x600000d9ddc0, {{32.0, 224.0}, {271.0, 21.0}}, identifier: 'email', value: ukautomationuser@e...
                  Cell, 0x600000d9dea0, {{0.0, 258.7}, {375.0, 71.0}}
                    TextField, 0x600000d9df80, {{32.0, 295.0}, {271.0, 21.0}}, identifier: 'password', value: Pa55word
                  Cell, 0x600000d9e060, {{0.0, 329.7}, {375.0, 64.0}}
                    Button, 0x600000d9e140, {{0.0, 329.7}, {343.0, 48.0}}, identifier: 'loginButton', label: 'Log in'
                    Other, 0x600000d9e220, {{0.0, 329.7}, {375.0, 64.0}}
                      Other, 0x600000d9e300, {{16.0, 337.7}, {343.0, 48.0}}
                        Other, 0x600000d9e3e0, {{16.0, 337.7}, {343.0, 48.0}}
                          Button, 0x600000d9e4c0, {{16.0, 337.7}, {343.0, 48.0}}, identifier: 'loginButton', label: 'Log in'

```

For our test scenario we need to located 3 elements each to have there own function, Two to enter text and one to be pressed. We already defined these functions, with two taking a String as a parameter. 

#### Find Element

Before beginning a more detail explanation of find element is [here](https://github.com/Babylonpartners/ios-playbook/blob/030750054285d8a21b562019053b40dbe56fc47e/Cookbook/Technical-Documents/AutomationIdentifiers.md#how-to-find-elements). But for the purpose of this article we are trying to find the element as fast and simply as possible. To begin with we define a base query, which will reduce the search time. Looking at the view we can the *XCUIElement* is contained within a cell, which is within a table. So we use the base query `app.tables.cells`.

Once you have the base query now you need an accessibility identifier, we store these as private enums in the screen object. 

``` swift
    fileprivate enum TextFields {
        static let email = "Email"
        static let password = "Password"
    }
```

Then we search for the specific *XCUIElement*, the most common and readable method is `app.tables.cells.textFields[TextFields.email]` which will find the XCUIElement, but has potential drawbacks. The framework will search the entire view hierarchy for matches and throw an exception if multiple matches are found. The exception makes sense as the return type is a `XCUIElement` and not a `XCUIElementQuery` it does mean the framework will spend time searching the entire view. The best way to mitigate this having a details base query.

The alternate solution is to write a `XCUIElementQuery` combined with `.firstMatch` This will work the same as the previous code, but while it is slightly less readable it will find the first match and stops traversing the accessibility hierarchy as soon as it finds a matching element. `app.tables.buttons.matching(identifier: Buttons.logInButton).firstMatch` 

In conclusion both methods are workable and reliable, the drawbacks mentioned in the first solution can be for the most part ignored as the complexity of the accessibility hierarchy is generally not the level that would have a noticeable performance impact. And because of the exception, it will encourage developers to assign identifiers to a single element, except where required, and in those cases a `XCUIElementQuery` without `.firstMatch` should be used. 

The most important optimisation I would like to stress is the base query, match it as detailed as you can without compromising reliability. For example using `app.tables.cells.textFields` instead of `app.textFields`

The one exception is **Bento** which has a habit of duplicating elements in the accessibility hierarchy, for example the `loginButton` in the hierarchy above appears twice. For this case I would use `XCUIElementQuery` with `.firstMatch`

#### Interact with Element

## API Interface
Detail how we use API's
# Test Scheme

Maybe explain the test scheme and environments

# Writing your Tests

The first stage is to write your `test scenario` which will either need to be added to an existing feature file or a new one created. Feature files follow the naming convention `feature``sub-feature` Feature.swift 


# How and when do we run UI tests




