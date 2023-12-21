//===-- tools/flang-format/Format.cpp -------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Format.h"

// #include "flang/Parser/characters.h"
// #include "flang/Parser/message.h"
// #include "flang/Parser/parse-tree-visitor.h"
// #include "flang/Parser/parse-tree.h"
// #include "flang/Parser/parsing.h"
// #include "flang/Parser/unparse.h"
// #include "flang/Semantics/expression.h"

namespace Fortran {

namespace format {

int format(llvm::StringRef path, parser::Options parserOpts,
    const FormatOptions &formatOpts) {
  if (formatOpts.sourceFormat == SourceFormat::Auto) {
    auto dot{path.rfind(".")};
    if (dot != std::string::npos) {
      std::string suffix{path.substr(dot + 1)};
      parserOpts.isFixedForm = suffix == "f" || suffix == "F" || suffix == "ff";
    }
  }

  parser::AllSources allSources;
  parser::AllCookedSources allCookedSources{allSources};
  parser::Parsing parsing{allCookedSources};

  parsing.Prescan(path.str(), parserOpts);
  if (!parsing.messages().empty() && parsing.messages().AnyFatalError()) {
    return EXIT_FAILURE;
  }

  parsing.Parse(llvm::outs());
  parsing.ClearLog();
  parsing.messages().Emit(llvm::errs(), parsing.allCooked());
  if (!parsing.consumedWholeFile()) {
    return EXIT_FAILURE;
  }
  if ((!parsing.messages().empty() && parsing.messages().AnyFatalError()) ||
      !parsing.parseTree()) {
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}

} // namespace format

} // namespace Fortran
