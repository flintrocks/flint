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
public struct Compiler {
  private var diagnoseOnly: Bool
  private var inputFiles: [URL]?
  private var stdlibFiles: [URL]?
  private var outputDirectory: URL?
  private var dumpAST: Bool?
  private var emitBytecode: Bool?
  private var diagnostics: DiagnosticPool?

  private var sourceContext: SourceContext? {
    if let inputFiles = inputFiles {
      return SourceContext(sourceFiles: inputFiles)
    }

    return nil
  }

  /**
   * Constructs a Compiler that supports only diagnosis of input files
   */
  public init(inputFiles: [URL]) {
    self.diagnoseOnly = true

    self.inputFiles = inputFiles
  }

  /**
   * Constructs a fully fledged Compiler
   */
  public init(inputFiles: [URL], stdlibFiles: [URL], outputDirectory: URL,
       dumpAST: Bool, emitBytecode: Bool, diagnostics: DiagnosticPool) {
    self.diagnoseOnly = false

    self.inputFiles = inputFiles
    self.stdlibFiles = stdlibFiles
    self.outputDirectory = outputDirectory
    self.dumpAST = dumpAST
    self.emitBytecode = emitBytecode
    self.diagnostics = diagnostics
  }

  func tokenizeFiles() throws -> [Token] {
    guard let inputFiles = inputFiles else {
      return []
    }

    let stdlibTokens = try StandardLibrary.default.files.flatMap { try Lexer(sourceFile: $0, isFromStdlib: true).lex() }
    let userTokens = try inputFiles.flatMap { try Lexer(sourceFile: $0).lex() }

    return stdlibTokens + userTokens
  }

  public func diagnose() throws -> [Diagnostic] {
    guard let sourceContext = sourceContext else {
      exitWithCompilerCreationError()
    }

    var diagnoseResult: [Diagnostic] = []
    let tokens = try tokenizeFiles()

    // Turn the tokens into an Abstract Syntax Tree (AST).
    let (parserAST, environment, parserDiagnostics) = Parser(tokens: tokens).parse()
    diagnoseResult += parserDiagnostics
    guard let ast = parserAST else {
      return diagnoseResult
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
    diagnoseResult += passRunnerOutcome.diagnostics

    return diagnoseResult
  }

  public func compile() throws -> CompilationOutcome {
    guard !diagnoseOnly,
      let outputDirectory = outputDirectory,
      let dumpAST = dumpAST,
      let emitBytecode = emitBytecode,
      let diagnostics = diagnostics,
      let sourceContext = sourceContext else {
        exitWithCompilerCreationError()
    }

    let tokens = try tokenizeFiles()

    // Turn the tokens into an Abstract Syntax Tree (AST).
    let (parserAST, environment, parserDiagnostics) = Parser(tokens: tokens).parse()

    if let failed = try diagnostics.checkpoint(parserDiagnostics) {
      if failed {
        exitWithFailure()
      }
      exit(0)
    }

    guard let ast = parserAST else {
      exitWithFailure()
    }

    if dumpAST {
      print(ASTDumper(topLevelModule: ast).dump())
      exit(0)
    }

    // The AST passes to run sequentially.
    let astPasses: [ASTPass] = [
      SemanticAnalyzer(),
      TypeChecker(),
      Optimizer(),
      TraitResolver(),
      FunctionCallCompleter(),
      IRPreprocessor()
    ]

    // Run all of the passes.
    let passRunnerOutcome = ASTPassRunner(ast: ast)
      .run(passes: astPasses, in: environment, sourceContext: sourceContext)
    if let failed = try diagnostics.checkpoint(passRunnerOutcome.diagnostics) {
      if failed {
        exitWithFailure()
      }
      exit(0)
    }

    // Generate YUL IR code.
    let irCode = IRCodeGenerator(topLevelModule: passRunnerOutcome.element, environment: passRunnerOutcome.environment)
      .generateCode()

    // Compile the YUL IR code using solc.
    try SolcCompiler(inputSource: irCode, outputDirectory: outputDirectory, emitBytecode: emitBytecode).compile()

    try diagnostics.display()

    print("Produced binary in \(outputDirectory.path.bold).")
    return CompilationOutcome(irCode: irCode, astDump: ASTDumper(topLevelModule: ast).dump())
  }

  func exitWithFailure() -> Never {
    print("Failed to compile.")
    exit(1)
  }

  func exitWithCompilerCreationError() -> Never {
    print("The compiler has not been initialised in a proper way.")
    exit(1)
  }
}

public struct CompilationOutcome {
  var irCode: String
  var astDump: String
}
