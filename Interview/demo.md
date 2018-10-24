<p align="center">
<img src="logo.png">
</p>


babylon iOS interview demo project
==================================

As described in the iOS recruitment process [main page](https://github.com/Babylonpartners/iOS-Interview-Demo/blob/master/README.md), we expect all candidates to submit a demo project, in one of the three formats below. **Only one of these is required**.

1. [The babylon demo project](#1-the-babylon-demo-project).
2. [A project you've already done](#2-already-written-project).
3. [An open source project you've done or contributed to](#3-open-source-work).

**IMPORTANT**: Please note that if you're a candidate interested in working remotely, your demo project **must** use a reactive programming library.

**IMPORTANT**: Please submit your interview demo project as a `.zip`ed archive.

Before proceeding to the section of your choice, please consider the following tips.

### General Advice and Tips

* We like code that is simple, but [simple is different from easy](https://www.infoq.com/presentations/Simple-Made-Easy).
* Keep in mind the [SOLID principles](https://en.wikipedia.org/wiki/SOLID_(object-oriented_design)) when doing the project.
* We left out of the requirements whether or not you should try to download everything (posts + each post detail). This is up to you to decide and to justify.
* Testing is very important for us. Even if you don't write a single test (for instance, because of time constraints), your app should be easy to test (we love [Dependency injection](https://en.wikipedia.org/wiki/Dependency_injection)).
* Error scenarios should be taken into consideration and it should be easy to add them, even if you don't explicitly handle them (e.g. using an `UIAlertController`).
* Although UI and UX are important, we are more concerned in this demo with your thought process and with how you architect your application. Your demo should take into consideration features that might be added in the future.
* You can use any 3rd party libraries you wish (`Alamofire`, `ReactiveCocoa`, `PromiseKit`, `Realm`, etc) but be prepared to justify why you did so. Feel free to use package managers to handle them.
* **Be consistent in your code**. We advise using something like [raywenderlich's swift style guide](https://github.com/raywenderlich/swift-style-guide) while doing the demo. It's absolutly fine to use any other style, as long as you are consistent.
* Clean the file project structure and remove any unused methods (e.g., from `AppDelegate`). This shows attention to detail.
* Be opinionated regarding any architecture you use and take your time to make it a reflection of your thought process.
* We don't have a submission deadline so take your time to polish your project.

### 1. The babylon demo project

From a high level point of view the demo consists of a list of posts, where each post has its own detail.

#### Posts Screen

A post has a title and it's up to you how to display it. To retrieve the posts, you can use the following API:

* http://jsonplaceholder.typicode.com/posts

When a post is tapped, you should go to the detail screen.

#### Detail screen

A post detail screen will have:

* Its author.
* Its description (via the `body`).
* The number of comments it has.

You can retrieve the remaining information from these API:

* http://jsonplaceholder.typicode.com/users
* http://jsonplaceholder.typicode.com/comments

#### Requirements

The following requirements should be met:

* Use Swift 3.0 or above.
* The information (posts and post details) should be available offline. It's assumed that, if it's the first time you are accessing the app and you are offline, you shouldn't see any data.
* The code should be production grade.
* It should compile and run.

### 2. Previously written project

We would be happy if you would submit a project you already have (for instance, a demo project for another company). Still, the project **must**:

* Use Swift 3.0 or above.
* Have at least two distinct network calls.
* Parse the network response and present the information to the user.
* Have some sort of persistence mechanism.
* Compile and run.
* Have a point of synchronization (e.g. making two concurrent requests and waiting for both of them to finish).

If you have a project with these requirements, then perfect! Please ensure that you also have a description of what the project does, in order to give us some context.

Once again, please note that the requirements above are **mandatory**.

### 3. Open Source work

We would like to see a **non-trivial** pull request you have made to a public open source project. This should be something you are proud of and where you show your technical skills. **It should also be related to iOS development** and aligned with what you will do on a day-to-day basis. 😊✨🌳

#### Thanks for your time! We look forward to hearing from you!
- The [babylon health iOS team](http://github.com/Babylonpartners)
