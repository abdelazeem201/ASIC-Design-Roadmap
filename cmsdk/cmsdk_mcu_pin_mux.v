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
// Abstract : Pin multiplexing control for example Cortex-M0/Cortex-M0+
//            microcontroller
//-----------------------------------------------------------------------------
//
module cmsdk_mcu_pin_mux (
  //-------------------------------------------
  // I/O ports
  //-------------------------------------------

    // UART
    output wire             uart0_rxd,
    input  wire             uart0_txd,
    input  wire             uart0_txen,
    output wire             uart1_rxd,
    input  wire             uart1_txd,
    input  wire             uart1_txen,
    output wire             uart2_rxd,
    input  wire             uart2_txd,
    input  wire             uart2_txen,

    // Timer
    output wire             timer0_extin,
    output wire             timer1_extin,

    // IO Ports
    output wire  [15:0]     p0_in,
    input  wire  [15:0]     p0_out,
    input  wire  [15:0]     p0_outen,
    input  wire  [15:0]     p0_altfunc,

    output wire  [15:0]     p1_in,
    input  wire  [15:0]     p1_out,
    input  wire  [15:0]     p1_outen,
    input  wire  [15:0]     p1_altfunc,

    // Processor debug interface
    output wire             i_trst_n,
    output wire             i_swditms,
    output wire             i_swclktck,
    output wire             i_tdi,
    input  wire             i_tdo,
    input  wire             i_tdoen_n,
    input  wire             i_swdo,
    input  wire             i_swdoen,

    // IO pads
    inout  wire   [15:0]    P0,
    inout  wire   [15:0]    P1,

    input  wire             nTRST, // Not needed if serial-wire debug is used
    input  wire             TDI,   // Not needed if serial-wire debug is used
    inout  wire             SWDIOTMS,
    input  wire             SWCLKTCK,
    output wire             TDO);   // Not needed if serial-wire debug is used

  //-------------------------------------------
  // Internal wires
  //-------------------------------------------
  wire      [15:0]     p0_out_mux;
  wire      [15:0]     p1_out_mux;

  wire      [15:0]     p0_out_en_mux;
  wire      [15:0]     p1_out_en_mux;

  //-------------------------------------------
  // Beginning of main code
  //-------------------------------------------
  // inputs
  assign    uart0_rxd    = p1_in[0];
  assign    uart1_rxd    = p1_in[2];
  assign    uart2_rxd    = p1_in[4];
  assign    timer0_extin = p1_in[8];
  assign    timer1_extin = p1_in[9];

  assign    p0_in        = P0;
  assign    p1_in        = P1;

  // Output function mux
  assign    p0_out_mux    = p0_out; // No function muxing for Port 0

  assign    p1_out_mux[0] =                               p1_out[0];
  assign    p1_out_mux[1] = (p1_altfunc[1]) ? uart0_txd : p1_out[1];
  assign    p1_out_mux[2] =                               p1_out[2];
  assign    p1_out_mux[3] = (p1_altfunc[3]) ? uart1_txd : p1_out[3];
  assign    p1_out_mux[4] =                               p1_out[4];
  assign    p1_out_mux[5] = (p1_altfunc[5]) ? uart2_txd : p1_out[5];
  assign    p1_out_mux[15:6] = p1_out[15:6];

  // Output enable mux
  assign    p0_out_en_mux   = p0_outen; // No function muxing for Port 0

  assign    p1_out_en_mux[0] =                                p1_outen[0];
  assign    p1_out_en_mux[1] = (p1_altfunc[1]) ? uart0_txen : p1_outen[1];
  assign    p1_out_en_mux[2] =                                p1_outen[2];
  assign    p1_out_en_mux[3] = (p1_altfunc[3]) ? uart1_txen : p1_outen[3];
  assign    p1_out_en_mux[4] =                                p1_outen[4];
  assign    p1_out_en_mux[5] = (p1_altfunc[5]) ? uart2_txen : p1_outen[5];
  assign    p1_out_en_mux[15:6] = p1_outen[15:6];

  // Output tristate
  assign    P0[ 0] = p0_out_en_mux[ 0] ? p0_out_mux[ 0] : 1'bz;
  assign    P0[ 1] = p0_out_en_mux[ 1] ? p0_out_mux[ 1] : 1'bz;
  assign    P0[ 2] = p0_out_en_mux[ 2] ? p0_out_mux[ 2] : 1'bz;
  assign    P0[ 3] = p0_out_en_mux[ 3] ? p0_out_mux[ 3] : 1'bz;
  assign    P0[ 4] = p0_out_en_mux[ 4] ? p0_out_mux[ 4] : 1'bz;
  assign    P0[ 5] = p0_out_en_mux[ 5] ? p0_out_mux[ 5] : 1'bz;
  assign    P0[ 6] = p0_out_en_mux[ 6] ? p0_out_mux[ 6] : 1'bz;
  assign    P0[ 7] = p0_out_en_mux[ 7] ? p0_out_mux[ 7] : 1'bz;
  assign    P0[ 8] = p0_out_en_mux[ 8] ? p0_out_mux[ 8] : 1'bz;
  assign    P0[ 9] = p0_out_en_mux[ 9] ? p0_out_mux[ 9] : 1'bz;
  assign    P0[10] = p0_out_en_mux[10] ? p0_out_mux[10] : 1'bz;
  assign    P0[11] = p0_out_en_mux[11] ? p0_out_mux[11] : 1'bz;
  assign    P0[12] = p0_out_en_mux[12] ? p0_out_mux[12] : 1'bz;
  assign    P0[13] = p0_out_en_mux[13] ? p0_out_mux[13] : 1'bz;
  assign    P0[14] = p0_out_en_mux[14] ? p0_out_mux[14] : 1'bz;
  assign    P0[15] = p0_out_en_mux[15] ? p0_out_mux[15] : 1'bz;

  assign    P1[ 0] = p1_out_en_mux[ 0] ? p1_out_mux[ 0] : 1'bz;
  assign    P1[ 1] = p1_out_en_mux[ 1] ? p1_out_mux[1] : 1'bz;
  assign    P1[ 2] = p1_out_en_mux[ 2] ? p1_out_mux[ 2] : 1'bz;
  assign    P1[ 3] = p1_out_en_mux[ 3] ? p1_out_mux[ 3] : 1'bz;
  assign    P1[ 4] = p1_out_en_mux[ 4] ? p1_out_mux[ 4] : 1'bz;
  assign    P1[ 5] = p1_out_en_mux[ 5] ? p1_out_mux[ 5] : 1'bz;
  assign    P1[ 6] = p1_out_en_mux[ 6] ? p1_out_mux[ 6] : 1'bz;
  assign    P1[ 7] = p1_out_en_mux[ 7] ? p1_out_mux[ 7] : 1'bz;
  assign    P1[ 8] = p1_out_en_mux[ 8] ? p1_out_mux[ 8] : 1'bz;
  assign    P1[ 9] = p1_out_en_mux[ 9] ? p1_out_mux[ 9] : 1'bz;
  assign    P1[10] = p1_out_en_mux[10] ? p1_out_mux[10] : 1'bz;
  assign    P1[11] = p1_out_en_mux[11] ? p1_out_mux[11] : 1'bz;
  assign    P1[12] = p1_out_en_mux[12] ? p1_out_mux[12] : 1'bz;
  assign    P1[13] = p1_out_en_mux[13] ? p1_out_mux[13] : 1'bz;
  assign    P1[14] = p1_out_en_mux[14] ? p1_out_mux[14] : 1'bz;
  assign    P1[15] = p1_out_en_mux[15] ? p1_out_mux[15] : 1'bz;

