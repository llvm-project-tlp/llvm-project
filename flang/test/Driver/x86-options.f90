! RUN: %flang --target=i386 -march=i386 -mx87 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=X87 %s
! RUN: %flang --target=i386 -march=i386 -mno-x87 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-X87 %s
! RUN: %flang --target=i386 -march=i386 -m80387 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=X87 %s
! RUN: %flang --target=i386 -march=i386 -mno-80387 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-X87 %s
! RUN: %flang --target=i386 -march=i386 -mno-fp-ret-in-387 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-X87 %s
! X87: "-target-feature" "+x87"
! NO-X87: "-target-feature" "-x87"

! RUN: %flang --target=i386 -march=i386 -### %s \
! RUN:     -msse -msse2 -msse3 -mssse3 -msse4a -msse4.1 -msse4.2 2>&1 \
! RUN:     | FileCheck -check-prefix=SSE %s
! RUN: %flang --target=i386 -march=i386 -### %s \
! RUN:     -mno-sse -mno-sse2 -mno-sse3 -mno-ssse3 -mno-sse4a -mno-sse4.1 -mno-sse4.2 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-SSE %s
! SSE: "-target-feature" "+sse" "-target-feature" "+sse2" "-target-feature" "+sse3" "-target-feature" "+ssse3" "-target-feature" "+sse4a" "-target-feature" "+sse4.1" "-target-feature" "+sse4.2"
! NO-SSE: "-target-feature" "-sse" "-target-feature" "-sse2" "-target-feature" "-sse3" "-target-feature" "-ssse3" "-target-feature" "-sse4a" "-target-feature" "-sse4.1" "-target-feature" "-sse4.2"

! RUN: %flang --target=i386 -march=i386 -msse4 -maes -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=SSE4-AES %s
! RUN: %flang --target=i386 -march=i386 -mno-sse4 -mno-aes -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-SSE4-AES %s
! SSE4-AES: "-target-feature" "+sse4.2" "-target-feature" "+aes"
! NO-SSE4-AES: "-target-feature" "-sse4.1" "-target-feature" "-aes"

! RUN: %flang --target=i386 -march=i386 -### %s \
! RUN:     -mavx -mavx2 -mavx512f -mavx512cd -mavx512dq -mavx512bw -mavx512vl -mavx512vbmi -mavx512vbmi2 -mavx512ifma 2>&1 \
! RUN:     | FileCheck -check-prefix=AVX %s
! RUN: %flang --target=i386 -march=i386 -### %s \
! RUN:     -mno-avx -mno-avx2 -mno-avx512f -mno-avx512cd -mno-avx512dq -mno-avx512bw -mno-avx512vl -mno-avx512vbmi -mno-avx512vbmi2 -mno-avx512ifma 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AVX %s
! AVX: "-target-feature" "+avx" "-target-feature" "+avx2" "-target-feature" "+avx512f" "-target-feature" "+avx512cd" "-target-feature" "+avx512dq" "-target-feature" "+avx512bw" "-target-feature" "+avx512vl" "-target-feature" "+avx512vbmi" "-target-feature" "+avx512vbmi2" "-target-feature" "+avx512ifma"
! NO-AVX: "-target-feature" "-avx" "-target-feature" "-avx2" "-target-feature" "-avx512f" "-target-feature" "-avx512cd" "-target-feature" "-avx512dq" "-target-feature" "-avx512bw" "-target-feature" "-avx512vl" "-target-feature" "-avx512vbmi" "-target-feature" "-avx512vbmi2" "-target-feature" "-avx512ifma"

