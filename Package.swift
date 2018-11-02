// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "flintc",
  products: [
    .executable(
      name: "flintc",
      targets: [
        "flintc",
      ]
    ),
    .executable(
      name: "lite",
      targets: [
        "lite",
      ]
    ),
    .executable(
      name: "langsrv",
      targets: [
        "langsrv",
      ]
    ),
    .executable(
      name: "file-check",
      targets: [
        "file-check",
      ]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "0.7.2"),
    .package(url: "https://github.com/onevcat/Rainbow.git", from: "3.0.0"),
    .package(url: "https://github.com/kylef/Commander", from: "0.8.0"),
    .package(url: "https://github.com/llvm-swift/Lite.git", from: "0.0.3"),
    .package(url: "https://github.com/llvm-swift/FileCheck.git", from: "0.0.4"),
    .package(url: "https://github.com/llvm-swift/Symbolic.git", from: "0.0.1"),
    .package(url: "https://github.com/theguild/json-swift.git", from: "4.0.0"),
    .package(url: "https://github.com/theguild/swift-lsp.git", from: "4.0.0"),
  ],
  targets: [
    // MARK: Source -
    .target(
      name: "Source",
      dependencies: []
    ),
    .testTarget(
      name: "SourceTests",
      dependencies: [
        "Source",
      ]
    ),
    // MARK: Compiler -
    .target(
      name: "Compiler",
      dependencies: [
        "Parser",
        "Lexer",
        "SemanticAnalyzer",
        "TypeChecker",
        "Optimizer",
        "IRGen",
        "Commander",
        "Rainbow",
        "Symbolic",
        "Diagnostic",
      ]
    ),
    .testTarget(
      name: "CompilerTests",
      dependencies: [
        "Compiler",
      ]
    ),
    // MARK: Diagnostic -
    .target(
      name: "Diagnostic",
      dependencies: [
        "Source",
        "Rainbow",
      ]
    ),
    .testTarget(
      name: "DiagnosticTests",
      dependencies: [
        "Diagnostic",
      ]
    ),
    // MARK: Lexer -
    .target(
      name: "Lexer",
      dependencies: [
        "Source",
        "Diagnostic",
      ]
    ),
    .testTarget(
      name: "LexerTests",
      dependencies: [
        "Lexer",
      ]
    ),
    // MARK: AST -
    .target(
      name: "AST",
      dependencies: [
        "Source",
        "Diagnostic",
        "Lexer",
      ],
      exclude: ["ASTPass/ASTPass.template.swift"],
      sources: [".", "../../.derived-sources/AST"]
    ),
    .testTarget(
      name: "ASTTests",
      dependencies: [
        "AST",
      ]
    ),
    // MARK: Parser -
    .target(
      name: "Parser",
      dependencies: [
        "Source",
        "Diagnostic",
        "AST",
        "Lexer",
      ]
    ),
    .testTarget(
      name: "ParserTests",
      dependencies: [
        "Parser",
      ]
    ),
    // MARK: SemanticAnalyzer -
    .target(
      name: "SemanticAnalyzer",
      dependencies: [
        "Source",
        "Diagnostic",
        "AST",
      ]
    ),
    .testTarget(
      name: "SemanticAnalyzerTests",
      dependencies: [
        "SemanticAnalyzer",
      ]
    ),
    // MARK: TypeChecker -
    .target(
      name: "TypeChecker",
      dependencies: [
        "Source",
        "Diagnostic",
        "AST",
      ]
    ),
    .testTarget(
      name: "TypeCheckerTests",
      dependencies: [
        "TypeChecker",
      ]
    ),
    // MARK: Optimizer -
    .target(
      name: "Optimizer",
      dependencies: [
        "Source",
        "Diagnostic",
        "AST",
      ]
    ),
    .testTarget(
      name: "OptimizerTests",
      dependencies: [
        "Optimizer",
      ]
    ),
    // MARK: IRGen -
    .target(
      name: "IRGen",
      dependencies: [
        "Source",
        "Diagnostic",
        "AST",
        "CryptoSwift",
      ]
    ),
    .testTarget(
      name: "IRGenTests",
      dependencies: [
        "IRGen",
      ]
    ),
    // MARK: flintc -
    .target(
      name: "flintc",
      dependencies: [
        "Compiler",
      ]
    ),
    // MARK: lite -
    .target(
        name: "lite",
        dependencies: [
          "LiteSupport",
          "Rainbow",
          "Symbolic",
      ]
    ),
    // MARK: file-check
    .target(
        name: "file-check",
        dependencies: [
          "FileCheck",
          "Commander",
      ]
    ),
    // MARK: langsrv
    .target(
      name: "langsrv",
      dependencies: [
        "Compiler",
        "JSONLib",
        "LanguageServerProtocol",
        "JsonRpcProtocol",
      ],
      path: "Sources/LSP/langsrv")
    ]
)
