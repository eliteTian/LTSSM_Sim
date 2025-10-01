module ts_gen(
    input                clk, //1GHz sys clock.
    input                rst,
    input[7:0]           ts_info, //state:[7:4] sub_state[3:0]
    input                ts_start,
    output               ts_start,
    input                speed,
    output[LANE_NUM-1:0] ts1_p2c
);

localparam COM = 8'hBC; //8'b101 11100
localparam PADG12 = 8'hF7;

wire[3:0] curr_state = ts_info[7:4];
wire[3:0] curr_sub_st = ts_info[3:0];

reg[15:0] cnt;
//wire[127:0] ts1_p2c = {
reg[7:0] symbol00_nxt, symbol00_reg; 
reg[7:0] symbol01_nxt, symbol01_reg;
reg[7:0] symbol02_nxt, symbol02_reg;
reg[7:0] symbol03_nxt, symbol03_reg;
reg[7:0] symbol04_nxt, symbol04_reg;
reg[7:0] symbol05_nxt, symbol05_reg;
reg[7:0] symbol06_nxt, symbol06_reg;
reg[7:0] symbol07_nxt, symbol07_reg;
reg[7:0] symbol08_nxt, symbol08_reg;
reg[7:0] symbol09_nxt, symbol09_reg;
reg[7:0] symbol10_nxt, symbol10_reg;
reg[7:0] symbol11_nxt, symbol11_reg; 
reg[7:0] symbol12_nxt, symbol12_reg;
reg[7:0] symbol13_nxt, symbol13_reg;
reg[7:0] symbol14_nxt, symbol14_reg;
reg[7:0] symbol15_nxt, symbol15_reg;



endmodule
