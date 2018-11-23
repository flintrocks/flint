//
//  EnclosingTypeAssigner.swift
//  ASTPreprocessor
//
//  Created by Nik on 23/11/2018.
//

import AST
import Diagnostic

/// The Enclosing Type Assignment pass for the AST.
public struct EnclosingTypeAssigner: ASTPass {

  public init() {}

  public func process(variableDeclaration: VariableDeclaration,
                      passContext: ASTPassContext) -> ASTPassResult<VariableDeclaration> {
    var passContext = passContext
    if passContext.inFunctionOrInitializer {
        // We're in a function. Record the local variable declaration.
        passContext.scopeContext?.localVariables += [variableDeclaration]
    }
    return ASTPassResult(element: variableDeclaration, diagnostics: [], passContext: passContext)
  }

  public func postProcess(binaryExpression: BinaryExpression,
                          passContext: ASTPassContext) -> ASTPassResult<BinaryExpression> {
    var binaryExpression = binaryExpression
    let environment = passContext.environment!

    if case .dot = binaryExpression.opToken {
      // The identifier explicitly refers to a state property, such as in `self.foo`.
      // We set its enclosing type to the type it is declared in.
      let enclosingType = passContext.enclosingTypeIdentifier!
      let lhsType = environment.type(of: binaryExpression.lhs,
                                     enclosingType: enclosingType.name,
                                     scopeContext: passContext.scopeContext!)
      if case .identifier(let enumIdentifier) = binaryExpression.lhs,
        environment.isEnumDeclared(enumIdentifier.name) {
        binaryExpression.rhs = binaryExpression.rhs.assigningEnclosingType(type: enumIdentifier.name)
      } else if lhsType == .selfType {
        if let traitDeclarationContext = passContext.traitDeclarationContext {
          binaryExpression.rhs =
            binaryExpression.rhs.assigningEnclosingType(type: traitDeclarationContext.traitIdentifier.name)
        }
      } else {
        binaryExpression.rhs = binaryExpression.rhs.assigningEnclosingType(type: lhsType.name)
      }
    }

    return ASTPassResult(element: binaryExpression, diagnostics: [], passContext: passContext)
  }

}
