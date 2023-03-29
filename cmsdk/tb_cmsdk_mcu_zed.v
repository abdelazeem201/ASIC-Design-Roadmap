//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2015 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//  Version and Release Control Information:
//
//  File Revision       : $Revision: 368442 $
//  File Date           : $Date: 2017-07-25 15:07:59 +0100 (Tue, 25 Jul 2017) $
//
//  Release Information : Cortex-M0 DesignStart-r2p0-00rel0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------
// Abstract : Testbench for the Cortex-M0 example system
//-----------------------------------------------------------------------------
//
`timescale 1ns/1ps
`include "cmsdk_mcu_defs.v"

module tb_cmsdk_mcu_zed;

  reg        XTAL1;   // crystal pin 1
  wire        XTAL2;   // crystal pin 2
  reg        NRST;    // active low reset

  wire [15:0] P0;      // Port 0
  wire [15:0] P1;      // Port 1


  //Debug tester signals
  wire        nTRST;
  wire        TDI;
  wire        SWDIOTMS;
  wire        SWCLKTCK;
  wire        TDO;

  wire        PCLK;          // Clock for UART capture device
  wire [5:0]  debug_command; // used to drive debug tester
  wire        debug_running; // indicate debug test is running
  wire        debug_err;     // indicate debug test has error

  wire        debug_test_en; // To enable the debug tester connection to MCU GPIO P0
                             // This signal is controlled by software,
                             // Use "UartPutc((char) 0x1B)" to send ESCAPE code to start
                             // the command, use "UartPutc((char) 0x11)" to send debug test
                             // enable command, use "UartPutc((char) 0x12)" to send debug test
                             // disable command. Refer to tb_uart_capture.v file for detail

  parameter BE              = 0;   // Big or little endian

  parameter BKPT            = 4;   // Number of breakpoint comparators
  parameter DBG             = 1;   // Debug configuration
  parameter NUMIRQ          = 32;  // NUM of IRQ
  parameter SMUL            = 0;   // Multiplier configuration
  parameter SYST            = 1;   // SysTick
  parameter WIC             = 1;   // Wake-up interrupt controller support
  parameter WICLINES        = 34;  // Supported WIC lines
  parameter WPT             = 2;   // Number of DWT comparators

 // --------------------------------------------------------------------------------
 // Cortex-M0/Cortex-M0+ Microcontroller
 // --------------------------------------------------------------------------------
          wire uart0_txd    ;
 // cmsdk_mcu
  cmsdk_mcu_zed
   #(.BE               (BE),
     .BKPT             (BKPT),          // Number of breakpoint comparators
     .DBG              (DBG),           // Debug configuration
     .NUMIRQ           (NUMIRQ),        // NUMIRQ
     .SMUL             (SMUL),          // Multiplier configuration
     .SYST             (SYST),          // SysTick
     .WIC              (WIC),           // Wake-up interrupt controller support
     .WICLINES         (WICLINES),      // Supported WIC lines
     .WPT              (WPT)            // Number of DWT comparators
   )
   u_cmsdk_mcu_zed (
  .XTAL1      (XTAL1),  // input
 // .i_clk      (XTAL1), 
 // .XTAL2      (XTAL2),  // output
  .RST       (NRST),   // active low reset
  .uartf_TXD (uart0_txd),
  .o_led (),
  //.P0_O         (),
  //.P1         (P1),
 // .nTRST      (nTRST),  // Not needed if serial-wire debug is used
  //.TDI        (TDI),    // Not needed if serial-wire debug is used
  //.TDO        (TDO),    // Not needed if serial-wire debug is used
  .SWDIOTMS   (SWDIOTMS),
  .SWCLKTCK   (SWCLKTCK)
  );

 // --------------------------------------------------------------------------------
 // Source for clock and reset
 // --------------------------------------------------------------------------------
//  cmsdk_clkreset u_cmsdk_clkreset(
//  .CLK  (XTAL1),
//  .NRST (NRST)
//  );
always #10 XTAL1 =~ XTAL1;
 // --------------------------------------------------------------------------------
 // UART output capture
 // --------------------------------------------------------------------------------
  assign PCLK = XTAL1;

  cmsdk_uart_capture   u_cmsdk_uart_capture(
    .RESETn               (~NRST),
    .CLK                  (PCLK),
    .RXD                  (uart0_txd), // UART 0 used for StdOut
    .DEBUG_TESTER_ENABLE  (debug_test_en),
    .SIMULATIONEND        (),      // This signal set to 1 at the end of simulation.
    .AUXCTRL              ()
  );

  // UART connection cross over for UART test
  assign P1[2] = P1[5];  // UART 1 RXD = UART 2 TXD
  assign P1[4] = P1[3];  // UART 2 RXD = UART 1 TXD

 // --------------------------------------------------------------------------------
 // Debug tester connection -
 // --------------------------------------------------------------------------------

 // No debug connection for Cortex-M0 DesignStart
 assign nTRST    = NRST;
 assign TDI      = 1'b1;
 assign SWDIOTMS = 1'b1;
 assign SWCLKTCK = 1'b1;

 bufif1 (P0[31-16], debug_running, debug_test_en);
 bufif1 (P0[30-16], debug_err, debug_test_en);

 pullup (debug_running);
 pullup (debug_err);

 // --------------------------------------------------------------------------------
 // Misc
 // --------------------------------------------------------------------------------

  // Format for time reporting
  initial    $timeformat(-9, 0, " ns", 0);
  initial  
  begin 
  	XTAL1 = 0;
    NRST = 1;
    #1000;
    NRST = 0;
 
    #100000;
  end
endmodule
