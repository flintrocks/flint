//
//  ASTPreprocessor.swift
//  ASTPreprocessor
//
//  Created by Nik Vangerow on 11/22/18.
//

import AST

/// The Preprocessing pass for the AST.
public struct ASTPreprocessor: ASTPass {

  public init() {}

  // Make binary expressions involving the dot (.) operator left-associative.
  // Binary expressions are parsed with the wrong associativity. Due to the recursive descent parsing,
  // Expressions associate to the right: a.(b.c). This is wrong. We want them to associate to the right: (a.b).c.
  public func process(binaryExpression: BinaryExpression,
                      passContext: ASTPassContext) -> ASTPassResult<BinaryExpression> {
    guard binaryExpression.opToken == .dot else {
      return ASTPassResult(element: binaryExpression, diagnostics: [], passContext: passContext)
    }

    // Find the pivot.
    // The pivot MUST be a direct right hand descendant of this expression to be valid.
    // Otherwise we have reached a leaf node.
    guard case .binaryExpression(let pivot) = binaryExpression.rhs, pivot.opToken == .dot else {
      return ASTPassResult(element: binaryExpression, diagnostics: [], passContext: passContext)
    }

    let transformedLHS = BinaryExpression(lhs: binaryExpression.lhs, op: pivot.op, rhs: pivot.lhs)
    let transformedRHS = pivot.rhs

    let newBinaryExpression = BinaryExpression(lhs: .binaryExpression(transformedLHS),
                                               op: binaryExpression.op,
                                               rhs: transformedRHS)

    return ASTPassResult(element: newBinaryExpression, diagnostics: [], passContext: passContext)
  }

}
