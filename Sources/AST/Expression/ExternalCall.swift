//
//  ExternalCall.swift
//  AST
//
//  Created by Catalin Craciun on 10/11/2018.
//
import Source
import Lexer

/// A call to an external function
public struct ExternalCall: ASTNode {
  public var gas: Int // The amount of gas for function execution, default to 2300
  public var wei: Int = -1 // If the external call is marked as payable, this should be non-negative
  public var reentrant: Bool = false // By default, external calls are not reentrant
  public var functionCall: FunctionCall

  public var returnsOptional: Bool // for call?
  public var forced: Bool // for call!

  public init(gas: Int = 2300,
              wei: Int = -1,
              reentrant: Bool = false,
              functionCall: FunctionCall,
              returnsOptional: Bool,
              forced: Bool) {
    self.gas = gas
    self.wei = wei
    self.reentrant = reentrant
    self.functionCall = functionCall

    self.returnsOptional = returnsOptional
    self.forced = forced
  }

  // MARK: - ASTNode
  public var sourceLocation: SourceLocation {
    return .spanning(functionCall.identifier, to: functionCall.closeBracketToken)
  }

  public var description: String {
    let argumentText = functionCall.arguments.map({ $0.description }).joined(separator: ", ")
    return "call(gas=\(gas), wei=\(wei), reentrant=\(reentrant)) - " +
        "\(functionCall.identifier)(\(argumentText))"
  }
}
