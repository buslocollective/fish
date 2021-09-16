# fish
Create Swift applications faster using opinionated set of rules.

> See the documentation by opening xcode 13 and doing Control + Shift + Command + D.

## Quick start

```swift
import fish
import UIKit

func MyView() -> UIView {
  UIView {
    UILabel().withProps(PropItem(\.text, value: "Hello world!"))
  }
}

```
