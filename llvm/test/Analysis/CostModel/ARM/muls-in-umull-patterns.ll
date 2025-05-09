; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py UTC_ARGS: --version 5
; RUN: opt -passes="print<cost-model>" 2>&1 -disable-output -mtriple thumbv8.1-m.main -mattr=+dsp  < %s | FileCheck %s
; RUN: opt -passes="print<cost-model>" 2>&1 -disable-output -mtriple thumbv8.1-m.main < %s | FileCheck %s --check-prefix=CHECK-NO-DSP
define i64 @test(i16 %a, i16 %b) {
; CHECK-LABEL: 'test'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %as = zext i16 %a to i32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %bs = zext i16 %b to i32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %m = mul i32 %as, %bs
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %ms = zext i32 %m to i64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %ms
;
; CHECK-NO-DSP-LABEL: 'test'
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %as = zext i16 %a to i32
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %bs = zext i16 %b to i32
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %m = mul i32 %as, %bs
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %ms = zext i32 %m to i64
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %ms
;
    %as = zext i16 %a to i32
    %bs = zext i16 %b to i32
    %m = mul i32 %as, %bs
    %ms = zext i32 %m to i64
    ret i64 %ms
}

define i64 @withadd(i16 %a, i16 %b, i64 %c) {
; CHECK-LABEL: 'withadd'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %as = zext i16 %a to i32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %bs = zext i16 %b to i32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %m = mul i32 %as, %bs
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %ms = zext i32 %m to i64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %r = add i64 %c, %ms
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
; CHECK-NO-DSP-LABEL: 'withadd'
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %as = zext i16 %a to i32
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %bs = zext i16 %b to i32
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %m = mul i32 %as, %bs
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %ms = zext i32 %m to i64
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %r = add i64 %c, %ms
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
    %as = zext i16 %a to i32
    %bs = zext i16 %b to i32
    %m = mul i32 %as, %bs
    %ms = zext i32 %m to i64
    %r = add i64 %c, %ms
    ret i64 %r
}

define i64 @withloads(ptr %pa, ptr %pb, i64 %c) {
; CHECK-LABEL: 'withloads'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %a = load i16, ptr %pa, align 2
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %b = load i16, ptr %pb, align 2
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %as = zext i16 %a to i32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %bs = zext i16 %b to i32
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %m = mul i32 %as, %bs
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %ms = zext i32 %m to i64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %r = add i64 %c, %ms
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
; CHECK-NO-DSP-LABEL: 'withloads'
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %a = load i16, ptr %pa, align 2
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %b = load i16, ptr %pb, align 2
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %as = zext i16 %a to i32
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %bs = zext i16 %b to i32
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %m = mul i32 %as, %bs
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %ms = zext i32 %m to i64
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %r = add i64 %c, %ms
; CHECK-NO-DSP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
    %a = load i16, ptr %pa
    %b = load i16, ptr %pb
    %as = zext i16 %a to i32
    %bs = zext i16 %b to i32
    %m = mul i32 %as, %bs
    %ms = zext i32 %m to i64
    %r = add i64 %c, %ms
    ret i64 %r
}
