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
  public var functionCall: BinaryExpression
  public var returnsOptional: Bool // used for representing call?
  public var forced: Bool // used for representing call!

  public init(configurationParameters: [FunctionArgument],
              functionCall: BinaryExpression,
              returnsOptional: Bool,
              forced: Bool) {
    self.configurationParameters = configurationParameters
    self.functionCall = functionCall
    self.returnsOptional = returnsOptional
    self.forced = forced
  }

  // MARK: - ASTNode
  public var sourceLocation: SourceLocation {
    return functionCall.sourceLocation
  }

  public var description: String {
    let configurationText = configurationParameters.map({ $0.description }).joined(separator: ", ")
    return "call(\(configurationText)) - " + "\(functionCall.description))"
  }
}
