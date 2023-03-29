
module MY_DESIGN ( Cin1, Cin2, Cout, data1, data2, sel, clk, out1, out2, out3);
  input [4:0] Cin1, Cin2, data1, data2;
  input sel, clk;
  output [4:0] Cout, out1, out2, out3;
  reg   [4:0] R1, R2, R3, R4, out1, out2, out3;
  wire   [4:0] arth_o;

  ARITH U1_ARITH ( .a(data1), .b(data2), .sel(sel), .out1(arth_o) );
  COMBO U_COMBO ( .Cin1(Cin1), .Cin2(Cin2), .sel(sel), .Cout(Cout) );


always @ (posedge clk)
  begin
    R1 <= arth_o;
    R2 <= data1 & data2;
    R3 <= data1 + data2;
    R4 <= R2 + R3;
  end

always @ (out2, R1, R3, R4)
  begin
    out1 <= R1 + R3;
    out2 <= R3 & R4;
    out3 <= out2 - R3;
  end

endmodule





module ARITH ( a, b, sel, out1 );
  input [4:0] a, b;
  input sel;
  output [4:0] out1;
  reg [4:0] out1;

always @(sel, a, b)

  begin
    case({sel})
        1'b0: out1 <= a + b;
        1'b1: out1 <= a - b;
    endcase
  end



endmodule




module COMBO ( Cin1, Cin2, sel, Cout );
  input [4:0] Cin1, Cin2;
  input sel;
  output [4:0] Cout;
  reg [4:0] Cout;

  wire   [4:0] arth_o;

  ARITH U2_ARITH ( .a(Cin1), .b(Cin2), .sel(sel), .out1(arth_o) );

always @ (Cin1, arth_o)
  begin
    Cout <= arth_o + Cin1;
  end

endmodule
