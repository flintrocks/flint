//
//  IRVariableDeclaration.swift
//  IRGen
//
//  Created by Hails, Daniel R on 29/08/2018.
//
import AST

/// Generates code for a variable declaration.
struct IRVariableDeclaration {
  var variableDeclaration: VariableDeclaration

  // Dependencies
  let mangler: Mangler

  init(variableDeclaration: VariableDeclaration, mangler: Mangler = Mangler.shared) {
    self.variableDeclaration = variableDeclaration
    self.mangler = mangler
  }

  func rendered(functionContext: FunctionContext) -> String {
    let allocate = IRRuntimeFunction.allocateMemory(
      size: functionContext.environment.size(of: variableDeclaration.type.rawType) * EVM.wordSize)
    let mangledName = mangler.mangleName(variableDeclaration.identifier.name)
    return "let \(mangledName) := \(allocate)"
  }
}
