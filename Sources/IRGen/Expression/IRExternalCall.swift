//
//  IRExternalCall.swift
//  IRGen
//
//  Created by Yicheng Luo on 11/14/18.
//
import AST

/// Generates code for an external call.
struct IRExternalCall {
  let externalCall: ExternalCall

  func rendered(functionContext: FunctionContext) -> ExpressionFragment {
    // hyper-parameter defaults
    var gasExpression = ExpressionFragment(pre: "", "2300")
    var valueExpression = ExpressionFragment(pre: "", "0")

    // hyper-parameters specified in the external call
    for parameter in externalCall.hyperParameters {
      switch parameter.identifier!.name {
      case "gas":
        gasExpression = IRExpression(expression: parameter.expression, asLValue: false).rendered(functionContext: functionContext)
      case "value":
        valueExpression = IRExpression(expression: parameter.expression, asLValue: false).rendered(functionContext: functionContext)
      default:
        break
      }
    }

    // Render the address of the external contract.
    let addressExpression = IRExpression(expression: externalCall.functionCall.lhs, asLValue: false).rendered(functionContext: functionContext)

    // The input stack consists of three parts:
    // - function selector (4 bytes of Keccak-256 hash of the signature)
    // - fixed-size data
    // - dynamic-size data
    var fixedSlots: [ExpressionFragment] = []
//    var dynamicSlots: [ExpressionFragment] = []
    var inputSize = 4
    guard case .functionCall(let functionCall) = externalCall.functionCall.rhs else {
      fatalError("cannot match external call with function")
    }
    guard case .matchedFunction(let matchingFunction) =
      functionContext.environment.matchFunctionCall(functionCall,
                                                    enclosingType: functionCall.identifier.enclosingType ?? functionContext.enclosingTypeName,
                                                    typeStates: [],
                                                    callerProtections: [],
                                                    scopeContext: functionContext.scopeContext) else {
      fatalError("cannot match function signature in external call")
    }

    for (parameterType, parameter) in zip(matchingFunction.parameterTypes, functionCall.arguments) {
      switch parameterType {
      case .basicType, .solidityType:
        inputSize += 32
        fixedSlots.append(IRExpression(expression: parameter.expression, asLValue: false).rendered(functionContext: functionContext))
      default:
        fatalError("cannot use non-basic type in external call")
      }
    }

    // render input stack storage
    var currentPosition = 4
    let fixedSlotsPreambles = fixedSlots.map { $0.preamble }
    let fixedSlotsExpressions = fixedSlots.map { (slot: ExpressionFragment) -> String in
      let storedPosition = currentPosition
      currentPosition += 32
      return "mstore(add(flint$callInput, \(storedPosition)), \(slot.expression))"
    }

    // The output is simply memory suitable for the declared return type.
    let outputSize = 32
    guard let functionSelector = (matchingFunction.declaration.externalSignatureHash?.map { [$0].toHexString() }) else {
      fatalError("cannot find function selector for function")
    }

    return ExpressionFragment(
        pre: """
        \(gasExpression.preamble)
        \(valueExpression.preamble)
        \(addressExpression.preamble)
        \(fixedSlotsPreambles.joined(separator: "\n"))
        let flint$callInput := flint$allocateMemory(\(inputSize))
        mstore8(flint$callInput, 0x\(functionSelector[0]))
        mstore8(add(flint$callInput, 1), 0x\(functionSelector[1]))
        mstore8(add(flint$callInput, 2), 0x\(functionSelector[2]))
        mstore8(add(flint$callInput, 3), 0x\(functionSelector[3]))
        \(fixedSlotsExpressions.joined(separator: "\n"))
        let flint$callOutput := flint$allocateMemory(\(outputSize))
        let flint$callSuccess := call(
            \(gasExpression.expression),
            \(addressExpression.expression),
            \(valueExpression.expression),
            flint$callInput,
            \(inputSize),
            flint$callOutput,
            \(outputSize)
          )
        flint$callOutput := mload(flint$callOutput)
        """,
        "flint$callOutput"
      )
    
    /*
    // prepare input (argument) memory
    let inSize = ... // calculate number of bytes needed for the full argument stack
    let input = allocate(inSize)
    mstore8(input, /* first byte of Keccak-256 hash of target function signature */)
    mstore8(input + 1, /* second byte of same */)
    mstore8(input + 2, /* third byte of same */)
    mstore8(input + 3, /* fourth byte of same */)
    /* store remaining arguments according to the Solidity ABI */

    // prepare output memory
    let outSize = ... // calculate number of bytes needed for the output
    let output = allocate(outSize)

    // enter external call state
    let previousState = self.flintState$
    self.flintState$ = "$externalCall"

    // execute call
    let callSuccess = call(
        gasAmount,
        externalContractAddress,
        weiAmount,
        in, inSize,
        out, outSize
      )

    // restore state
    self.flintState$ = previousState
    */
    
    /*
    let environment = functionContext.environment
    let enclosingType: RawTypeIdentifier = functionContext.enclosingTypeName
    let scopeContext: ScopeContext = functionContext.scopeContext

    if case .matchedEvent(let eventInformation) =
      environment.matchEventCall(functionCall,
                                 enclosingType: enclosingType,
                                 scopeContext: scopeContext) {
      return IREventCall(eventCall: functionCall, eventDeclaration: eventInformation.declaration)
        .rendered(functionContext: functionContext)
    }

    let args: String = functionCall.arguments.map({ argument in
      return IRExpression(expression: argument.expression, asLValue: false).rendered(functionContext: functionContext)
    }).joined(separator: ", ")
    let identifier = functionCall.mangledIdentifier ?? functionCall.identifier.name
    return "\(identifier)(\(args))"
    */
  }
}
