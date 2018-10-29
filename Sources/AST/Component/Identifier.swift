//
//  Identifier.swift
//  AST
//
//  Created by Hails, Daniel J R on 21/08/2018.
//
import Source
import Lexer

/// An identifier for a contract, struct, variable, or function.
public struct Identifier: Hashable, ASTNode {
  public var identifierToken: Token
  public var enclosingType: String?
  public var isFunctionCallArgLabel: Bool

  public var name: String {
    if case .self = identifierToken.kind {
      return "self"
    }
    guard case .identifier(let name) = identifierToken.kind else { fatalError() }
    return name
  }

  public init(identifierToken: Token, isFunctionCallArgLabel: Bool = false) {
    self.identifierToken = identifierToken
    self.isFunctionCallArgLabel = isFunctionCallArgLabel
  }

  public init(name: String, sourceLocation: SourceLocation, isFunctionCallArgLabel: Bool = false) {
    self.identifierToken = Token(kind: .identifier(name), sourceLocation: sourceLocation)
    self.isFunctionCallArgLabel = isFunctionCallArgLabel
  }

  public var hashValue: Int {
    return "\(name)_\(sourceLocation)".hashValue
  }

  // MARK: - ASTNode
  public var sourceLocation: SourceLocation {
    return identifierToken.sourceLocation
  }

  public var description: String {
    return "\(identifierToken)"
  }
}
