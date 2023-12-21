//===-- tools/flang-format/Main.cpp ---------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Main.h"
#include "Format.h"

#include "flang/Common/Version.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include <list>
#include <optional>
#include <string>

namespace Fortran {

namespace format {

struct CommandLineOptions {
  bool backslash{false};
  bool extendedSource{false};
  bool freeForm{false};
  bool fixedForm{false};
  bool debugLines{false};
  bool version{false};
  std::list<std::string> files;
};

static const FormatOptions getFormatOptions(const CommandLineOptions &clOpts) {
  FormatOptions opts;

  if (clOpts.fixedForm) {
    opts.sourceFormat = SourceFormat::Fixed;
  } else if (clOpts.freeForm) {
    opts.sourceFormat = SourceFormat::Free;
  }

  return opts;
}

static parser::Options getParserOptions(const CommandLineOptions &clOpts) {
  parser::Options opts;

  opts.predefinitions.emplace_back("__flang__", "1");
  opts.predefinitions.emplace_back(
      "__flang_major__", FLANG_VERSION_MAJOR_STRING);
  opts.predefinitions.emplace_back(
      "__flang_minor__", FLANG_VERSION_MINOR_STRING);
  opts.predefinitions.emplace_back(
      "__flang_patchlevel__", FLANG_VERSION_PATCHLEVEL_STRING);

  opts.features.Enable(common::LanguageFeature::BackslashEscapes, true);

  opts.features.Enable(common::LanguageFeature::OpenACC);
  opts.predefinitions.emplace_back("_OPENACC", "202211");

  // FIXME: This macro probably needs to be changed.
  opts.features.Enable(common::LanguageFeature::OpenMP);
  opts.predefinitions.emplace_back("_OPENMP", "201511");

  opts.features.Enable(
      common::LanguageFeature::BackslashEscapes, clOpts.backslash);

  if (clOpts.debugLines) {
    opts.features.Enable(common::LanguageFeature::OldDebugLines);
  }

  if (clOpts.extendedSource) {
    opts.fixedFormColumns = 132;
  }

  if (clOpts.fixedForm) {
    opts.isFixedForm = true;
  } else if (clOpts.freeForm) {
    opts.isFixedForm = false;
  }

  return opts;
}

static int checkCommandLineOptions(const CommandLineOptions &clOpts) {
  if (clOpts.fixedForm && clOpts.freeForm) {
    llvm::errs() << "error: cannot specify both --fixed-form and --free-form\n";
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}

static void resetCommandLineOptions() {
  llvm::cl::ResetCommandLineParser();
  for (auto &i : llvm::cl::getRegisteredOptions()) {
    llvm::cl::Option &opt = *i.getValue();
    if (opt.Categories.size() == 1) {
      llvm::StringRef cat = opt.Categories[0]->getName();
      if (cat == "General options" or cat == "Generic Options" or
          cat == "Color Options")
        opt.setHiddenFlag(llvm::cl::ReallyHidden);
    }
  }
}

static const CommandLineOptions parseCommandLineOptions(
    int argc, char *const argv[]) {
  using namespace llvm;

  CommandLineOptions clOpts;

  // The command line options have to be registered after resetting the parser.
  cl::opt<bool, true> backslash("backslash", cl::location(clOpts.backslash),
      cl::init(false),
      cl::desc(
          "Specify that backslash in string introduces an escape character"));

  cl::opt<bool, true> oldDebugLines("debug-lines",
      cl::location(clOpts.debugLines), cl::init(false),
      cl::desc("Enable fixed form D lines"));

  cl::opt<bool, true> extendedSource("extended-source",
      cl::location(clOpts.extendedSource), cl::init(false),
      cl::desc("Process source files 132-column fixed form"));

  cl::opt<bool, true> fixedForm("ffixed-form", cl::location(clOpts.fixedForm),
      cl::init(false), cl::desc("Process source files in fixed form"));

  cl::opt<bool, true> freeForm("ffree-form", cl::location(clOpts.freeForm),
      cl::init(false), cl::desc("Process source files in free form"));

  cl::opt<bool, true> version("version", cl::location(clOpts.version),
      cl::init(false), cl::desc("Print the tool version"));

  cl::list<std::string, std::list<std::string>> files(cl::Positional,
      cl::ZeroOrMore, cl::location(clOpts.files), cl::desc("<file>"));

  cl::ParseCommandLineOptions(argc, argv);

  return clOpts;
}

int flang_format(int argc, char *const argv[]) {
  // Reset all the command line options so the LLVM-specific options that are
  // always registered are removed.
  resetCommandLineOptions();
  const CommandLineOptions clOpts = parseCommandLineOptions(argc, argv);
  if (checkCommandLineOptions(clOpts) != EXIT_SUCCESS)
    return EXIT_FAILURE;

  if (clOpts.version) {
    llvm::outs() << "flang-format " << FLANG_VERSION_MAJOR_STRING << "."
                 << FLANG_VERSION_MINOR_STRING << "."
                 << FLANG_VERSION_PATCHLEVEL_STRING << "\n";
    return EXIT_SUCCESS;
  }

  const parser::Options parserOpts = getParserOptions(clOpts);
  const format::FormatOptions toolOpts = getFormatOptions(clOpts);

  if (clOpts.files.empty()) {
    if (format::format("-", parserOpts, toolOpts) == EXIT_FAILURE)
      return EXIT_FAILURE;
  } else {
    for (const auto &file : clOpts.files)
      if (format::format(file, parserOpts, toolOpts) == EXIT_FAILURE)
        return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}

} // namespace format

} // namespace Fortran