! RUN: %flang --target=i386 -march=i386 -### %s \
! RUN:     -mpclmul -mrdrnd -mfsgsbase -mbmi -mbmi2 2>&1 \
! RUN:     | FileCheck -check-prefix=BMI %s
! RUN: %flang --target=i386 -march=i386 -### %s \
! RUN:     -mno-pclmul -mno-rdrnd -mno-fsgsbase -mno-bmi -mno-bmi2 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-BMI %s
! BMI: "-target-feature" "+pclmul" "-target-feature" "+rdrnd" "-target-feature" "+fsgsbase" "-target-feature" "+bmi" "-target-feature" "+bmi2"
! NO-BMI: "-target-feature" "-pclmul" "-target-feature" "-rdrnd" "-target-feature" "-fsgsbase" "-target-feature" "-bmi" "-target-feature" "-bmi2"

! RUN: %flang --target=i386 -march=i386 -### %s \
! RUN:     -mlzcnt -mpopcnt -mtbm -mfma -mfma4 2>&1 \
! RUN:     | FileCheck -check-prefix=FMA %s
! RUN: %flang --target=i386 -march=i386 -### %s \
! RUN:     -mno-lzcnt -mno-popcnt -mno-tbm -mno-fma -mno-fma4 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-FMA %s
! FMA: "-target-feature" "+lzcnt" "-target-feature" "+popcnt" "-target-feature" "+tbm" "-target-feature" "+fma" "-target-feature" "+fma4"
! NO-FMA: "-target-feature" "-lzcnt" "-target-feature" "-popcnt" "-target-feature" "-tbm" "-target-feature" "-fma" "-target-feature" "-fma4"

! RUN: %flang --target=i386 -march=i386 -### %s \
! RUN:     -mxop -mf16c -mrtm -mprfchw -mrdseed 2>&1 \
! RUN:     | FileCheck -check-prefix=XOP %s
! RUN: %flang --target=i386 -march=i386 -### %s \
! RUN:     -mno-xop -mno-f16c -mno-rtm -mno-prfchw -mno-rdseed 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-XOP %s
! XOP: "-target-feature" "+xop" "-target-feature" "+f16c" "-target-feature" "+rtm" "-target-feature" "+prfchw" "-target-feature" "+rdseed"
! NO-XOP: "-target-feature" "-xop" "-target-feature" "-f16c" "-target-feature" "-rtm" "-target-feature" "-prfchw" "-target-feature" "-rdseed"

! RUN: %flang --target=i386 -### %s \
! RUN:     -march=i386 -msha -mpku -madx -mcx16 -mfxsr 2>&1 \
! RUN:     | FileCheck -check-prefix=SHA %s
! RUN: %flang --target=i386 -### %s \
! RUN:     -march=i386 -mno-sha -mno-pku -mno-adx -mno-cx16 -mno-fxsr 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-SHA %s
! SHA: "-target-feature" "+sha" "-target-feature" "+pku" "-target-feature" "+adx" "-target-feature" "+cx16" "-target-feature" "+fxsr"
! NO-SHA: "-target-feature" "-sha" "-target-feature" "-pku" "-target-feature" "-adx" "-target-feature" "-cx16" "-target-feature" "-fxsr"

! RUN: %flang --target=i386 -march=i386 -### %s \
! RUN:     -mxsave -mxsaveopt -mxsavec -mxsaves 2>&1 \
! RUN:     | FileCheck -check-prefix=XSAVE %s
! RUN: %flang --target=i386 -march=i386 -### %s \
! RUN:     -mno-xsave -mno-xsaveopt -mno-xsavec -mno-xsaves 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-XSAVE %s
! XSAVE: "-target-feature" "+xsave" "-target-feature" "+xsaveopt" "-target-feature" "+xsavec" "-target-feature" "+xsaves"
! NO-XSAVE: "-target-feature" "-xsave" "-target-feature" "-xsaveopt" "-target-feature" "-xsavec" "-target-feature" "-xsaves"

! RUN: %flang --target=i386 -march=i386 -mclflushopt -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=CLFLUSHOPT %s
! RUN: %flang --target=i386 -march=i386 -mno-clflushopt -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-CLFLUSHOPT %s
! CLFLUSHOPT: "-target-feature" "+clflushopt"
! NO-CLFLUSHOPT: "-target-feature" "-clflushopt"

