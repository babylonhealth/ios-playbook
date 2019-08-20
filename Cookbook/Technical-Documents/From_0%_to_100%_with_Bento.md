 Outline of "From 0% to 100% screen with Bento"

## Why & when to use Bento?
I'd like to inform the reader as to why developing a screen with Bento will take less time than writing it from scratch.

### Examples from our code
Provide examples of our app & code what screens are written in Bento and link them here as a reference point 

### Bento & SwiftUI
Small explanation on what our team's current approach to adopting SwiftUI looks like. This will be a be a short section saying that Bento will eventually replaced by SwiftUI (in few years perspective).

## How to use BabylonBoxViewController, ViewModel & Renderer
Section when I'd like to describe how to setup a typical RAF module with strong focus on `Renderer` part.
I want this section to be a guide with code samples, line by line, how to write a renderer.

### Keywords in Bento
- What are `Screen`, `Box`, `Section`, `Node`.
- What is a `BabylonBoxViewController`?
- What is `AnyRenderable`
- What Operators can I use?

## How to write a component which is not in Design Library 
**Introduction** to Design Library. Why is it there and how is it related with Bento? How do I find a component I need to use? What to do if I cannot find a component?

## BabylonBoxViewController from scratch (optional)
Note: I'm still thinking if that should be a part of the article.
Rarely, but sometimes, we cannot use `BabylonBoxViewController`. I'd like to guide how a simple implementation of custom ViewController can look like. Maybe, the example would use UICollectionView instead of UITableView which is used by `BabylonBoxViewController`

## Outline notes
- The order of section may change in the article. I'd like to make this article about 1k words long. 
- Naming of sections may be changed in the future (to sound better)
- Sections marked as `(optional)` may be skipped if I find the article gets too big and overwhelming.
- Once it's accepted by @scass91 and @RuiAAPeres I'll change the PR to be "draft" and I'm going to work on the article in this file below the `----`. Before the final merge I'm going to delete the outline.
---- 
# The Article (in progress):
To be added... Stay tuned 😎

In this article I would answer few questions regarding Bento. If you are a new person in the team and you have questions like: "What is Bento?", "Why do we use it?", "How should I use it?", "What's a renderable?". If you've had any of these questions, then the article is for you.

## What and why?
First of all, Bento is our internal library which allows us to write UI code in a declarative way. This makes it faster to write the UI code. 

```plain
Bento now is our internal library however we used to open source it. It has changed when Apple announced SwiftUI at WWDC 2019. We decided to move it under the main repo back then.
```

## Renderer
I assume you are already kind of familiar with our Architecture. Quick recap, a typical screen is built from:
- ViewController
- ViewModel
- Renderer
- Builder
- FlowController

In this article we are going to focus on the renderer. 

Renderer purpose is to calculate a UI. I used the word calculate on purpose as we express our UI as a function of state `UI = f(state)`. The function is named `func render(state: ViewModel.State) -> Screen<SectionId, ItemId>`.

First things first. To create a Renderer you need to create a struct and conforms to `BoxRenderer`. This is what you get from the Xcode's template.

```swift
struct RepeatPrescriptionListRenderer: BoxRenderer {
    private let config: Config
    private let observer: Sink<RepeatPrescriptionListViewModel.Action>

    init(
        observer: @escaping Sink<RepeatPrescriptionListViewModel.Action>,
        appearance: BabylonAppAppearance,
        config: Config
    ) {
        self.config = config
        self.observer = observer
    }

    func render(state: RepeatPrescriptionListViewModel.State) -> Screen<SectionID, NodeID> {
        return Screen(title: "", box: .empty)
    }

    struct Config {
        let bundle: Bundle

        init(bundle: Bundle = .main) {
            self.bundle = bundle
        }
    }
}

extension RepeatPrescriptionListRenderer {
    enum SectionID: Hashable {
        case first
    }

    enum NodeID: Hashable {
        case first
    }
}

```

Your first question might be "What's a Config".The way how `BoxRenderer` is coupled with `BabylonBoxViewController` we cannot pass dependencies as we usually do in the init. Config is a way of injecting dependencies into a renderer.

```plain
 12 Aug 2019 - Renderer has to be a struct as there is a problem with classes & memory management. Classes are not being deallocated. It may be fixed someday but it's still a case when I'm writing this article.
```

Now let's jump into the `render(state:)`. It returns a Screen. This is how it may look a Screen.
```swift
    return Screen(
        title: screenTitle,
				rightBarItems: [faqButton],
				shouldUseSystemSeparators: false,
				box: render(state),
				pinnedToBottomBox: renderBottomButtons(state)
    )
```

With Screen you can modify many behaviour like alignment, whether you want separators or not. If you need to modify something which cannot be represented by a box I encourge you to take a look on the init of the Screen. Variables there pretty self explanatory.

What's the Box then?

`Box` is rendered usually by `UITableView` or `UICollectionView`. Sometimes you may need a way to stick some part of the view to the bottom of a
