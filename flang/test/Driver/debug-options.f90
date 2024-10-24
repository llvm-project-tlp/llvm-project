! Check to make sure flang is somewhat picky about -g options.

! Linux.
! RUN: %flang -### -c -g %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_GDB %s
! RUN: %flang -### -c -g2 %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_GDB %s
! RUN: %flang -### -c -g3 %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_GDB %s
! RUN: %flang -### -c -ggdb %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_GDB %s
! RUN: %flang -### -c -ggdb1 %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY -check-prefix=G_GDB %s
! RUN: %flang -### -c -ggdb3 %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_GDB %s
! RUN: %flang -### -c -glldb %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE -check-prefix=G_LLDB %s
! RUN: %flang -### -c -gsce %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_SCE %s
! RUN: %flang -### -c -gdbx %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_DBX %s

! Android.
! Android should always generate DWARF4.
! RUN: %flang -### -c -g %s -target arm-linux-androideabi 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED -check-prefix=G_DWARF4 %s

! Darwin.
! RUN: %flang -### -c -g %s -target x86_64-apple-darwin14 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF2 \
! RUN:                         -check-prefix=G_LLDB %s
! RUN: %flang -### -c -g %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 \
! RUN:                         -check-prefix=G_LLDB %s
! RUN: %flang -### -c -g2 %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -g3 %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -ggdb %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 \
! RUN:                         -check-prefix=G_GDB %s
! RUN: %flang -### -c -ggdb1 %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY %s
! RUN: %flang -### -c -ggdb3 %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -g %s -target x86_64-apple-macosx10.11 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -g %s -target x86_64-apple-macosx10.10 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY_DWARF2 %s
! RUN: %flang -### -c -g %s -target armv7-apple-ios9.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -g %s -target armv7-apple-ios8.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY_DWARF2 %s
! RUN: %flang -### -c -g %s -target armv7k-apple-watchos 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -g %s -target arm64-apple-tvos9.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -g %s -target x86_64-apple-driverkit19.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -g %s -target x86_64-apple-macosx15 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF5 %s
! RUN: %flang -### -c -g %s -target arm64-apple-ios17.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -g %s -target arm64-apple-ios18.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF5 %s
! RUN: %flang -### -c -g %s -target arm64_32-apple-watchos11 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF5 %s
! RUN: %flang -### -c -g %s -target arm64-apple-tvos18.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF5 %s
! RUN: %flang -### -c -g %s -target x86_64-apple-driverkit24.0 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF5 %s
! RUN: %flang -### -c -g %s -target arm64-apple-xros1 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -g %s -target arm64-apple-xros2 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF5 %s
!
! RUN: %flang -### -c -fsave-optimization-record %s    \
! RUN:        -target x86_64-apple-darwin 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY %s
! RUN: %flang -### -c -g -fsave-optimization-record %s \
! RUN:        -target x86_64-apple-darwin 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE %s

! FreeBSD.
! RUN: %flang -### -c -g %s -target x86_64-pc-freebsd 2>&1 \
! RUN:             | FileCheck -check-prefix=G_GDB \
! RUN:                         -check-prefix=G_DWARF4 %s

! Haiku.
! RUN: %flang -### -c -g %s --target=x86_64-unknown-haiku 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE \
! RUN:                         -check-prefix=G_DWARF4 %s

! Windows.
! RUN: %flang -### -c -g %s -target x86_64-w64-windows-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_GDB %s
! RUN: %flang -### -c -g %s -target x86_64-windows-msvc 2>&1 \
! RUN:             | FileCheck -check-prefix=G_NOTUNING %s

