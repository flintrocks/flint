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
  public var configurationParameters: [FunctionArgument]
  public var closeBracketToken: Token
  public var functionCall: FunctionCall
  public var returnsOptional: Bool // used for representing call?
  public var forced: Bool // used for representing call!

  public init(configurationParameters: [FunctionArgument],
              closeBracketToken: Token,
              functionCall: FunctionCall,
              returnsOptional: Bool,
              forced: Bool) {
    self.configurationParameters = configurationParameters
    self.closeBracketToken = closeBracketToken
    self.functionCall = functionCall
    self.returnsOptional = returnsOptional
    self.forced = forced
  }

  // MARK: - ASTNode
  public var sourceLocation: SourceLocation {
    return .spanning(functionCall.identifier, to: functionCall.closeBracketToken)
  }

  public var description: String {
    let configurationText = configurationParameters.map({ $0.description }).joined(separator: ", ")
    let argumentText = functionCall.arguments.map({ $0.description }).joined(separator: ", ")
    return "call(\(configurationText)) - " + "\(functionCall.identifier)(\(argumentText))"
  }
}
