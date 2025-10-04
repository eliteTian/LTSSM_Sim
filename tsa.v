`timescale 1ns/100ps
`include "define.v"
module tsa(
    input                clk, //1GHz sys clock.
    input                rst,
    input[7:0]           ts_info, //state:[7:4] sub_state[3:0]
    input                ts_update,
    input                ts_stop,    
    input                speed,
    input                to_tsa_ts_sent_enough, //each substate, the controllers knows how many
    input               ts_valid,
    input[127:0]         ts,
    input                ts_tx_fifo_full
    
);

/* methodology
define states:
1. awaiting TS to capture depending on the state
2. counting
define inputs:
ts_valid
ts
current FSM states
3. transitions
once ts_info is obtained, go to counting.
once 



