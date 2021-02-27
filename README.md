# ASIC-Physical-Design-Roadmap
The journey of designing an ASIC (application specific integrated circuit) is long and involves a number of major steps – moving from a concept to specification to tape-outs. Although the end product is typically quite small (measured in nanometers), this long journey is interesting and filled with many engineering challenges.


Application Specific Integrated Circuit (ASIC) are application specific, which means the design is for sole purpose. So, the CPU inside your phone is ASIC. The digital circuitry of ASIC is made up of permanently connected gates and flip-flops in silicon. The logic function of ASIC is specified using hardware description languages such as Verilog, System Verilog or VHDL. ASIC is more power efficient than FPGAs, since its circuit is optimized for its specific function. Power consumption of ASICs can be very minutely controlled and optimized using many approaches such as Design Space Exploration DSE. ASIC is well suited for very high-volume mass production. ASIC are capable of working at much higher frequency than FPGAs. The important factor, ASICs can have complete analog circuitry, for example WiFi transceiver, on the same die along with microprocessor cores. This is the advantage which FPGAs lack. But as said, ASICs are not suited or preferred for the application areas where the design might need to be upgraded frequently or once-in-a-while. The verification is an absolutely importation step in ASIC prototyping as it is not recommended to prototype a design using ASICs unless it has been validated and verified. Thus, when the silicon has been taped out, almost nothing can be done to fix a design bug.

Thus, ASICs are better as mass production is possible, the cost per unit is lesser as compared to FPGA(whereas getting started with FPGA is cheaper as compared to ASIC). ASIC is comparatively energy efficient.The designer has few entry barriers to start with ASICs. Analog design can be implemented on ASIC.

![Fig. Complex ASIC Design](https://github.com/abdelazeem201/ASIC-Physical-Design-Roadmap/blob/main/Figures/Fig.%20Complex%20ASIC%20Design.jpeg)

# *Physical Design flow of Application Specific Integrated Circuits:*

*A. Prerequisite for this Roadmap:*

1. First of all I would like to tell you to build your basic concepts strong,which includes Digital electronics ,MOSFET,CMOS Design,FF ,Latches.
"https://www.youtube.com/playlist?list=PLMSBalys69yzp1vrmnYAmpRFiptbuGuaj" 
 
   *>>"Note" You don't need to go through the whole coures, you just need the basic concepts of MOSFET* 

2. Digital logic design (ASIC/SOC)/Frontend design: This includes digital design techniques, HDLs like Verilog/SystemVerilog, and several design techniques like timing, synthesis, logic circuits, state machines, pipelining, etc etc
The best resources in terms of an online course for this is available with cs221 digital design by Dr/Waleed Youssef as Digital System Design - 
   
   "https://youtube.com/playlist?list=PLoK2Lr1miEm8b6Vv5zAfsbMEPZ1C7fCQw"

   and in terms of an Online course for Verilog is available with Hardware modeling using verilog by Dr/Indranil Sen Gupta
   "https://www.youtube.com/playlist?list=PLJ5C_6qdAvBELELTSPgzYkQg3HgclQh-5"

3. Digital Design & Computer Architecture
   
   DR/Onur Mutlu's lecture videos from the freshman-level Digital Design and Computer Architecture course taught at ETH Zürich in Spring 2020.
   
   "https://www.youtube.com/playlist?list=PL5Q2soXY2Zi_FRrloMa2fUYWPGiZUBQo2"

4. Digital IC Design: A comprehensive Digital IC Design course -by Dr/Hesham Omran- that takes you from basics to ASICs based on the popular textbook "CMOS VLSI Design: A Circuits and Systems Perspective" 4th ed. by Weste and Harris.

   part1: https://youtube.com/playlist?list=PLMSBalys69yzvAKErDt7tT7O-iIKPlOCP

   part2: https://youtube.com/playlist?list=PLMSBalys69yxoIjeZ2Q3fxs69cGCU14B1

   part3: https://youtube.com/playlist?list=PLMSBalys69yw1tSoF42QW9jbbC0-UeCAy

# *ASIC Design Cycle Work "PnR":*

  *1. Advanced Logic Synthesis by Dhiraj Taneja,Broadcom, Hyderabad.*
   
   This course aims at imparting practical knowledge in Synthesis and Timing Closure. It also includes Synopsys DC and PT labs. 

   "https://www.youtube.com/playlist?list=PLbMVogVj5nJQe0_9YJlN9S7ktkA8DI-fL"
  
   "You can skip the first 12 videos if you want" 

  *2. VLSI Physical Design By Prof. Indranil Sengupta*
   
   Physical design and implementation: In VLSI design flow after the front end logic design and verification is done, the backend or physical design flow is the next step in terms of mapping the design to technology. This involves the following steps majorly - Design Netlist (synthesis), Floorplanning, Partitioning, Placement, Clock tree synthesis, Routing, Physical Verification, and GDS Generation for tape out.
   
   There are some good online courses available for these on youtube at the following link

   "https://www.youtube.com/playlist?list=PLU8VFS-HdvKtKswbcvvA8yVhzleTV7OE8"
  
    *6. Digital VLSI Design (RTL to GDS)*
     "cover the basics of Chip Implementation, from designing the logic (RTL) to providing a layout ready for fabrication (GDS)."
     "https://www.youtube.com/playlist?list=PLZU5hLL_713x0_AV_rVbay0pWmED7992G"
