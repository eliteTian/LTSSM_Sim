`timescale 1ns/100ps
`include "define.v"
module ts_gen(
    input                clk, //1GHz sys clock.
    input                rst,
    input[7:0]           ts_info, //state:[7:4] sub_state[3:0]
    input                ts_update,
    input                ts_stop,    
    input                speed,
    output               to_tsa_ts_sent_enough,
    output               ts_valid,
    input[127:0]         ts,
    input                ts_tx_fifo_full
    
);

