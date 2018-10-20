//
//  IRConformanceProcessor.swift
//  IRGen
//
//  Created by Nik on 20/10/2018.
//

import AST
import Lexer

/// A prepocessing step to update the program's AST before code generation, specifically in order to resolve Self

public struct IRConformanceProcessor: ASTPass {
  public init() {}

  // MARK: Declaration
  public func process(structDeclaration: StructDeclaration,
                      passContext: ASTPassContext) -> ASTPassResult<StructDeclaration> {
    let environment = passContext.environment!
    var structDeclaration = structDeclaration

    let conformingFunctions = environment.conformingFunctions(in: structDeclaration.identifier.name)
      .compactMap { functionInformation -> StructMember in
        var functionDeclaration = functionInformation.declaration
        functionDeclaration.scopeContext = ScopeContext()

        return .functionDeclaration(functionDeclaration)
    }

    structDeclaration.members += conformingFunctions

    return ASTPassResult(element: structDeclaration, diagnostics: [], passContext: passContext)
  }

  public func process(functionDeclaration: FunctionDeclaration,
                      passContext: ASTPassContext) -> ASTPassResult<FunctionDeclaration> {
    var functionDeclaration = functionDeclaration
    var environment = passContext.environment!

    // Convert Self to struct type, if defined in struct
    if let structDeclarationContext = passContext.structDeclarationContext {
      functionDeclaration.signature.parameters =
        functionDeclaration.signature.parameters.map { (parameter) -> Parameter in
          // Change types in environment as well
          let type = parameter.type.rawType

          if type.isSelfType {
            var parameter = parameter
            let structType: RawType = .userDefinedType(structDeclarationContext.structIdentifier.name)

            if type.isInout {
              parameter.type.rawType = .inoutType(structType)
            } else {
              parameter.type.rawType = structType
            }

            return parameter
          }

          return parameter
      }

      environment.addFunction(functionDeclaration, enclosingType: structDeclarationContext.structIdentifier.name,
                              states: [], callerProtections: [])
    }


    return ASTPassResult(element: functionDeclaration, diagnostics: [], passContext: passContext)
  }
}
