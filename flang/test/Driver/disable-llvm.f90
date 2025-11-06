! Check that the option to disable LLVM IR passes works as expected
!
! RUN: %flang -### -Xflang -disable-llvm-passes %s 2>&1 \
! RUN:     | FileCheck --check-prefixes=FC1,PASSES %s
! RUN: %flang -### -Xflang -disable-llvm-optzns %s 2>&1 \
! RUN:     | FileCheck --check-prefixes=FC1,OPTZNS %s
!
! FC1: "-fc1"
! PASSES-SAME: "-disable-llvm-passes"
! OPTZNS-SAME: "-disable-llvm-optzns"
!
! DEFINE: %{triple} =
!
! DEFINE: %{passes0} = %flang_fc1 -disable-llvm-passes -fdebug-pass-manager \
! DEFINE:     -triple %{triple} -emit-obj %s -O0 -o /dev/null 2>&1 \
! DEFINE:     | FileCheck --check-prefix=DISABLE-PASSES --allow-empty %s
!
! DEFINE: %{passes1} = %flang_fc1 -disable-llvm-passes -fdebug-pass-manager \
! DEFINE:     -triple %{triple} -emit-obj %s -O1 -o /dev/null 2>&1 \
! DEFINE:     | FileCheck --check-prefix=DISABLE-PASSES --allow-empty %s
!
! DEFINE: %{optzns0} = %flang_fc1 -disable-llvm-optzns -fdebug-pass-manager \
! DEFINE:     -triple %{triple} -emit-obj %s -O0 -o /dev/null 2>&1 \
! DEFINE:     | FileCheck --check-prefix=DISABLE-PASSES --allow-empty %s
!
! DEFINE: %{optzns1} = %flang_fc1 -disable-llvm-optzns -fdebug-pass-manager \
! DEFINE:     -triple %{triple} -emit-obj %s -O1 -o /dev/null 2>&1 \
! DEFINE:     | FileCheck --check-prefix=DISABLE-PASSES --allow-empty %s
!
! REDEFINE: %{triple} = aarch64-pc-linux-gnu
! RUN: %if aarch64-registered-target %{ %{passes0} %}
! RUN: %if aarch64-registered-target %{ %{passes1} %}
! RUN: %if aarch64-registered-target %{ %{optzns0} %}
! RUN: %if aarch64-registered-target %{ %{optzns1} %}
!
! REDEFINE: %{triple} = x86_64-pc-linux-gnu
! RUN: %if x86-registered-target %{ %{passes0} %}
! RUN: %if x86-registered-target %{ %{passes1} %}
! RUN: %if x86-registered-target %{ %{optzns0} %}
! RUN: %if x86-registered-target %{ %{optzns1} %}
!
! DISABLE-PASSES-NOT: Running analysis
! DISABLE-PASSES-NOT: Running pass
