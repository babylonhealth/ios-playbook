# Automation Locater Updates
## Updating how Screen Elements are located

One of the challenges/maintenance activities we face with our UI tests is that the majority of elements do not have a "accessibilityIdentifier" defined and the value of the element was used. This made the tests more fragile to changes in copy and require a corresponding update to the automation. 

This page covers why this happens and how we can improve the testing moving forward.

## How to Find Elements
Normally we need to update how elements are located because the text has changed either from phrase app, a back end response or change in design.

The most efficient way to locate a *XCUIElement* on screen is to use accessibility combined with a query. The framework supports among other methods accessibility labels and accessibility identifiers. We should avoid using accessibility labels because these are used by voice over, localized and can be accessed by external tools. Accessibility identifier's are developer-facing, not localized and is the recommended method from Apple.

### Locating Elements
Identification of *XCUIElements* in automation code should be done in the screen objects and screen object should not reference each other. If interacting with an element is handled elsewhere this is probably a bug. Though in some cases the identifiers are injected at run time, this has been used in content driven screens i.e. promo code details.

#### Identifiers
The identifiers themselves are passed to the framework as a string and defined in a file using a private enum or injected into the constructor. As you can see from the example below, we have used both accessibility identifiers and the text within the element to locate XCUIElement's.

##### Chatbot Bento Screen
```sh
    fileprivate enum Others {
        static let ctaInput = "inputContentbarCTAInputView"
        static let textInput = "inputContentInputBarView"
        static let imageInput = "inputContentPhotosAccessoryView"
        static let outgoingImage = "outgoingImage"
        static let outgoingText = "outgoingText"
        static let assessment = "incomingOutcomeAssessment"
        static let miniMap = "outgoingMiniMap"
    }

    fileprivate enum StaticTexts {
        static let callSamaritans = "Are you sure you want to call Samaritans?"
        static let callSupport = "Are you sure you want to call support?"
        static let leafletOne = "NHS Choices"
        static let leafletTwo = "NHSChoices"
        static let summary = "View information about possible causes for your symptoms."
        static let assessment = "View Assessment"
        static let rate = "Rate answer"
    }
```

#### Queries
The other way to find a element is using a *XCUIElementQuery* which can either make use of a identifier or not. The key difference is that a query requires detailed knowledge of the screen layout and is more commonly used when multi *XCUIElement* with the same identifier are displayed on the screens i.e. the address list.

##### Examples
- ```sh let element = app.navigationBars[NavigationBars.pageHeader] ``` Returns a single **XCUIElement** or throws a error if there are multiple matches
- `let queryWithIdentifier = app.navigationBars.matching(identifier: NavigationBars.pageHeader)` Returns a **XCUIElementQuery** array with multiple **XCUIElement**
- ```sh let queryWithOutIdentifier = app.navigationBars ``` Returns a **XCUIElementQuery** array with all .navigationBars on screen
- ```sh let queryWithSingleResult  = app.navigationBars.firsrMatch ``` Returns the first **XCUIElment** matching the **XCUIElementQuery**  & is the only method that stops searching on the forstMatch, while the other methods will search the entire view hierarchy.

## Updating Locator's

The quick solution is to simply update the enum. When an identifier's text has changed, this is very straight forward and simple. Update the text defined in the enum to the correct value and automation should start working. Resulting in Pull Requests like this https://github.com/Babylonpartners/babylon-ios/pull/6475

```sh
	fileprivate enum NavigationBar {
			static let header = "Privacy policy"
			- static let telus = "Babylon by TELUS Health Privacy Policy"
			+ static let telus = "Privacy Policy"
	 }
```

While this will fix the test, it is susceptible to future changes. In this case time permitting, we should attempt to define a accessibilityIdentifier for the element and then update the enum to use this identifier. This is not always possible as is the case with chat responses, but it is something we should strive for in order to make our testings more stable. And at the same time reducing the amount of updates needed in the future.

#### Updating Queries

The most common root cause is that the **XCUIElementQuery** requires a update. The thing we need to consider is that the performance of the framework is effected by how much of the view hierarchy is searched when looking for an element. This is because the framework will by default search the entire view hierarchy. This is time consuming, the recommended solution is to give the query as much information as possible. For example, below, we are telling the framework that the the button is within an alert, this improves the performance of the test.

    `let okButton = app.alerts.buttons[Buttons.okButton]`

But comes at the cost, that if the layout changes, the query itself, not the identifier can be broken. In this case the query will need to be updated, to reflect the change, i.e. if the buttons moves from the alert to table. Then the query should be updated to:

    `let okButton = app.tables.buttons[Buttons.okButton]`

This will fix the issue, while not changing the identifier itself.

#### Accessibility Identifier Naming

This is something that tends to be subjective. But in general I would recommend using the naming convention used in ChatBot Bento, which has worked well. The key requirement is that identifier should be unique to each screen, except when used in a dynamic list i.e an address list. Also if the element itself can be present on multiple screens we should also include a reference to the screen in the name.

For example in the registration screen I would recommend the following for the "Lets go" button as it is both unique to the screen and application.
- **"letsGo"**

However for the first name field as this is present in multiple screens I would use:
- **"registerFirstName"**
