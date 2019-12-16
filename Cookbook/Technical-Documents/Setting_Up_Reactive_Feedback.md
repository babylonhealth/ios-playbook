#  Updating State with Reactive Feedback


## Intro

We divide our work into "Features" Which Encapsulate a Screen, State, and a set of interactions that change the state and interact with the rest of the application and the outside world. We affectionally call these "Bento Boxes" (which is the term will we use for the rest of the article). In code this is represented as a 4-Tuple of a Builder, FlowController, ViewModel and Renderer. We will assume some famaliarity of what these are and how they work, if they are new to you or would like a refresher please check out [inami article]. There is also [ilya article], which is an excellent walkthrough of building an entire feature within a BentoBox. This article will focus on how we use `Feedback`s to update our system and interact with the outside world. To do this we'll build a (contrived) feature with a BentoBox that should hopefully touch on all the ways we handle input and output of the system. 

## How we use RAF

Let's Add a new bento box from our xcode template [commit hash] [link to templates and install instructions]. This will give us all the boilerplate we need to get started. We'll also update the Actions, State and Reducer, so that we can represent some change in our system [sha] and we'll update the renderer with a label to show us the state and a button to update it. [sha]. For more on how to use Bento to build a renderer see [bento link].

### Interacting with the UI

With our bento box set up we have a well established way to update the UI via our Renderer. But what about getting input?. As it turns out we're already set up for that too!

You'll notice from our initial template we have `Feedback.input` already added as a feedback, and also VM.send is hooked up to use this. So what this means is if you start off using our template, you need to do _nothing_ to make user actions from the renderer, get fed into our viewmodel sytem. Great 😄. To understand a little more how this works, check out how the `Builder` sets up a `BoxRenderer`. For now let's look at how we manage other side effects.

### Interacting with the outside world

The next most common thing we do is interact with external services. This is often the network but can any non deterministic part of the system from bluetooth to a random number generator. 

Let's add update our bento box so we have can represent some new states and can receive some new events [sha]. The model is now (slightly) more sophisticated but we can now start to see how this could mirror a typical feature.

Now let's implememt another feedback which will communicate with the outside world. We'll use this `NumberGeneratorService` which provides us with a signal generator for a number, which takes another number as input.

[Code snippits]

A lot of the side effects we manage day to day will have this kind of form. We'll have some `Service`, an api client for examplem that provides an interface that returns a signal producer for some `Entity`. Often in the form of `Result<Entity,Error>`. Very often there will be an `Event` which represents an update with the returned entity as well as one that represents an error. 

Since this represents so many of our interactions, lets look explore it further to generalise a bit more.

#### How to think about `Feedback`s

Conceptually Feedback is of the form `(Signal<State>) -> Signal<Event>`. Or "Whenever we get a particular state, do we need to interact with something outside the system? And will it produce further input?" So as in the example we've just seen. I get a `.loading` state so we start fetching our number from the service.

#### Common Patterns / Practises

- All dependencies are injected when creating the feedback. Often we'll see that the depency requires parameters that are part of the `state` we receive.
- If it needs to run only when the state matches a certain pattern, We can use a particular initialiser `Feedback(predicate:...`  [link to example in our codebase]
- If we care about a particular subset of the `State`, we have `Feedback(lensing:...` [link to example in our codebase]
- If we don't care about the state at all and use something else an input as with `Feedback.input`.
- Naming - if possible we can communicate when this Feedback invokes a side effect for example `whenLoading`
- Created using `static` functions, which allows us to create / test / mock them independantly.
- If we don't intend to return any event. In this case `Signal<Event>` can very easily model zero values i.e using `.empty` [link to PR switching mood detail analytics to Feedback]


### Interacting with _other_ Bento Boxes / features

While not part of a ReactiveFeedback system directly, routes still represent another necessary part of the business logic which is navigating in/out of different screens / Bento Boxes. Routes and FlowControllers are our way of doing this. 

By convention we communicate how we want to interact with the system outside of our screen via an `Intent`. This means we can explicitely enumerate the ways in which we want to interact with other Bento Boxes. [One more reference to inami article]

[Code Snippet]


## Further Reading

- Bento 0 - 100
- Architecture Overview
- Ilya Feedback article
- Moore Machine