! RUN: %flang --target=i386 -march=i386 -mclwb -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=CLWB %s
! RUN: %flang --target=i386 -march=i386 -mno-clwb -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-CLWB %s
! CLWB: "-target-feature" "+clwb"
! NO-CLWB: "-target-feature" "-clwb"

! RUN: %flang --target=i386 -march=i386 -mwbnoinvd -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=WBNOINVD %s
! RUN: %flang --target=i386 -march=i386 -mno-wbnoinvd -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-WBNOINVD %s
! WBNOINVD: "-target-feature" "+wbnoinvd"
! NO-WBNOINVD: "-target-feature" "-wbnoinvd"

! RUN: %flang --target=i386 -march=i386 -mmovbe -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=MOVBE %s
! RUN: %flang --target=i386 -march=i386 -mno-movbe -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-MOVBE %s
! MOVBE: "-target-feature" "+movbe"
! NO-MOVBE: "-target-feature" "-movbe"

! RUN: %flang --target=i386 -march=i386 -mshstk -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=CETSS %s
! RUN: %flang --target=i386 -march=i386 -mno-shstk -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-CETSS %s
! CETSS: "-target-feature" "+shstk"
! NO-CETSS: "-target-feature" "-shstk"

! RUN: %flang --target=i386 -march=i386 -msgx -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=SGX %s
! RUN: %flang --target=i386 -march=i386 -mno-sgx -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-SGX %s
! SGX: "-target-feature" "+sgx"
! NO-SGX: "-target-feature" "-sgx"

! RUN: %flang --target=i386 -march=i386 -mprefetchi -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=PREFETCHI %s
! RUN: %flang --target=i386 -march=i386 -mno-prefetchi -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-PREFETCHI %s
! PREFETCHI: "-target-feature" "+prefetchi"
! NO-PREFETCHI: "-target-feature" "-prefetchi"

! RUN: %flang --target=i386 -march=i386 -mclzero -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=CLZERO %s
! RUN: %flang --target=i386 -march=i386 -mno-clzero -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-CLZERO %s
! CLZERO: "-target-feature" "+clzero"
! NO-CLZERO: "-target-feature" "-clzero"

! RUN: %flang --target=i386 -march=i386 -mvaes -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=VAES %s
! RUN: %flang --target=i386 -march=i386 -mno-vaes -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-VAES %s
! VAES: "-target-feature" "+vaes"
! NO-VAES: "-target-feature" "-vaes"

! RUN: %flang --target=i386 -march=i386 -mgfni -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=GFNI %s
! RUN: %flang --target=i386 -march=i386 -mno-gfni -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-GFNI %s
! GFNI: "-target-feature" "+gfni"
! NO-GFNI: "-target-feature" "-gfni

! RUN: %flang --target=i386 -march=i386 -mvpclmulqdq -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=VPCLMULQDQ %s
! RUN: %flang --target=i386 -march=i386 -mno-vpclmulqdq -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-VPCLMULQDQ %s
! VPCLMULQDQ: "-target-feature" "+vpclmulqdq"
! NO-VPCLMULQDQ: "-target-feature" "-vpclmulqdq"

! RUN: %flang --target=i386 -march=i386 -mavx512bitalg -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=BITALG %s
! RUN: %flang --target=i386 -march=i386 -mno-avx512bitalg -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-BITALG %s
! BITALG: "-target-feature" "+avx512bitalg"
! NO-BITALG: "-target-feature" "-avx512bitalg"

! RUN: %flang --target=i386 -march=i386 -mavx512vnni -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=VNNI %s
! RUN: %flang --target=i386 -march=i386 -mno-avx512vnni -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-VNNI %s
! VNNI: "-target-feature" "+avx512vnni"
! NO-VNNI: "-target-feature" "-avx512vnni"

