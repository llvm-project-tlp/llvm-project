!-------------------------------------------------------------------------------
!
! Test handling of -f(no-)function-sections
!
! RUN: %flang -### %s -fsyntax-only 2>&1 \
! RUN:     | FileCheck --check-prefix=NOFS %s
!
! RUN: %flang -### %s -fsyntax-only \
! RUN:     -ffunction-sections 2>&1 \
! RUN:     | FileCheck --check-prefix=FS %s
!
! RUN: %flang -### %s -fsyntax-only \
! RUN:     -fno-function-sections 2>&1 \
! RUN:     | FileCheck --check-prefix=NOFS %s
!
! RUN: %flang -### %s -fsyntax-only \
! RUN:     -ffunction-sections -fno-function-sections 2>&1 \
! RUN:     | FileCheck --check-prefix=NOFS %s
!
! RUN: %flang -### %s -fsyntax-only \
! RUN:     -fno-function-sections -ffunction-sections 2>&1 \
! RUN:     | FileCheck --check-prefix=FS %s
!
! RUN: %flang -### %s -fsyntax-only \
! RUN:     -ffunction-sections -fno-function-sections -ffunction-sections 2>&1 \
! RUN:     | FileCheck --check-prefix=FS %s
!
! FS: -ffunction-sections
! NOFS-NOT: -ffunction-sections
!
!-------------------------------------------------------------------------------
!
! On PS4/PS5, -ffunction-sections is the default. If this is the default on any
! other architectures, those should also be tested here.
!
! RUN: %if x86-registered-target %{ \
! RUN:   %flang -### -target x86_64-scei-ps4 %s 2>&1 \
! RUN:       | FileCheck %s -check-prefix=DEFAULT-FS \
! RUN: %}
!
! RUN: %if x86-registered-target %{ \
! RUN:   %flang -### -target x86_64-sie-ps5 %s 2>&1 \
! RUN:       | FileCheck %s -check-prefix=DEFAULT-FS \
! RUN: %}
!
! DEFAULT-FS: -ffunction-sections
!
!-------------------------------------------------------------------------------
!
! TODO: Support for -ffunction-sections with LTO has not been implemented yet.
! When it is implemented, these tests may have to be removed/replaced
!
! RUN: %flang -### -fsyntax-only %s -ffunction-sections -flto 2>&1 \
! RUN:     | FileCheck %s -check-prefix=WARN-LTO
!
! RUN: %flang -### -fsyntax-only %s -ffunction-sections -flto=thin 2>&1 \
! RUN:     | FileCheck %s -check-prefix=WARN-LTO
!
! RUN: %flang -### -fsyntax-only %s -ffunction-sections -flto=full 2>&1 \
! RUN:     | FileCheck %s -check-prefix=WARN-LTO
!
! WARN-LTO: warning: '-ffunction-sections' is not yet supported with LTO{{$}}
