//
//  DiagnosticTranslator.swift
//  AST
//
//  Created by Ethan on 27/10/2018.
//

import LanguageServerProtocol
import Diagnostic

public protocol DiagnosticTranslator {
  func translate(diagnostic: Diagnostic.Diagnostic) -> LanguageServerProtocol.Diagnostic
}
