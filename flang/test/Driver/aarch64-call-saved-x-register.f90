! RUN: %flang --target=aarch64-none-gnu -fcall-saved-x8 -### %s  2>&1  \
! RUN:     | FileCheck --check-prefix=CALL-SAVED-X8 %s
!
! RUN: %flang --target=aarch64-none-gnu -fcall-saved-x9 -### %s  2>&1  \
! RUN:     | FileCheck --check-prefix=CALL-SAVED-X9 %s
!
! RUN: %flang --target=aarch64-none-gnu -fcall-saved-x10 -### %s  2>&1  \
! RUN:     | FileCheck --check-prefix=CALL-SAVED-X10 %s
!
! RUN: %flang --target=aarch64-none-gnu -fcall-saved-x11 -### %s  2>&1  \
! RUN:     | FileCheck --check-prefix=CALL-SAVED-X11 %s
!
! RUN: %flang --target=aarch64-none-gnu -fcall-saved-x12 -### %s  2>&1  \
! RUN:     | FileCheck --check-prefix=CALL-SAVED-X12 %s
!
! RUN: %flang --target=aarch64-none-gnu -fcall-saved-x13 -### %s  2>&1  \
! RUN:     | FileCheck --check-prefix=CALL-SAVED-X13 %s
!
! RUN: %flang --target=aarch64-none-gnu -fcall-saved-x14 -### %s  2>&1  \
! RUN:     | FileCheck --check-prefix=CALL-SAVED-X14 %s
!
! RUN: %flang --target=aarch64-none-gnu -fcall-saved-x15 -### %s  2>&1  \
! RUN:     | FileCheck --check-prefix=CALL-SAVED-X15 %s
!
! RUN: %flang --target=aarch64-none-gnu -fcall-saved-x18 -### %s  2>&1  \
! RUN:     | FileCheck --check-prefix=CALL-SAVED-X18 %s
!
! Test all call-saved-x# options together.
! RUN: %flang --target=aarch64-none-gnu -### %s \
! RUN:     -fcall-saved-x8 \
! RUN:     -fcall-saved-x9 \
! RUN:     -fcall-saved-x10 \
! RUN:     -fcall-saved-x11 \
! RUN:     -fcall-saved-x12 \
! RUN:     -fcall-saved-x13 \
! RUN:     -fcall-saved-x14 \
! RUN:     -fcall-saved-x15 \
! RUN:     -fcall-saved-x18 2>&1 \
! RUN:     | FileCheck %s \
! RUN:                 --check-prefix=CALL-SAVED-X8 \
! RUN:                 --check-prefix=CALL-SAVED-X9 \
! RUN:                 --check-prefix=CALL-SAVED-X10 \
! RUN:                 --check-prefix=CALL-SAVED-X11 \
! RUN:                 --check-prefix=CALL-SAVED-X12 \
! RUN:                 --check-prefix=CALL-SAVED-X13 \
! RUN:                 --check-prefix=CALL-SAVED-X14 \
! RUN:                 --check-prefix=CALL-SAVED-X15 \
! RUN:                 --check-prefix=CALL-SAVED-X18
!
! CALL-SAVED-X8: "-target-feature" "+call-saved-x8"
! CALL-SAVED-X9: "-target-feature" "+call-saved-x9"
! CALL-SAVED-X10: "-target-feature" "+call-saved-x10"
! CALL-SAVED-X11: "-target-feature" "+call-saved-x11"
! CALL-SAVED-X12: "-target-feature" "+call-saved-x12"
! CALL-SAVED-X13: "-target-feature" "+call-saved-x13"
! CALL-SAVED-X14: "-target-feature" "+call-saved-x14"
! CALL-SAVED-X15: "-target-feature" "+call-saved-x15"
! CALL-SAVED-X18: "-target-feature" "+call-saved-x18"
