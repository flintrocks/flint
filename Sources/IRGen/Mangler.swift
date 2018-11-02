//
//  Mangler.swift
//  AST
//
//  Created by Franklin Schrans on 09/02/2018.
//

import AST

struct Mangler {

  // Singleton Pattern
  private init() { }

  static var shared = Mangler()

  func mangleName(_ name: String) -> String {
    return "_\(name)"
  }

  func mangleFunctionName(_ name: String, parameterTypes: [RawType], enclosingType: String) -> String {
    let parameters = parameterTypes.map { $0.name }.joined(separator: "_")
    let dollar = parameters.isEmpty ? "" : "$"
    return "\(enclosingType)$\(name)\(dollar)\(parameters)"
  }

  func mangleInitializerName(_ enclosingType: String, parameterTypes: [RawType]) -> String {
    return mangleFunctionName("init", parameterTypes: parameterTypes, enclosingType: enclosingType)
  }

  /// Constructs the parameter name to indicate whether the given parameter is a memory reference.
  func isMem(for parameter: String) -> String {
    return "\(parameter)$isMem"
  }
}
