# Mocking Guidelines

Mocks are a valuable tool to have in your toolbox for writing effective tests as they help you test the behaviour of a single unit while stubbing the implementation of all other public methods.

Unfortunately, as Swift does not have mocking and we are aiming for a cross-platform project, we decided to manually mock and stub parts of the code as required. This document is designed to outline the process for stubbing and mocking to ensure that we maintain a consistent style. A consistent style will help us find and make appropriate changes if we change interfaces or even just add new classes.

## Design Considerations

When using mocks, we need to fundamentally change the design of our application in order to mock. The most important of these is *dependency injection*. Rather than having a single global singleton instance, we should initialise dependencies that we need globally at the start of the program and pass these around as state. This way we can initialise objects in tests with a simulated environment to interrogate only the behaviour of that unit. In addition, static methods should not be used as they cannot be stubbed.

When you encounter a piece of old code that you wish to test, you are strongly encouraged to convert it to use a dependency injection style. Dependency injection works best when used globally.

Again, other languages that are prevalent in industry make dependency injection easy because they support mocking. This is not the case in Swift and therefore we have to again roll our own. With dependency injection, please try to keep down the number of dependencies required in a unit. If you have a large number of dependencies, your unit is probably too big.

## Organisation

Flint is organised into modules, which make testing the entire compiler slightly easier as there is already a separation of responsibilities and a sense of modularity.

We propose the following rules:
1. Each module has its own test package.
2. Each unit should have its own test file.

## Making things work

Because XCTest is not natively supported on Linux, please make sure you modify:
1. the global `Tests/LinuxMain.swift` file *if adding a new module*,
2. a module's `XCTestManifests.swift` file *if adding a new unit*,
3. a unit's `allTests` property *if adding a new test case*.

## Pattern

