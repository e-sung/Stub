import SwiftSyntax
import XCTest

@testable import StubMacro

final class UT_VariablesImplementationFactory: XCTestCase {
  func testVariablesDeclarations() throws {
    let declaration = DeclSyntax("var point: (x: Int, y: Int?, (Int, Int)) { get }")

    let protocolVariableDeclaration = try XCTUnwrap(VariableDeclSyntax(declaration))

    let result = try VariablesImplementationFactory().variablesDeclarations(
      protocolVariableDeclaration: protocolVariableDeclaration
    )

    assertBuildResult(
      result,
      """
      var point: (x: Int, y: Int?, (Int, Int)) {
          get {
              stubbedPoint
          }
          set {
              stubbedPoint = newValue
          }
      }
      var stubbedPoint: ((x: Int, y: Int?, (Int, Int)))!
      """
    )
  }

  func testVariablesDeclarationsOptional() throws {
    let declaration = DeclSyntax("var foo: String? { get }")

    let protocolVariableDeclaration = try XCTUnwrap(VariableDeclSyntax(declaration))

    let result = try VariablesImplementationFactory().variablesDeclarations(
      protocolVariableDeclaration: protocolVariableDeclaration
    )

    assertBuildResult(
      result,
      """
      var foo: String?
      """
    )
  }

  func testVariablesDeclarationsClosure() throws {
    let declaration = DeclSyntax("var completion: () -> Void { get }")

    let protocolVariableDeclaration = try XCTUnwrap(VariableDeclSyntax(declaration))

    let result = try VariablesImplementationFactory().variablesDeclarations(
      protocolVariableDeclaration: protocolVariableDeclaration
    )

    assertBuildResult(
      result,
      """
      var completion: () -> Void {
          get {
              stubbedCompletion
          }
          set {
              stubbedCompletion = newValue
          }
      }
      var stubbedCompletion: (() -> Void)!
      """
    )
  }

  func testVariablesDeclarationsWithMultiBindings() throws {
    let declaration = DeclSyntax("var foo: String?, bar: Int")

    let protocolVariableDeclaration = try XCTUnwrap(VariableDeclSyntax(declaration))

    XCTAssertThrowsError(
      try VariablesImplementationFactory().variablesDeclarations(
        protocolVariableDeclaration: protocolVariableDeclaration)
    ) { error in
      XCTAssertEqual(
        error as! StubDiagnostic, StubDiagnostic.variableDeclInProtocolWithNotSingleBinding)
    }
  }

  func testVariablesDeclarationsWithTuplePattern() throws {
    let declaration = DeclSyntax("var (x, y): Int")

    let protocolVariableDeclaration = try XCTUnwrap(VariableDeclSyntax(declaration))

    XCTAssertThrowsError(
      try VariablesImplementationFactory().variablesDeclarations(
        protocolVariableDeclaration: protocolVariableDeclaration)
    ) { error in
      XCTAssertEqual(
        error as! StubDiagnostic,
        StubDiagnostic.variableDeclInProtocolWithNotIdentifierPattern)
    }
  }
}
