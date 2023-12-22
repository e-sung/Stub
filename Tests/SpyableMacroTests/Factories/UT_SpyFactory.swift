import SwiftSyntax
import SwiftSyntaxBuilder
import XCTest

@testable import StubMacro

final class UT_StubFactory: XCTestCase {
  func testDeclarationEmptyProtocol() throws {
    let declaration = DeclSyntax(
      """
      protocol Foo {}
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try StubFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class StubFoo: Foo {
          static var shared = StubFoo()
      }
      """
    )
  }

  func testDeclaration() throws {
    let declaration = DeclSyntax(
      """
      protocol Service {
      func fetch()
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try StubFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class StubService: Service {
          static var shared = StubService()
          var fetchCallsCount = 0
          var fetchCalled: Bool {
              return fetchCallsCount > 0
          }
          var fetchClosure: (() -> Void)?
          func fetch() {
              fetchCallsCount += 1
              fetchClosure?()
          }
      }
      """
    )
  }

  func testDeclarationArguments() throws {
    let declaration = DeclSyntax(
      """
      protocol ViewModelProtocol {
      func foo(text: String, count: Int)
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try StubFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class StubViewModelProtocol: ViewModelProtocol {
          static var shared = StubViewModelProtocol()
          var fooTextCountCallsCount = 0
          var fooTextCountCalled: Bool {
              return fooTextCountCallsCount > 0
          }
          var fooTextCountReceivedArguments: (text: String, count: Int)?
          var fooTextCountReceivedInvocations: [(text: String, count: Int)] = []
          var fooTextCountClosure: ((String, Int) -> Void)?
          func foo(text: String, count: Int) {
              fooTextCountCallsCount += 1
              fooTextCountReceivedArguments = (text, count)
              fooTextCountReceivedInvocations.append((text, count))
              fooTextCountClosure?(text, count)
          }
      }
      """
    )
  }

  func testDeclarationReturnValue() throws {
    let declaration = DeclSyntax(
      """
      protocol Bar {
      func print() -> (text: String, tuple: (count: Int?, Date))
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try StubFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class StubBar: Bar {
          static var shared = StubBar()
          var printCallsCount = 0
          var printCalled: Bool {
              return printCallsCount > 0
          }
          var stubbedPrintResult: (text: String, tuple: (count: Int?, Date))!
          var printClosure: (() -> (text: String, tuple: (count: Int?, Date)))?
          func print() -> (text: String, tuple: (count: Int?, Date)) {
              printCallsCount += 1
              if printClosure != nil {
                  return printClosure!()
              } else {
                  return stubbedPrintResult
              }
          }
      }
      """
    )
  }

  func testDeclarationAsync() throws {
    let declaration = DeclSyntax(
      """
      protocol ServiceProtocol {
      func foo(text: String, count: Int) async -> Decimal
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try StubFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class StubServiceProtocol: ServiceProtocol {
          static var shared = StubServiceProtocol()
          var fooTextCountCallsCount = 0
          var fooTextCountCalled: Bool {
              return fooTextCountCallsCount > 0
          }
          var fooTextCountReceivedArguments: (text: String, count: Int)?
          var fooTextCountReceivedInvocations: [(text: String, count: Int)] = []
          var stubbedFooTextCountResult: Decimal!
          var fooTextCountClosure: ((String, Int) async -> Decimal)?
          func foo(text: String, count: Int) async -> Decimal {
              fooTextCountCallsCount += 1
              fooTextCountReceivedArguments = (text, count)
              fooTextCountReceivedInvocations.append((text, count))
              if fooTextCountClosure != nil {
                  return await fooTextCountClosure!(text, count)
              } else {
                  return stubbedFooTextCountResult
              }
          }
      }
      """
    )
  }

  func testDeclarationThrows() throws {
    let declaration = DeclSyntax(
      """
      protocol ServiceProtocol {
      func foo(_ added: ((text: String) -> Void)?) throws -> (() -> Int)?
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try StubFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class StubServiceProtocol: ServiceProtocol {
          static var shared = StubServiceProtocol()
          var fooCallsCount = 0
          var fooCalled: Bool {
              return fooCallsCount > 0
          }
          var fooReceivedAdded: ((text: String) -> Void)?
          var fooReceivedInvocations: [((text: String) -> Void)?] = []
          var fooThrowableError: (any Error)?
          var stubbedFooResult: (() -> Int)?
          var fooClosure: ((((text: String) -> Void)?) throws -> (() -> Int)?)?
          func foo(_ added: ((text: String) -> Void)?) throws -> (() -> Int)? {
              fooCallsCount += 1
              fooReceivedAdded = (added)
              fooReceivedInvocations.append((added))
              if let fooThrowableError {
                  throw fooThrowableError
              }
              if fooClosure != nil {
                  return try fooClosure!(added)
              } else {
                  return stubbedFooResult
              }
          }
      }
      """
    )
  }

  func testDeclarationVariable() throws {
    let declaration = DeclSyntax(
      """
      protocol ServiceProtocol {
          var data: Data { get }
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try StubFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class StubServiceProtocol: ServiceProtocol {
          static var shared = StubServiceProtocol()
          var data: Data {
              get {
                  stubbedData
              }
              set {
                  stubbedData = newValue
              }
          }
          var stubbedData: (Data)!
      }
      """
    )
  }

  func testDeclarationClosureVariable() throws {
    let declaration = DeclSyntax(
      """
      protocol ServiceProtocol {
          var completion: () -> Void { get set }
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try StubFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class StubServiceProtocol: ServiceProtocol {
          static var shared = StubServiceProtocol()
          var completion: () -> Void {
              get {
                  stubbedCompletion
              }
              set {
                  stubbedCompletion = newValue
              }
          }
          var stubbedCompletion: (() -> Void)!
      }
      """
    )
  }
}
