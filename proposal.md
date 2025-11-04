# Senior Project Proposal: Cold Boot Attack on RISC-V

**Project Title:** Develop open source tools to demonstrate a cold boot attack on RISC-V<br>
**Student:** Gabriel Bauer<br>
**Faculty Advisor:** Nat Tuck<br>
**Department:** Computer Science<br> 
**Date:** 11-03-2025<br>
**Duration:** 16 Weeks (Spring 2026 Semester)

---

## Abstract

This senior project proposes the design and implementation of a proof-of-concept cold boot attack framework targeting the RISC-V architecture, specifically the SiFive HiFive Unmatched B. The project will develop a custom UEFI application capable of performing a memory dump directly from the system's RAM during the boot process, bypassing standard operating system protections. The implementation will progress from establishing a RISC-V development environment using QEMU and EDK2, to creating the memory acquisition tool, and culminate in the development of an analysis program that scans dumped memory for high-entropy data patterns indicative of cryptographic keys. This work aims to demonstrate the viability of hardware-based attacks on modern RISC-V systems and will provide a foundational toolkit for further research into memory forensics and physical security vulnerabilities on non-x86 architectures. If the UEFI application and demonstration prove too simple, a secondary, non-UEFI RISC-V development board will be purchased, and the process of creating a program to dump system RAM will be created in pure Assembly/C.

1.  **Hardware Dependency:** The core of a cold boot attack is the physical property of memory decay. This **cannot** be fully simulated in QEMU, as QEMU virtualizes memory and doesn't simulate its physical decay. QEMU is perfect for the software development phase, but the final proof-of-concept will require real hardware (a HiFive Unmatched B).
2.  **Complexity:** This is dealing with the intersection of RISC-V architecture, UEFI development, and memory forensics. Each of these is a deep field on its own.
3.  **UEFI on RISC-V:** While UEFI for RISC-V exists (e.g., in TianoCore EDK2), it's a less common and potentially less documented path than for x86_64.

Given these challenges, the project's goal should be refined to: **"To develop and demonstrate a proof-of-concept cold boot attack framework for a RISC-V system, implementing the key software components in a UEFI application and validating the memory dumping mechanism."**

The "attack" part would be considered successful if it can dump memory from a "suspended" state (simulating the decay) and find a known key placed in memory.

### Courses Used:
- CS2220 - Computer Hardware
- CS2470 - Systems Programming in C/C++
- CS4250 - Computer Architecture
- CS4310 - Operating Systems

### 16-Week Senior Project Plan

This plan is aggressive. I will need to be disciplined and proactive.

#### Phase 1: Foundation & Environment (Weeks 1-4)

**Goal:** Establish a working development and debugging environment.

*   **Week 1: Project Setup & Research**
    *   **Tasks:**
        1.  Set up a Linux development machine (I already have this.)
        3.  Install QEMU for RISC-V targets (`qemu-system-riscv64`.)
        4.  **Research:** Read the SiFive U74 manual. Understand the basics of the RISC-V privilege levels (M, S, U). Read high-level overviews of cold boot attacks and UEFI.
    *   **Deliverable:** A working QEMU RISC-V build and a 1-2-page project proposal document outlining the attack theory and plan.

