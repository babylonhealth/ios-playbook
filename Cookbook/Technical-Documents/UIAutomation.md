# UI Automation with XCTest & Gherkin
As part of our UI automation we utilize the open source Gherkin framework [Links with title](https://github.com/net-a-porter-mobile/XCTest-Gherkin "XCTest-Gherkin") to make the test cases more readable and use the screen object model to improve maintainability of the test code.

## Step Definitions
In order to support the Gherkin syntax, communally referred to as cucumber, we use XCTest-Gherkin. This allows test scenarios to be written in a human readable language which can match the description in TestRail. Gherkin uses a set of keywords to give structure and meaning to executable step definitions. When defining these step definition we use a naming convention.

## Naming Convention
Step definitions are broken down into a number of key actions, each with their own naming convention.Though not all our steps have been updated to this convention.

### User Actions
For user actions we use the prefix "I" do something, for example
```javascript
step("I consent to switching NHS GP")
step("I click done on appointment confirmation screen")
step("I tap on the child account holder")
```

### System State or Responses
In order to check a state in the application or if the application has completed a action we use "the"
```javascript
step("the Prescription screen with delivery address is displayed")
step("the Settings screen is displayed")
step("the user is returned to the home screen")
```

### Non User Actions
This is intended as a catch all for "mocked" or "simulated" or "API" call, these normally begin with "a" but not always. These are normally part of the Given component of the test scenarios in order to speed up tests.
```javascript
step("a registered verified user logs in with \"(.*?)\" credentials")
step("a GP is added to the child family member")
step("verify user in the background")
```
