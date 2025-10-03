`timescale 1ns/100ps
`include "define.v"
/* This project is aimed for understanding core LTSSM transition.
It's meant to be a digital only project, many core analog signals
are omitted or substituted by simulation construct. The core is
fully synthesizable and expandable and can be built into product IP
if expanded with enough features.*/
/*TS1 and TS2s are meant to be transmitted directly. The project is
two LTSSMs of same module talking to each other via TS1s. This process
simplifies the communication and eliminates the complexity of serdes
sim*/
/*TS1s are transmitted serially over the differential pair. The speed of
different gens are
Gen1: 2.5G/s    serial clock cycle and freq: 400ps 2.5GHz
Gen2: 5.0G/s    serial clock cycle and freq: 200ps 5.0GHz
Gen3: 8.0G/s    serial clock cycle and freq: 125ps 8.0GHz
Gen4: 16G/s     serial clock cycle and freq: 62.5ps 16.0GHz
Gen5: 32G/s     serial clock cycle and freq: 31.25ps 32.0GHz

Say system digital clock speed is 1GHz, the parallel TSs come in at a given
rate:
TS1: 16symbol = 128bit, Throughput = 128bitx1G = 128Gbps/per lane
assuming TS1s are sent back to back.
Gen1: 2.5Gx0.8(overhead) = 2Gbps. coming at 1 valid/ 128/2=64 cycles
Gen2: 5.0Gx0.8(overhead) = 4Gbps. coming at 1 valid/ 128/4=32 cycles
Gen3: 8.0Gx(128/130) = 8Gbps(neglecting encoding): coming at 1 valid/ 128/8=16 cycles
Gen4: 16.0Gx(128/130) = 16Gbps(neglecting encoding): coming at 1 valid/ 128/16=8 cycles
Gen5: 32.0Gx(128/130) = 32Gbps(neglecting encoding): coming at 1 valid/ 128/32=4 cycles

*/


module LTSSM(
    input            clk, //1GHz sys clock.
    input            rst,
    //RX detect
    input            lane0_rx_det,
    input            lane1_rx_det,
    input            lane2_rx_det,
    input            lane3_rx_det,

    input            lane0_idle_break,
    input            lane1_idle_break,
    input            lane2_idle_break,
    input            lane3_idle_break,

    output           lane0_rx_det_seq_req,
    output           lane1_rx_det_seq_req,
    output           lane2_rx_det_seq_req,
    output           lane3_rx_det_seq_req,

    input            lane0_rx_det_seq_ack,
    input            lane1_rx_det_seq_ack,
    input            lane2_rx_det_seq_ack,
    input            lane3_rx_det_seq_ack,

    
    //TS1/s IF
    input[127:0]     lane0_ts_i,
    input            lane0_ts_i_vld,
    output[127:0]    lane0_ts_o,
    output           lane0_ts_o_vld,
    input[127:0]     lane1_ts_i,
    input            lane1_ts_i_vld,
    output[127:0]    lane1_ts_o,
    output           lane1_ts_o_vld,
    input[127:0]     lane2_ts_i,
    input            lane2_ts_i_vld,
    output[127:0]    lane2_ts_o,
    output           lane2_ts_o_vld,
    input[127:0]     lane3_ts_i,
    input            lane3_ts_i_vld,
    output[127:0]    lane3_ts_o,
    output           lane3_ts_o_vld,


    output           linkup
);

wire[3:0]   w_elec_idle_brk     =   {lane3_idle_break,lane2_idle_break,lane1_idle_break,lane0_idle_break};
wire[3:0]   w_rx_det_seq_ack    =   {lane3_rx_det_seq_ack,lane2_rx_det_seq_ack,lane1_rx_det_seq_ack,lane0_rx_det_seq_ack};
wire[3:0]   w_rx_det_seq_req;
assign      {lane3_rx_det_seq_req,lane2_rx_det_seq_req,lane1_rx_det_seq_req,lane0_rx_det_seq_req} = w_rx_det_seq_req;

wire[3:0]   w_lanes_rx_det; 
assign      w_lanes_rx_det = {lane3_rx_det, lane2_rx_det, lane1_rx_det, lane0_rx_det} ;

wire[7:0]   w_ts_info;
wire        w_ts_start;

ts_gen ts_gen_u0(
   .clk                             (clk), //1GHz sys clock.
   .rst                             (rst),
   .ts_info                         (w_ts_info), //state:[7:4] sub_state[3:0]
   .ts_update                       (w_ts_update),
   .ts_stop                         (ts_stop),    
   .to_tsa_ts_sent_enough           (),
   .ts_valid                        (lane0_ts_o_vld),
   .ts                              (lane0_ts_o),
   .ts_tx_fifo_full                    ()
);

ts_gen ts_gen_u1(
   .clk                             (clk), //1GHz sys clock.
   .rst                             (rst),
   .ts_info                         (w_ts_info), //state:[7:4] sub_state[3:0]
   .ts_update                       (w_ts_update),
   .ts_stop                         (ts_stop),    
   .to_tsa_ts_sent_enough           (),
   .ts_valid                        (lane1_ts_o_vld),
   .ts                              (lane1_ts_o),
   .ts_tx_fifo_full                    ()
);

ts_gen ts_gen_u2(
   .clk                             (clk), //1GHz sys clock.
   .rst                             (rst),
   .ts_info                         (w_ts_info), //state:[7:4] sub_state[3:0]
   .ts_update                       (w_ts_update),
   .ts_stop                         (ts_stop),    
   .to_tsa_ts_sent_enough           (),
   .ts_valid                        (lane2_ts_o_vld),
   .ts                              (lane2_ts_o),
   .ts_tx_fifo_full                    ()
);

ts_gen ts_gen_u3(
   .clk                             (clk), //1GHz sys clock.
   .rst                             (rst),
   .ts_info                         (w_ts_info), //state:[7:4] sub_state[3:0]
   .ts_update                       (w_ts_update),
   .ts_stop                         (ts_stop),    
   .to_tsa_ts_sent_enough           (),
   .ts_valid                        (lane3_ts_o_vld),
   .ts                              (lane3_ts_o),
   .ts_tx_fifo_full                    ()
);

core_fsm core_fsm_u(
    .clk                            (clk), //1GHz sys clock.
    .rst                            (rst),
    .elec_idle_break                (w_elec_idle_brk),
    .rx_det_seq_req                 (w_rx_det_seq_req),
    .rx_det_seq_ack                 (w_rx_det_seq_ack),
    .rx_det_valid                   (w_lanes_rx_det),

    .ts_info                        (w_ts_info), //state:[7:4] sub_state[3:0]
    .ts_update                      (w_ts_update),
    .ts_stop                        (w_ts_stop),
    
    .curr_speed                     (),
    .tsa_p2c                        (),
    .tsa_p_a2c                      ()
);

endmodule
    

