# Stub

> This is a fork project of [swift-spyable](https://github.com/Matejkob/swift-spyable) to use same functionality, but with different interface names, only to support backward compatibility of my existing project

A powerful tool for Swift that simplifies and automates the process of creating spies
for testing. Using the `@Stub` annotation on a protocol, the macro generates
a stub class that implements the same interface as the protocol and keeps track of 
interactions with its methods and properties.

## Overview

A "stub" is a specific type of test double that not only replaces a real component, but also 
records all interactions for later inspection. It's particularly useful in behavior verification,
where the interaction between objects, rather than the state, is the subject of the test.

The Stub macro is designed to simplify and enhance the usage of spies in Swift testing. 
Traditionally, developers would need to manually create spies for each protocol in  their
codebase — a tedious and error-prone task. The Stub macro revolutionizes this process
by automatically generating these spies.

When a protocol is annotated with `@Stub`, the macro generates a corresponding stub class that 
implement this protocol. This stub class is capable of tracking all interactions with its methods
and properties. It records method invocations, their arguments, and returned values, providing 
a comprehensive log of interactions that occurred during the test. This data can then be used 
to make precise assertions about the behavior of the system under test.

**TL;DR**

The Stub macro provides the following functionality: 
- **Automatic Stub Generation**: No need to manually create stub classes for each protocol.
  Just annotate the protocol with `@Stub`, and let the macro do the rest.
- **Interaction Tracking**: The generated stub records method calls, arguments, and return
  values, making it easy to verify behavior in your tests.
- **Swift Syntax**: The macro uses Swift syntax, providing a seamless and familiar experience
  for Swift developers.

## Quick start

To get started, import Stub: `import Stub`, annotate your protocol with `@Stub`:

```swift
@Stub
protocol ServiceProtocol {
    var name: String { get }
    func fetchConfig(arg: UInt8) async throws -> [String: String]
}
```

This will generate a stub class named `StubServiceProtocol` that implements `ServiceProtocol`.
The generated class includes properties and methods for tracking the number of method calls,
the arguments passed, and whether the method was called.

```swift
class StubServiceProtocol: ServiceProtocol {
    var name: String {
        get { stubbedName }
        set { stubbedName = newValue }
    }
    var stubbedName: (String)!
    
    var fetchConfigArgCallsCount = 0
    var fetchConfigArgCalled: Bool {
        return fetchConfigArgCallsCount > 0
    }
    var fetchConfigArgReceivedArg: UInt8?
    var fetchConfigArgReceivedInvocations: [UInt8] = []
    var stubbedFetchConfigArg: [String: String]!
    var fetchConfigArgClosure: ((UInt8) async throws -> [String: String])?

    func fetchConfig(arg: UInt8) async throws -> [String: String] {
        fetchConfigArgCallsCount += 1
        fetchConfigArgReceivedArg = (arg)
        fetchConfigArgReceivedInvocations.append((arg))
        if fetchConfigArgClosure != nil {
            return try await fetchConfigArgClosure!(arg)
        } else {
            return stubbedFetchConfigArg
        }
    }
}
```

Then, in your tests, you can use the stub to verify that your code is interacting
with the `service` dependency of type `ServiceProtocol` correctly:

```swift
func testFetchConfig() async throws {
    let stubService = StubServiceProtocol()
    let sut = ViewModel(service: stubService)

    stubService.stubbedFetchConfigArg = ["key": "value"]

    try await sut.fetchConfig()

    XCTAssertEqual(stubService.fetchConfigArgCallsCount, 1)
    XCTAssertEqual(stubService.fetchConfigArgReceivedInvocations, [1])

    try await sut.saveConfig()

    XCTAssertEqual(stubService.fetchConfigArgCallsCount, 2)
    XCTAssertEqual(stubService.fetchConfigArgReceivedInvocations, [1, 1])
}
```
