# ASIC-Design-Roadmap
The journey of designing an ASIC (application specific integrated circuit) is long and involves a number of major steps – moving from a concept to specification to tape-outs. Although the end product is typically quite small (measured in nanometers), this long journey is interesting and filled with many engineering challenges.


Application Specific Integrated Circuit (ASIC) are application specific, which means the design is for sole purpose. So, the CPU inside your phone is ASIC. The digital circuitry of ASIC is made up of permanently connected gates and flip-flops in silicon. The logic function of ASIC is specified using hardware description languages such as Verilog, System Verilog or VHDL. ASIC is more power efficient than FPGAs, since its circuit is optimized for its specific function. Power consumption of ASICs can be very minutely controlled and optimized using many approaches such as Design Space Exploration DSE. ASIC is well suited for very high-volume mass production. ASIC are capable of working at much higher frequency than FPGAs. The important factor, ASICs can have complete analog circuitry, for example WiFi transceiver, on the same die along with microprocessor cores. This is the advantage which FPGAs lack. But as said, ASICs are not suited or preferred for the application areas where the design might need to be upgraded frequently or once-in-a-while. The verification is an absolutely importation step in ASIC prototyping as it is not recommended to prototype a design using ASICs unless it has been validated and verified. Thus, when the silicon has been taped out, almost nothing can be done to fix a design bug.

Thus, ASICs are better as mass production is possible, the cost per unit is lesser as compared to FPGA(whereas getting started with FPGA is cheaper as compared to ASIC). ASIC is comparatively energy efficient.The designer has few entry barriers to start with ASICs. Analog design can be implemented on ASIC.

