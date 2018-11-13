import XCTest
@testable import SemanticAnalyzer
import Cuckoo
import AST
import Diagnostic
import Source
import Lexer

final class SemanticAnalyzerTests: XCTestCase {

  private struct Fixture {
    let pass = SemanticAnalyzer()
  }

  private func buildPassContext(stubEnvironment: (MockEnvironment.Stubbing) -> Void) -> ASTPassContext {
    var context = ASTPassContext()
    let environment = MockEnvironment()
    stub(environment, block: stubEnvironment)
    context.environment = environment
    return context
  }

  // MARK: postProcess TopLevelModule
  func testTopLevelModule_noDeclaredContract_diagnosticEmitted() {
    // Given
    let f = Fixture()
    let module = TopLevelModule(declarations: [])
    let passContext = buildPassContext { (environment) in
      environment.hasDeclaredContract().thenReturn(false)
    }

    // When
    let result = f.pass.postProcess(topLevelModule: module, passContext: passContext)

    // Then
    XCTAssertEqual(result.diagnostics.count, 1)
    XCTAssertEqual(result.diagnostics.first!, Diagnostic.contractNotDeclaredInModule())
  }

  func testTopLevelModule_privateFallbackNotUniqueForContract_diagnosticEmitted() {
    // Given
    let f = Fixture()

//    let contract = ContractDeclaration(contractToken: TokenStub(), identifier: Identifier(name: "", sourceLocation: ),
    //conformances: [], states: [], members: [])
//    let module = TopLevelModule(declarations: [.contractDeclaration(contract)])
  }

//  static var allTests = [
//    ("testTopLevelModule_noDeclaredContract_diagnosticEmitted",
//     testTopLevelModule_noDeclaredContract_diagnosticEmitted)
//  ]
}
