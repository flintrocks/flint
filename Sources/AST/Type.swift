//
//  Type.swift
//  AST
//
//  Created by Hails, Daniel J R on 21/08/2018.
//
import Lexer
import Source
/// The raw representation of an RawType.
public typealias RawTypeIdentifier = String

// A Flint raw type, without a source location.
public indirect enum RawType: Equatable {
  case basicType(BasicType)
  case rangeType(RawType)
  case arrayType(RawType)
  case fixedSizeArrayType(RawType, size: Int)
  case dictionaryType(key: RawType, value: RawType)
  case userDefinedType(RawTypeIdentifier)
  case inoutType(RawType)
  case functionType(parameters: [RawType], result: RawType)
  case externalType(ExternalType)
  case selfType
  case any
  case errorType

  public enum BasicType: RawTypeIdentifier {
    case address = "Address"
    case int = "Int"
    case string = "String"
    case void = "Void"
    case bool = "Bool"
    case event = "Event"
  }

  public enum StdlibType: RawTypeIdentifier {
    case wei = "Wei"
  }

  public enum ExternalType: RawTypeIdentifier {
    // Address
    case address = "Address"

    // String
    case string = "String"

    // Bool
    case bool = "Bool"

    // Int
    case int8 = "Int8"
    case int16 = "Int16"
    case int24 = "Int24"
    case int32 = "Int32"
    case int40 = "Int40"
    case int48 = "Int48"
    case int56 = "Int56"
    case int64 = "Int64"
    case int72 = "Int72"
    case int80 = "Int80"
    case int88 = "Int88"
    case int96 = "Int96"
    case int104 = "Int104"
    case int112 = "Int112"
    case int120 = "Int120"
    case int128 = "Int128"
    case int136 = "Int136"
    case int144 = "Int144"
    case int152 = "Int152"
    case int160 = "Int160"
    case int168 = "Int168"
    case int176 = "Int176"
    case int184 = "Int184"
    case int192 = "Int192"
    case int200 = "Int200"
    case int208 = "Int208"
    case int216 = "Int216"
    case int224 = "Int224"
    case int232 = "Int232"
    case int240 = "Int240"
    case int248 = "Int248"
    case int256 = "Int256"

    // UInt
    case uint8 = "UInt8"
    case uint16 = "UInt16"
    case uint24 = "UInt24"
    case uint32 = "UInt32"
    case uint40 = "UInt40"
    case uint48 = "UInt48"
    case uint56 = "UInt56"
    case uint64 = "UInt64"
    case uint72 = "UInt72"
    case uint80 = "UInt80"
    case uint88 = "UInt88"
    case uint96 = "UInt96"
    case uint104 = "UInt104"
    case uint112 = "UInt112"
    case uint120 = "UInt120"
    case uint128 = "UInt128"
    case uint136 = "UInt136"
    case uint144 = "UInt144"
    case uint152 = "UInt152"
    case uint160 = "UInt160"
    case uint168 = "UInt168"
    case uint176 = "UInt176"
    case uint184 = "UInt184"
    case uint192 = "UInt192"
    case uint200 = "UInt200"
    case uint208 = "UInt208"
    case uint216 = "UInt216"
    case uint224 = "UInt224"
    case uint232 = "UInt232"
    case uint240 = "UInt240"
    case uint248 = "UInt248"
    case uint256 = "UInt256"

    static let solidityNames: [ExternalType: String] = [
      .address: "address",
      .string: "string",
      .bool: "bool",
      .int8: "int8",
      .int16: "int16",
      .int24: "int24",
      .int32: "int32",
      .int40: "int40",
      .int48: "int48",
      .int56: "int56",
      .int64: "int64",
      .int72: "int72",
      .int80: "int80",
      .int88: "int88",
      .int96: "int96",
      .int104: "int104",
      .int112: "int112",
      .int120: "int120",
      .int128: "int128",
      .int136: "int136",
      .int144: "int144",
      .int152: "int152",
      .int160: "int160",
      .int168: "int168",
      .int176: "int176",
      .int184: "int184",
      .int192: "int192",
      .int200: "int200",
      .int208: "int208",
      .int216: "int216",
      .int224: "int224",
      .int232: "int232",
      .int240: "int240",
      .int248: "int248",
      .int256: "int256",
      .uint8: "uint8",
      .uint16: "uint16",
      .uint24: "uint24",
      .uint32: "uint32",
      .uint40: "uint40",
      .uint48: "uint48",
      .uint56: "uint56",
      .uint64: "uint64",
      .uint72: "uint72",
      .uint80: "uint80",
      .uint88: "uint88",
      .uint96: "uint96",
      .uint104: "uint104",
      .uint112: "uint112",
      .uint120: "uint120",
      .uint128: "uint128",
      .uint136: "uint136",
      .uint144: "uint144",
      .uint152: "uint152",
      .uint160: "uint160",
      .uint168: "uint168",
      .uint176: "uint176",
      .uint184: "uint184",
      .uint192: "uint192",
      .uint200: "uint200",
      .uint208: "uint208",
      .uint216: "uint216",
      .uint224: "uint224",
      .uint232: "uint232",
      .uint240: "uint240",
      .uint248: "uint248",
      .uint256: "uint256"
    ]

    private var solidityName: String {
      return ExternalType.solidityNames[self]!
    }
  }

  public var name: String {
    switch self {
    case .fixedSizeArrayType(let rawType, size: let size): return "\(rawType.name)[\(size)]"
    case .arrayType(let rawType): return "[\(rawType.name)]"
    case .rangeType(let rawType): return "(\(rawType.name))"
    case .basicType(let builtInType): return "\(builtInType.rawValue)"
    case .dictionaryType(let keyType, let valueType): return "[\(keyType.name): \(valueType.name)]"
    case .userDefinedType(let identifier): return identifier
    case .inoutType(let rawType): return "$inout\(rawType.name)"
    case .selfType: return "Self"
    case .any: return "Any"
    case .errorType: return "Flint$ErrorType"
    case .functionType(let parameters, let result):
      return "(\(parameters.map { $0.name }.joined(separator: ", ")) -> \(result)"
    case .externalType(let externalType):
      return "External(\(externalType.rawValue))"
    }
  }

  public var isBuiltInType: Bool {
    switch self {
    case .basicType, .any, .errorType: return true
    case .arrayType(let element): return element.isBuiltInType
    case .rangeType(let element): return element.isBuiltInType
    case .fixedSizeArrayType(let element, _): return element.isBuiltInType
    case .dictionaryType(let key, let value): return key.isBuiltInType && value.isBuiltInType
    case .inoutType(let element): return element.isBuiltInType
    case .selfType: return false
    case .userDefinedType: return false
    case .functionType: return false
    case .externalType: return true
    }
  }

  public var isUserDefinedType: Bool {
    return !isBuiltInType
  }

  /// Whether the type is a dynamic type.
  public var isDynamicType: Bool {
    if case .basicType(_) = self {
      return false
    }

    return true
  }

  public var isInout: Bool {
    if case .inoutType(_) = self {
      return true
    }
    return false
  }

  public var isSelfType: Bool {
    if case .inoutType(.selfType) = self {
      return true
    }

    return self == .selfType
  }

  public var isCurrencyType: Bool {
    if case .userDefinedType(let typeIdentifier) = self, RawType.StdlibType(rawValue: typeIdentifier) == .wei {
      return true
    }
    return false
  }

  // Strip inoutType for use in type comparisons
  public var stripInout: RawType {
    if case .inoutType(let type) = self {
      return type
    }

    return self
  }

  /// Whether the type is compatible with the given type, i.e., if two expressions of those types can be used
  /// interchangeably.
  public func isCompatible(with otherType: RawType) -> Bool {
    if self == .any || otherType == .any { return true }
    guard self != otherType else { return true }

    switch (self, otherType) {
    case (.arrayType(let e1), .arrayType(let e2)):
      return e1.isCompatible(with: e2)
    case (.fixedSizeArrayType(let e1, _), .fixedSizeArrayType(let e2, _)):
      return e1.isCompatible(with: e2)
    case (.fixedSizeArrayType(let e1, _), .arrayType(let e2)):
      return e1.isCompatible(with: e2)
    case (.dictionaryType(let key1, let value1), .dictionaryType(let key2, let value2)):
      return key1.isCompatible(with: key2) && value1.isCompatible(with: value2)
    default: return false
    }
  }

  public func isCompatible(with otherType: RawType, in passContext: ASTPassContext) -> Bool {
    if let traitDeclarationContext = passContext.traitDeclarationContext,
      self == .selfType,
      traitDeclarationContext.traitIdentifier.name == otherType.name {
      return true
    }

    return isCompatible(with: otherType)
  }

  public func replacingSelf(with enclosingType: RawTypeIdentifier) -> RawType {
    if isSelfType {
      if isInout {
        return RawType.inoutType(.userDefinedType(enclosingType))
      }

      return RawType.userDefinedType(enclosingType)
    }

    return self
  }
}