*   **Week 2: Booting a RISC-V System in QEMU**
    *   **Tasks:**
        1.  Find a [pre-built RISC-V UEFI firmware image](https://retrage.github.io/edk2-nightly/).
        2.  Create a virtual disk image (`qemu-img create -f qcow2 disk.qcow2 1G`).
        3.  Craft a QEMU command line that boots the RISC-V VM using the UEFI firmware and the virtual disk.
        4.  Get a shell or console prompt in the QEMU VM.
    *   **Deliverable:** A script that successfully launches a RISC-V QEMU VM.

*   **Week 3: UEFI Development Toolchain**
    *   **Tasks:**
        1.  Set up the EDK2 build environment. This is complex; follow the official EDK2 documentation for RISC-V.
        2.  Build the base EDK2 firmware for RISC-V in QEMU.
        3.  Navigate to the sample application directory.
    *   **Deliverable:** A confirmed, working EDK2 build environment.

*   **Week 4: "Hello World" UEFI Application**
    *   **Tasks:**
        1.  Create my own new UEFI application module within the EDK2 source tree.
        2.  Write the simplest possible "Hello World" application using the `Print()` function from the UEFI System Table.
        3.  Compile it into an EFI executable (`.efi` file).
        4.  Copy the `.efi` file to my virtual disk image.
        5.  Boot the QEMU VM and successfully execute my "Hello World" application from the UEFI shell.
    *   **Deliverable:** A screenshot or log of my custom UEFI application running inside the QEMU VM.

#### Phase 2: Core Memory Dumping Logic (Weeks 5-9)

**Goal:** Build the fundamental capability to access and dump system memory.

*   **Week 5-6: Understanding UEFI Memory Services**
    *   **Tasks:**
        1.  Study the UEFI specification, focusing on the `EFI_MEMORY_ATTRIBUTE_PROTOCOL` and the Boot Services `GetMemoryMap()`.
        2.  Write a UEFI application that retrieves the system's memory map and prints it out.
        3.  Identify which memory regions are likely to contain OS runtime data (conventional memory) and which are reserved.
    *   **Deliverable:** An application that logs the complete memory map of the QEMU VM.

*   **Week 7-8: Direct Memory Access & Dumping**
    *   **Tasks:**
        1.  Learn how to read from physical memory addresses in UEFI. (This often involves understanding that the OS may not have overwritten the identity mapping present at boot).
        2.  Write a function that, given a starting physical address and a length, reads the memory content.
        3.  Modify my application to dump the entire "Conventional Memory" region to a file on the virtual disk.
    *   **Deliverable:** An application that can create a binary file containing a dump of system RAM.

*   **Week 9: microSD Card Storage Protocol**
    *   **Tasks:**
        1.  Research the `EFI_BLOCK_IO_PROTOCOL` and `EFI_FILE_PROTOCOL`.
        2.  Modify my dumping application to locate a microSD storage device.
        3.  Write the memory dump file directly to the microSD device's file system (e.g., a FAT32 partition). This is much more realistic than using the virtual disk.
    *   **Deliverable:** Memory dump successfully saved to a microSD storage device attached to QEMU.

#### Phase 3: Cold Boot Attack Simulation & Analysis (Weeks 10-13)

**Goal:** Implement the "attack" logic and analyze the dumped memory.

*   **Week 10: Simulating the "Cold Boot"**
    *   **Tasks:**
        1.  Write a simple C program for a generic OS (e.g., Linux) that allocates a buffer and places a known cryptographic key (e.g., a 256-bit AES key) in it.
        2.  Boot the RISC-V VM into this OS and run the program to load the key into memory.
        3.  **Simulate Reset:** Use QEMU's `pmemsave` command to snapshot memory at a specific point. This is the "cold boot" simulation.
    *   **Deliverable:** A methodology for getting a key into RAM and then booting into my UEFI dumper.

*   **Week 11-12: Key-Finding Algorithm**
    *   **Tasks:**
        1.  Write a separate, host-based analysis tool (in Python or C) that can parse my memory dump file.
        2.  Implement a simple entropy calculation function (e.g., Shannon entropy).
        3.  Implement a sliding window that scans the memory dump, calculating the entropy of each chunk (e.g., 32-byte chunks). Flag chunks with entropy above a certain threshold as potential keys.
        4.  Implement a simple pattern search to find the specific known key you planted.
    *   **Deliverable:** A host-based tool that can successfully locate the known key inside a memory dump.

*   **Week 13: Integration & Testing**
    *   **Tasks:**
        1.  Perform the full simulated attack chain: Boot OS -> Load Key -> Simulate Reset -> Boot UEFI Dumper -> Dump to microSD -> Analyze on Host -> Find Key.
        2.  Refine the tools and scripts. Document the entire process.
        3.  Test with different key sizes and locations.
    *   **Deliverable:** A fully integrated, working proof-of-concept.

#### Phase 4: Wrap-up (Weeks 14-15)

*   **Week 14: Final Testing & Documentation**
    *   **Tasks:**
        1.  Finalize all code and comments.
        2.  Write the final project report. Include: Introduction, Background, Methodology, Challenges, Results (with screenshots and logs of the key being found), and Conclusion.
        3.  Prepare my presentation.
    *   **Deliverable:** Complete final report and presentation slides.

-   **Week 15: Bare-Metal Testing**
    *   **Tasks:**
        1. Install UEFI application on physical microSD.
        2. Install latest LTS version of Ubuntu (24.04) with FDE on a HiFive Unmatched B
        3. Utilize a bottle of compressed cooling air and a circuit breaker to simulate a cold boot
        4. Utilize the UEFI enabled microSD to dump system RAM on startup
        5. Utilize the key-finding algorithm to attempt to find the encryption key
    - **Deliverable:** Working demonstration of cold boot attack on a modern RISC-V board

*   **Week 16: Presentation**
    *   **Tasks:**
        1.  Practice my presentation.
        2.  Deliver my presentation and demo.
    *   **Deliverable:** A successful project presentation and demonstration.
    
## Risk Assessment

### Technical Risks
| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|-------------------|
| Hardware documentation gaps | High | Medium | Investigate the boot process used by open source systems like FreeBSD or Linux on the board |
| Lack of sufficient EDK2 documentation | High | High | Define a minimum viable product (MVP) which defines a basic "Hello World" UEFI application getting to run, grep the git logs and ask for help from online communities |
| Timeline overruns | Medium | Medium | Defined MVP |

### Success Criteria

**Minimum Viable Product:**
- Get through Phase 1. A well-documented report on the process of setting up the RISC-V QEMU/EDK2 environment, the challenges of UEFI development, and a working "Hello World" UEFI application.

**Target Achievement:**
- Get through Phase 2. A UEFI application that can successfully dump the memory map and save a RAM image to a file in QEMU. The key-finding algorithm can be a separate, host-based tool.

**Stretch Goals:**
- Successfully port the entire QEMU-based proof-of-concept to a physical HiFive Unmatched board.
- **Conditional Live Demonstration:** *If and only if* the physical attack can be reliably replicated multiple times in a controlled, pre-presentation environment, a live demo will be performed.
- **Video Demonstration Fallback:** A pre-recorded, high-quality video of a successful full attack chain (from OS boot to key recovery) will be produced as the primary demonstration asset for the final presentation.

**Going Further:**
- If the development of the UEFI scraper proves to be too simple, buy another RISC-V development board without UEFI and try to accomplish the same task in pure Assembly and/or C

## Resource Requirements

### Hardware
- Any machine which can run a Linux development environment (already have)
- A SiFive HiFive Unmatched B
- Two microSDs (one with our UEFI application to dump RAM data and a second to host a full OS to process the dumped data)
- A microSD to USB converter (for when we intend to process our dumped data, the HiFive Unmatched B only has one microSD slot)
- A bottle of compressed air

### Software
- qemu-system-riscv64
- A UEFI development library for developing UEFI applications for RISC-V (TianoCore EDK II)
- A toolchain capable of cross-compilation (Clang)

### Documentation & References
- TianoCore documentation
- RISC-V documentation and specs
- Shannon entropy algorithm references
- Online forums and communities

