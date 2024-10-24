! Check to make sure flang is somewhat picky about -g options.
! This is a selection of tests from clang/test/Driver/debug-options.c that are
! relevant to flang.

! Linux.
! RUN: %clang -### -c -g %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_GDB %s
! RUN: %clang -### -c -g2 %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_GDB %s
! RUN: %clang -### -c -g3 %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_GDB %s
! RUN: %clang -### -c -ggdb %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_GDB %s
! RUN: %clang -### -c -ggdb1 %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY -check-prefix=G_GDB %s
! RUN: %clang -### -c -ggdb3 %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_GDB %s
! RUN: %clang -### -c -glldb %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE -check-prefix=G_LLDB %s
! RUN: %clang -### -c -gsce %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_SCE %s
! RUN: %clang -### -c -gdbx %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_DBX %s

! Darwin.
! RUN: %clang -### -c -g %s -target x86_64-apple-darwin14 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF2 \
! RUN:                         -check-prefix=G_LLDB %s
! RUN: %clang -### -c -g %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 \
! RUN:                         -check-prefix=G_LLDB %s
! RUN: %clang -### -c -g2 %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -g3 %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -ggdb %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 \
! RUN:                         -check-prefix=G_GDB %s
! RUN: %clang -### -c -ggdb1 %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY %s
! RUN: %clang -### -c -ggdb3 %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -g %s -target x86_64-apple-macosx10.11 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -g %s -target x86_64-apple-macosx10.10 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY_DWARF2 %s
! RUN: %clang -### -c -g %s -target armv7-apple-ios9.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -g %s -target armv7-apple-ios8.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY_DWARF2 %s
! RUN: %clang -### -c -g %s -target armv7k-apple-watchos 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -g %s -target arm64-apple-tvos9.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -g %s -target x86_64-apple-driverkit19.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -g %s -target x86_64-apple-macosx15 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF5 %s
! RUN: %clang -### -c -g %s -target arm64-apple-ios17.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -g %s -target arm64-apple-ios18.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF5 %s
! RUN: %clang -### -c -g %s -target arm64_32-apple-watchos11 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF5 %s
! RUN: %clang -### -c -g %s -target arm64-apple-tvos18.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF5 %s
! RUN: %clang -### -c -g %s -target x86_64-apple-driverkit24.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF5 %s
! RUN: %clang -### -c -g %s -target arm64-apple-xros1 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -g %s -target arm64-apple-xros2 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF5 %s

! FreeBSD.
! RUN: %clang -### -c -g %s -target x86_64-pc-freebsd 2>&1 \
! RUN:             | FileCheck -check-prefix=G_GDB \
! RUN:                         -check-prefix=G_DWARF4 %s

! Haiku.
! RUN: %clang -### -c -g %s --target=x86_64-unknown-haiku 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s

! Windows.
! RUN: %clang -### -c -g %s -target x86_64-w64-windows-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_GDB %s
! RUN: %clang -### -c -g %s -target x86_64-windows-msvc 2>&1 \
! RUN:             | FileCheck -check-prefix=G_NOTUNING %s

! On AIX, -g defaults to limited debug info.
! RUN: %clang -### -c -g %s -target powerpc-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED %s
! RUN: %clang -### -c -g %s -target powerpc64-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED %s
! RUN: %clang -### -c -g %s -target powerpc-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=G_NOTUNING %s
! RUN: %clang -### -c -g %s -target powerpc64-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=G_NOTUNING %s
! RUN: %clang -### -c -g -gdbx %s -target powerpc-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefixes=G_LIMITED,G_DBX %s
! RUN: %clang -### -c -g -gdbx %s -target powerpc64-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefixes=G_LIMITED,G_DBX %s

! On AIX, -g defaults to -gno-column-info.
! RUN: %clang -### -c -g %s -target powerpc-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=NOCI %s
! RUN: %clang -### -c -g %s -target powerpc64-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=NOCI %s
! RUN: %clang -### -c -g %s -target powerpc-ibm-aix-xcoff -gcolumn-info 2>&1 \
! RUN:             | FileCheck -check-prefix=CI %s
! RUN: %clang -### -c -g %s -target powerpc64-ibm-aix-xcoff -gcolumn-info \
! RUN:             2>&1 | FileCheck -check-prefix=CI %s

! For DBX, -g defaults to -gstrict-dwarf.
! RUN: %clang -### -c -g %s -target powerpc-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=STRICT %s
! RUN: %clang -### -c -g %s -target powerpc64-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=STRICT %s
! RUN: %clang -### -c -g -gno-strict-dwarf %s -target powerpc-ibm-aix-xcoff \
! RUN:             2>&1 | FileCheck -check-prefix=NOSTRICT %s
! RUN: %clang -### -c -g %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=NOSTRICT %s
! RUN: %clang -### -c -g -ggdb %s -target powerpc-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=NOSTRICT %s


