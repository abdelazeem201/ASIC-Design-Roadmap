//-----------------------------------------------------------------------------
//  Abstract : FPGA BlockRam/OnChip RAM
// ----------------------------------------------------------------------------

module fpga_ram_top #(
// --------------------------------------------------------------------------
// Parameter Declarations
// --------------------------------------------------------------------------
  parameter AW = 16,
  parameter filename = ""
)
 (
  // Inputs
  input  wire          CLK,
  input  wire [AW-1:2] ADDR,
  input  wire [31:0]   WDATA,
  input  wire [3:0]    WREN,
  input  wire          CS,

  // Outputs
  output wire [31:0]   RDATA
 );

blk_mem_zed //#(
  //.filename("mem0.coe"))
  blk_mem0 
  (
  .clka (CLK),
  .ena  (CS),
  .wea  (WREN[0]),
  .addra(ADDR[15:2]),
  .dina (WDATA[7:0]),
  .douta(RDATA[7:0])
);
blk_mem_zed// #(
 // .filename("mem1.coe"))
  blk_mem1 (
  .clka (CLK),
  .ena  (CS),
  .wea  (WREN[1]),
  .addra(ADDR[15:2]),
  .dina (WDATA[15:8]),
  .douta(RDATA[15:8])
);
blk_mem_zed //#(
 // .filename("mem2.coe"))
  blk_mem2 (
  .clka (CLK),
  .ena  (CS),
  .wea  (WREN[2]),
  .addra(ADDR[15:2]),
  .dina (WDATA[23:16]),
  .douta(RDATA[23:16])
);
blk_mem_zed //#(
  //.filename("mem3.coe"))
  blk_mem3 (
  .clka (CLK),
  .ena  (CS),
  .wea  (WREN[3]),
  .addra(ADDR[15:2]),
  .dina (WDATA[31:24]),
  .douta(RDATA[31:24])
);

endmodule