`timescale 1ns/100ps
`include "define.v"
module elec_idle #(
    parameter DELAY_CYCLES = 1000,  // configurable delay in clock cycles
    parameter WIDTH = 4
)(
    input               clk,
    input               rst,
    input [WIDTH-1:0]   in_sig,
    output[WIDTH-1:0]    out_sig
);

reg[WIDTH-1:0]  delayed_out;
reg sig_valid;

assign out_sig = delayed_out;

    initial begin
        delayed_out = 0;
        sig_valid = 0;
        forever begin
            @(posedge clk);               // wait for rising edge of input
            if(rst) begin
                delayed_out <= 0;
            end else if(in_sig | sig_valid) 
                begin
                    sig_valid <= 1'b1;
                    repeat(DELAY_CYCLES) @(posedge clk);  // wait DELAY_CYCLES
                        delayed_out <= {WIDTH{1'b1}};
                end
        end
    end


endmodule

module rx_det_circuit #(
    parameter DELAY_CYCLES = 1000  // configurable delay in clock cycles

)(
    input               clk,
    input               rst,
    input               rx_present,
    input               rx_det_req,
    output  reg            rx_det_ack,
    output  reg            rx_det_vld
);

//output reg rx_det_ack;
//output reg rx_det_vld;

//always@(posedge clk, posedge rst) begin
//    if(rst) begin
//        rx_det_ack <= 0;
//        rx_det_vld <= 0;
//        start <= 0;
//    end else begin
//        if(~start) begin
//            rx_det_ack <= rx_det_req ? 1'b1: 1'b0;
//            start <= rx_det_req ? 1'b1: 1'b0;
//        end else begin
//            rx_det_proc(rx_present, DELAY_CYCLES, rx_det_vld, start);
//        end
//    end
//end

initial begin
        rx_det_ack = 0;
        rx_det_vld = 0;
        forever begin
            fork
                begin
                    @(posedge rst);
                    rx_det_ack = 0;
                    rx_det_vld = 0;
                end
                begin
                    @(posedge rx_det_req);
                    @(posedge clk);
                    rx_det_ack = 1'b1;
                    rx_det_proc(rx_present, rx_det_vld);
                    rx_det_ack = 1'b0;

                end
            join
        end
end


task rx_det_proc; 
input rx_present;
output rx_det_vld;
begin
    repeat(DELAY_CYCLES) @(posedge clk);  // wait DELAY_CYCLES
    rx_det_vld = 1;  
end
endtask


endmodule

module serdes(
    input               clk,
    input               phy_clk,
    input               rst,
    input               data_valid,
    input               speed,
    input               speed_change,
    output   reg        busy
);

wire[5:0] cycle_w = (speed == `G1 || speed == `G2)? 160: 130;
reg[5:0] cycle_r;
initial begin
    busy = 1'b0;
    cycle_r = cycle_w;
    @(posedge rst);
    @(posedge clk);
    busy = 1'b0;
    forever begin
        @(posedge data_valid);
        busy = 1'b1;
        repeat(cycle_r) @(posedge phy_clk);
        @(posedge clk);
        busy = 1'b0;
    end
end


endmodule