! RUN: %flang --target=i386 -march=i386 -mavx512vbmi2 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=VBMI2 %s
! RUN: %flang --target=i386 -march=i386 -mno-avx512vbmi2 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-VBMI2 %s
! VBMI2: "-target-feature" "+avx512vbmi2"
! NO-VBMI2: "-target-feature" "-avx512vbmi2"

! RUN: %flang --target=i386-linux-gnu -mavx512vp2intersect -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=VP2INTERSECT %s
! RUN: %flang --target=i386-linux-gnu -mno-avx512vp2intersect -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-VP2INTERSECT %s
! VP2INTERSECT: "-target-feature" "+avx512vp2intersect"
! NO-VP2INTERSECT: "-target-feature" "-avx512vp2intersect"

! RUN: %flang --target=i386 -march=i386 -mrdpid -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=RDPID %s
! RUN: %flang --target=i386 -march=i386 -mno-rdpid -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-RDPID %s
! RDPID: "-target-feature" "+rdpid"
! NO-RDPID: "-target-feature" "-rdpid"

! RUN: %flang --target=i386 -march=i386 -mrdpru -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=RDPRU %s
! RUN: %flang --target=i386 -march=i386 -mno-rdpru -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-RDPRU %s
! RDPRU: "-target-feature" "+rdpru"
! NO-RDPRU: "-target-feature" "-rdpru"

! RUN: %flang --target=i386-linux-gnu -mwaitpkg -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=WAITPKG %s
! RUN: %flang --target=i386-linux-gnu -mno-waitpkg -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-WAITPKG %s
! WAITPKG: "-target-feature" "+waitpkg"
! NO-WAITPKG: "-target-feature" "-waitpkg"

! RUN: %flang --target=i386 -march=i386 -mmovdiri -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=MOVDIRI %s
! RUN: %flang --target=i386 -march=i386 -mno-movdiri -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-MOVDIRI %s
! MOVDIRI: "-target-feature" "+movdiri"
! NO-MOVDIRI: "-target-feature" "-movdiri"

! RUN: %flang --target=i386 -march=i386 -mmovdir64b -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=MOVDIR64B %s
! RUN: %flang --target=i386 -march=i386 -mno-movdir64b -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-MOVDIR64B %s
! MOVDIR64B: "-target-feature" "+movdir64b"
! NO-MOVDIR64B: "-target-feature" "-movdir64b"

! RUN: %flang --target=i386 -march=i386 -mpconfig -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=PCONFIG %s
! RUN: %flang --target=i386 -march=i386 -mno-pconfig -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-PCONFIG %s
! PCONFIG: "-target-feature" "+pconfig"
! NO-PCONFIG: "-target-feature" "-pconfig"

! RUN: %flang --target=i386 -march=i386 -mptwrite -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=PTWRITE %s
! RUN: %flang --target=i386 -march=i386 -mno-ptwrite -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-PTWRITE %s
! PTWRITE: "-target-feature" "+ptwrite"
! NO-PTWRITE: "-target-feature" "-ptwrite"

! RUN: %flang --target=i386 -march=i386 -minvpcid -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=INVPCID %s
! RUN: %flang --target=i386 -march=i386 -mno-invpcid -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-INVPCID %s
! INVPCID: "-target-feature" "+invpcid"
! NO-INVPCID: "-target-feature" "-invpcid"

! RUN: %flang --target=i386 -march=i386 -mavx512bf16 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=AVX512BF16 %s
! RUN: %flang --target=i386 -march=i386 -mno-avx512bf16 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AVX512BF16 %s
! AVX512BF16: "-target-feature" "+avx512bf16"
! NO-AVX512BF16: "-target-feature" "-avx512bf16"

! RUN: %flang --target=i386 -march=i386 -menqcmd -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=ENQCMD %s
! RUN: %flang --target=i386 -march=i386 -mno-enqcmd -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=NO-ENQCMD %s
! ENQCMD: "-target-feature" "+enqcmd"
! NO-ENQCMD: "-target-feature" "-enqcmd"

