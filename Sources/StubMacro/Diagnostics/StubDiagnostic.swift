import SwiftDiagnostics

/// `StubDiagnostic` is an enumeration defining specific error messages related to the Stub system.
///
/// It conforms to the `DiagnosticMessage` and `Error` protocols to provide comprehensive error information
/// and integrate smoothly with error handling mechanisms.
///
/// - Note: The `StubDiagnostic` enum can be expanded to include more diagnostic cases as
///         the Stub system grows and needs to handle more error types.
enum StubDiagnostic: String, DiagnosticMessage, Error {
  case onlyApplicableToProtocol
  case variableDeclInProtocolWithNotSingleBinding
  case variableDeclInProtocolWithNotIdentifierPattern

  var message: String {
    switch self {
    case .onlyApplicableToProtocol:
      "'@Stub' can only be applied to a 'protocol'"
    case .variableDeclInProtocolWithNotSingleBinding:
      "Variable declaration in a 'protocol' with the '@Stub' attribute must have exactly one binding"
    case .variableDeclInProtocolWithNotIdentifierPattern:
      "Variable declaration in a 'protocol' with the '@Stub' attribute must have identifier pattern"
    }
  }

  var severity: DiagnosticSeverity {
    switch self {
    case .onlyApplicableToProtocol: .error
    case .variableDeclInProtocolWithNotSingleBinding: .error
    case .variableDeclInProtocolWithNotIdentifierPattern: .error
    }
  }

  var diagnosticID: MessageID {
    MessageID(domain: "StubMacro", id: rawValue)
  }
}
