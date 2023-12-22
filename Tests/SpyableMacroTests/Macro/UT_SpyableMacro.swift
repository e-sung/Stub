import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import StubMacro

final class UT_SpyableMacro: XCTestCase {
  private let sut = ["Stub": StubMacro.self]

  func testMacro() {
    let protocolDeclaration = """
      public protocol ServiceProtocol {
          var name: String {
              get
          }
          var anyProtocol: any Codable {
              get
              set
          }
          var secondName: String? {
              get
          }
          var added: () -> Void {
              get
              set
          }
          var removed: (() -> Void)? {
              get
              set
          }

          mutating func logout()
          func initialize(name: String, secondName: String?)
          func fetchConfig() async throws -> [String: String]
          func fetchData(_ name: (String, count: Int)) async -> (() -> Void)
      }
      """

    assertMacroExpansion(
      """
      @Stub
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class StubServiceProtocol: ServiceProtocol {
            static var shared = StubServiceProtocol()
            var name: String {
                get {
                    stubbedName
                }
                set {
                    stubbedName = newValue
                }
            }
            var stubbedName: (String)!
            var anyProtocol: any Codable {
                get {
                    stubbedAnyProtocol
                }
                set {
                    stubbedAnyProtocol = newValue
                }
            }
            var stubbedAnyProtocol: (any Codable)!
                var secondName: String?
            var added: () -> Void {
                get {
                    stubbedAdded
                }
                set {
                    stubbedAdded = newValue
                }
            }
            var stubbedAdded: (() -> Void)!
                var removed: (() -> Void)?
            var logoutCallsCount = 0
            var logoutCalled: Bool {
                return logoutCallsCount > 0
            }
            var logoutClosure: (() -> Void)?
            func logout() {
                logoutCallsCount += 1
                logoutClosure?()
            }
            var initializeNameSecondNameCallsCount = 0
            var initializeNameSecondNameCalled: Bool {
                return initializeNameSecondNameCallsCount > 0
            }
            var initializeNameSecondNameReceivedArguments: (name: String, secondName: String?)?
            var initializeNameSecondNameReceivedInvocations: [(name: String, secondName: String?)] = []
            var initializeNameSecondNameClosure: ((String, String?) -> Void)?
                func initialize(name: String, secondName: String?) {
                initializeNameSecondNameCallsCount += 1
                initializeNameSecondNameReceivedArguments = (name, secondName)
                initializeNameSecondNameReceivedInvocations.append((name, secondName))
                initializeNameSecondNameClosure?(name, secondName)
            }
            var fetchConfigCallsCount = 0
            var fetchConfigCalled: Bool {
                return fetchConfigCallsCount > 0
            }
            var fetchConfigThrowableError: (any Error)?
            var stubbedFetchConfigResult: [String: String]!
            var fetchConfigClosure: (() async throws -> [String: String])?
                func fetchConfig() async throws -> [String: String] {
                fetchConfigCallsCount += 1
                if let fetchConfigThrowableError {
                    throw fetchConfigThrowableError
                }
                if fetchConfigClosure != nil {
                    return try await fetchConfigClosure!()
                } else {
                    return stubbedFetchConfigResult
                }
            }
            var fetchDataCallsCount = 0
            var fetchDataCalled: Bool {
                return fetchDataCallsCount > 0
            }
            var fetchDataReceivedName: (String, count: Int)?
            var fetchDataReceivedInvocations: [(String, count: Int)] = []
            var stubbedFetchDataResult: (() -> Void)!
            var fetchDataClosure: (((String, count: Int)) async -> (() -> Void))?
                func fetchData(_ name: (String, count: Int)) async -> (() -> Void) {
                fetchDataCallsCount += 1
                fetchDataReceivedName = (name)
                fetchDataReceivedInvocations.append((name))
                if fetchDataClosure != nil {
                    return await fetchDataClosure!(name)
                } else {
                    return stubbedFetchDataResult
                }
            }
        }
        """,
      macros: sut
    )
  }
}