! RUN: %flang --target=i386 -march=i386 -mvzeroupper -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=VZEROUPPER %s
! RUN: %flang --target=i386 -march=i386 -mno-vzeroupper -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=NO-VZEROUPPER %s
! VZEROUPPER: "-target-feature" "+vzeroupper"
! NO-VZEROUPPER: "-target-feature" "-vzeroupper"

! RUN: %flang --target=i386 -march=i386 -mserialize -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=SERIALIZE %s
! RUN: %flang --target=i386 -march=i386 -mno-serialize -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-SERIALIZE %s
! SERIALIZE: "-target-feature" "+serialize"
! NO-SERIALIZE: "-target-feature" "-serialize"

! RUN: %flang --target=i386 -march=i386 -mtsxldtrk -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=TSXLDTRK %s
! RUN: %flang --target=i386 -march=i386 -mno-tsxldtrk -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=NO-TSXLDTRK %s
! TSXLDTRK: "-target-feature" "+tsxldtrk"
! NO-TSXLDTRK: "-target-feature" "-tsxldtrk"

! RUN: %flang --target=i386-linux-gnu -mkl -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=KL %s
! RUN: %flang --target=i386-linux-gnu -mno-kl -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-KL %s
! KL: "-target-feature" "+kl"
! NO-KL: "-target-feature" "-kl"

! RUN: %flang --target=i386-linux-gnu -mwidekl -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=WIDE_KL %s
! RUN: %flang --target=i386-linux-gnu -mno-widekl -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-WIDE_KL %s
! WIDE_KL: "-target-feature" "+widekl"
! NO-WIDE_KL: "-target-feature" "-widekl"

! RUN: %flang --target=i386 -march=i386 -mamx-tile -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=AMX-TILE %s
! RUN: %flang --target=i386 -march=i386 -mno-amx-tile -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=NO-AMX-TILE %s
! AMX-TILE: "-target-feature" "+amx-tile"
! NO-AMX-TILE: "-target-feature" "-amx-tile"

! RUN: %flang --target=i386 -march=i386 -mamx-bf16 -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=AMX-BF16 %s
! RUN: %flang --target=i386 -march=i386 -mno-amx-bf16 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AMX-BF16 %s
! AMX-BF16: "-target-feature" "+amx-bf16"
! NO-AMX-BF16: "-target-feature" "-amx-bf16"

! RUN: %flang --target=i386 -march=i386 -mamx-int8 -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=AMX-INT8 %s
! RUN: %flang --target=i386 -march=i386 -mno-amx-int8 -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=NO-AMX-INT8 %s
! AMX-INT8: "-target-feature" "+amx-int8"
! NO-AMX-INT8: "-target-feature" "-amx-int8"

! RUN: %flang --target=x86_64 -mamx-fp16 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=AMX-FP16 %s
! RUN: %flang --target=x86_64 -mno-amx-fp16 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AMX-FP16 %s
! AMX-FP16: "-target-feature" "+amx-fp16"
! NO-AMX-FP16: "-target-feature" "-amx-fp16"

! RUN: %flang --target=x86_64-unknown-linux-gnu -mamx-complex -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=AMX-COMPLEX %s
! RUN: %flang --target=x86_64-unknown-linux-gnu -mno-amx-complex -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AMX-COMPLEX %s
! AMX-COMPLEX: "-target-feature" "+amx-complex"
! NO-AMX-COMPLEX: "-target-feature" "-amx-complex"

! RUN: %flang --target=x86_64-unknown-linux-gnu -mamx-avx512 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=AMX-AVX512 %s
! RUN: %flang --target=x86_64-unknown-linux-gnu -mno-amx-avx512 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AMX-AVX512 %s
! AMX-AVX512: "-target-feature" "+amx-avx512"
! NO-AMX-AVX512: "-target-feature" "-amx-avx512"

