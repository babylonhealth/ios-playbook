# Bento and Compositional Layout
## Motivation
To address the increasing layout complexities of our UI designs, Bento is in the process of being extended to support iOS 13 style compositional layout in your familiar declarative Bento syntax.
## Overview
With the introduction of compositional layout, you would work with these two entities:
* `RenderableViewController`  to host the Bento component as a UIKit view controller, and mediate between your view model, your renderer and the UIKit view layer.
* `UI.Collection` for efficiently laying out your component tree in a scrollable canvas.
### Getting started
The simplest way to start using compositional layout is using `UI.Collection` as if you are writing a `BoxRenderer` for the Bento table view.
```swift
import Bento

extension HomeRenderer: Renderer {
	func render(_ state: HomeViewModel.State) -> AnyRenderable {
		return UI.Collection(
			sections: renderSections(state)
		).asAnyRenderable()
	}

	private func renderSections(_ state: HomeViewModel.State) -> [Section<SectionID, ItemID>] {
		// Just like your conventional `BoxRenderer`.
		// ...
	}
}
```
`UI.Collection` by default uses compositional layout, and behaves like a `UITableView` with items spanning the whole container width being laid out along the vertical axis. The default behavior is also known as the _linear_ section layout hint, which would be mentioned below.

### Per-section layout hints
#### Linear
wip
#### Grid 
wip
### Per-section orthogonal scrolling behaviour 
wip
## Backing implementation
We use a fork of [IBPCollectionViewCompositionalLayout](https://github.com/kishikawakatsumi/IBPCollectionViewCompositionalLayout), written by Kishikawa Katsumi, @kishikawakatsumi. The following customisations were made:
* Self sizing through the UICollectionView in-built _preferred attributes_ mechanism.
* Rebuild the core layout logic to preserve the hierarchical layout structure for self sizing correctness.

Here are also customisations being planned (priority from top to bottom):
* Stop proxying to iOS 13 `UICollectionViewCompositionalLayout`.
* Content vertical alignment control: top and center.
* View hierarchy optimization for orthogonal scrolling.
* Advanced alignment controls for the Chat experience.
* Flow layout option on `IBPNSCollectionLayoutSection`.