! On the PS4/PS5, -g defaults to -gno-column-info. We default to always
! generating the arange section, but keyed off SCE DebuggerTuning being in
! play during codegen, instead of -generate-arange-section.
! RUN: %flang -### -c %s -target x86_64-scei-ps4 2>&1 \
! RUN:             | FileCheck -check-prefix=NOG_PS %s
! RUN: %flang -### -c %s -target x86_64-sie-ps5 2>&1 \
! RUN:             | FileCheck -check-prefix=NOG_PS %s
!/ PS4 will stay on v4 even if the generic default version changes.
! RUN: %flang -### -c %s -g -target x86_64-scei-ps4 2>&1 \
! RUN:             | FileCheck -check-prefixes=G_DWARF4,G_SCE,NOCI %s
! RUN: %flang -### -c %s -g -target x86_64-sie-ps5 2>&1 \
! RUN:             | FileCheck -check-prefixes=G_DWARF5,G_SCE,NOCI %s
! RUN: %flang -### -c %s -g -gcolumn-info -target x86_64-scei-ps4 2>&1 \
! RUN:             | FileCheck -check-prefix=CI %s
! RUN: %flang -### -c %s -gsce -target x86_64-unknown-linux 2>&1 \
! RUN:             | FileCheck -check-prefix=NOCI %s
! RUN: %flang -### %s -g -flto=thin -target x86_64-scei-ps4 2>&1 \
! RUN:             | FileCheck -check-prefix=LDGARANGE %s
! RUN: %flang -### %s -g -flto=full -target x86_64-scei-ps4 2>&1 \
! RUN:             | FileCheck -check-prefix=LDGARANGE %s
! RUN: %flang -### %s -g -flto -target x86_64-sie-ps5 2>&1 \
! RUN:             | FileCheck -check-prefix=LDGARANGE %s
! RUN: %flang -### %s -g -target x86_64-sie-ps5 2>&1 \
! RUN:             | FileCheck -check-prefix=LDGARANGE %s

! On the AIX, -g defaults to limited debug info.
! RUN: %flang -### -c -g %s -target powerpc-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED %s
! RUN: %flang -### -c -g %s -target powerpc64-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=G_LIMITED %s
! RUN: %flang -### -c -g %s -target powerpc-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=G_NOTUNING %s
! RUN: %flang -### -c -g %s -target powerpc64-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=G_NOTUNING %s
! RUN: %flang -### -c -g -gdbx %s -target powerpc-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefixes=G_LIMITED,G_DBX %s
! RUN: %flang -### -c -g -gdbx %s -target powerpc64-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefixes=G_LIMITED,G_DBX %s

! On the AIX, -g defaults to -gno-column-info.
! RUN: %flang -### -c -g %s -target powerpc-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=NOCI %s
! RUN: %flang -### -c -g %s -target powerpc64-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=NOCI %s
! RUN: %flang -### -c -g %s -target powerpc-ibm-aix-xcoff -gcolumn-info 2>&1 \
! RUN:             | FileCheck -check-prefix=CI %s
! RUN: %flang -### -c -g %s -target powerpc64-ibm-aix-xcoff -gcolumn-info \
! RUN:             2>&1 | FileCheck -check-prefix=CI %s

! For DBX, -g defaults to -gstrict-dwarf.
! RUN: %flang -### -c -g %s -target powerpc-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=STRICT %s
! RUN: %flang -### -c -g %s -target powerpc64-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=STRICT %s
! RUN: %flang -### -c -g -gno-strict-dwarf %s -target powerpc-ibm-aix-xcoff \
! RUN:             2>&1 | FileCheck -check-prefix=NOSTRICT %s
! RUN: %flang -### -c -g %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=NOSTRICT %s
! RUN: %flang -### -c -g -ggdb %s -target powerpc-ibm-aix-xcoff 2>&1 \
! RUN:             | FileCheck -check-prefix=NOSTRICT %s

! WebAssembly.
! WebAssembly should default to DWARF4.
! RUN: %flang -### -c -g %s -target wasm32 2>&1 \
! RUN:             | FileCheck -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -g %s -target wasm64 2>&1 \
! RUN:             | FileCheck -check-prefix=G_DWARF4 %s