! RUN: %flang --target=x86_64-unknown-linux-gnu -mamx-tf32 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=AMX-TF32 %s
! RUN: %flang --target=x86_64-unknown-linux-gnu -mno-amx-tf32 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AMX-TF32 %s
! AMX-TF32: "-target-feature" "+amx-tf32"
! NO-AMX-TF32: "-target-feature" "-amx-tf32"

! RUN: %flang --target=i386 -march=i386 -mhreset -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=HRESET %s
! RUN: %flang --target=i386 -march=i386 -mno-hreset -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-HRESET %s
! HRESET: "-target-feature" "+hreset"
! NO-HRESET: "-target-feature" "-hreset"

! RUN: %flang --target=x86_64 -muintr -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=UINTR %s
! RUN: %flang --target=x86_64 -mno-uintr -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-UINTR %s
! UINTR: "-target-feature" "+uintr"
! NO-UINTR: "-target-feature" "-uintr"

! RUN: %flang --target=i386 -march=i386 -mavxvnni -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=AVX-VNNI %s
! RUN: %flang --target=i386 -march=i386 -mno-avxvnni -### %s 2>&1 \
! RUN:     | FileCheck --check-prefix=NO-AVX-VNNI %s
! AVX-VNNI: "-target-feature" "+avxvnni"
! NO-AVX-VNNI: "-target-feature" "-avxvnni"

! RUN: %flang --target=i386 -march=i386 -mavx512fp16 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=AVX512FP16 %s
! RUN: %flang --target=i386 -march=i386 -mno-avx512fp16 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AVX512FP16 %s
! AVX512FP16: "-target-feature" "+avx512fp16"
! NO-AVX512FP16: "-target-feature" "-avx512fp16"

! RUN: %flang --target=x86_64 -mcmpccxadd -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=CMPCCXADD %s
! RUN: %flang --target=x86_64 -mno-cmpccxadd -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-CMPCCXADD %s
! CMPCCXADD: "-target-feature" "+cmpccxadd"
! NO-CMPCCXADD: "-target-feature" "-cmpccxadd"

! RUN: %flang --target=i386 -march=i386 -mraoint -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=RAOINT %s
! RUN: %flang --target=i386 -march=i386 -mno-raoint -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-RAOINT %s
! RAOINT: "-target-feature" "+raoint"
! NO-RAOINT: "-target-feature" "-raoint"

! RUN: %flang --target=i386-linux-gnu -mavxifma -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=AVXIFMA %s
! RUN: %flang --target=i386-linux-gnu -mno-avxifma -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AVXIFMA %s
! AVXIFMA: "-target-feature" "+avxifma"
! NO-AVXIFMA: "-target-feature" "-avxifma"

! RUN: %flang --target=i386 -mavxvnniint8 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=AVX-VNNIINT8 %s
! RUN: %flang --target=i386 -mno-avxvnniint8 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AVX-VNNIINT8 %s
! AVX-VNNIINT8: "-target-feature" "+avxvnniint8"
! NO-AVX-VNNIINT8: "-target-feature" "-avxvnniint8"

! RUN: %flang --target=i386 -mavxneconvert -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=AVXNECONVERT %s
! RUN: %flang --target=i386 -mno-avxneconvert -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AVXNECONVERT %s
! AVXNECONVERT: "-target-feature" "+avxneconvert"
! NO-AVXNECONVERT: "-target-feature" "-avxneconvert"

! RUN: %flang --target=i386 -msha512 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=SHA512 %s
! RUN: %flang --target=i386 -mno-sha512 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-SHA512 %s
! SHA512: "-target-feature" "+sha512"
! NO-SHA512: "-target-feature" "-sha512"

! RUN: %flang --target=i386 -msm3 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=SM3 %s
! RUN: %flang --target=i386 -mno-sm3 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-SM3 %s
! SM3: "-target-feature" "+sm3"
! NO-SM3: "-target-feature" "-sm3"

! RUN: %flang --target=i386 -msm4 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=SM4 %s
! RUN: %flang --target=i386 -mno-sm4 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-SM4 %s
! SM4: "-target-feature" "+sm4"
! NO-SM4: "-target-feature" "-sm4"