// synopsys translate_off

  // Pullup
  pullup(P0[ 0]);
  pullup(P0[ 1]);
  pullup(P0[ 2]);
  pullup(P0[ 3]);
  pullup(P0[ 4]);
  pullup(P0[ 5]);
  pullup(P0[ 6]);
  pullup(P0[ 7]);
  pullup(P0[ 8]);
  pullup(P0[ 9]);
  pullup(P0[10]);
  pullup(P0[11]);
  pullup(P0[12]);
  pullup(P0[13]);
  pullup(P0[14]);
  pullup(P0[15]);

  pullup(P1[ 0]);
  pullup(P1[ 1]);
  pullup(P1[ 2]);
  pullup(P1[ 3]);
  pullup(P1[ 4]);
  pullup(P1[ 5]);
  pullup(P1[ 6]);
  pullup(P1[ 7]);
  pullup(P1[ 8]);
  pullup(P1[ 9]);
  pullup(P1[10]);
  pullup(P1[11]);
  pullup(P1[12]);
  pullup(P1[13]);
  pullup(P1[14]);
  pullup(P1[15]);

// synopsys translate_on

  //-------------------------------------------
  // Debug connections
  //-------------------------------------------

  assign    i_trst_n     = nTRST;
  assign    i_tdi        = TDI;
  assign    i_swclktck   = SWCLKTCK;
  assign    i_swditms    = SWDIOTMS;

  // Tristate buffers for debug output signals
 // bufif1 (SWDIOTMS, i_swdo, i_swdoen);
assign   SWDIOTMS = i_swdoen ? i_swdo : 1'bz;
  bufif0 (TDO,      i_tdo,  i_tdoen_n);

  endmodule
