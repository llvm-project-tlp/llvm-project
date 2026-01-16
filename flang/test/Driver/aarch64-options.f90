! This is intended to check AArch64-specific options that don't require many
! tests. For contrast, see aarch64-sve-vector-bits.f90, which has many RUN
! directives for the same option. This is to avoid adding files with just one or
! two tests
!
! RUN: %flang --target=aarch64-none-gnu -mlr-for-calls-only -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=MLR-FOR-CALLS-ONLY %s
! MLR-FOR-CALLS-ONLY: "-target-feature" "+reserve-lr-for-ra"
!
! ------------------------------------------------------------------------------
!
! RUN: %flang -O3 --target=aarch64 %s -### %s 2>&1 \
! RUN:     | FileCheck %s --check-prefixes=FIX-835769-NO
! RUN: %flang -O3 --target=aarch64 -mfix-cortex-a53-835769 -### %s 2>&1 \
! RUN:     | FileCheck %s --check-prefixes=FIX-835769
! RUN: %flang -O3 --target=aarch64 -mno-fix-cortex-a53-835769 -### %s 2>&1 \
! RUN:     | FileCheck %s --check-prefixes=FIX-835769-NO
!
! FIX-835769-NO-NOT: "+fix-cortex-a53-835769"
! FIX-835769: "-target-feature" "+fix-cortex-a53-835769"
!
! ------------------------------------------------------------------------------
!
! RUN: %flang -target aarch64-none-linux-android -v -### %s \
! RUN:     -mfix-cortex-a53-843419 2>&1 \
! RUN:     | FileCheck %s -check-prefix=FIX-843419
! RUN: %flang -target aarch64-none-linux-android -v -### %s \
! RUN:     -mno-fix-cortex-a53-843419 2>&1 \
! RUN:     | FileCheck %s -check-prefix=FIX-843419-NO
!
! FIX-843419-NO-NOT: "--fix-cortex-a53-843419"
! FIX-843419: "--fix-cortex-a53-843419"
