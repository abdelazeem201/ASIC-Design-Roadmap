//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2010-2013 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2013-03-22 11:05:41 +0000 (Fri, 22 Mar 2013) $
//
//      Revision            : $Revision: 242013 $
//
//      Release Information : Cortex-M System Design Kit-r1p0-00rel0
//
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : Simple AHB ROM model wrapper
//-----------------------------------------------------------------------------
// This ROM wrapper allows various types of memory to be instantiated by
// simply changing MEM_TYPE parameter.
//
// Select one of the following
//
// MEM_TYPE = 0 : AHB_ROM_NONE
// - Memory not present
//
// MEM_TYPE = 1 : AHB_ROM_BEH_MODEL
// - Simple behavioral model (default)
//
// MEM_TYPE = 2 : AHB_ROM_FPGA_SRAM_MODEL
// - behavioral model of simple ASIC/FPGA ROM/SRAM model with wrapper
//
// MEM_TYPE = 3 : AHB_ROM_FLASH32_MODEL
// - 32-bit flash model
//
// MEM_TYPE = 4 : AHB_ROM_FLASH16_MODEL
// - 16-bit flash model
//

`include "cmsdk_ahb_memory_models_defs.v"
//`define MEM_TYPE  2 
module cmsdk_ahb_rom #(
// --------------------------------------------------------------------------
// Parameter Declarations
// --------------------------------------------------------------------------
 //parameter MEM_TYPE = 1,   // Memory Type : Default to behavioral memory
  parameter MEM_TYPE = 2,   // Memory Type : Default to behavioral memory
 parameter AW       = 16,  // Address width
 parameter filename = "",
 parameter WS_N     = 0,   // First access wait state
 parameter WS_S     = 0,   // Subsequent access wait state
 parameter BE       = 0    // Big endian
 )
 (
  input  wire          HCLK,    // Clock
  input  wire          HRESETn, // Reset
  input  wire          HSEL,    // Device select
  input  wire [AW-1:0] HADDR,   // Address
  input  wire [1:0]    HTRANS,  // Transfer control
  input  wire [2:0]    HSIZE,   // Transfer size
  input  wire          HWRITE,  // Write control
  input  wire [31:0]   HWDATA,  // Write data
  input  wire          HREADY,  // Transfer phase done

  output wire          HREADYOUT, // Device ready
  output wire [31:0]   HRDATA,  // Read data output
  output wire          HRESP    // Device response (always OKAY)
  );

  //----------------------------------------------------------------
  // AHB_ROM_NONE : Memory not present

  generate if (MEM_TYPE == `AHB_ROM_NONE) begin
    assign HREADYOUT = 1'b1;
    assign HRDATA    = {32{1'b0}};
    assign HRESP     = 1'b0;
  end endgenerate

  //----------------------------------------------------------------
  // AHB_ROM_BEH_MODEL : Simple behavioral model (default)
/*
  generate if (MEM_TYPE == `AHB_ROM_BEH_MODEL) begin
    // Behavioral memory model
  cmsdk_ahb_ram_beh
  #(.AW(AW),
    .filename(filename),
    .WS_N(WS_N),
    .WS_S(WS_S)
    )
  u_ahb_ram_beh (
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),
    .HSEL       (HSEL),  // AHB inputs
    .HADDR      (HADDR),
    .HTRANS     (HTRANS),
    .HSIZE      (HSIZE),
    .HWRITE     (1'b0), // write disabled
    .HWDATA     (32'h00000000),
    .HREADY     (HREADY),

    .HREADYOUT  (HREADYOUT), // Outputs
    .HRDATA     (HRDATA),
    .HRESP      (HRESP)
  );
  end endgenerate
*/
  //----------------------------------------------------------------
  // AHB_ROM_FPGA_SRAM_MODEL :
  //    behavioral model of simple ASIC/FPGA ROM/SRAM model with wrapper

 // generate if (MEM_TYPE == `AHB_ROM_FPGA_SRAM_MODEL) begin
  // wires for ROM/SRAM interface
  wire  [AW-3:0] SRAMADDR;
  wire    [31:0] SRAMWDATA;
  wire    [31:0] SRAMRDATA;
  wire     [3:0] SRAMWEN;
  wire           SRAMCS;

  // AHB to SRAM bridge
  cmsdk_ahb_to_sram
    #(.AW(AW)
   ) u_ahb_to_sram
  (
    // AHB Inputs
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),
    .HSEL       (HSEL),  // AHB inputs
    .HADDR      (HADDR),
    .HTRANS     (HTRANS),
    .HSIZE      (HSIZE),
    .HWRITE     (HWRITE),
    .HWDATA     (HWDATA),
    .HREADY     (HREADY),

    // AHB Outputs
    .HREADYOUT  (HREADYOUT), // Outputs
    .HRDATA     (HRDATA),
    .HRESP      (HRESP),

   // SRAM input
    .SRAMRDATA  (SRAMRDATA),
   // SRAM Outputs
    .SRAMADDR   (SRAMADDR),
    .SRAMWDATA  (SRAMWDATA),
    .SRAMWEN    (SRAMWEN),
    .SRAMCS     (SRAMCS)
   );

  // RAM model