! RUN: %flang --target=i386 -mavxvnniint16 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=AVXVNNIINT16 %s
! RUN: %flang --target=i386 -mno-avxvnniint16 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AVXVNNIINT16 %s
! AVXVNNIINT16: "-target-feature" "+avxvnniint16"
! NO-AVXVNNIINT16: "-target-feature" "-avxvnniint16"

! RUN: %flang --target=i386 -mavx10.1 -### %s -Werror 2>&1 \
! RUN:     | FileCheck -check-prefix=AVX10_1 %s
! RUN: %flang --target=i386 -mno-avx10.1 -### %s -Werror 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AVX10_1 %s
! AVX10_1: "-target-feature" "+avx10.1"
! NO-AVX10_1: "-target-feature" "-avx10.1"

! RUN: %flang --target=i386 -mavx10.2 -### %s -Werror 2>&1 \
! RUN:     | FileCheck -check-prefix=AVX10_2 %s
! RUN: %flang --target=i386 -mno-avx10.2 -### %s -Werror 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-AVX10_2 %s
! AVX10_2: "-target-feature" "+avx10.2"
! NO-AVX10_2: "-target-feature" "-avx10.2"

! RUN: %flang --target=i386 -musermsr -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=USERMSR %s
! RUN: %flang --target=i386 -mno-usermsr -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-USERMSR %s
! USERMSR: "-target-feature" "+usermsr"
! NO-USERMSR: "-target-feature" "-usermsr"

! RUN: %flang --target=i386 -mmovrs -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=MOVRS %s
! RUN: %flang --target=i386 -mno-movrs -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-MOVRS %s
! MOVRS: "-target-feature" "+movrs"
! NO-MOVRS: "-target-feature" "-movrs"

! RUN: %flang --target=i386 -march=i386 -mcrc32 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=CRC32 %s
! RUN: %flang --target=i386 -march=i386 -mno-crc32 -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-CRC32 %s
! CRC32: "-target-feature" "+crc32"
! NO-CRC32: "-target-feature" "-crc32"

! RUN: not %flang --target=aarch64 -### %s \
! RUN:     -mcrc32 -msse4.1 -msse4.2 -mno-sgx 2>&1 \
! RUN:     | FileCheck --check-prefix=NONX86 %s
! NONX86:      error: unsupported option '-mcrc32' for target 'aarch64'
! NONX86-NEXT: error: unsupported option '-msse4.1' for target 'aarch64'
!/ TODO: This warning is a workaround for https:!github.com/llvm/llvm-project/issues/63270
! NONX86-NEXT: warning: argument unused during compilation: '-msse4.2' [-Wunused-command-line-argument]
! NONX86-NEXT: error: unsupported option '-mno-sgx' for target 'aarch64'

! RUN: not %flang -### --target=i386 -muintr %s 2>&1 \
! RUN:     | FileCheck --check-prefix=NON-UINTR %s
! RUN: %flang -### --target=i386 -mno-uintr %s 2>&1 > /dev/null
! RUN: not %flang -### --target=i386 -mapx-features=ndd %s 2>&1 \
! RUN:     | FileCheck --check-prefix=NON-APX %s
! RUN: not %flang -### --target=i386 -mapxf %s 2>&1 \
! RUN:     | FileCheck --check-prefix=NON-APX %s
! RUN: %flang -### --target=i386 -mno-apxf %s 2>&1 > /dev/null
! NON-UINTR:    error: unsupported option '-muintr' for target 'i386'
! NON-APX:      error: unsupported option '-mapx-features=|-mapxf' for target 'i386'
! NON-APX-NOT:  error: {{.*}} -mapx-features=

