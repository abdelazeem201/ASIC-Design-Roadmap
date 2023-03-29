// 1second_test 
`timescale 1 ns / 1 ns

module led_1second(
             clk,
             reset,
             led_a
             );
input  clk;
input  reset;
output led_a;   

reg reg_led_a;


reg reg_1s_flag;
reg reg_ms_flag;
reg reg_us_flag;
//reg reg_1m_flag;
//reg [5:0] reg_s_count;
reg [9:0] reg_ms_count;
reg [9:0] reg_us_count;
reg [5:0] reg_clk_count;

//——————————————————————begin 以下代码的功能：实现1分钟计数，并产生一个一分钟标志————————————————

//clk计数器，当计到50 个时钟（50MHZ的时钟，周期是20ns）时清零，也就是1000ms = 1微秒
always @(posedge clk or negedge reset)
begin
  if (~reset)
     reg_clk_count <= 6'b00000;
  else  if( reg_clk_count == 49) reg_clk_count <= 6'b00000;
  else  reg_clk_count <= reg_clk_count + 1;
end

//产生1us标志 reg_us_flag
always @(posedge clk or negedge reset)
begin
  if (~reset)
     reg_us_flag <= 0;
  else  if( reg_clk_count == 49) reg_us_flag <= 1;
  else  reg_us_flag <= 0;
end
//us 计数器，当计到1000us 时清零，也就是1毫秒
always @(posedge clk or negedge reset)
begin
  if (~reset)
     reg_us_count <= 0;
  else  if( reg_us_count == 999) reg_us_count <= 10'h000;
  else  if( reg_us_flag) reg_us_count <= reg_us_count + 1;
end

//产生1ms标志 reg_ms_flag
always @(posedge clk or negedge reset)
begin
  if (~reset)
     reg_ms_flag <= 0;
  else  if( reg_us_count == 999) reg_ms_flag <= 1;
  else  reg_ms_flag <= 0;
end
//ms 计数器，当计到1000ms 时清零，也就是1秒钟
always @(posedge clk or negedge reset)
begin
  if (~reset)
     reg_ms_count <= 0;
  else  if( reg_ms_count == 999) reg_ms_count <= 10'h000;
  else  if( reg_ms_flag) reg_ms_count <= reg_ms_count + 1;
end

//产生1s 标志reg_1s_flag
always @(posedge clk or negedge reset)
begin
  if (~reset)
     reg_1s_flag <= 0;
  else  if( reg_ms_count == 999) reg_1s_flag <= 1;
  else  reg_1s_flag <= 0;
end


always @(posedge clk or negedge reset)
begin
  if (~reset)
     reg_led_a <= 0;
  else  if( reg_1s_flag == 1) reg_led_a <= ~reg_led_a;
  else  reg_led_a <= reg_led_a;
end

assign led_a = reg_led_a ;


endmodule

















