//===-- tools/flang-format/Main.h -----------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FLANG_TOOLS_FLANG_FORMAT_MAIN_H
#define FLANG_TOOLS_FLANG_FORMAT_MAIN_H

namespace Fortran {

namespace format {

int flang_format(int argc, char *const argv[]);

} // namespace format

} // namespace Fortran

#endif // FLANG_TOOLS_FLANG_FORMAT_MAIN_H
