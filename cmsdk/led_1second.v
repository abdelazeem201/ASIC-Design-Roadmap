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

//��������������������������������������������begin ���´���Ĺ��ܣ�ʵ��1���Ӽ�����������һ��һ���ӱ�־��������������������������������

//clk�����������Ƶ�50 ��ʱ�ӣ�50MHZ��ʱ�ӣ�������20ns��ʱ���㣬Ҳ����1000ms = 1΢��
always @(posedge clk or negedge reset)
begin
  if (~reset)
     reg_clk_count <= 6'b00000;
  else  if( reg_clk_count == 49) reg_clk_count <= 6'b00000;
  else  reg_clk_count <= reg_clk_count + 1;
end

//����1us��־ reg_us_flag
always @(posedge clk or negedge reset)
begin
  if (~reset)
     reg_us_flag <= 0;
  else  if( reg_clk_count == 49) reg_us_flag <= 1;
  else  reg_us_flag <= 0;
end
//us �����������Ƶ�1000us ʱ���㣬Ҳ����1����
always @(posedge clk or negedge reset)
begin
  if (~reset)
     reg_us_count <= 0;
  else  if( reg_us_count == 999) reg_us_count <= 10'h000;
  else  if( reg_us_flag) reg_us_count <= reg_us_count + 1;
end

//����1ms��־ reg_ms_flag
always @(posedge clk or negedge reset)
begin
  if (~reset)
     reg_ms_flag <= 0;
  else  if( reg_us_count == 999) reg_ms_flag <= 1;
  else  reg_ms_flag <= 0;
end
//ms �����������Ƶ�1000ms ʱ���㣬Ҳ����1����
always @(posedge clk or negedge reset)
begin
  if (~reset)
     reg_ms_count <= 0;
  else  if( reg_ms_count == 999) reg_ms_count <= 10'h000;
  else  if( reg_ms_flag) reg_ms_count <= reg_ms_count + 1;
end

//����1s ��־reg_1s_flag
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

