! RUN: %flang -### -c -gdwarf-2 %s 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY_DWARF2 %s
!
! RUN: not %flang -### -c -gfoo %s 2>&1 | FileCheck -check-prefix=G_ERR %s
! RUN: %flang -### -c -g -g0 %s 2>&1 | FileCheck -check-prefix=G_NO %s
! RUN: %flang -### -c -ggdb0 %s 2>&1 | FileCheck -check-prefix=G_NO %s
! RUN: %flang -### -c -glldb -g0 %s 2>&1 | FileCheck -check-prefix=G_NO %s
! RUN: %flang -### -c -glldb -g1 %s 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY -check-prefix=G_LLDB %s
!
! PS4 defaults to sce; -ggdb0 changes tuning but turns off debug info,
! then -g turns it back on without affecting tuning.
! RUN: %flang -### -c -ggdb0 -g -target x86_64-scei-ps4 %s 2>&1 \
! RUN:             | FileCheck -check-prefix=G_GDB %s
!
! RUN: %flang -### -c -g1 %s 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY %s
! RUN: %flang -### -c -gmlt %s 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY %s
! RUN: %flang -### -c -gline-tables-only %s 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY %s
! RUN: %flang -### -c -gline-tables-only %s -target x86_64-apple-darwin 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY %s
! RUN: %flang -### -c -gline-tables-only %s -target i686-pc-openbsd 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_ONLY_DWARF2 %s
! RUN: %flang -### -c -gline-tables-only -g %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY %s
! RUN: %flang -### -c -gline-tables-only -g %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -gline-tables-only -g %s -target i686-pc-openbsd 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY_DWARF2 %s
! RUN: %flang -### -c -gline-tables-only -g %s --target=i386-pc-solaris 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY %s
! RUN: %flang -### -c -gline-tables-only -g0 %s 2>&1 \
! RUN:             | FileCheck -check-prefix=GLTO_NO %s
!
! RUN: %flang -### -c -gline-directives-only %s -target x86_64-apple-darwin 2>&1 \
! RUN:             | FileCheck -check-prefix=GLIO_ONLY %s
! RUN: %flang -### -c -gline-directives-only %s -target i686-pc-openbsd 2>&1 \
! RUN:             | FileCheck -check-prefix=GLIO_ONLY_DWARF2 %s
! RUN: %flang -### -c -gline-directives-only -g %s -target x86_64-linux-gnu 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY %s
! RUN: %flang -### -c -gline-directives-only -g %s -target x86_64-apple-darwin16 2>&1 \
! RUN:             | FileCheck -check-prefix=G_STANDALONE -check-prefix=G_DWARF4 %s
! RUN: %flang -### -c -gline-directives-only -g %s -target i686-pc-openbsd 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY_DWARF2 %s
! RUN: %flang -### -c -gline-directives-only -g %s --target=i386-pc-solaris 2>&1 \
! RUN:             | FileCheck -check-prefix=G_ONLY %s
! RUN: %flang -### -c -gline-directives-only -g0 %s 2>&1 \
! RUN:             | FileCheck -check-prefix=GLIO_NO %s

! RUN: %flang -### -c -gstrict-dwarf -gno-strict-dwarf %s 2>&1 | FileCheck -check-prefix=GIGNORE %s

! RUN: %flang -### -c -ggnu-pubnames %s 2>&1 | FileCheck -check-prefix=GPUB %s
! RUN: %flang -### -c -ggdb %s 2>&1 | FileCheck -check-prefix=NOPUB %s
! RUN: %flang -### -c -ggnu-pubnames -gno-gnu-pubnames %s 2>&1 | FileCheck -check-prefix=NOPUB %s
! RUN: %flang -### -c -ggnu-pubnames -gno-pubnames %s 2>&1 | FileCheck -check-prefix=NOPUB %s
!
! RUN: %flang -### -c -gpubnames %s 2>&1 | FileCheck -check-prefix=PUB %s
! RUN: %flang -### -c -ggdb %s 2>&1 | FileCheck -check-prefix=NOPUB %s
! RUN: %flang -### -c -gpubnames -gno-gnu-pubnames %s 2>&1 | FileCheck -check-prefix=NOPUB %s
! RUN: %flang -### -c -gpubnames -gno-pubnames %s 2>&1 | FileCheck -check-prefix=NOPUB %s

