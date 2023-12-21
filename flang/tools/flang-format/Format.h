//===-- tools/flang-format/Format.h ---------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FLANG_TOOLS_FLANG_FORMAT_FORMAT_H
#define FLANG_TOOLS_FLANG_FORMAT_FORMAT_H

#include "flang/Parser/parsing.h"
#include "llvm/ADT/StringRef.h"

namespace Fortran {

namespace format {

// The source file formats.
enum class SourceFormat {
  // The format of the source file will be determined by the extension.
  Auto,

  // Process the files as fixed form.
  Fixed,

  // Process the files as free form.
  Free,
};

struct FormatOptions {
  // The output encoding of the file. This is relevant for comments which may
  // not be in ASCII.
  Fortran::parser::Encoding encoding{Fortran::parser::Encoding::LATIN_1};

  // How to process the source file.
  SourceFormat sourceFormat = SourceFormat::Auto;

  // If true, format the file in place. Otherwise, the formatted file will be
  // written to stdout.
  bool inplace = false;
};

// Format a file.
int format(llvm::StringRef file, Fortran::parser::Options parserOpts,
    const FormatOptions &formatOpts);

} // namespace format

} // namespace Fortran

#endif // FLANG_TOOLS_FLANG_FORMAT_FORMAT_H
