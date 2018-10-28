//
//  Compiler.swift
//  flintcPackageDescription
//
//  Created by Franklin Schrans on 12/19/17.
//

import Foundation
import AST
import Diagnostic
import Lexer
import Parser
import SemanticAnalyzer
import TypeChecker
import Optimizer
import IRGen

/// Runs the different stages of the compiler.
struct Compiler {
  var inputFiles: [URL]
  var stdlibFiles: [URL]
  var outputDirectory: URL
  var diagnostics: DiagnosticPool

  var sourceContext: SourceContext {
    return SourceContext(sourceFiles: inputFiles)
  }

  func tokenizeFiles() throws -> [Token] {
    let stdlibTokens = try StandardLibrary.default.files.flatMap { try Lexer(sourceFile: $0, isFromStdlib: true).lex() }
    let userTokens = try inputFiles.flatMap { try Lexer(sourceFile: $0).lex() }

    return stdlibTokens + userTokens
  }

  func compile() throws -> [Diagnostic] {
    let tokens = try tokenizeFiles()

    // Turn the tokens into an Abstract Syntax Tree (AST).
    let (parserAST, environment, parserDiagnostics) = Parser(tokens: tokens).parse()

    if let failed = try diagnostics.checkpoint(parserDiagnostics) {
      if failed {
        return parserDiagnostics
      }
    }

    guard let ast = parserAST else {
      return parserDiagnostics
    }

    // The AST passes to run sequentially.
    let astPasses: [ASTPass] = [
      SemanticAnalyzer(),
      TypeChecker(),
      Optimizer(),
      IRPreprocessor()
    ]

    // Run all of the passes.
    let passRunnerOutcome = ASTPassRunner(ast: ast)
      .run(passes: astPasses, in: environment, sourceContext: sourceContext)
    if let failed = try diagnostics.checkpoint(passRunnerOutcome.diagnostics) {
      if failed {
        return passRunnerOutcome.diagnostics
      }
      return []
    }
    return []
  }

  func exitWithFailure() -> Never {
    print("Failed to compile.")
    exit(1)
  }
}
