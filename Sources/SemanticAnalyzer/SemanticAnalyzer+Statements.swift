//
//  SemanticAnalyzer+Statements.swift
//  SemanticAnalyzer
//
//  Created by Farcas, Calin on 10/11/2018.
//
import Foundation
import AST
import Lexer
import Diagnostic

extension SemanticAnalyzer {
  public func postProcess(ifStatement: IfStatement,
                          passContext: ASTPassContext) -> ASTPassResult<IfStatement> {
    let ifStatement = ifStatement
    let condition = ifStatement.condition
    let environment = passContext.environment!
    let enclosingTypeIdentifier = passContext.enclosingTypeIdentifier!
    let typeStates = passContext.contractBehaviorDeclarationContext?.typeStates ?? []
    let callerProtections = passContext.contractBehaviorDeclarationContext?.callerProtections ?? []
    var diagnostics = [Diagnostic]()

    let expressionType = environment.type(of: condition,
                                          enclosingType: enclosingTypeIdentifier.name,
                                          typeStates: typeStates,
                                          callerProtections: callerProtections,
                                          scopeContext: passContext.scopeContext!)

    // Check that expression inside If statement is a Bool
    if expressionType != RawType.basicType(RawType.BasicType.bool) {
      diagnostics.append(.invalidConditionTypeInIfStatement(ifStatement))
    }

    return ASTPassResult(element: ifStatement, diagnostics: diagnostics, passContext: passContext)
  }
}