![Fig. Complex ASIC Design](https://github.com/abdelazeem201/ASIC-Physical-Design-Roadmap/blob/main/Figures/Fig.%20Complex%20ASIC%20Design.jpeg)


# *Physical Design flow of Application Specific Integrated Circuits:*
<div align="center"> بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم</div>

<div align="center"> “وَمَا أُوتِيتُمْ مِنَ الْعِلْمِ إِلَّا قَلِيلًا”</div>
*A. Prerequisite for this Roadmap:*

## Tutorials and Courses
1. [Digital electronics](https://www.youtube.com/playlist?list=PLMSBalys69yzp1vrmnYAmpRFiptbuGuaj) 📽 - First of all I would like to tell you to build your basic concepts strong,which includes Digital electronics ,MOSFET,CMOS Design,FF ,Latches.
 
 `"Note" You don't need to go through the whole coures, you just need the basic concepts of MOSFET` 

2. Digital logic design (ASIC/SOC)/Frontend design: This includes digital design techniques

[CS221 digital design by Dr/Waleed Youssef](https://youtube.com/playlist?list=PLoK2Lr1miEm8b6Vv5zAfsbMEPZ1C7fCQw) 📽 - Digital System Design

[Hardware modeling using verilog by Dr/Indranil Sen Gupta](https://www.youtube.com/playlist?list=PLJ5C_6qdAvBELELTSPgzYkQg3HgclQh-5) 📽 -HDLs like Verilog, and several design techniques like timing, synthesis, logic circuits, state machines, pipelining, etc etc

3. Digital Design & Computer Architecture
   
   [Digital Design and Computer Architecture](https://www.youtube.com/playlist?list=PL5Q2soXY2Zi_FRrloMa2fUYWPGiZUBQo2) 📽- Digital Design and Computer Architecture

4. Digital IC Design: A comprehensive Digital IC Design course -by Dr/Hesham Omran- that takes you from basics to ASICs based on the popular textbook "CMOS VLSI Design: A Circuits and Systems Perspective" 4th ed. by Weste and Harris.

   part1: https://youtube.com/playlist?list=PLMSBalys69yzvAKErDt7tT7O-iIKPlOCP

   part2: https://youtube.com/playlist?list=PLMSBalys69yxoIjeZ2Q3fxs69cGCU14B1

   part3: https://youtube.com/playlist?list=PLMSBalys69yw1tSoF42QW9jbbC0-UeCAy

### *ASIC Design Cycle Work "PnR":*

  *1. Advanced Logic Synthesis by Dhiraj Taneja,Broadcom, Hyderabad.*
   
[Logic Synthesis](https://www.youtube.com/playlist?list=PLbMVogVj5nJQe0_9YJlN9S7ktkA8DI-fL) 📽 - This course aims at imparting practical knowledge in Synthesis and Timing Closure. It also includes Synopsys DC and PT labs. 
  
   "You can skip the first 12 videos if you want" 

  *2. VLSI Physical Design By Prof. Indranil Sengupta*
   
[Physical design and implementation](https://www.youtube.com/playlist?list=PLU8VFS-HdvKtKswbcvvA8yVhzleTV7OE8) 📽 - Physical design and implementation: In VLSI design flow after the front end logic design and verification is done, the backend or physical design flow is the next step in terms of mapping the design to technology. This involves the following steps majorly - Design Netlist (synthesis), Floorplanning, Partitioning, Placement, Clock tree synthesis, Routing, Physical Verification, and GDS Generation for tape out.).
  
   *3. Digital VLSI Design (RTL to GDS)* "Very recommended" 
     
[RTL2GDSII](https://www.youtube.com/playlist?list=PLZU5hLL_713x0_AV_rVbay0pWmED7992G) 📽 - cover the basics of Chip Implementation, from designing the logic (RTL) to providing a layout ready for fabrication (GDS).
  
   
   
   
# Awesome Digital IC

> A collection of great ASIC/FPGA/VLSI project/tutorial/website.

- 📍 = Github Project
- 📽 = With vedio
- 👶 = Easy to get start with
- ⭐ = Recommended
- 💬 = More Details

## Awesome Awesome ⭐

> Awesome-lists for digital ic.

- [FPGA Tutorial](https://github.com/LeiWang1999/FPGA) 📍![stars](https://img.shields.io/github/stars/LeiWang1999/FPGA) - A curated list of amazingly FPGA tutorials and projects.
- [Awesome Hardware Description Languages](https://github.com/drom/awesome-hdl) 📍![stars](https://img.shields.io/github/stars/drom/awesome-hdl) - A curated list of amazingly awesome hardware description language projects.
- [Awesome FPGA](https://github.com/Vitorian/awesome-fpga) 📍![stars](https://img.shields.io/github/stars/Vitorian/awesome-fpga) - A collection of resources on FPGA devices and development in general.
- [Open Hardware Verification](https://github.com/ben-marshall/awesome-open-hardware-verification) 📍![stars](https://img.shields.io/github/stars/ben-marshall/awesome-open-hardware-verification) - A curated List of Free and Open Source hardware verification tools and frameworks.
- [Awesome Open Source EDA Projects](https://github.com/clin99/awesome-eda) 📍![stars](https://img.shields.io/github/stars/clin99/awesome-eda) - A curated list of EDA open source projects. 
- [List of FPGA boards](https://github.com/iDoka/awesome-fpga-boards) 📍![stars](https://img.shields.io/github/stars/iDoka/awesome-fpga-boards) - List of Repurposed FPGA boards.
- [awesome-hwd-tools](https://github.com/TM90/awesome-hwd-tools) 📍![stars](https://img.shields.io/github/stars/TM90/awesome-hwd-tools) - A curated list of awesome open source hardware design tools with a focus on chip design.
- [Awesome Electronics](https://github.com/kitspace/awesome-electronics) 📍![stars](https://img.shields.io/github/stars/kitspace/awesome-electronics) - A curated list of awesome resources for electronic engineers and hobbyists.
- [Awesome Lattice FPGA boards](https://github.com/kelu124/awesome-latticeFPGAs) 📍![stars](https://img.shields.io/github/stars/kelu124/awesome-latticeFPGAs) - A curated list of awesome open-source FPGA boards

### Github Topics

- [verilog](https://github.com/topics/verilog?o=desc&s=stars) 📍 - Here are 2,566 public repositories matching "verilog" topic...
- [vhdl](https://github.com/topics/vhdl?o=desc&s=stars) 📍- Here are 1,766 public repositories matching "vhdl" topic...
- [fpga](https://github.com/topics/fpga?o=desc&s=stars) 📍 - Here are 3,136 public repositories matching "fpga" topic...

### Quora Topics

- [verilog](https://github.com/topics/verilog?o=desc&s=stars) 📍 - Here are 2,566 public repositories matching "verilog" topic...
- [vhdl](https://github.com/topics/vhdl?o=desc&s=stars) 📍- Here are 1,766 public repositories matching "vhdl" topic...
- [fpga](https://github.com/topics/fpga?o=desc&s=stars) 📍 - Here are 3,136 public repositories matching "fpga" topic...

## Projects and IPs

- [OpenCores](https://opencores.org/) ⭐ - Free and open source IP cores.
- [FreeCores](http://freecores.github.io/) 📍![stars](https://img.shields.io/github/stars/freecores/freecores.github.io) - A home for open source hardware cores, a fork of almost all cores that was once on OpenCores.org.
- [Must-have verilog systemverilog modules](https://github.com/pConst/basic_verilog) 📍![stars](https://img.shields.io/github/stars/pConst/basic_verilog) - A collection of verilog systemverilog synthesizable modules.
- [fpga4fun](https://www.fpga4fun.com/) - Some projects build on FPGA.
- [32 Verilog Mini Projects](https://github.com/sudhamshu091/32-Verilog-Mini-Projects/) 📍![stars](https://img.shields.io/github/stars/sudhamshu091/32-Verilog-Mini-Projects) - 32 useful mini verilog projects for beginners.

### Communication Technology

- [ALEX FORENCICH](http://alexforencich.com/wiki/en/verilog/start) - Verilog IPs including PCIe/Ethernet/I2C/Uart etc.

- [ALEX FORENCICH - AXI](https://github.com/alexforencich/verilog-axi) 📍![stars](https://img.shields.io/github/stars/alexforencich/verilog-axi) - Collection of AXI4 and AXI4 lite bus components. Most components are fully parametrizable in interface widths.
- [TVIP - AXI](https://github.com/taichi-ishitani/tvip-axi) 📍![stars](https://img.shields.io/github/stars/taichi-ishitani/tvip-axi) - An UVM package of AMBA AXI4 VIP.
- [PULP-platform - AXI](https://github.com/pulp-platform/axi) 📍![stars](https://img.shields.io/github/stars/pulp-platform/axi) - AXI SystemVerilog synthesizable IP modules and verification infrastructure for high-performance on-chip communication.
- [ALEX FORENCICH - AXIS](https://github.com/alexforencich/verilog-axis) 📍![stars](https://img.shields.io/github/stars/alexforencich/verilog-axis) - Collection of AXI Stream bus components. Most components are fully parametrizable in interface widths.
- [ALEX FORENCICH - IIC](https://github.com/alexforencich/verilog-i2c) 📍![stars](https://img.shields.io/github/stars/alexforencich/verilog-i2c) - I2C interface components. Includes full MyHDL testbench with intelligent bus cosimulation endpoints.
- [corundum - NIC](https://github.com/corundum/corundum) 📍![stars](https://img.shields.io/github/stars/corundum/corundum)
- [RIFFA - PCIe](https://github.com/KastnerRG/riffa) 📍![stars](https://img.shields.io/github/stars/KastnerRG/riffa) - Reusable Integration Framework for FPGA Acceleratorscommunication.
- [ALEX FORENCICH - UART](http://github.com/alexforencich/verilog-uart/) 📍![stars](https://img.shields.io/github/stars/alexforencich/verilog-uart) - A basic UART to AXI Stream IP core, written in Verilog with cocotb testbenches.
- [zipcpu - UART](https://github.com/ZipCPU/wbuart32) 📍![stars](https://img.shields.io/github/stars/ZipCPU/wbuart32) - A simple, basic, formally verified UART controller.
- [C910 - UART](https://github.com/MeDove/openc910/tree/main/smart_run/logical) 📍

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



