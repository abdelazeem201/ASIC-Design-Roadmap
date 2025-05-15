# 🧠 ASIC Design Roadmap

> Empowering students worldwide with a complete roadmap to learn **Application Specific Integrated Circuit (ASIC)** Design — from logic to layout, RTL to GDSII.

<div align="center">بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم</div>
<div align="center">“وَمَا أُوتِيتُمْ مِنَ الْعِلْمِ إِلَّا قَلِيلًا”</div>

---

The journey of designing an ASIC (Application Specific Integrated Circuit) is long and deeply technical — transforming an idea into silicon requires precision, planning, and patience. Despite the final chip being only a few nanometers in scale, the design process includes multiple sophisticated steps filled with engineering challenges and opportunities for learning.

ASICs are purpose-built chips tailored for specific applications. Unlike general-purpose processors or FPGAs, they are optimized for power, performance, and area (PPA), making them ideal for mass production. Their circuits, built from permanent gates and flip-flops, are described using hardware description languages such as Verilog, SystemVerilog, or VHDL.

> ✅ More power-efficient than FPGAs  
> ✅ Capable of higher frequencies  
> ✅ Ideal for high-volume production  
> ⚠️ Not suitable for frequent upgrades  
> ⚠️ Bugs after tape-out are costly

![Complex ASIC Design](https://github.com/abdelazeem201/ASIC-Physical-Design-Roadmap/blob/main/Figures/Fig.%20Complex%20ASIC%20Design.jpeg)
---

# 📌 Why This Roadmap?
Many students and entry-level engineers want to break into the world of IC design but are unsure where to begin or how to build strong fundamentals. When you search for resources online, the flood of random posts and YouTube videos can leave you even more lost and overwhelmed. That’s why I decided to build this open-source roadmap — to make the learning process smoother and more organized for anyone looking to enter the industry.

# 🎯 Who Is This For?
Whether you’re a student, fresh graduate, or an engineer transitioning into VLSI, this roadmap is tailored to help you navigate Physical Design — one of the most critical and challenging domains in ASIC development.

# 🚀 What’s Inside?
This roadmap is not just a list of tools or topics. It’s a carefully structured guide with:

> * Step-by-step learning paths from basic concepts to industry-level knowledge
> * Hands-on projects and scripts to give you practical experience
> * Tips and insights from real-world Physical Design workflows
> * Links to trusted resources — not just random Google or YouTube results


---

## 📘 Table of Contents

- [Introduction](#introduction)
- [Fundamentals](#fundamentals)
- [ASIC Design Flow](#asic-design-flow)
- [Awesome Digital IC Resources](#awesome-digital-ic-resources)
- [Project Repositories and IPs](#project-repositories-and-ips)

---

## 🧾 Introduction

The aim of this roadmap is to provide aspiring ASIC and Digital IC designers a clear path to follow — with carefully selected courses, resources, and projects that balance theory and practice. Whether you're a beginner or transitioning from FPGA/Embedded design, this roadmap is crafted to guide you through every phase of ASIC development.

---

## 🧱 Fundamentals

### 1. **Digital Electronics & CMOS Basics**
- [Digital Electronics (Playlist)](https://www.youtube.com/playlist?list=PLMSBalys69yzp1vrmnYAmpRFiptbuGuaj) 📽  
  *Focus: Logic gates, FFs, CMOS inverter, MOSFET switching.*

### 2. **Digital Logic Design / Frontend**
- [Digital Design – CS221 by Dr. Waleed Youssef](https://youtube.com/playlist?list=PLoK2Lr1miEm8b6Vv5zAfsbMEPZ1C7fCQw) 📽  
- [Verilog Modeling – Dr. Indranil Sen Gupta](https://www.youtube.com/playlist?list=PLJ5C_6qdAvBELELTSPgzYkQg3HgclQh-5) 📽  

### 3. **Computer Architecture**
- [Digital Design and Computer Architecture (YouTube)](https://www.youtube.com/playlist?list=PL5Q2soXY2Zi_FRrloMa2fUYWPGiZUBQo2) 📽

### 4. **Digital IC Design (RTL to ASIC)**
> Based on "CMOS VLSI Design" by Weste & Harris  
- [Part 1](https://youtube.com/playlist?list=PLMSBalys69yzvAKErDt7tT7O-iIKPlOCP) 📽  
- [Part 2](https://youtube.com/playlist?list=PLMSBalys69yxoIjeZ2Q3fxs69cGCU14B1) 📽  
- [Part 3](https://youtube.com/playlist?list=PLMSBalys69yw1tSoF42QW9jbbC0-UeCAy) 📽  

---

## 🔧 ASIC Design Flow

### Logic Synthesis & Timing Closure
- [Advanced Logic Synthesis by Dhiraj Taneja](https://www.youtube.com/playlist?list=PLbMVogVj5nJQe0_9YJlN9S7ktkA8DI-fL) 📽  
  *Includes Synopsys DC/PT Labs – skip first 12 videos if needed*

### Physical Design
- [Physical Design – Prof. Indranil Sengupta](https://www.youtube.com/playlist?list=PLU8VFS-HdvKtKswbcvvA8yVhzleTV7OE8) 📽  
  *Covers Floorplanning, Placement, CTS, Routing, DRC/LVS*

- [RTL to GDSII (by Adi Teman)](https://www.youtube.com/playlist?list=PLZU5hLL_713x0_AV_rVbay0pWmED7992G) 📽  
  *Very recommended* ✅

- [My Slideshare RTL2GDSII Notes](https://www.slideshare.net/AhmedAbdelazeem28/presentations) 📚

---

## 🌍 Awesome Digital IC Resources

> Curated lists and tools for ASIC/VLSI/FPGA engineers

| Name | Type | Description |
|------|------|-------------|
| [Awesome FPGA](https://github.com/Vitorian/awesome-fpga) | 📍⭐ | FPGA resources and boards |
| [Awesome HDL](https://github.com/drom/awesome-hdl) | 📍⭐ | Hardware description languages |
| [Awesome Open Source EDA](https://github.com/clin99/awesome-eda) | 📍 | Open-source EDA tools |
| [Awesome Hardware Verification](https://github.com/ben-marshall/awesome-open-hardware-verification) | 📍 | Verification tools |
| [Awesome HWD Tools](https://github.com/TM90/awesome-hwd-tools) | 📍 | Open-source IC design tools |
| [Awesome Lattice FPGAs](https://github.com/kelu124/awesome-latticeFPGAs) | 📍 | Lattice FPGA board list |

---

## 📦 Project Repositories and IPs

### Core IPs and Repos
- [OpenCores](https://opencores.org/) ⭐ - IP Cores Archive  
- [FreeCores](http://freecores.github.io/) 📍 - Legacy IPs from OpenCores  
- [Basic Verilog Modules](https://github.com/pConst/basic_verilog) 📍 - Synthesizable Verilog modules  
- [32 Mini Projects (Verilog)](https://github.com/sudhamshu091/32-Verilog-Mini-Projects) 📍👶

### Communication Protocols
- [Alex Forencich's IPs](http://alexforencich.com/wiki/en/verilog/start) - PCIe, Ethernet, I2C, UART and more


### Information Technology

#### RISC-V

- [RISC-V Instruction Set Manual](https://github.com/riscv/riscv-isa-manual) - This repository contains the LaTeX source for the draft RISC-V Instruction Set Manual.

- [RISC-V Exchange: Cores & SoCs](https://riscv.org/exchanges/cores-socs/) - A list of RICS-V cores and SoCs.
- [PULP](https://github.com/pulp-platform/pulp) - Open source Parallel Ultra-Low-Power RISC-V core.
- [openc910](https://github.com/T-head-Semi/openc910) 📍![stars](https://img.shields.io/github/stars/T-head-Semi/openc910) - OpenXuantie C910 Core.
- [XiangShan](https://github.com/OpenXiangShan/XiangShan) 📍![stars](https://img.shields.io/github/stars/OpenXiangShan/XiangShan) - Open-source high-performance RISC-V processor.
- [riscv-starship](https://github.com/riscv-zju/riscv-starship) 📍![stars](https://img.shields.io/github/stars/riscv-zju/riscv-starship) - Run rocket-chip on FPGA(Xilinx Virtex-7 VC707).
- [Wujian100](https://github.com/T-head-Semi/wujian100_open) 📍![stars](https://img.shields.io/github/stars/T-head-Semi/wujian100_open) - A MCU base SoC.
- [picorv32](https://github.com/YosysHQ/picorv32) 📍![stars](https://img.shields.io/github/stars/YosysHQ/picorv32) - A Size-Optimized RISC-V CPU.
- [Hummingbirdv2 E203 Core and SoC](https://github.com/riscv-mcu/e203_hbirdv2) 📍![stars](https://img.shields.io/github/stars/riscv-mcu/e203_hbirdv2) [Docs](https://doc.nucleisys.com/hbirdv2/) - A Ultra-Low Power RISC-V Core.
- [darkriscv](https://github.com/darklife/darkriscv) 📍![stars](https://img.shields.io/github/stars/darklife/darkriscv) - A proof of concept for the opensource RISC-V instruction set.
- [CVA6 RISC-V CPU](https://github.com/openhwgroup/cva6) 📍![stars](https://img.shields.io/github/stars/openhwgroup/cva6) - An application class 6-stage RISC-V CPU capable of booting Linux.
- [VexRiscv](https://github.com/SpinalHDL/VexRiscv) 📍![stars](https://img.shields.io/github/stars/SpinalHDL/VexRiscv) - A FPGA friendly 32 bit RISC-V CPU implementation.

#### Others

- [zipcpu](https://github.com/ZipCPU/zipcpu) ⭐📍![stars](https://img.shields.io/github/stars/ZipCPU/zipcpu) - with detailed comments.
- [openmsp430](https://opencores.org/projects/openmsp430) - The openMSP430 is a synthesizable 16bit microcontroller core written in Verilog.
- [Nyuzi Processor](https://github.com/jbush001/NyuziProcessor) 📍![stars](https://img.shields.io/github/stars/jbush001/NyuziProcessor) - GPGPU microprocessor architecture.

## Tutorials and Courses 💬[Intro](./Tutorials%20and%20Courses/README.md)

- [zipcpu](http://zipcpu.com/tutorial/) 👶 - Verilog, Formal Verification and Verilator Beginner's Tutorial
- [WORLD OF ASIC](http://asic-world.com/) ⭐ - A great source of detailed VLSI tutorials and examples.

### HDL

- More information about hardware description language on [Awesome HDL](https://github.com/drom/awesome-hdl)

#### Verilog Grammar

- [Verilog TUTORIAL for beginners](http://www.referencedesigner.com/tutorials/verilog/verilog_01.php) 👶 - A tutorial based upon free Icarus Verilog compiler.
- [ChipVerify: Verilog Tutorial](https://www.chipverify.com/verilog/verilog-tutorial) - A guide for someone new to Verilog.
- [Verilog/SystemVerilog Guide](https://github.com/mikeroyal/Verilog-SystemVerilog-Guide) 📍![stars](https://img.shields.io/github/stars/mikeroyal/Verilog-SystemVerilog-Guide) - A guide covering Verilog & SystemVerilog.


#### VHDL Grammar

- [VHDL Guide](https://github.com/mikeroyal/VHDL-Guide) 📍![stars](https://img.shields.io/github/stars/mikeroyal/VHDL-Guide) - A guide covering VHDL.


### Verification

- [Verification Academy](https://verificationacademy.com/) - The most comprehensive resource for verification training.
- [Verification Guide](https://www.verificationguide.com/p/home.html) - Tutorials with links to example codes on EDA Playground.
- [Doulos](https://www.doulos.com) - Global training solutions for engineers creating the world's electronics products.
- [testbench](http://www.testbench.in/) - Some training articals for systemverilog.
- [ClueLogic](http://cluelogic.com) - Providing the clues to solve your verification problems.
- [ChipVerify](https://www.chipverify.com/) - A simple and complete set of verilog/System Verilog/UVM tutorials.

### Build a CPU

- [RISC-V Guide](https://github.com/mikeroyal/RISC-V-Guide) 📍![stars](https://img.shields.io/github/stars/mikeroyal/RISC-V-Guide) - A guide covering the RISC-V Architecture.
- [ARM Guide](https://github.com/mikeroyal/ARM-Guide) 📍![stars](https://img.shields.io/github/stars/mikeroyal/ARM-Guide) - A guide covering ARM architecture.
- [nand2tetris](https://www.nand2tetris.org/) - Build an advanced computer from nand gate.
- [Building a RISC-V CPU Core - edX](https://www.edx.org/course/building-a-risc-v-cpu-core) 📽 - Build a RISC-V cpu core. No prior knowledge of digital logic design is required.
- [Build a Modern Computer from First Principles: From Nand to Tetris - coursera](https://www.coursera.org/learn/build-a-computer "依据基本原理构建现代计算机：从与非门到俄罗斯方块（基于项目的课程）") 📽 - Build a modern computer system.

### FPGA

- [FPGA Tutorial](https://github.com/LeiWang1999/FPGA) 
- [Complex Programmable Logic Device (CPLD) Guide](https://github.com/mikeroyal/CPLD-Guide) 📍![stars](https://img.shields.io/github/stars/mikeroyal/CPLD-Guide) - A guide covering CPLD.

## Tools

- [EDA Playground](https://www.edaplayground.com/) - Edit, save, simulate, synthesize SystemVerilog, Verilog, VHDL and other HDLs from your web browser.
- [tree-core-ide](https://github.com/microdynamics-cpu/tree-core-ide)  📍![stars](https://img.shields.io/github/stars/microdynamics-cpu/tree-core-ide)- A VSCode-based HDL extension.
- [WaveDrom](https://wavedrom.com/) - Digital Timing Diagram everywhere
- [Icarus Verilog](http://iverilog.icarus.com/) 📍[Github](https://github.com/steveicarus/iverilog)![stars](https://img.shields.io/github/stars/steveicarus/iverilog) - A Verilog simulation and synthesis tool.
- [GTKWave](http://gtkwave.sourceforge.net/) - GTKWave is a fully featured GTK+ based wave viewer.
- [OpenROAD](https://theopenroadproject.org/) 💬[Doc](https://openroad.readthedocs.io/en/latest/main/README.html) 📍[Github](https://github.com/The-OpenROAD-Project/OpenROAD)![stars](https://img.shields.io/github/stars/The-OpenROAD-Project/OpenROAD) - An RTL-to-GDS Flow
- More information about hardware dv tools on [Awesome Open Hardware Verification - Tools](https://github.com/ben-marshall/awesome-open-hardware-verification#Tools) and [Awesome HWD Tools](https://github.com/TM90/awesome-hwd-tools)



## Online Judge Platforms

- [HDL bits](https://hdlbits.01xz.net/wiki/Main_Page) - A collection of small circuit design exercises for practicing digital hardware design using Verilog Hardware Description Language (HDL).
- [nowcoder - Verilog Part](https://www.nowcoder.com/exam/oj?page=1&tab=Verilog%E7%AF%87&topicId=301) - A verilog oj platform.
---

## 🧠 Final Thoughts

🔹 Start slow, stay consistent.  
🔹 Simulate everything before synthesizing.  
🔹 Join VLSI communities and open-source projects.  
🔹 Learn by doing – replicate designs, break them, and fix them.  

If this roadmap helped you, consider sharing it with others or contributing back to the repo!  
📬 For inquiries or collaborations: [a.abdelazeem201@gmail.com](mailto:a.abdelazeem201@gmail.com)

---

> _“Whoever treads a path in search of knowledge, Allah will make easy for him the path to Paradise.” – Prophet Muhammad ﷺ_


