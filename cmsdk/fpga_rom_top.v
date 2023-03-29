//-----------------------------------------------------------------------------
//  Abstract : FPGA BlockRam/OnChip ROM
// ----------------------------------------------------------------------------

module fpga_rom_top #(
// --------------------------------------------------------------------------
// Parameter Declarations
// --------------------------------------------------------------------------
  parameter AW = 16,
  parameter filename = "image.hex"
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

blk_mem_zed 
#(
  .filename("mem0.mif"))
  blk_mem0 
  (
  .clka (CLK),
  .ena  (1'b1),
  .wea  (WREN[0]),
  .addra(ADDR[15:2]),
  .dina (WDATA[7:0]),
  .douta(RDATA[7:0])
);
blk_mem_zed 
#(
  .filename("mem1.mif"))
  blk_mem1 (
  .clka (CLK),
  .ena  (1'b1),
  .wea  (WREN[1]),
  .addra(ADDR[15:2]),
  .dina (WDATA[15:8]),
  .douta(RDATA[15:8])
);
blk_mem_zed 
#(
  .filename("mem2.mif"))
  blk_mem2 (
  .clka (CLK),
  .ena  (1'b1),
  .wea  (WREN[2]),
  .addra(ADDR[15:2]),
  .dina (WDATA[23:16]),
  .douta(RDATA[23:16])
);
blk_mem_zed 
#(
  .filename("mem3.mif"))
  blk_mem3 (
  .clka (CLK),
  .ena  (1'b1),
  .wea  (WREN[3]),
  .addra(ADDR[15:2]),
  .dina (WDATA[31:24]),
  .douta(RDATA[31:24])
);

endmodule