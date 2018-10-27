//
//  Environment.swift
//  AST
//
//  Created by Franklin Schrans on 12/26/17.
//
import Source
import Lexer

/// Information about the source program.
public struct Environment {
  /// Information about each type (contracts, structs and traits) which the program define, such as its properties and
  /// functions.
  var types = [RawTypeIdentifier: TypeInformation]()

  /// A list of the names of the contracts which have been declared in the program.
  var declaredContracts = [Identifier]()

  /// A list of the names of the structs which have been declared in the program.
  var declaredStructs = [Identifier]()

  /// A list of the names of the enums which have been declared in the program.
  var declaredEnums = [Identifier]()

  // A list of the names of the traits which have been declared in the program.
  var declaredTraits = [Identifier]()

  /// The name of the stdlib struct which contains all global functions.
  public static let globalFunctionStructName = "Flint$Global"

  public init() {}

  // MARK: - Property
  public func property(_ identifier: String, _ enclosingType: RawTypeIdentifier) -> PropertyInformation? {
    return types[enclosingType]?.properties[identifier]
  }

  /// The source location of a property declaration.
  public func propertyDeclarationSourceLocation(_ identifier: String,
                                                enclosingType: RawTypeIdentifier) -> SourceLocation? {
    return property(identifier, enclosingType)!.sourceLocation
  }

  /// The names of the properties declared in a type.
  public func properties(in enclosingType: RawTypeIdentifier) -> [String] {
    return types[enclosingType]!.orderedProperties
  }

  /// The list of property declarations in a type.
  public func propertyDeclarations(in enclosingType: RawTypeIdentifier) -> [Property] {
    return types[enclosingType]?.properties.values.map { $0.property } ?? []
  }

  // MARK: - Accessors of type properties

  /// The list of conforming functions in a type.
  public func conformingFunctions(in enclosingType: RawTypeIdentifier) -> [FunctionInformation] {
    return types[enclosingType]!.conformingFunctions
  }

  /// The list of initializers in a type.
  public func initializers(in enclosingType: RawTypeIdentifier) -> [SpecialInformation] {
    return types[enclosingType]!.allInitialisers
  }

  /// The list of fallbacks in a type.
  public func fallbacks(in enclosingType: RawTypeIdentifier) -> [SpecialInformation] {
    return types[enclosingType]!.fallbacks
  }

  /// The list of events in a type.
  public func events(in enclosingType: RawTypeIdentifier) -> [EventInformation] {
    return types[enclosingType]!.allEvents.flatMap({ $1 })
  }

  /// The list of properties declared in a type which can be used as caller protections.
  func declaredCallerProtections(enclosingType: RawTypeIdentifier) -> [String] {
    let properties: [String] = types[enclosingType]!.properties.compactMap { key, value in
      switch value.rawType {
      case .basicType(.address): return key
      case .fixedSizeArrayType(.basicType(.address), _): return key
      case .arrayType(.basicType(.address)): return key
      case .dictionaryType(_, .basicType(.address)): return key
      default: return nil
      }
    }
    let functions: [String] = types[enclosingType]!.functions.compactMap { name, functions in
      for function in functions {
        if function.resultType == .basicType(.address), function.parameterTypes == [] {
          return name
        }
        if function.resultType == .basicType(.bool), function.parameterTypes == [.basicType(.address)] {
          return name
        }
      }
      return nil
    }
    return properties + functions
  }

  public func getStateValue(_ state: Identifier, in contract: RawTypeIdentifier) -> Expression {
    let enumName = ContractDeclaration.contractEnumPrefix + contract
    return types[enumName]!.properties[state.name]!.property.value!
  }

  /// The public initializer for the given contract. A contract should have at most one public initializer.
  public func publicInitializer(forContract contract: RawTypeIdentifier) -> SpecialDeclaration? {
    return types[contract]?.publicInitializer
  }

  /// The public fallback for the given contract. A contract should have at most one public fallback.
  public func publicFallback(forContract contract: RawTypeIdentifier) -> SpecialDeclaration? {
    return types[contract]?.publicFallback
  }

