import XCTest
@testable import SemanticAnalyzer
import Cuckoo
import AST
import Diagnostic

final class SemanticAnalyzerTests: XCTestCase {

  private struct Fixture {
    let pass = SemanticAnalyzer()
  }

  private var emptyPassContext: ASTPassContext {
    var context = ASTPassContext()
    context.environment = Environment()
    return context
  }

  // MARK: postProcess TopLevelModule
  func testTopLevelModule_noDeclaredContract_diagnosticEmitted() {
    // Given
    let f = Fixture()
    let module = TopLevelModule(declarations: [])

    // When
    let result = f.pass.postProcess(topLevelModule: module, passContext: emptyPassContext)

    // Then
    XCTAssertEqual(result.diagnostics.count, 1)
    XCTAssertEqual(result.diagnostics.first!, Diagnostic.contractNotDeclaredInModule())
  }

//  static var allTests = [
//    ("testTopLevelModule_noDeclaredContract_diagnosticEmitted",
//     testTopLevelModule_noDeclaredContract_diagnosticEmitted)
//  ]
}
