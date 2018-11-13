import XCTest
@testable import SemanticAnalyzer
import Cuckoo
import AST
import Diagnostic

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

//  static var allTests = [
//    ("testTopLevelModule_noDeclaredContract_diagnosticEmitted",
//     testTopLevelModule_noDeclaredContract_diagnosticEmitted)
//  ]
}
