# Testing Conventions: Automating a UI Flow
# Table of Contents
1. [Why We Automate](#Why-We-Automate)
2. [Test Scenarios](#Test-Scenarios)
3. [Preparation](#Preparation)
4. [Automate a Flow](#Automate-a-Flow)
5. [Test Execution](#Test-Execution)

# Why We Automate
In order to complete a story we need to verify what is delivered. Testing functionality can *normally* be done at multiple levels of test pyramid and nearly always at the UI level. *So the question becomes where do we want to test and why*. As a general rule the lower in the pyramid we test the more efficient and resource inexpensive it is, for example unit, integration or snapshot tests. 

UI testing should be utilised for functionality that *can't be fully covered at other levels* or *verify an end to end flow* or *requires subjective evaluation* i.e. video. For features where UI level testing is required, the next stage is to decide if we should automate, this should be decided with input from the squads QA's and Dev's.

At its heart we automate to facilitate *regular* regression testing and earlier identification of bugs without the overhead of manual testing. This article explains how we automate a UI flow for a iOS application using [XCTest for UI testing](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/09-ui_testing.html).

# Test Scenarios
We need to identify the user flows we want to automate, referred to as Test Scenarios. These are created from the stories acceptance criteria and during discussion between QA and Dev to understand what is being delivered. In some cases Dev will solely define the scenarios. It is by understanding the story and the functionality being delivered that we can determine the best place to test the story and what to cover at the user interface level. Test Scenarios are written in [gherkin](https://cucumber.io/docs/gherkin/) a Business Readable, Domain Specific Language created especially for behaviour descriptions.

# Preparation
## Automation Components
For our project we decided to create an automation framework utilising [Cucumber](https://cucumber.io/docs/cucumber/) and the Page Object Model design pattern, referenced as *Screen Object Model*. This was done in order to make code maintenance and extension easier. This base design has been extended and improved by the team over time. When implementing automation code you need to understand the different automation components, their responsibilities, what frameworks have been used and the overall design.

### Feature Files
These files contain the test scenarios written in [Gherkin](https://cucumber.io/docs/gherkin/). The naming convention for the file itself is `functionality` `sub-functionality` *Feature.swift* i.e. `AppointmentsFamilyFeature.swift`. These files should contain all test scenarios for the specified area in order to facilitate targeted testing of features.

### Step definitions
These files are used to link the human readable Gherkin to user actions, implemented in screen objects. The library selected was [xctest-gherkin](https://github.com/net-a-porter-mobile/XCTest-Gherkin). The library uses regex to search for the corresponding step and facilitates passing in parameters.

It is at this level where we should be asserting screen states, grouping *cross screen* actions or completing a single action. A detailed naming convention for step definitions is defined [here](https://github.com/Babylonpartners/ios-playbook/blob/master/Cookbook/Technical-Documents/UIAutomation.md).

### Screen Objects
These files are intended to contain all code that controls the user interface, checks the screen state or in limited cases groups *single screen* actions. Functions within a Screen objects should adhere to the single responsibility principle and should **never** reference another screen object.

#### State Checks
Check functions are intended to *evaluate* the screen under tests and return a value. In practise these fall, into three categories but are not limited to these. Code to check if something is displayed, normally returning a Boolean. 

```swift 
func isScreenDisplayed() -> Bool
``` 

We can with well written step definitions pass in a parameter to be evaluated from the feature file. For example passing the **Card** name to verified it is displayed on the *HomeScreen*.

```swift
func isCardDisplayed(for card: HomeScreenCards) -> Bool
``` 

The third type of check the function will retrieve a value, for example how many Pharmacies are displayed. This can then be asserted against a parameter or static value.

```swift 
func pharmaciesCount() -> Int
```

Whatever variable is being returned, should be asserted in the Step Definition and not within the screen object itself.

```swift
XCTAssertTrue(HomeScreen().isScreenDisplayed(), "Home screen icon was not displayed")
```

#### Interface Interactions
Interactions are intended to reproduce user actions on screen, if we look at the login screen we would find the following functions

```swift 
func enterEmail(_ email: String)
func enterPassword()
``` 

Common interactions can also be grouped, so long as they are within the scope of the screen and make logical sense, staying with the login screen we could have: 

```swift 
func enterCredentialsAndLogin(email: String)
```

#### Accessibility identifiers
In order to do anything in automation, we first need to find the **XCUIElement** we want to interact with. The optimal way to do this is using *Accessibility identifiers* though this is not the only way. Identifiers need to defined in code and referenced in automation. 

The way we do this has evolved in the iOS team, rather than having Accessibility identifiers defined in production code and again in the Screen Object, we now access the identifier defined in a **AccessibilityContent** enum in the production code and reference from the automation code. ```AccessibilityContent.SignUp.termsAndConditionsCell``` this ensures identifiers are only defined and read from one location. Though is a work in progress

The historical method for handling identifiers was to define them in code and then define them again in the screen object, normally using a static *enum* for each element type. And then reference the identifier from the functions using ```Cells.passwordField```. This was to ensured *identifiers* are only defined once in each screen object and can be updated with a single change. 

A detailed naming convention for accessibility identifiers can be found [here](https://github.com/Babylonpartners/ios-playbook/blob/master/Cookbook/Technical-Documents/AutomationIdentifiers.md).

### API Calls
When not mocking API calls, we use real API requests to control the state of the application. For example using the client API in the family appointment tests to add family member or the clinical API to prescribe medication. By completing these actions at the API level it removes the requirement to complete them through the UI, reducing execution time, removing duplication and facilitating tests that start in a controlled state. These network requests are normally handled by extending `APIInterface` with functional specific requests for example `APIInterface+Appointment`

In some cases the `APIInterface` will use the **BabylonSDK** to make the network request rather than making it directly from code. This method gives better coverage of Babylon releases and tests integration.

# Automate a Flow
We will now go through a set of truncated steps to automate a UI flow. Below is the example test scenario we intend to add.

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
We need to select the appropriate *feature file* for the test scenario, for this example we will use `LoginFeature.swift` which already contains a number of sign in tests. To begin with copy the test into the feature file updating the scenario to follow the [XCTest-Gherkin](https://github.com/net-a-porter-mobile/XCTest-Gherkin) formatting, otherwise the code will fail to compile. For this example were writing a single test `scenario` though `XCTest-Gherkin` also supports `scenario outlines`.

##### Exception
Please **note** *that if you add a new Feature file, Xcode will automatically add the file to the default scheme causing it to be included in a Unit Test run, you will have to manually exclude it, or your PR will fail*.

## Step Definitions
### Existing Step
First we need to identify if the step already exists, either with the same step name or an alternative. The easiest way is to work backwards from the screen objects. For example `("I tap the login option in the Start up screen")` is interacting with the **StartUpScreen**. Navigate to the screen object and find the `func` that presses login, in this case it's the function **startLoginJourney**, then search for any steps which calls it. This identifies any steps we can use in the test, even though the *text* may differ, if this is the case we'll update the feature file to used the pre-existing step. So long as the action or evaluation is the same we can use this step or if none exist we will create one.

### New Step
We will assume `("I enter credentials for a \"United Kingdom\" user")` does not exist. Identify an appropriate steps file, normally a step files contain a broad series of definitions relating to a functional area of the application, in this case we'll use `LoginSteps.swift` and add the following code.

```swift
        step("I enter credentials for a \"(.*?)\" user") { (user: String) in
            // TODO
        }
```

Before we continue it's worth looking at the documentation for [XCTest-Gherkin](https://github.com/net-a-porter-mobile/XCTest-Gherkin/blob/master/README.md) to understand [how steps definitions work](https://github.com/net-a-porter-mobile/XCTest-Gherkin/blob/master/README.md#step-definitions).

#### Paramaters
In order to make the *step* more robust we can pass in the **country** as a parameter, we need to write a regex capture group and define the data type. This part of the step `\"(.*?)\"` will capture the parameter, We've used `\"` as a method to demote the boundary of the parameter though this is not technically needed to make the code work, but more of a coding style for readability. The Pod's documentation details that up to two parameters can be passed in, but can be both complex or primitive types. Complex types allow us to pass in objects. For this step we will take any value and define it as a `String`. 
 
## Screen Objects
Screen objects are intended to contain all code relating to a screen. Functions will normally fall into three main types as defined [here](#Screen-Objects). Here are some of the interaction functions we need to create for our test.

```swift
    func enterCredentialsFor(_ email: String) { ... }
		...
    }

    private func enterEmail(_ email: String) {
		...
    }

    private func enterPassword() {
		...
    }
    
    func tapLogin() {
		...
    }
```
At the heart of iOS automation is [XCUIElement](https://developer.apple.com/documentation/xctest/xcuielement) and [XCUIElementQuery](https://developer.apple.com/documentation/xctest/xcuielementquery), before we can interact with anything on screen we need to find the element we want to interact with. The first thing to do is put a break point in your *func* and print the view hierarchy in console using `XCUIApplication().debugDescription`. Here is a simplified example.

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

For our test scenario we need to located three elements with each to have there own function, two to enter text and one to press a button. We already defined these functions, with two taking a String as a parameter. 

#### Finding A Element
Before beginning a more detail explanation of find element is [here](https://github.com/Babylonpartners/ios-playbook/blob/030750054285d8a21b562019053b40dbe56fc47e/Cookbook/Technical-Documents/AutomationIdentifiers.md#how-to-find-elements). 

But for the purpose of this article we are trying to find the element as fast and simply as possible. To begin with we define a base query, which will reduces the search time and overhead. Looking at the view we can the *XCUIElement* is contained within a cell, which is within a table. So we use the base query `app.tables.cells`.

Once you have the base query now you need an accessibility identifier, we will store these as private enums in the screen object. Though on new screen we can use the **AccessibilityContent** method.

``` swift
    fileprivate enum TextFields {
        static let email = "Email"
        static let password = "Password"
    }
```

Then we search for the specific *XCUIElement*, the most common and readable method is ```app.tables.cells.textFields[TextFields.email]``` which will find the *XCUIElement*, but has potential drawbacks. The framework will search the entire view hierarchy for matches and throw an exception if multiple matches are found. The exception makes sense as the return type is `XCUIElement` and not `XCUIElementQuery`.

An alternate solution or for cases were you want to find an element and know that there are potentially multiple matches, we would suggest using a `XCUIElementQuery` combined with `.firstMatch`. Giving us alternate code for locating the element, ```app.tables.cells.textFields.matching(identifier: TextFields.email).firstMatch```. One thing to note with `.firstMatch` is that it will stop the query on the first match, making the query technically faster.

Of course if you want to find all elements matching a criteria or Predicate, you can remove `.firstMatch` and get all matches contained within a `XCUIElementQuery`

In conclusion both methods are workable and reliable, the drawbacks mentioned in the initial  code can be for the most part ignored as the complexity of the accessibility hierarchy is generally not at the level that would have a noticeable performance impact. And because of the exception, it will encourage developers to assign identifiers to a single element, except where required, and in those cases a `XCUIElementQuery` without `.firstMatch` should be used. 

The most important *optimisation* you can make in automation is to have a details base query. This makes it easier for the framework to find the *XCUIElement* you are trying to locate without compromising reliability. For example by using `app.tables.cells.textFields` instead of `app.textFields` it gives the framework more detail on the Element it is searching for and will remove the need to search the entire *view hierarchy*. 

This gives us the following code:

```swift
    func enterCredentialsFor(_ email: String) {
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

The one exception is **Bento** which has a habit of duplicating elements in the accessibility hierarchy, for example the `loginButton` in the hierarchy above appears twice. For this case we would use `XCUIElementQuery` with `.firstMatch`. 

#### Interact with Element
Now that we have the element, we can interact with it. We won't repeat what is already included in Apple documentation. We will simply cover the two functions we use in out screen object. For the password and email field we need to enter the text, to do this we use `element.typeText(text)` the problem with this function is that is requires the element to have keyboard focus. You solved this by tapping on the element using `element.tap()` prior to using `typeText`.

Rather than duplicate this code in both functions we have a *helper* function in *BaseScreen.swift*. This helper does a bit more in that it also verifies the state of the button and wait for the desired state up to a specified timeout.

```swift
    func typeInto(element: XCUIElement, withText input: String, andState state: ElementState = .exists, waiting timeout: TimeInterval = 10.0) {
        waitAndTap(element: element, withState: state, waiting: timeout)
        element.typeText(input)
    }
    
    func waitAndTap(element: XCUIElement, withState state: ElementState = .exists, waiting timeout: TimeInterval = 10.0) {
        tryWait(for: element, with: state, timeout: timeout)
        element.tap()
    }
```

For pressing the login button we can either use **waitAndTap** or call **tap** directly, which is slightly faster. The helpers functions are intended to stabilise test execution by checking the state of an element before interacting or proceeding, and while this has worked in making the tests much more reliable, it has a performance impact. We would only recommend using these types of helpers when needed, in this example for pressing the login button we will just use the frameworks API directly.

## API Interface
We created a class **APIInterface.swift** to contain code relating to creating requests, creating and parsing json's. This class is extended with functionality specific extensions to handle request for a particular area **APIInterface+Appointments.swift**. These classes are written in pure Swift and only use *BabylonCore* with no additional Pods. 

### Finishing the Step Definition

Now that were written out API calls and implemented our screen object we can complete out step definition with the following code.

```swift
        step("I enter credentials for a \"(.*?)\" user") { (user: String) in
            let email = self.generateRandomEmail()
            self.registerUser(withEmail: email, forCountry: user)
            
            LoginScreen().enterCredentialsFor(email)
            LoginScreen().tapLogin()            
        }
```

On completion the user will be signed in with a new user created at the API level for the specified country.

# Test Execution
## Test Scheme
In Babylon we decided to run the tests using a **Fastlane** lane and a separate scheme. The scheme created was called **BabylonAppUITests** and will need to be selected before attempting to run any UI tests. However this had the unforeseen impact that when Xcode began to support parallel test execution, **Fastlane** did not. To solve this in the short term multiple lanes were created to allow testing to be completed in parallel. Though we may want to consider using **Fastlane** if they do not fully support Xcode. features. 

## How and when do we run UI tests
Once a new test has been added and if a new feature file was created also added to **UILanes**  the tests will be run nightly as per our CircleCI yml file. Once a lane has been run the results will be published the #ios-build channel for anyone in the team to see, though normally the support engineer and senior Automation Engineer will review the results.

## Running Tests
The `Fastlane` lanes defined in `UILanes` will be run nightly on CircleCI using the **develop** source and **PreProd (AWS)** environment. If you want to run the UI tests for your branch you can use the following command from the **ios-build** channel in slack.

```
/fastlane ui_test_babylon_smoke branch:release/babylon/4.4.0
```

Change `ui_test_babylon_smoke` to the required lane and `release/babylon/4.4.0` to the branch to be tested. As the name of the lanes are regularly changing we would recommend referring to the `UILanes` file in source for a list off the current lanes. This will start the build once resources are available though CircleCI is slower than your local machines. We recommend leaving the full regression run on CircleCI to be run once a night.







