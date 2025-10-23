! Check that the -ffunction-sections option behaves as expected
!
! DEFINE: %{triple} =
! DEFINE: %{check-plain} = %flang_fc1 -triple %{triple} \
! DEFINE:     -S -o - %s | FileCheck %s --check-prefixes=PLAIN
! DEFINE: %{check-sects} = %flang_fc1 -triple %{triple} -ffunction-sections \
! DEFINE:     -S -o - %s | FileCheck %s --check-prefixes=SECTS
!
! REDEFINE: %{triple} = aarch64-pc-linux-gnu
! RUN: %if aarch64-registered-target %{ %{check-plain} %}
! RUN: %if aarch64-registered-target %{ %{check-sects} %}
!
! REDEFINE: %{triple} = x86_64-pc-linux-gnu
! RUN: %if x86-registered-target %{ %{check-plain} %}
! RUN: %if x86-registered-target %{ %{check-sects} %}

module m
contains
  subroutine hello()
  end subroutine hello

  subroutine world()
  end subroutine world
end module m

! PLAIN-NOT: section
! PLAIN: _QMmPhello:
! PLAIN: _QMmPworld:
!
! SECTS: section .text._QMmPhello,
! SECTS: _QMmPhello:
! SECTS: section .text._QMmPworld,
! SECTS: _QMmPworld:
