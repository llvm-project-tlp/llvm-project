//===- PreprocessorOptions.h ------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file contains the declaration of the PreprocessorOptions class, which
/// is the class for all preprocessor options.
///
//===----------------------------------------------------------------------===//
//
// Coding style: https://mlir.llvm.org/getting_started/DeveloperGuide/
//
//===----------------------------------------------------------------------===//

#ifndef FORTRAN_FRONTEND_PREPROCESSOROPTIONS_H
#define FORTRAN_FRONTEND_PREPROCESSOROPTIONS_H

#include "llvm/ADT/StringRef.h"

namespace Fortran::frontend {

/// Communicates whether to include/exclude predefined and command
/// line preprocessor macros
enum class PPMacrosFlag : uint8_t {
  /// Use the file extension to decide
  Unknown,

  Include,
  Exclude
};

/// Search directories may be specified using several different command line
/// options. This groups the search directories by the option with which they
/// were added.
struct SearchDirectories {
  /// Directories specified by the user with -I
  std::vector<std::string> dirsFromDashI;

  /// Directories specified by the user with -isystem
  std::vector<std::string> dirsFromISystem;

  /// Directories specified by the user with -fintrinsic-modules-path
  std::vector<std::string> dirsFromIntrModPath;
};

/// This class is used for passing the various options used
/// in preprocessor initialization to the parser options.
struct PreprocessorOptions {
  PreprocessorOptions() {}

  std::vector<std::pair<std::string, /*isUndef*/ bool>> macros;

  SearchDirectories searchDirs;

  PPMacrosFlag macrosFlag = PPMacrosFlag::Unknown;

  // -P: Suppress #line directives in -E output
  bool noLineDirectives{false};

  // -fno-reformat: Emit cooked character stream as -E output
  bool noReformat{false};

  // -fpreprocess-include-lines: Treat INCLUDE as #include for -E output
  bool preprocessIncludeLines{false};

  // -dM: Show macro definitions with -dM -E
  bool showMacros{false};

  void addMacroDef(llvm::StringRef name) {
    macros.emplace_back(std::string(name), false);
  }

  void addMacroUndef(llvm::StringRef name) {
    macros.emplace_back(std::string(name), true);
  }
};

} // namespace Fortran::frontend

#endif // FORTRAN_FRONTEND_PREPROCESSOROPTIONS_H
