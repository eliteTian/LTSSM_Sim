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
    input clk, //1GHz sys clock.
    input rst,
    //RX detect
    input            lane0_rx_det,
    input            lane1_rx_det,
    input            lane2_rx_det,
    input            lane3_rx_det,
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


    output          linkup
);

            

