/// The `@Stub` macro generates a test spy class for the protocol to which it is attached.
/// A spy is a type of test double that observes and records interactions for later verification in your tests.
///
/// The `@Stub` macro simplifies the task of writing test spies manually. It automatically generates a new
/// class (the spy) that implements the given protocol. It tracks and exposes information about how the protocol's
/// methods and properties were used, providing valuable insight for test assertions.
///
/// Usage:
/// ```swift
/// @Stub
/// protocol Service {
///     var data: Data { get }
///     func fetchData(id: String) -> Data
/// }
/// ```
///
/// This example would generate a spy class named `StubServiceProtocol` that implements `ServiceProtocol`.
/// The generated class includes properties and methods for tracking the number of method calls, the arguments
/// passed, whether the method was called, and so on.
///
/// Example of generated code:
/// ```swift
/// class StubService: Service {
///     static var shared = StubService() 
///     var data: Data {
///         get { stubbedData }
///         set { stubbedData = newValue }
///     }
///     var stubbedData: Data!
///
///     var fetchDataIdCallsCount = 0
///     var fetchDataIdCalled: Bool {
///         return fetchDataIdCallsCount > 0
///     }
///     var fetchDataIdReceivedArguments: String?
///     var fetchDataIdReceivedInvocations: [String] = []
///     var stubbedFetchData: Data!
///     var fetchDataIdClosure: ((String) -> Data)?
///
///     func fetchData(id: String) -> Data {
///         fetchDataIdCallsCount += 1
///         fetchDataIdReceivedArguments = id
///         fetchDataIdReceivedInvocations.append(id)
///         if fetchDataIdClosure != nil {
///             return fetchDataIdClosure!(id)
///         } else {
///             return stubbedFetchData
///         }
///     }
/// }
/// ```
/// - Parameter behindPreprocessorFlag: This defaults to nil, and can be optionally supplied to wrap the generated code in a preprocessor flag like `#if DEBUG`.
///
/// - NOTE: The `@Stub` macro should only be applied to protocols. Applying it to other
///         declarations will result in an error.
@attached(peer, names: suffixed(Stub))
public macro Stub(behindPreprocessorFlag: String? = nil) =
  #externalMacro(
    module: "StubMacro",
    type: "StubMacro"
  )
