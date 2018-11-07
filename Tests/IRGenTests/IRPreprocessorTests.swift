import XCTest
@testable import IRGen
import AST
import Cuckoo

// MARK: Tests
final class IRPreprocessorTests: XCTestCase {

  func testIRPreprocessor() {
    let mangler = MockManglerProtocol()
    stub (mangler) { stub in
      when(stub.mangleFunctionName(any(), parameterTypes: any(), enclosingType: any()).thenReturn("")
    }

    let pp = IRPreprocessor(mangler: mangler)
    // etc 
    pp.process(functionDeclaration: <#T##FunctionDeclaration#>, passContext: <#T##ASTPassContext#>)
//    var mangler = StubMangler()
//    mangler.stub_isMem = { (_ name: String) -> String in
//      return ""
//      return ""
//    }
//
//    let preprocessor = IRPreprocessor(mangler: mangler)
  }

  static var allTests: [(String, () -> Void)] = []
}