  // MARK: - Compatibility
  func areArgumentsCompatible(source: EventInformation,
                              target: [FunctionArgument],
                              enclosingType: String,
                              scopeContext: ScopeContext) -> Bool {
    let sourceVariables = source.declaration.variableDeclarations
    let sourceTypes = source.eventTypes

    guard target.count <= source.parameterIdentifiers.count &&
          target.count >= source.requiredParameterIdentifiers.count else {
      return false
    }

    // Check required parameters first
    var sourceIndex = 0
    var targetIndex = 0

    while sourceIndex < sourceVariables.count && sourceVariables[sourceIndex].assignedExpression == nil {
      // Check identifiers
      if target[targetIndex].identifier != nil {
        if target[targetIndex].identifier!.name != sourceVariables[sourceIndex].identifier.name {
          return false
        }
      }

      // Check types
      if sourceTypes[sourceIndex] != type(of: target[targetIndex].expression,
                                          enclosingType: enclosingType,
                                          scopeContext: scopeContext) {
        // Wrong type
        return false
      }

      sourceIndex += 1
      targetIndex += 1
    }

    // Check default parameters
    while sourceIndex < sourceVariables.count && targetIndex < target.count {
      guard let argumentIdentifier = target[targetIndex].identifier else {
        if sourceTypes[sourceIndex] != type(of: target[targetIndex].expression,
                                            enclosingType: enclosingType,
                                            scopeContext: scopeContext) {
          return false
        }

        sourceIndex += 1
        targetIndex += 1
        continue
      }

      while sourceIndex < sourceVariables.count &&
            argumentIdentifier.name != sourceVariables[sourceIndex].identifier.name {
        sourceIndex += 1
      }

      if sourceIndex == sourceVariables.count {
        // Identifier was not found
        return false
      }

      if sourceTypes[sourceIndex] != type(of: target[targetIndex].expression,
                                          enclosingType: enclosingType,
                                          scopeContext: scopeContext) {
        // Wrong type
        return false
      }

      sourceIndex += 1
      targetIndex += 1
    }

    if targetIndex < target.count {
      // Not all arguments were matches
      return false
    }

    return true
  }

  /// Whether to function arguments are compatible.
  ///
  /// - Parameters:
  ///   - source: function information of the function that the user is trying to call.
  ///   - target: function call available in this scope.
  /// - Returns: Boolean indicating whether function arguments are compatible.
  func areFunctionArgumentsCompatible(source: FunctionInformation,
                                      target: FunctionCall,
                                      enclosingType: RawTypeIdentifier,
                                      scopeContext: ScopeContext) -> Bool {
    // If source contains an argument of self type then attempt to replace with enclosing type
    let sourceSelf = source.parameterTypes.map { type -> RawType in
      if type.isSelfType {
        if type.isInout {
          return .inoutType(.userDefinedType(enclosingType))
        }

        return .userDefinedType(enclosingType)
      }

      return type
    }

    let sourceVariables = source.declaration.signature.parameters.map({ $0.asVariableDeclaration })
    let targetArguments = target.arguments

    guard targetArguments.count <= source.parameterIdentifiers.count &&
          targetArguments.count >= source.requiredParameterIdentifiers.count else {
      return false
    }

    // Check required parameters first
    var sourceIndex = 0
    var targetIndex = 0

    while sourceIndex < sourceVariables.count && sourceVariables[sourceIndex].assignedExpression == nil {
      // Check identifiers
      if targetArguments[targetIndex].identifier != nil {
        if targetArguments[targetIndex].identifier!.name != sourceVariables[sourceIndex].identifier.name {
          return false
        }
      }

      // Check types
      if sourceSelf[sourceIndex] != type(of: targetArguments[targetIndex].expression,
                                         enclosingType: enclosingType,
                                         scopeContext: scopeContext) {
        // Wrong type
        return false
      }

      sourceIndex += 1
      targetIndex += 1
    }

    // Check default parameters
    while sourceIndex < sourceVariables.count && targetIndex < targetArguments.count {
      guard let argumentIdentifier = targetArguments[targetIndex].identifier else {
        if sourceSelf[sourceIndex] != type(of: targetArguments[targetIndex].expression,
                                           enclosingType: enclosingType,
                                           scopeContext: scopeContext) {
          return false
        }

        sourceIndex += 1
        targetIndex += 1
        continue
      }

      while sourceIndex < sourceVariables.count &&
            argumentIdentifier.name != sourceVariables[sourceIndex].identifier.name {
        sourceIndex += 1
      }

      if sourceIndex == sourceVariables.count {
        // Identifier was not found
        return false
      }

      if sourceSelf[sourceIndex] != type(of: targetArguments[targetIndex].expression,
                                         enclosingType: enclosingType,
                                         scopeContext: scopeContext) {
        // Wrong type
        return false
      }

      sourceIndex += 1
      targetIndex += 1
    }

    if targetIndex < targetArguments.count {
      // Not all arguments were matches
      return false
    }

    return true
  }

  /// Whether two caller protection groups are compatible, i.e. whether a function with caller protection `source` is
  /// able to call a function which require caller protections `target`.
  func areCallerProtectionsCompatible(source: [CallerProtection], target: [CallerProtection]) -> Bool {
    guard !target.isEmpty else { return true }
    for callCallerProtection in source {
      if !target.contains(where: { return callCallerProtection.isSubProtection(of: $0) }) {
        return false
      }
    }
    return true
  }

  /// Whether two type state groups are compatible, i.e. whether a function with
  /// type states `source` is able to call a function requiring 'target' states.
  func areTypeStatesCompatible(source: [TypeState], target: [TypeState]) -> Bool {
    guard !target.isEmpty else { return true }
    for callTypeState in source {
      if !target.contains(where: { return callTypeState.isSubState(of: $0) }) {
        return false
      }
    }
    return true
  }
}