!/ Specify --target= so that %flang doesn't exit with code 1 even if LLVM_DEFAULT_TARGET_TRIPLE specifies a RISC-V target triple.
! RUN: %flang -### --target=x86_64 -c -gsplit-dwarf -g -gno-pubnames %s 2>&1 | FileCheck -check-prefix=NOPUB %s
!
! RUN: %flang -### -c -fdebug-ranges-base-address %s 2>&1 | FileCheck -check-prefix=RNGBSE %s
! RUN: %flang -### -c %s 2>&1 | FileCheck -check-prefix=NORNGBSE %s
! RUN: %flang -### -c -fdebug-ranges-base-address -fno-debug-ranges-base-address %s 2>&1 | FileCheck -check-prefix=NORNGBSE %s
!
! RUN: %flang -### -c -gomit-unreferenced-methods -fno-standalone-debug %s 2>&1 | FileCheck -check-prefix=INCTYPES %s
! RUN: %flang -### -c %s 2>&1 | FileCheck -check-prefix=NOINCTYPES %s
! RUN: %flang -### -c -gomit-unreferenced-methods -fdebug-types-section -target x86_64-unknown-linux %s 2>&1 \
! RUN:        | FileCheck -check-prefix=NOINCTYPES %s
! RUN: %flang -### -c -gomit-unreferenced-methods -fstandalone-debug %s 2>&1 | FileCheck -check-prefix=NOINCTYPES %s
!
! RUN: %flang -### -c -glldb %s 2>&1 | FileCheck -check-prefix=NOPUB %s
! RUN: %flang -### -c -glldb -gno-pubnames %s 2>&1 | FileCheck -check-prefix=NOPUB %s
!
! RUN: %flang -### -c -gdwarf-aranges %s 2>&1 | FileCheck -check-prefix=GARANGE %s
!
! RUN: %flang -### -fdebug-types-section -target x86_64-unknown-linux %s 2>&1 \
! RUN:        | FileCheck -check-prefix=FDTS %s
!
! RUN: %flang -### -fdebug-types-section -fno-debug-types-section -target x86_64-unknown-linux %s 2>&1 \
! RUN:        | FileCheck -check-prefix=NOFDTS %s
!
! RUN: %flang -### -fdebug-types-section -target wasm32-unknown-unknown %s 2>&1 \
! RUN:        | FileCheck -check-prefix=FDTS %s
!
! RUN: not %flang -### -fdebug-types-section -target x86_64-apple-darwin %s 2>&1 \
! RUN:        | FileCheck -check-prefix=FDTSE %s
!
! RUN: %flang -### -fdebug-types-section -fno-debug-types-section -target x86_64-apple-darwin %s 2>&1 \
! RUN:        | FileCheck -check-prefix=NOFDTSE %s
!
! RUN: %flang -### -g -gno-column-info %s 2>&1 \
! RUN:        | FileCheck -check-prefix=NOCI %s
!
! RUN: %flang -### -g -target x86_64-unknown-unknown %s 2>&1 \
! RUN:        | FileCheck -check-prefix=CI %s
!
! NOG_PS: "-fc1"
! NOG_PS-NOT: "-dwarf-version=
! NOG_PS-NOT: "-generate-arange-section"
!
! G_ERR: error: unknown argument:
!
! G_NO: "-fc1"
! G_NO-NOT: -debug-info-kind=
!
! GLTO_ONLY: "-fc1"
! GLTO_ONLY-NOT: "-dwarf-ext-refs"
! GLTO_ONLY: "-debug-info-kind=line-tables-only"
! GLTO_ONLY-NOT: "-dwarf-ext-refs"
!
! GLTO_ONLY_DWARF2: "-fc1"
! GLTO_ONLY_DWARF2: "-debug-info-kind=line-tables-only"
! GLTO_ONLY_DWARF2: "-dwarf-version=2"
!
! GLIO_ONLY: "-fc1"
! GLIO_ONLY-NOT: "-dwarf-ext-refs"
! GLIO_ONLY: "-debug-info-kind=line-directives-only"
! GLIO_ONLY-NOT: "-dwarf-ext-refs"
!
! GLIO_ONLY_DWARF2: "-fc1"
! GLIO_ONLY_DWARF2: "-debug-info-kind=line-directives-only"
! GLIO_ONLY_DWARF2: "-dwarf-version=2"
!
! G_ONLY: "-fc1"
! G_ONLY: "-debug-info-kind=constructor"
!
! These tests assert that "-gline-tables-only" "-g" uses the latter,
! but otherwise not caring about the DebugInfoKind.
! G_ONLY_DWARF2: "-fc1"
! G_ONLY_DWARF2: "-debug-info-kind={{standalone|constructor}}"
! G_ONLY_DWARF2: "-dwarf-version=2"
!
! G_STANDALONE: "-fc1"
! G_STANDALONE: "-debug-info-kind=standalone"
! G_LIMITED: "-fc1"
! G_LIMITED: "-debug-info-kind=constructor"
! G_DWARF2: "-dwarf-version=2"
! G_DWARF4-DAG: "-dwarf-version=4"
! G_DWARF5-DAG: "-dwarf-version=5"
!
! G_GDB:  "-debugger-tuning=gdb"
! G_LLDB: "-debugger-tuning=lldb"
! G_SCE-DAG:  "-debugger-tuning=sce"
! G_DBX:  "-debugger-tuning=dbx"
!
! STRICT:  "-gstrict-dwarf"
! NOSTRICT-NOT:  "-gstrict-dwarf"
!
! G_NOTUNING: "-fc1"
! G_NOTUNING-NOT: "-debugger-tuning="
!
! This tests asserts that "-gline-tables-only" "-g0" disables debug info.
! GLTO_NO: "-fc1"
! GLTO_NO-NOT: -debug-info-kind=
!
! This tests asserts that "-gline-directives-only" "-g0" disables debug info.
! GLIO_NO: "-fc1"
! GLIO_NO-NOT: -debug-info-kind=
!
! GIGNORE-NOT: "argument unused during compilation"
!
! GPUB: -ggnu-pubnames
! NOPUB-NOT: -ggnu-pubnames
! NOPUB-NOT: -gpubnames
!

