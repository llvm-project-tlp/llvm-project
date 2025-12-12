<!--===- docs/CombinedFlangCommunityCallNotes.md

   Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
   See https://llvm.org/LICENSE.txt for license information.
   SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

-->
# Combined Flang Community Call Notes

## About these notes

This document now combines the notes from the LLVM Flang Technical Calls
and the LLVM Flang Community Calls. This was done to make the Community Call 
notes more publicly available than we could make them previously.

## Helpful definitions

- "LLVM Flang" is the Fortran 2018 compiler being developed as part of the 
LLVM project, and located in the LLVM monorepo ([github.com/llvm/llvm-project](http://github.com/llvm/llvm-project)).  
- "Classic Flang" is the Flang Fortran 2003/2008 compiler located at [github.com/flang-compiler/flang](http://github.com/flang-compiler/flang).

## Call Information

* 8:30 am PT alternating Wednesdays  
* Join from the meeting link  
  * [https://lanl-us.webex.com/lanl-us/j.php?MTID=m0fcaebfcf6b4b4f506efd792a71a015c](https://lanl-us.webex.com/lanl-us/j.php?MTID=m0fcaebfcf6b4b4f506efd792a71a015c)
* Join by meeting number  
  * Meeting number (access code): 177 400 7047  
  * Meeting password: 6PCdCYKmN43  
  * Tap to join from a mobile device (attendees only)  
  * [\+1-415-655-0002,,1774007047\#\#](tel:%2B1-415-655-0002,,*01*1774007047%23%23*01*) US Toll  
* Join by phone  
  * [\+1-415-655-0002](tel:+14156550002) US Toll  
  * [Global call-in numbers](https://lanl-us.webex.com/lanl-us/globalcallin.php?MTID=ma8c4fc1f538bce541415427fbe89c85b)  
* Join from a video system or application  
  * Dial [1774007047@lanl-us.webex.com](mailto:1774007047@lanl-us.webex.com
)  
  * You can also dial 173.243.2.68 and enter your meeting number

## Flang Community

* **Websites:**  
  * **LLVM Flang:** [https://flang.llvm.org](https://flang.llvm.org)   
  * **Classic Flang:** [https://github.com/flang-compiler/flang](https://github.com/flang-compiler/flang) 

* **Issues:**  
  * Issues for LLVM Flang should be reported in GitHub: [https://github.com/llvm/llvm-project/issues](https://github.com/llvm/llvm-project/issues).
  Use the "flang" tag for flang-related issues, please  
  * Issues for Classic Flang should be reported to the GitHub issues section at either [https://github.com/flang-compiler/flang/issues](https://github.com/flang-compiler/flang/issues)
  or [flang-compiler/flang-driver](https://github.com/flang-compiler/flang-driver) as appropriate

* **LLVM mailing lists and Discourse channels:** There are now two communication channels hosted by llvm.org:  
  * The Flang Discourse channel: [https://discourse.llvm.org/c/subprojects/flang/33](https://discourse.llvm.org/c/subprojects/flang/33)   
  * The flang-commits mailing list: subscribe at [https://lists.llvm.org/cgi-bin/mailman/listinfo/flang-commits](https://lists.llvm.org/cgi-bin/mailman/listinfo/flang-commits) 

* **Slack:** The [flang-compiler.slack.com](http://flang-compiler.slack.com)
workspace is used for informal real-time communication in the Flang community.  
  * Classic Flang \- use the Slack channel \#classic-flang-pull-requests to
 coordinate what pull requests you are working on

* **LLVM Flang Development:**  
  * On GitHub: The source code for LLVM Flang is available on [https://github.com/llvm/llvm-project/tree/main/flang](https://github.com/llvm/llvm-project/tree/main/flang). It is recommended to start in the "docs" directory.  
  * Public plan: The team maintains a plan for upcoming Flang work at [https://github.com/orgs/flang-compiler/projects/](https://github.com/orgs/flang-compiler/projects/). This reflects current LLVM Flang priorities and context for the
  project and its long-term goals. (OpenMP work for flang, clang, and
  OpenMPIRBuilder is tracked separately.)

* **Classic Flang Development:**  
  * Outstanding pull requests: [https://github.com/flang-compiler/flang/pulls](https://github.com/flang-compiler/flang/pulls)
  for the current list of 
pull requests  
  * Current status of Fortran 2008 features can be found at [https://github.com/flang-compiler/flang/wiki/Fortran-2008](https://github.com/flang-compiler/flang/wiki/Fortran-2008). 

## NOTES

### Combined Call 2025-12-03

#### Agenda

* Design docs and/or RFCs  
  * [\[RFC\] How to inform users why an executable stack is required](https://discourse.llvm.org/t/rfc-how-to-inform-users-why-an-executable-stack-is-required/89007)  
    * Currently trampolines are implemented on the stack requiring the stack
    to be executable and the linker emits a message about it, but this may
    be confusing to users  
    * There are a few options to explore for how to improve this
    implementation (see RFC)  
    * Reorganizing the table of contents for the documentation \- seems a
    good idea and at least one person volunteered to review PRs related to this 
 
    * Should trampolines be implemented on the stack or on the heap?  
      * Kiran: Implementing on the heap is better, but do people have the
      bandwidth to re-implement on the heap?  
    * This RFC is about improving the explanation to users, not necessarily
    about re-implementing trampolines in an improved fashion  
  * [\`-ffp-contract=fast\` Violates the Fortran Standard](https://discourse.llvm.org/t/ffp-contract-fast-violates-the-fortran-standard/88897)  
    * Themos Tsikas: currently there is a disagreement about parentheses in
    rounding.  We may need an interp request from the J3 committee.  
    * Jean Perier: we need to account for behavior that apps rely on and
    provide a fallback mechanism if we make a change  
  * [\[RFC\] Command-line compatibility with gfortran](https://discourse.llvm.org/t/rfc-command-line-compatibility-with-gfortran/88961)     
    * Related PR: [https://github.com/llvm/llvm-project/pull/165579](https://github.com/llvm/llvm-project/pull/165579)  
    * Consensus: we should not try to aim for command-line compatibility
    with gfortran, and a list exists of specific options that are wanted by
    users for their specific cases.  Support for options will be considered
    on a case-by-case basis.  
    * Compatibility with Clang \> with gfortran  
* PRs of Note  
  * [\[Flang\]\[FIR\] Introduce FIRToCoreMLIR pass. \#168703](https://github.com/llvm/llvm-project/pull/168703)    
* Issues of Note  
  * [Invalid code for 'where'](https://urldefense.com/v3/__https://discourse.llvm.org/t/invalid-code-for-where/88881/2__;!!Bt8fGhp8LhKGRg!AzRYeczr2-nZWMBB2mVGUwRR3M58rt_SIF-svPI6IVhIyIiSgTTDssvRaU8H0UI4kGx_9LKg4f2gkD4HaosWtAksKlal0j8r$)   
* FYI  
  * CFP FOSDEM 2026 LLVM dev room  
    * extended the submission deadline with 1 week until December 7th  
    * [Discourse post](https://urldefense.com/v3/__https://discourse.llvm.org/t/cfp-fosdem-2026-llvm-dev-room-deadline-extended-until-december-7th/88746/2__;!!Bt8fGhp8LhKGRg!CN-bph7losNBxOURN0VbmhDaHVSVDiQSqbr3oJqWjE6O7tA4Q3yebG-T8B6JQFkQc97cWmtY5XlHyqO9n44zxlCjPvgysnnW$)  
  * [Flang Liaison Report ot J3](https://j3-fortran.org/doc/year/25/25-184r1.txt)   
  * [Operational Maturity Round Table Notes](https://urldefense.com/v3/__https://discourse.llvm.org/t/operational-maturity-round-table-notes/88898/4__;!!Bt8fGhp8LhKGRg!DBCD7MXLIlKDQMxYC24V2tf9xKpQF7PD3s92rD_AqokuSQOdNeDC7vxesj3En2jeZJlK5nCu2wRFTbe3WtjJCi-o4hGTHJtt$)  
    * Possible switch to PR-only mechanism  
* Other topics as time allows  
  * Proposing an Interactive Fortran Workflow with Flang using Jupyter
  Notebooks  
    * Anutosh Bhat \- Fortran ecosystem lacks a modern interactive workflow
  
    * Something is available using LFortran, but it's not perfect: [https://github.com/lfortran/lfortran/blob/main/share/lfortran/nb/Demo1.ipynb](https://github.com/lfortran/lfortran/blob/main/share/lfortran/nb/Demo1.ipynb)  
 
    * Flang seems a natural place to bring this into being  
    * [https://compiler-research.org/xeus-cpp-wasm/lab/index.html](https://compiler-research.org/xeus-cpp-wasm/lab/index.html)   
    * There is clang-repl for this with C++  
    * RFC coming  
    * [OpenMP notebook demo](https://github.com/compiler-research/xeus-cpp/blob/da0cc730b175c2dd880d16845187e68917afc9f5/notebooks/openmp-notebooks/openmp-demo.ipynb)
    * [CUDA notebook demo](https://github.com/compiler-research/xeus-clang-repl/blob/main/notebooks/kalman_CUDA_demo/run_kf.ipynb)   
    * [prototype-debug.mp4](https://drive.google.com/file/d/1KxMpHz7njRTb2d1FSTPumZXfgoNRHhbM/view)
    * [FOSDEM 2025 \- O\_o \[ Flang \+ WASM \] o\_O](https://archive.fosdem.org/2025/schedule/event/fosdem-2025-5202-oo-flang-wasm-oo/)   
  * Given the issues with the Call Notes document, this may be a good time
  to migrate to a Markdown document located in the repo  

#### Details

* Consists of over **704,000** lines of code, documentation, build files,
and test  
* To date, over **11,430** commits have been made to Flang
