# Bento Component Composition Using `UIStackView`

#### Updated at: 23-3-2019

## The scope of this document 
Component Composition with `Bento` is a very wide topic due to its flexible design.
`Bento` components can be composed in many ways.

The purpose of this document is to provide documentation for __composing Bento components using `UIStackView`__.
Other ways of composition are out of the scope of this document.

## How to use component composition in your framework

Well, the answer to this question is that your can't.
The reasoning for this decision is that
* we must reuse components via the `DesignLibrary`
* If you need something custom and customizable then using `UIStackView`s probably won't be good enough for you
* We need to be flexible and to depend on abstractions.

#### Where and how to use component composition
In `BabylonUI` there is a new namespace called `UI` which is the place for `Atomic Components`.

- `Atomic Components` are the `Bento` Components version of `UIKit`'s components so the nomenclature is similar  like `UILabel` and `UI.Label`, `UIButton` and `UI.Button` etc 
- `Atomic Components` use `Stylesheets` for styling
- `Atomic Components` should behave like their `UIKit` counterpart.

## Code Sample

```swift
[
    UI.Label(
      text: "Some Title",
      styleSheet: LabelStyleSheet()
          .compose(\.textColor, tokens.colors.black)
          .compose(\.font, font(fontAttributes: tokens.typography.body))
    ).asAnyRenderable(),
    UI.Label(
        text: "Some Details",
        styleSheet: LabelStyleSheet()
            .compose(\.textColor, tokens.colors.grey700)
            .compose(\.font, font(fontAttributes: tokens.typography.subhead))
    ).asAnyRenderable()
]
.stack(
    axis: .vertical,
    spacing: 2
)
```

Currently `Renderable` provides some util methods like `card(..)`, `stack(...)`, `width(...)` and `height(...)`.
You can also add new convenience methods if you need them. 

## `UIStackView` based component composition depends on Auto Layout

When you compose `Bento` components using `UIStackView` __there is an implicit behaviour change on how you create your UI__.

So let's start with how it works

| Atomic Components using UIStackView | BentoKit | Vanilla Bento |
|:-------:|:------:|:------:|
| <ul><li> Step 1: Compose your components like in the code sample. This step means that you use Auto Layout. </li><li> Step 2: render your `Box` </li> <li>Step 3: `UITableView`/`UICollectionView` use Auto Layout in order to calculate the size of the cell.</li></ul> | Step 1: Implement your components using Auto Layout. </li> <li> Step2: Implement `HeightCustomizing` and calculate the size of the component. <li> Step 3: render your `Box` </li> <li>Step 4: `UITableView`/`UICollectionView` use Auto Layout in order to calculate the size of the cell __if the component doesn't comfort to `HeightCustomizing` othewise it uses the provided value__.</li></ul>  |  <li>Step 1: Implement your components *and* use Auto Layout. </li><li> Step 2: render your `Box` </li> <li>Step 3: `UITableView`/`UICollectionView` use Auto Layout in order to calculate the size of the cell.</li></ul>  |

With `UIStackView` based composition we can have truly self sizing cells but this means that its incompatible with `BentoKit`, because `BentoKit` doesn't really provides self sizing cells. `BentoKit` is using Auto Layout but it also provides the size of the component via `HeightCustomizing`.
In order to make a `BentoKit` component compatible with `UIStackView` based composition you either have to drop `HeightCustomzing` or you should use `UIView.systemLayoutSizeFitting` in your `HeightCustomzing` implementation.