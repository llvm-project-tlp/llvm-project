! Test that the -fdebug-pass* and -mdebug-pass options work as expected.
!
! RUN: %flang -fintegrated-as -O1 -S %s -o /dev/null \
! RUN:     -fdebug-pass-structure 2>&1 \
! RUN:     | FileCheck %s --check-prefixes=ARGUMENTS,STRUCTURE
!
! RUN: %flang -fintegrated-as -O1 -S %s -o /dev/null \
! RUN:     -Xflang -mdebug-pass -Xflang "Structure" 2>&1 \
! RUN:     | FileCheck %s --check-prefixes=ARGUMENTS,STRUCTURE
!
! RUN: %flang -fintegrated-as -O1 -S %s -o /dev/null \
! RUN:     -fdebug-pass-arguments 2>&1 \
! RUN:     | FileCheck %s --check-prefixes=ARGUMENTS
!
! RUN: %flang -fintegrated-as -O1 -S %s -o /dev/null \
! RUN:     -Xflang -mdebug-pass -Xflang "Arguments" 2>&1 \
! RUN:     | FileCheck %s --check-prefixes=ARGUMENTS
!
! ARGUMENTS: Pass Arguments: -tti
! STRUCTURE-NEXT: Target Transform Information
!
! RUN: not %flang -fintegrated-as -O1 -S %s -o /dev/null \
! RUN:     -Xflang -mdebug-pass -Xflang "Unknown" 2>&1 \
! RUN:     | FileCheck %s --check-prefixes=ERROR
!
! ERROR: for the --debug-pass option: Cannot find option named 'Unknown'
