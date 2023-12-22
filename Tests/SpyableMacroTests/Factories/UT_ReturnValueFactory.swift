import SwiftSyntax
import XCTest

@testable import StubMacro

final class UT_ReturnValueFactory: XCTestCase {
  func testVariableDeclaration() throws {
    let variablePrefix = "function_name"
    let functionReturnType = TypeSyntax("(text: String, count: UInt)")

    let result = try ReturnValueFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      functionReturnType: functionReturnType
    )

    assertBuildResult(
      result,
      """
      var stubbedFunction_name: (text: String, count: UInt)!
      """
    )
  }

  func testVariableDeclarationOptionType() throws {
    let variablePrefix = "functionName"
    let functionReturnType = TypeSyntax("String?")

    let result = try ReturnValueFactory().variableDeclaration(
      variablePrefix: variablePrefix,
      functionReturnType: functionReturnType
    )

    assertBuildResult(
      result,
      """
      var stubbedFunctionName: String?
      """
    )
  }

  func testReturnStatement() {
    let variablePrefix = "functionName"

    let result = ReturnValueFactory().returnStatement(variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      return stubbedFunctionName
      """
    )
  }
}