! LDGARANGE: {{".*ld.*"}} {{.*}}
! LDGARANGE-NOT: -generate-arange-section"
! SNLDTLTOGARANGE: {{".*orbis-ld.*"}} {{.*}} "-lto-thin-debug-options= -generate-arange-section"
! SNLDFLTOGARANGE: {{".*orbis-ld.*"}} {{.*}} "-lto-debug-options= -generate-arange-section"

! PUB: -gpubnames
!
! RNGBSE: -fdebug-ranges-base-address
! NORNGBSE-NOT: -fdebug-ranges-base-address
!
! INCTYPES: -gomit-unreferenced-methods
! NOINCTYPES-NOT: -gomit-unreferenced-methods
!
! GARANGE-DAG: -generate-arange-section
!
! FDTS: "-mllvm" "-generate-type-units"
! FDTSE: error: unsupported option '-fdebug-types-section' for target 'x86_64-apple-darwin'
!
! NOFDTS-NOT: "-mllvm" "-generate-type-units"
! NOFDTSE-NOT: error: unsupported option '-fdebug-types-section' for target 'x86_64-apple-darwin'
!
! CI-NOT: "-gno-column-info"
!
! NOCI-DAG: "-gno-column-info"
!
! GNOMOD-NOT: -debug-info-kind=

! RUN: not %flang_fc1 -debug-info-kind=watkind %s 2>&1 \
! RUN:     | FileCheck -check-prefix=BADSTRING1 %s
! BADSTRING1: error: invalid value 'watkind' in '-debug-info-kind=watkind'

