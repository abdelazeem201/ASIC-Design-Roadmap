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
//      Checked In          : $Date: 2013-04-10 15:27:13 +0100 (Wed, 10 Apr 2013) $
//
//      Revision            : $Revision: 243506 $
//
//      Release Information : Cortex-M System Design Kit-r1p0-00rel0
//
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : Simple AHB RAM model wrapper
//-----------------------------------------------------------------------------
// This RAM wrapper allows various types of RAM to be instantiated by
// simply changing MEM_TYPE parameter.
//
// Select one of the following
//
// MEM_TYPE = 0 : AHB_ROM_NONE
// - Memory not present
//
// MEM_TYPE = 1 : AHB_RAM_BEH_MODEL
// - Simple behavioral model (default)
//
// MEM_TYPE = 2 : AHB_RAM_FPGA_SRAM_MODEL
// - behavioral model of simple ASIC/FPGA SRAM model with AHB wrapper
//
// MEM_TYPE = 3 : AHB_RAM_EXT_SRAM16_MODEL
// - behavioral model of simple 16-bit external SRAM model with external memory interface
//
// MEM_TYPE = 4 : AHB_RAM_EXT_SRAM8_MODEL
// - behavioral model of simple 8-bit external SRAM model with external memory interface
//
`include "cmsdk_ahb_memory_models_defs.v"

module cmsdk_ahb_ram #(
  parameter MEM_TYPE = 2, // Memory Type : Default to behavioral memory
  parameter AW       = 16,// Address width
  parameter filename = "",
  parameter WS_N     = 0, // First access wait state
  parameter WS_S     = 0  // Subsequent access wait state
 )
 (
  input  wire          HCLK,    // Clock
  input  wire          HRESETn, // Reset
  // AHB inputs
  input  wire          HSEL,    // Device select
  input  wire [AW-1:0] HADDR,   // Address
  input  wire [1:0]    HTRANS,  // Transfer control
  input  wire [2:0]    HSIZE,   // Transfer size
  input  wire          HWRITE,  // Write control
  input  wire [31:0]   HWDATA,  // Write data
  input  wire          HREADY,  // Transfer phase done
  // AHB Outputs
  output wire          HREADYOUT, // Device ready
  output wire [31:0]   HRDATA,  // Read data output
  output wire          HRESP);  // Device response (always OKAY)
  
//  parameter MEM_TYPE = 2;
  //----------------------------------------------------------------
  // AHB_RAM_NONE : Memory not present
/*
  generate if (MEM_TYPE == `AHB_RAM_NONE) begin
    assign HREADYOUT = 1'b1;
    assign HRDATA    = {32{1'b0}};
    assign HRESP     = 1'b0;
  end endgenerate

  //----------------------------------------------------------------
  // AHB_RAM_BEH_MODEL : Simple behavioral model (default)

  generate if (MEM_TYPE == `AHB_RAM_BEH_MODEL) begin
  // Behavioral SRAM model
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
    .HWRITE     (HWRITE),
    .HWDATA     (HWDATA),
    .HREADY     (HREADY),

    .HREADYOUT  (HREADYOUT), // Outputs
    .HRDATA     (HRDATA),
    .HRESP      (HRESP)
  );
  end endgenerate
*/
  //----------------------------------------------------------------
  // AHB_RAM_FPGA_SRAM_MODEL :
  //    behavioral model of simple ASIC/FPGA SRAM model with AHB wrapper

  //generate if (MEM_TYPE == `AHB_RAM_FPGA_SRAM_MODEL) begin
  // wires for SRAM interface
  wire  [AW-3:0] SRAMADDR;
  wire    [31:0] SRAMWDATA;
  wire    [31:0] SRAMRDATA;
  wire     [3:0] SRAMWEN;
  wire           SRAMCS;

  // AHB to SRAM bridge
  cmsdk_ahb_to_sram #(.AW(AW)) u_ahb_to_sram
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

  // SRAM model
 // cmsdk_fpga_sram #(.AW(AW)) u_fpga_sram
  fpga_ram_top #(.AW(AW)) fpga_ram_top
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

  //----------------------------------------------------------------
  // AHB_RAM_EXT_SRAM16_MODEL :
  //    behavioral model of 16-bit external SRAM with AHB to external RAM interface
  //
  //    Note    : for benchmarking using 16-bit external asynchronous SRAM.
  //              In real application the 16-bit external SRAM will be off chip
  //
/*
  generate if (MEM_TYPE == `AHB_RAM_EXT_SRAM16_MODEL) begin
  // wires for external SRAM interface
  wire    [AW-1:0]  EMIADDR;  // External memory interface address
  wire    [15:0]  EMIDATA;  // External memory interface data (bi-directional)
  wire    [15:0]  EMIDATAIN;
  wire    [15:0]  EMIDATAOUT;
  wire            EMIDATAOEn;
  wire            EMIWEn;   // Write enable (active low)
  wire            EMIOEn;   // Output enable (active low)
  wire            EMICEn;   // Chip enable (active low)
  wire            EMILBn;   // Lower byte strobe (active low)
  wire            EMIUBn;   // Upper byte strobe (active low)

  wire    [2:0]   CFGREADCYCLE;
  wire    [2:0]   CFGWRITECYCLE;
  wire    [2:0]   CFGTURNAROUNDCYCLE;
  wire            CFGSIZE;

  assign  CFGSIZE            = 1'b1; // 16-bit
  assign  CFGREADCYCLE       = WS_N;
  assign  CFGWRITECYCLE      = WS_N;
  assign  CFGTURNAROUNDCYCLE = WS_N;

  // interface to external SRAM
  cmsdk_ahb_to_extmem16
    #(.AW (AW))
    u_ahb_to_extmem16 (
    .HCLK         (HCLK),
    .HRESETn      (HRESETn),

    .HSEL         (HSEL),       // AHB inputs
    .HADDR        (HADDR[AW-1:0]),
    .HTRANS       (HTRANS),
    .HSIZE        (HSIZE),
    .HWRITE       (HWRITE),
    .HWDATA       (HWDATA),
    .HREADY       (HREADY),

    .HREADYOUT    (HREADYOUT), // AHB Outputs
    .HRDATA       (HRDATA),
    .HRESP        (HRESP),

     // Configuration signals
    .CFGREADCYCLE      (CFGREADCYCLE),   // Read cycle
    .CFGWRITECYCLE     (CFGWRITECYCLE),  // Write cycle
    .CFGTURNAROUNDCYCLE(CFGTURNAROUNDCYCLE),  // Turn around cycle
    .CFGSIZE           (CFGSIZE),     // Size (0 = 8-bit, 1 = 16-bit)

     // External memory
    .DATAIN       (EMIDATAIN),      // data input

    .ADDR         (EMIADDR[AW-1:0]),        // address output
    .DATAOUT      (EMIDATAOUT),     // data output
    .DATAOEn      (EMIDATAOEn),     // output enable (active low)
    .WEn          (EMIWEn),         // write control (active low)
    .OEn          (EMIOEn),         // read control  (active low)
    .CEn          (EMICEn),         // Chip Enable   (active low)
    .LBn          (EMILBn),         // Lower Byte    (active low)
    .UBn          (EMIUBn)          // Upper Byte    (active low)
  );

  // Tristate buffer for data
  assign EMIDATAIN = EMIDATA;
  assign EMIDATA   = (EMIDATAOEn==1'b0) ? EMIDATAOUT : {16{1'bz}};

  // 16-bit SRAM model
  cmsdk_sram256x16
    #(.AW(AW))
    u_sram256x16 (
    .Address  (EMIADDR[AW-1:0]),
    .DataIO   (EMIDATA),
    .WEn      (EMIWEn),
    .OEn      (EMIOEn),
    .CEn      (EMICEn),
    .LBn      (EMILBn),
    .UBn      (EMIUBn)
    );

  end endgenerate

  //----------------------------------------------------------------
  // AHB_RAM_EXT_SRAM8_MODEL :
  //    behavioral model of 8-bit external SRAM with AHB to external RAM interface
  //
  //    Note    : for benchmarking using 8-bit external asynchronous SRAM.
  //              In real application the 8-bit external SRAM will be off chip
  //

  generate if (MEM_TYPE == `AHB_RAM_EXT_SRAM8_MODEL) begin
  // wires for external SRAM interface
  wire    [AW-1:0]  EMIADDR;  // External memory interface address
  wire    [15:0]  EMIDATA;  // External memory interface data (bi-directional)
  wire    [15:0]  EMIDATAIN;
  wire    [15:0]  EMIDATAOUT;
  wire            EMIDATAOEn;
  wire            EMIWEn;   // Write enable (active low)
  wire            EMIOEn;   // Output enable (active low)
  wire            EMICEn;   // Chip enable (active low)
  wire            EMILBn;   // Lower byte strobe (active low)
  wire            EMIUBn;   // Upper byte strobe (active low)

  wire    [2:0]   CFGREADCYCLE;
  wire    [2:0]   CFGWRITECYCLE;
  wire    [2:0]   CFGTURNAROUNDCYCLE;
  wire            CFGSIZE;

  assign  CFGSIZE            = 1'b0; // 8-bit
  assign  CFGREADCYCLE       = WS_N;
  assign  CFGWRITECYCLE      = WS_N;
  assign  CFGTURNAROUNDCYCLE = WS_N;

  // interface to external SRAM
  cmsdk_ahb_to_extmem16
    #(.AW (AW))
    u_ahb_to_extmem16 (
    .HCLK         (HCLK),
    .HRESETn      (HRESETn),

    .HSEL         (HSEL),       // AHB inputs
    .HADDR        (HADDR[AW-1:0]),
    .HTRANS       (HTRANS),
    .HSIZE        (HSIZE),
    .HWRITE       (HWRITE),
    .HWDATA       (HWDATA),
    .HREADY       (HREADY),

    .HREADYOUT    (HREADYOUT), // AHB Outputs
    .HRDATA       (HRDATA),
    .HRESP        (HRESP),

     // Configuration signals
    .CFGREADCYCLE      (CFGREADCYCLE),   // Read cycle
    .CFGWRITECYCLE     (CFGWRITECYCLE),  // Write cycle
    .CFGTURNAROUNDCYCLE(CFGTURNAROUNDCYCLE),  // Turn around cycle
    .CFGSIZE           (CFGSIZE),     // Size (0 = 8-bit, 1 = 16-bit)

     // External memory
    .DATAIN       (EMIDATAIN),      // data input

    .ADDR         (EMIADDR[AW-1:0]),// address output
    .DATAOUT      (EMIDATAOUT),     // data output
    .DATAOEn      (EMIDATAOEn),     // output enable (active low)
    .WEn          (EMIWEn),         // write control (active low)
    .OEn          (EMIOEn),         // read control  (active low)
    .CEn          (EMICEn),         // Chip Enable   (active low)
    .LBn          (EMILBn),         // Lower Byte    (active low)
    .UBn          (EMIUBn)          // Upper Byte    (active low)
  );

  // Tristate buffer for data 
  assign EMIDATAIN = {8'h00, EMIDATA[7:0]};
  assign EMIDATA   = (EMIDATAOEn==1'b0) ? EMIDATAOUT : {16{1'bz}};

  // 8-bit SRAM model
  cmsdk_sram256x8
    #(.AW(AW))
    u_sram256x8 (
    .Address  (EMIADDR[AW-1:0]),
    .DataIO   (EMIDATA[7:0]),
    .WEn      (EMIWEn),
    .OEn      (EMIOEn),
    .CEn      (EMICEn)
    );

  end endgenerate
*/
  //----------------------------------------------------------------


endmodule

