# Creating custom property and layout definition constructs
Use ``PropertyConfigurator`` or ``LayoutConfigurator`` to create new propery and layout definition constructs.

## Getting started
Conforming to a ``PropertyConfigurator`` or ``LayoutConfigurator`` allows additional control or convenience in building flow stream items.
This is enabled by defining such configurator construct inside `withLayout` or `withProps`.

To conform to a ``PropertyConfigurator``, define such construct as follows:
```swift
struct MyFlow: Flow { ... }

struct MyCustomProperty<Target: MyFlow>: PropertyConfigurator {
    func apply(_ target: Target) {
        // your custom code
    }
}
```

Similarly for a ``LayoutConfigurator``:
```swift
struct MyFlow: Flow { ... }

struct MyLayout { ... }

struct MyCustomLayout<Target: MyFlow>: PropertyConfigurator {
    func apply(_ target: Target) -> [MyLayout] {
        // layout definitions to be made
    }
}
```

> Tip: To define configuration items for a property or layout construct, use the normal `sturct` instantiation syntax.

> Note: Notice that the `MyFlow` construct is defined as a convenience for locking conformance to a particular flow state configuration. 
The relationship of which will be discussed on _The configurator construct and its relation to `Flow`_.

To use this newly made construct, do the following:
```swift
func block() -> MyItem {
    MyItem()
        .withProps(MyCustomProperty())
        .withLayout(MyCustomLayout())
}
```

> Note: Layout definitions are applied lazily. That is, when a flow stream item is added to a contaning item using `withChildren` or `withProjection`.

## The configurator construct and its relation to Flow
When conforming to a ``PropertyConfigurator`` or ``LayoutConfigurator`` construct, a ``Flow`` constraint is required as this aligns the construct with
its intended flow stream item. This association is used when a flow stream item is being built inside a ``FlowBuilder`` hierarchy.

Flexibility on the ``PropertyConfigurator`` or ``LayoutConfigurator`` construct is granted by defining the `Flow.State` a common ancestor.

An example of this is how ``ViewFlow`` is defined:
```swift
public protocol ViewFlow: Flow where State == ViewFlowState {
    associatedtype View: UIView
    
    var source: View { get }
}
```

Here we see that ViewFlow's `Source` constraint is constrainted to `UIView`, the base class of all UIKit controls. This allows the ``FlowBuilder`` flexibility
in passing disparate `UIView` types without having to check at runtime if a particular flow stream item matches their type are related with each other.

Additionally, defining it this way allows any conformances to ``PropertyConfigurator`` and ``LayoutConfigurator`` to be used by any instances that is inherited
by that common ancestor `Source` type. Conversely, additional constraints can be added to such constructs to limit such access by defining a `where` constraint
definition to a ``PropertyConfigurator`` or ``LayoutConfigurator`` construct.

## Composing multiple configuration objects

A limitation with `withProps` and `withLayout` is that only one concrete conforming type can be accepted. Doing this on a flow stream item will yield an error:
```swift
MyItem()
    .withProps(PropType1(), PropType2()) // error: Cannot convert value of type 'PropType2' to expected argument type 'PropType1'.
```

A solution for this is to do type erasure on all properties defined in the method call. This can be done by adding the `.item` property:
```swift
MyItem()
    .withProps(PropType1().item, PropType2().item) // no errors!
```