//  cmsdk_fpga_rom #(.AW(AW), .filename(filename)) u_fpga_rom
  fpga_rom_top #(.AW(AW), .filename(filename))  fpga_rom_top
   (
   // SRAM Inputs
    .CLK        (HCLK),
    .ADDR       (SRAMADDR),
    .WDATA      (SRAMWDATA),
    .WREN       (SRAMWEN),
    .CS         (SRAMCS),
   // SRAM Outputs
    .RDATA      (SRAMRDATA)
   );
//  end endgenerate

/*
  //----------------------------------------------------------------
  // AHB_ROM_FLASH32_MODEL : 32-bit flash model (no pre-fetcher)

  generate if (MEM_TYPE == `AHB_ROM_FLASH32_MODEL) begin
  // wires for Flash interface
  wire  [AW-3:0] FLASHADDR;
  wire    [31:0] FLASHRDATA;

  // flash memory wrapper
  cmsdk_ahb_to_flash32
   #(
   .AW (AW),
   .WS (WS_N)
    ) u_ahb_to_flash32 (
    .HCLK         (HCLK),
    .HRESETn      (HRESETn),
    .HSEL         (HSEL),  // AHB inputs
    .HADDR        (HADDR),
    .HTRANS       (HTRANS),
    .HPROT        (4'h8), // Always cacheable
    .HSIZE        (HSIZE),
    .HWRITE       (HWRITE),
    .HWDATA       (32'h00000000), // not used
    .HREADY       (HREADY),

    .HREADYOUT    (HREADYOUT), // Outputs
    .HRDATA       (HRDATA),
    .HRESP        (HRESP),

    .FLASHADDR    (FLASHADDR),
    .FLASHRDATA   (FLASHRDATA)
  );

  // 32-bit flash
  cmsdk_flash_rom32
    #(
   .AW (AW),
   .WS (WS_N),
   .filename (filename)
    ) u_flash_rom32(
    .rst_n        (HRESETn),    // for emulation of timing
    .clk          (HCLK),       // for emulation of timing
    .addr         (FLASHADDR),  // address
    .rdata        (FLASHRDATA)  // data
    );

  end endgenerate

  //----------------------------------------------------------------
  // AHB_ROM_FLASH16_MODEL : 16-bit flash model (no pre-fetcher)

  generate if (MEM_TYPE == `AHB_ROM_FLASH16_MODEL) begin
  // wires for Flash interface
  wire  [AW-2:0] FLASHADDR;
  wire    [15:0] FLASHRDATA;

  wire    [AW-1:0] MHADDR;
  wire    [1:0]    MHTRANS;
  wire    [3:0]    MHPROT;
  wire    [2:0]    MHSIZE;
  wire             MHWRITE;
  wire    [15:0]   MHRDATA;
  wire             MHREADY;
  wire             MHRESP;

  // Down sizer for 16-bit memory
  cm0p_32to16_dnsize   #(
   .AW (AW)
    ) u_cm0p_32to16_dnsize (
    .HCLK         (HCLK),
    .HRESETn      (HRESETn),

    // Inputs
    .SHADDR       (HADDR),
    .SHTRANS      (HTRANS),
    .SHPROT       (4'h8),
    .SHBURST      (3'h0),
    .SHMASTLOCK   (1'b0),
    .SHSIZE       (HSIZE),
    .SHWRITE      (HWRITE),
    .SHWDATA      (HWDATA),
    .SHREADY      (HREADY),
    .SHSEL        (HSEL),

    .SHMASTER     (1'b0),

    // Outputs
    .SHREADYOUT   (HREADYOUT),
    .SHRDATA      (HRDATA),
    .SHRESP       (HRESP),

    .MHADDR       (MHADDR),
    .MHTRANS      (MHTRANS),
    .MHPROT       (MHPROT),
    .MHBURST      (), // not used
    .MHMASTLOCK   (), // not used
    .MHSIZE       (MHSIZE),
    .MHWRITE      (MHWRITE),
    .MHWDATA      (), // not used


    .MHMASTER     (), // not used

    // Inputs
    .MHREADY      (MHREADY),
    .MHRDATA      (MHRDATA),
    .MHRESP       (MHRESP));

  // flash memory wrapper
  cmsdk_ahb_to_flash16
   #(
   .AW (AW),
   .WS (WS_N)
    ) u_ahb_to_flash16 (
    .HCLK         (HCLK),
    .HRESETn      (HRESETn),
    // AHB inputs
    .HSEL         (1'b1),
    .HADDR        (MHADDR),
    .HTRANS       (MHTRANS),
    .HPROT        (MHPROT), // Always cacheable
    .HSIZE        (MHSIZE),
    .HWRITE       (MHWRITE),
    .HWDATA       (16'h0000), // not used
    .HREADY       (MHREADY),

    .HREADYOUT    (MHREADY), // Outputs
    .HRDATA       (MHRDATA),
    .HRESP        (MHRESP),

    .FLASHADDR    (FLASHADDR),
    .FLASHRDATA   (FLASHRDATA)
  );

  // 16-bit flash
  cmsdk_flash_rom16
    #(
   .AW (AW),
   .WS (WS_N),
   .filename (filename)
    ) u_flash_rom16(
    .rst_n        (HRESETn),    // for emulation of timing
    .clk          (HCLK),       // for emulation of timing
    .addr         (FLASHADDR),  // address
    .rdata        (FLASHRDATA)  // data
    );

  end endgenerate
*/
  //----------------------------------------------------------------

endmodule