! RUN: %flang --target=x86_64-unknown-linux-gnu -mapxf -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=APXF %s
! RUN: %flang --target=x86_64-unknown-linux-gnu -mno-apxf -### %s 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-APXF %s
!
! APXF: "-target-feature" "+egpr" "-target-feature" "+push2pop2" "-target-feature" "+ppx" "-target-feature" "+ndd" "-target-feature" "+ccmp" "-target-feature" "+nf" "-target-feature" "+zu"
! NO-APXF: "-target-feature" "-egpr" "-target-feature" "-push2pop2" "-target-feature" "-ppx" "-target-feature" "-ndd" "-target-feature" "-ccmp" "-target-feature" "-nf" "-target-feature" "-zu"

! RUN: %flang --target=x86_64-pc-linux-gnu -### %s -mapx-features=egpr 2>&1 \
! RUN:     | FileCheck -check-prefix=EGPR %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s -mapx-features=push2pop2 2>&1 \
! RUN:     | FileCheck -check-prefix=PUSH2POP2 %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s -mapx-features=ppx 2>&1 \
! RUN:     | FileCheck -check-prefix=PPX %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s -mapx-features=ndd 2>&1 \
! RUN:     | FileCheck -check-prefix=NDD %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s -mapx-features=ccmp 2>&1 \
! RUN:     | FileCheck -check-prefix=CCMP %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s -mapx-features=nf 2>&1 \
! RUN:     | FileCheck -check-prefix=NF %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s -mapx-features=cf 2>&1 \
! RUN:     | FileCheck -check-prefix=CF %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s -mapx-features=zu 2>&1 \
! RUN:     | FileCheck -check-prefix=ZU %s
! EGPR: "-target-feature" "+egpr"
! PUSH2POP2: "-target-feature" "+push2pop2"
! PPX: "-target-feature" "+ppx"
! NDD: "-target-feature" "+ndd"
! CCMP: "-target-feature" "+ccmp"
! NF: "-target-feature" "+nf"
! CF: "-target-feature" "+cf"
! ZU: "-target-feature" "+zu"

! RUN: %flang --target=x86_64-pc-linux-gnu -### %s \
! RUN:     -mapx-features=egpr,ndd 2>&1 \
! RUN:     | FileCheck -check-prefix=EGPR-NDD %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s \
! RUN:     -mapx-features=egpr -mapx-features=ndd 2>&1 \
! RUN:     | FileCheck -check-prefix=EGPR-NDD %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s \
! RUN:     -mno-apx-features=egpr -mno-apx-features=ndd 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-EGPR-NO-NDD %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s \
! RUN:     -mno-apx-features=egpr -mapx-features=egpr,ndd 2>&1 \
! RUN:     | FileCheck -check-prefix=EGPR-NDD %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s \
! RUN:     -mno-apx-features=egpr,ndd -mapx-features=egpr 2>&1 \
! RUN:     | FileCheck -check-prefix=EGPR-NO-NDD %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s \
! RUN:     -mapx-features=egpr,ndd -mno-apx-features=egpr 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-EGPR-NDD %s
! RUN: %flang --target=x86_64-pc-linux-gnu -### %s \
! RUN:     -mapx-features=egpr -mno-apx-features=egpr,ndd 2>&1 \
! RUN:     | FileCheck -check-prefix=NO-EGPR-NO-NDD %s
!
! EGPR-NDD: "-target-feature" "+egpr" "-target-feature" "+ndd"
! EGPR-NO-NDD: "-target-feature" "-ndd" "-target-feature" "+egpr"
! NO-EGPR-NDD: "-target-feature" "+ndd" "-target-feature" "-egpr"
! NO-EGPR-NO-NDD: "-target-feature" "-egpr" "-target-feature" "-ndd"

! RUN: not %flang --target=x86_64-unknown-linux-gnu -### %s \
! RUN:     -mapx-features=egpr,foo,bar 2>&1 \
! RUN:     | FileCheck -check-prefix=ERROR %s
!
! ERROR: unsupported argument 'foo' to option '-mapx-features='
! ERROR: unsupported argument 'bar' to option '-mapx-features='
