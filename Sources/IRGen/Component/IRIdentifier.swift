//
//  IRIdentifier.swift
//  IRGen
//
//  Created by Hails, Daniel R on 29/08/2018.
//
import AST
import Lexer

/// Generates code for an identifier.
struct IRIdentifier {
  var identifier: Identifier
  var asLValue: Bool

  // Dependencies
  let mangler: ManglerProtocol

  init(identifier: Identifier, asLValue: Bool = false, mangler: ManglerProtocol = Mangler.shared) {
    self.identifier = identifier
    self.asLValue = asLValue
    self.mangler = mangler
  }

  func rendered(functionContext: FunctionContext) -> String {
    if identifier.enclosingType != nil {
      return IRPropertyAccess(lhs: .self(Token(kind: .self, sourceLocation: identifier.sourceLocation)),
                              rhs: .identifier(identifier), asLValue: asLValue)
        .rendered(functionContext: functionContext)
    }
    return mangler.mangleName(identifier.name)
  }

  static func mangleName(_ name: String) -> String {
    return "_\(name)"
  }
}