! WebAssembly should default to DWARF4.
! RUN: %clang -### -c -g %s -target wasm32 2>&1 \
! RUN:             | FileCheck -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -g %s -target wasm64 2>&1 \
! RUN:             | FileCheck -check-prefix=G_DWARF4 %s

! RUN: %clang -### -c -gdwarf-2 %s 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY_DWARF2 %s
!
! RUN: not %clang -### -c -gfoo %s 2>&1 | FileCheck -check-prefix=G_ERR %s
! RUN: %clang -### -c -g -g0 %s 2>&1 | FileCheck -check-prefix=G_NO %s
! RUN: %clang -### -c -ggdb0 %s 2>&1 | FileCheck -check-prefix=G_NO %s
! RUN: %clang -### -c -glldb -g0 %s 2>&1 | FileCheck -check-prefix=G_NO %s
! RUN: %clang -### -c -glldb -g1 %s 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY -check-prefix=G_LLDB %s

! RUN: %clang -### -c -g1 %s 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY %s
! RUN: %clang -### -c -gmlt %s 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY %s
! RUN: %clang -### -c -gline-tables-only %s 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY %s
! RUN: %clang -### -c -gline-tables-only %s -target x86_64-apple-darwin 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY %s
! RUN: %clang -### -c -gline-tables-only %s -target i686-pc-openbsd 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY_DWARF2 %s
! RUN: %clang -### -c -gline-tables-only -g %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY %s
! RUN: %clang -### -c -gline-tables-only -g %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -gline-tables-only -g %s -target i686-pc-openbsd 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY_DWARF2 %s
! RUN: %clang -### -c -gline-tables-only -g %s --target=i386-pc-solaris 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY %s
! RUN: %clang -### -c -gline-tables-only -g0 %s 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_NO %s
!
! RUN: %clang -### -c -gline-directives-only %s -target x86_64-apple-darwin 2>&1 \
! RUN:             | FileCheck -check-prefix=GLIO_ONLY %s
! RUN: %clang -### -c -gline-directives-only %s -target i686-pc-openbsd 2>&1 \
! RUN:             | FileCheck -check-prefix=GLIO_ONLY_DWARF2 %s
! RUN: %clang -### -c -gline-directives-only -g %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY %s
! RUN: %clang -### -c -gline-directives-only -g %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE -check-prefix=G_DWARF4 %s
! RUN: %clang -### -c -gline-directives-only -g %s -target i686-pc-openbsd 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY_DWARF2 %s
! RUN: %clang -### -c -gline-directives-only -g %s --target=i386-pc-solaris 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY %s
! RUN: %clang -### -c -gline-directives-only -g0 %s 2>&1 \
! RUN:             | FileCheck -check-prefix=GLIO_NO %s

! RUN: not %flang -### -c -gdwarf-2 -gdwarf64 --target=x86_64 %s 2>&1 \
! RUN:     | FileCheck -check-prefix=GDWARF64_VER %s
! RUN: %flang -### -c -gdwarf-5 -gdwarf64 -target x86_64 %s 2>&1 \
! RUN:     | FileCheck -check-prefix=GDWARF64_ON %s
! RUN: %flang -### -c -gdwarf-4 -gdwarf64 -target x86_64 %s 2>&1 \
! RUN:     | FileCheck -check-prefix=GDWARF64_ON %s
! RUN: %flang -### -c -gdwarf-3 -gdwarf64 -target x86_64 %s 2>&1 \
! RUN:     | FileCheck -check-prefix=GDWARF64_ON %s
! RUN: %flang -### -c -gdwarf-4 -gdwarf64 -target x86_64 -target x86_64 %s 2>&1 \
! RUN:     | FileCheck -check-prefix=GDWARF64_ON %s
! RUN: not %flang -### -c -gdwarf-4 -gdwarf64 --target=i386-linux-gnu %s 2>&1 \
! RUN:     | FileCheck -check-prefix=GDWARF64_32ARCH %s
! RUN: not %flang -### -c -gdwarf-4 -gdwarf64 -target x86_64-apple-darwin %s 2>&1 \
! RUN:     | FileCheck -check-prefix=GDWARF64_ELF %s

! GDWARF64_ON:  "-gdwarf64"
! GDWARF64_VER:  error: invalid argument '-gdwarf64' only allowed with 'DWARFv3 or greater'
! GDWARF64_32ARCH: error: invalid argument '-gdwarf64' only allowed with '64 bit architecture'
! GDWARF64_ELF: error: invalid argument '-gdwarf64' only allowed with 'ELF platforms'

! Default to -fno-dwarf-directory-asm for -fno-integrated-as before DWARF v5.
! RUN: %flang -### -target x86_64 -c -gdwarf-2 %s 2>&1 \
! RUN:     | FileCheck --check-prefix=DIRECTORY %s
! RUN: %flang -### -target x86_64 -c -gdwarf-5 %s 2>&1 \
! RUN:     | FileCheck --check-prefix=DIRECTORY %s

! DIRECTORY-NOT: "-fno-dwarf-directory-asm"

end program
