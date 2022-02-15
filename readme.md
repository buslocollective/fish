# fish

Create Swift applications faster using opinionated set of rules.

> Documentation coming soon!

## Quick start

```swift
import fish
import UIKit

@UIViewTree func MyView() -> UIViewTree.Result {
  UIView {
    UILabel()
      .withModifier {
          $0.text = "Hello world!"
      }
  }
}
```
