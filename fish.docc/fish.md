# ``fish``
Create Swift applications faster using opinionated set of rules.

## Overview
Fish has three main areas in defining different parts of an application:
- View construction by utilising type-safe constructs and result builders.
- Consistent application architecture by separating view and data definitions.
- Simplified network interaction model.

### Extensibility
Different parts of Fish can be extended to support use cases not included by default:
- Bringing your own reactive library.
- <doc:extending-prop-layout>.
- <doc:extending-flow-constructs>.

### Compatibility
Fish is compatible with Swift 5.4 onwards. There is no minimum platform requirement (except for brought-in dependencies).

## Topics

### Core Contracts
These are the contract types that Fish relies on its operation.

- ``ComponentContract``
- ``ComponentAssignableContract``

### View Construction
View construction is mainly done by creating **flow streams**.

A flow stream is a concept that in its most simple definition is an instance being modified functionally and is chained onto one another.

- ``Flow``
- ``FlowState``
- ``FlowBuilder``
- ``Flows``
- <doc:extending-flow-constructs>

### View Construction Customisation
Defining contracts for creating property and layout definition constructs. 

- ``PropertyConfigurator``
- ``PropItem``

- ``LayoutConfigurator``
- ``LayoutItem``

- <doc:extending-prop-layout>

### View Construction for UIKit
UIKit-specific ``Flow`` and ``FlowState`` specializations.

- ``ViewFlow``
- ``ViewFlowState``
- ``ViewSource``
- <doc:uikit-considerations>
