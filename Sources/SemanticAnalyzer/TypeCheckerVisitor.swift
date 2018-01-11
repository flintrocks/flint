//
//  TypeCheckerVisitor.swift
//  SemanticAnalyzer
//
//  Created by Franklin Schrans on 1/11/18.
//

import AST
import Diagnostic

final class TypeCheckerVisitor: DiagnosticsTracking {
  var context: Context
  var diagnostics = [Diagnostic]()

  init(context: Context) {
    self.context = context
  }

  func type(of expression: Expression, functionDeclarationContext: FunctionDeclarationContext) -> Type.RawType {
    switch expression {
    case .binaryExpression(let binaryExpression):
      return type(of: binaryExpression.rhs, functionDeclarationContext: functionDeclarationContext)

    case .bracketedExpression(let expression):
      return type(of: expression, functionDeclarationContext: functionDeclarationContext)

    case .functionCall(let functionCall):
      let contractContext = functionDeclarationContext.contractContext
      return context.type(of: functionCall, contractIdentifier: contractContext.contractIdentifier, callerCapabilities: contractContext.callerCapabilities)!

    case .identifier(let identifier):
      if let localVariable = functionDeclarationContext.declaration.matchingLocalVariable(identifier) {
        return localVariable.type.rawType
      }
      return context.type(of: identifier, contractIdentifier: functionDeclarationContext.contractContext.contractIdentifier)!

    case .literal(let token):
      guard case .literal(let literal) = token.kind else { fatalError() }
      switch literal {
      case .boolean(_): return .builtInType(.bool)
      case .decimal(.integer(_)): return .builtInType(.int)
      default: fatalError()
      }
    case .self(_): return .userDefinedType(functionDeclarationContext.contractContext.contractIdentifier.name)
    case .variableDeclaration(let variableDeclaration):
      return variableDeclaration.type.rawType
    case .subscriptExpression(let subscriptExpression):
      let type = context.type(of: subscriptExpression.baseIdentifier, contractIdentifier: functionDeclarationContext.contractContext.contractIdentifier)!

      switch type {
      case .arrayType(let elementType, _): return elementType
      case .dictionaryType(_, let valueType): return valueType
      default: fatalError()
      }
    }
  }

  func visit(_ topLevelModule: TopLevelModule) {
    for declaration in topLevelModule.declarations {
      visit(declaration)
    }
  }

  func visit(_ topLevelDeclaration: TopLevelDeclaration) {
    switch topLevelDeclaration {
    case .contractDeclaration(let contractDeclaration):
      visit(contractDeclaration)
    case .contractBehaviorDeclaration(let contractBehaviorDeclaration):
      visit(contractBehaviorDeclaration)
    }
  }

  func visit(_ contractDeclaration: ContractDeclaration) {
    for variableDeclaration in contractDeclaration.variableDeclarations {
      visit(variableDeclaration)
    }
  }

  func visit(_ contractBehaviorDeclaration: ContractBehaviorDeclaration) {
    visit(contractBehaviorDeclaration.contractIdentifier)

    guard context.declaredContractsIdentifiers.contains(contractBehaviorDeclaration.contractIdentifier) else {
      addDiagnostic(.contractBehaviorDeclarationNoMatchingContract(contractBehaviorDeclaration))
      return
    }

    for callerCapability in contractBehaviorDeclaration.callerCapabilities {
      visit(callerCapability)
    }

    let properties = context.properties(declaredIn: contractBehaviorDeclaration.contractIdentifier)
    let contractBehaviorDeclarationContext = ContractBehaviorDeclarationContext(contractIdentifier: contractBehaviorDeclaration.contractIdentifier, contractProperties: properties, callerCapabilities: contractBehaviorDeclaration.callerCapabilities)

    for functionDeclaration in contractBehaviorDeclaration.functionDeclarations {
      visit(functionDeclaration, contractContext: contractBehaviorDeclarationContext)
    }
  }

  func visit(_ variableDeclaration: VariableDeclaration) {
    visit(variableDeclaration.identifier)
    visit(variableDeclaration.type)
  }

  func visit(_ functionDeclaration: FunctionDeclaration, contractContext: ContractBehaviorDeclarationContext) {
    visit(functionDeclaration.identifier)
    for parameter in functionDeclaration.parameters {
      visit(parameter)
    }

    if let resultType = functionDeclaration.resultType {
      visit(resultType)
    }

    let functionDeclarationContext = FunctionDeclarationContext(declaration: functionDeclaration, contractContext: contractContext)

    visitBody(functionDeclaration.body, functionDeclarationContext: functionDeclarationContext)
  }

  func visit(_ parameter: Parameter) {}

  func visit(_ typeAnnotation: TypeAnnotation) {}

  func visit(_ identifier: Identifier) {}

  func visit(_ type: Type) {}

  func visit(_ callerCapability: CallerCapability) {}

  func visit(_ expression: Expression) {
    switch expression {
    case .binaryExpression(let binaryExpression): visit(binaryExpression)
    case .bracketedExpression(let expression): visit(expression)
    case .functionCall(let functionCall): visit(functionCall)
    case .identifier(let identifier): visit(identifier)
    case .literal(_): break
    case .self(_): break
    case .variableDeclaration(let variableDeclaration): visit(variableDeclaration)
    case .subscriptExpression(let subscriptExpression): visit(subscriptExpression)
    }
  }

  func visitBody(_ statements: [Statement], functionDeclarationContext: FunctionDeclarationContext) {
    let returnStatementIndex = statements.index(where: { statement in
      if case .returnStatement(_) = statement { return true }
      return false
    })

    if let returnStatementIndex = returnStatementIndex {
      if returnStatementIndex != statements.count - 1 {
        let nextStatement = statements[returnStatementIndex + 1]
        addDiagnostic(.codeAfterReturn(nextStatement))
      }
    }

    for statement in statements {
      visit(statement, functionDeclarationContext: functionDeclarationContext)
    }
  }

  func visit(_ statement: Statement, functionDeclarationContext: FunctionDeclarationContext) {
    switch statement {
    case .expression(let expression): visit(expression)
    case .ifStatement(let ifStatement): visit(ifStatement, functionDeclarationContext: functionDeclarationContext)
    case .returnStatement(let returnStatement):
      visit(returnStatement, functionDeclarationContext: functionDeclarationContext)
    }
  }

  func visit(_ binaryExpression: BinaryExpression) {
    if case .binaryOperator(.equal) = binaryExpression.op.kind {
      visit(binaryExpression.lhs)
    }

    visit(binaryExpression.lhs)
    visit(binaryExpression.rhs)
  }

  func visit(_ functionCall: FunctionCall) {
    for argument in functionCall.arguments {
      visit(argument)
    }
  }

  func visit(_ subscriptExpression: SubscriptExpression) {
    visit(subscriptExpression.baseIdentifier)
    visit(subscriptExpression.indexExpression)
  }

  func visit(_ returnStatement: ReturnStatement, functionDeclarationContext: FunctionDeclarationContext) {
    guard let expression = returnStatement.expression else { return }
    let actualType = type(of: expression, functionDeclarationContext: functionDeclarationContext)
    let expectedType = functionDeclarationContext.declaration.rawType

    if actualType != expectedType {
      addDiagnostic(.incompatibleReturnType(actualType: actualType, expectedType: expectedType, expression: expression))
    }
  }

  func visit(_ ifStatement: IfStatement, functionDeclarationContext: FunctionDeclarationContext) {
    visitBody(ifStatement.body, functionDeclarationContext: functionDeclarationContext)
  }
}