! RUN: not %flang_fc1 -debugger-tuning=gmodal %s 2>&1 \
! RUN:     | FileCheck -check-prefix=BADSTRING2 %s
! BADSTRING2: error: invalid value 'gmodal' in '-debugger-tuning=gmodal'

! RUN: %flang -### -g -fno-eliminate-unused-debug-types -c %s 2>&1 \
! RUN:        | FileCheck -check-prefix=DEBUG_UNUSED_TYPES %s
! DEBUG_UNUSED_TYPES: "-debug-info-kind=unused-types"
! DEBUG_UNUSED_TYPES-NOT: "-debug-info-kind=limited"

! RUN: %flang -### -g -feliminate-unused-debug-types -c %s 2>&1 \
! RUN:        | FileCheck -check-prefix=NO_DEBUG_UNUSED_TYPES %s
! RUN: %flang -### -fno-eliminate-unused-debug-types -g1 -c %s 2>&1 \
! RUN:        | FileCheck -check-prefix=NO_DEBUG_UNUSED_TYPES %s
! NO_DEBUG_UNUSED_TYPES: "-debug-info-kind={{constructor|line-tables-only|standalone}}"
! NO_DEBUG_UNUSED_TYPES-NOT: "-debug-info-kind=unused-types"
!
! RUN: %flang -### -c -gdwarf-5 -gdwarf64 -target x86_64 %s 2>&1 | FileCheck -check-prefix=GDWARF64_ON %s
! RUN: %flang -### -c -gdwarf-4 -gdwarf64 -target x86_64 %s 2>&1 | FileCheck -check-prefix=GDWARF64_ON %s
! RUN: %flang -### -c -gdwarf-3 -gdwarf64 -target x86_64 %s 2>&1 | FileCheck -check-prefix=GDWARF64_ON %s
! RUN: not %flang -### -c -gdwarf-2 -gdwarf64 --target=x86_64 %s 2>&1 | FileCheck -check-prefix=GDWARF64_VER %s
! RUN: %flang -### -c -gdwarf-4 -gdwarf64 -target x86_64 -target x86_64 %s 2>&1 \
! RUN:       | FileCheck -check-prefix=GDWARF64_ON %s
! RUN: not %flang -### -c -gdwarf-4 -gdwarf64 --target=i386-linux-gnu %s 2>&1 \
! RUN:       | FileCheck -check-prefix=GDWARF64_32ARCH %s
! RUN: not %flang -### -c -gdwarf-4 -gdwarf64 -target x86_64-apple-darwin %s 2>&1 \
! RUN:       | FileCheck -check-prefix=GDWARF64_ELF %s
!
! GDWARF64_ON:  "-gdwarf64"
! GDWARF64_VER:  error: invalid argument '-gdwarf64' only allowed with 'DWARFv3 or greater'
! GDWARF64_32ARCH: error: invalid argument '-gdwarf64' only allowed with '64 bit architecture'
! GDWARF64_ELF: error: invalid argument '-gdwarf64' only allowed with 'ELF platforms'

!/ Default to -fno-dwarf-directory-asm for -fno-integrated-as before DWARF v5.
! RUN: %flang -### -target x86_64 -c -gdwarf-2 %s 2>&1 | FileCheck --check-prefix=DIRECTORY %s
! RUN: %flang -### -target x86_64 -c -gdwarf-5 %s 2>&1 | FileCheck --check-prefix=DIRECTORY %s
! RUN: %flang -### -target x86_64 -c -gdwarf-4 -fno-integrated-as %s 2>&1 | FileCheck --check-prefix=NODIRECTORY %s
! RUN: %flang -### -target x86_64 -c -gdwarf-5 -fno-integrated-as %s 2>&1 | FileCheck --check-prefix=DIRECTORY %s

! RUN: %flang -### -target x86_64 -c -gdwarf-4 -fno-dwarf-directory-asm %s 2>&1 | FileCheck --check-prefix=NODIRECTORY %s

! DIRECTORY-NOT: "-fno-dwarf-directory-asm"
! NODIRECTORY: "-fno-dwarf-directory-asm"
