//
//  IREventCall.swift
//  IRGen
//
//  Created by Hails, Daniel R on 29/08/2018.
//
import AST

/// Generates code for an event call.
struct IREventCall {
  var eventCall: FunctionCall
  var eventDeclaration: EventDeclaration

  func rendered(functionContext: FunctionContext) -> String {
    let types = eventDeclaration.variableDeclarations.map { $0.type }

    var stores = [String]()
    var memoryOffset = 0

    let argumentsWithDefault = addDefaultParameters(functionCall: eventCall,
            toAdd: eventDeclaration.variableDeclarations)

    for (i, argument) in argumentsWithDefault.enumerated() {
      let argument = IRExpression(expression: argument.expression).rendered(functionContext: functionContext)
      stores.append("mstore(\(memoryOffset), \(argument))")
      memoryOffset += functionContext.environment.size(of: types[i].rawType) * EVM.wordSize
    }

    let totalSize = types.reduce(0) { return $0 + functionContext.environment.size(of: $1.rawType) } * EVM.wordSize
    let typeList = types.map { type in
      return "\(CanonicalType(from: type.rawType)!.rawValue)"
      }.joined(separator: ",")

    let eventHash = "\(eventCall.identifier.name)(\(typeList))".sha3(.keccak256)
    let log = "log1(0, \(totalSize), 0x\(eventHash))"

    return """
    \(stores.joined(separator: "\n"))
    \(log)
    """
  }

  // Adds the defaulted parameters to a function call given a function declaration
  // This assumes parameters are passed in order, and they are valid
  public func addDefaultParameters(functionCall: FunctionCall, toAdd: [VariableDeclaration]) -> [FunctionArgument] {
    var declarationIndex = 0
    var existingArguments = functionCall.arguments;

    while declarationIndex < toAdd.count {
      if declarationIndex == existingArguments.count {
        // Add everything that's remaining
        existingArguments.insert(FunctionArgument(identifier: toAdd[declarationIndex].identifier,
                expression: toAdd[declarationIndex].assignedExpression!),
                at: declarationIndex)

        declarationIndex+=1
        continue
      }

      if existingArguments[declarationIndex].identifier == nil {
        // Identifier-less call parameters should always match the declaration parameter
        declarationIndex+=1

        continue;
      }

      if toAdd[declarationIndex].assignedExpression == nil {
        // Parameter must have been provided
        declarationIndex+=1

        continue
      }

      if toAdd[declarationIndex].identifier.name == existingArguments[declarationIndex].identifier!.name {
        // Default parameter value is overridden
        declarationIndex+=1

        continue
      }

      existingArguments.insert(FunctionArgument(identifier: toAdd[declarationIndex].identifier,
              expression: toAdd[declarationIndex].assignedExpression!),
              at: declarationIndex)

      declarationIndex+=1
    }

    return existingArguments
  }
}
