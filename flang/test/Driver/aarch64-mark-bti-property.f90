! REQUIRES: aarch64-registered-target
!
! When -mmark-bti-property is passed the generated file object gets BTI marking.
!
! RUN: %flang -target aarch64-linux-none -mmark-bti-property -c -o - %s \
! RUN:     | llvm-readobj -n - \
! RUN:     | FileCheck %s --check-prefixes=ALL,GEN
!
! ALL: Name: .note.gnu.property
! ALL: Type: NT_GNU_PROPERTY_TYPE_0
! GEN: aarch64 feature: BTI
