//
//  IRSelf.swift
//  IRGen
//
//  Created by Hails, Daniel R on 29/08/2018.
//
import Lexer
/// Generates code for a "self" expression.
struct IRSelf {
  var selfToken: Token
  var asLValue: Bool

  func rendered(functionContext: FunctionContext) -> GeneratedCode {
    guard case .self = selfToken.kind else {
      fatalError("Unexpected token \(selfToken.kind)")
    }

    return GeneratedCode("", functionContext.isInStructFunction ? "_flintSelf" : asLValue ? "0" : "")
  }
}