/// A Flint type.
public struct Type: ASTNode {
  public var rawType: RawType
  public var genericArguments = [Type]()

  public var name: String {
    return rawType.name
  }

  public var isCurrencyType: Bool {
    return rawType.isCurrencyType
  }

  var isSelfType: Bool {
    return rawType.isSelfType
  }

  // Initializers for each kind of raw type.

  public init(identifier: Identifier, genericArguments: [Type] = []) {
    let name = identifier.name
    if let builtInType = RawType.BasicType(rawValue: name) {
      rawType = .basicType(builtInType)
    } else if let externalType = RawType.ExternalType(rawValue: name) {
      rawType = .externalType(externalType)
    } else {
      rawType = .userDefinedType(name)
    }
    self.genericArguments = genericArguments
    self.sourceLocation = identifier.sourceLocation
  }

  public init(ampersandToken: Token, inoutType: Type) {
    rawType = .inoutType(inoutType.rawType)
    sourceLocation = ampersandToken.sourceLocation
  }

  public init(inoutToken: Token, inoutType: Type) {
    rawType = .inoutType(inoutType.rawType)
    sourceLocation = inoutToken.sourceLocation
  }

  public init(openSquareBracketToken: Token, arrayWithElementType type: Type, closeSquareBracketToken: Token) {
    rawType = .arrayType(type.rawType)
    sourceLocation = .spanning(openSquareBracketToken, to: closeSquareBracketToken)
  }

  public init(fixedSizeArrayWithElementType type: Type, size: Int, closeSquareBracketToken: Token) {
    rawType = .fixedSizeArrayType(type.rawType, size: size)
    sourceLocation = .spanning(type, to: closeSquareBracketToken)
  }

  public init(openSquareBracketToken: Token,
              dictionaryWithKeyType keyType: Type,
              valueType: Type,
              closeSquareBracketToken: Token) {
    rawType = .dictionaryType(key: keyType.rawType, value: valueType.rawType)
    sourceLocation = .spanning(openSquareBracketToken, to: closeSquareBracketToken)
  }

  public init(inferredType: RawType, identifier: Identifier) {
    rawType = inferredType
    sourceLocation = identifier.sourceLocation
  }

  // MARK: - ASTNode
  public var sourceLocation: SourceLocation

  public var description: String {
    return name
  }
}
