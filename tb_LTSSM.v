`timescale 1ns/100ps
`include "define.v"
module LTSSM_tb;

reg clk;
reg rst;

initial begin
    #0 clk = 1'b0;
       rst = 1'b0;
    #10
       rst = 1'b1;
    #100
       rst = 1'b0;
end

//1G clk
always
    #0.5 clk = ~clk;
    
wire    usp_lane0_rx_det;
wire    usp_lane1_rx_det;
wire    usp_lane2_rx_det;
wire    usp_lane3_rx_det;

wire    dsp_lane0_rx_det;
wire    dsp_lane1_rx_det;
wire    dsp_lane2_rx_det;
wire    dsp_lane3_rx_det;



// Lane 0
wire [127:0] usp_lane0_ts;
wire         usp_lane0_ts_vld;

// Lane 1
wire [127:0] usp_lane1_ts;
wire         usp_lane1_ts_vld;

// Lane 2
wire [127:0] usp_lane2_ts;
wire         usp_lane2_ts_vld;

// Lane 3
wire [127:0] usp_lane3_ts;
wire         usp_lane3_ts_vld;

// Lane 0
wire [127:0] dsp_lane0_ts;
wire         dsp_lane0_ts_vld;

// Lane 1
wire [127:0] dsp_lane1_ts;
wire         dsp_lane1_ts_vld;

// Lane 2
wire [127:0] dsp_lane2_ts;
wire         dsp_lane2_ts_vld;

// Lane 3
wire [127:0] dsp_lane3_ts;
wire         dsp_lane3_ts_vld;

wire        lane0_idel_break;
wire        lane1_idel_break;
wire        lane2_idel_break;
wire        lane3_idel_break;




LTSSM LTSSM_DSP(
    .clk                        (  clk   ),
    .rst				        (  rst   ),

    .lane0_rx_det				( 1'b1   ),
    .lane1_rx_det				( 1'b1   ),
    .lane2_rx_det				( 1'b1   ),
    .lane3_rx_det				( 1'b1   ),

    .lane0_idel_break			( lane0_idel_break  ),
    .lane1_idel_break			( lane1_idel_break  ),
    .lane2_idel_break			( lane2_idel_break  ),
    .lane3_idel_break			( lane3_idel_break  ),

    .lane0_rx_det_seq_req		(dsp_lane0_rx_det    ),
    .lane1_rx_det_seq_req		(dsp_lane1_rx_det    ),
    .lane2_rx_det_seq_req		(dsp_lane2_rx_det    ),
    .lane3_rx_det_seq_req		(dsp_lane3_rx_det    ),

    .lane0_rx_det_seq_ack		(usp_lane0_rx_det    ),
    .lane1_rx_det_seq_ack		(usp_lane1_rx_det    ),
    .lane2_rx_det_seq_ack		(usp_lane2_rx_det    ),
    .lane3_rx_det_seq_ack		(usp_lane3_rx_det    ),

    .lane0_ts_i				    (  usp_lane0_ts       ),
    .lane0_ts_i_vld				(  usp_lane0_ts_vld   ),
    .lane0_ts_o			    	(  dsp_lane0_ts       ),
    .lane0_ts_o_vld				(  dsp_lane0_ts_vld   ),
    .lane1_ts_i				    (  usp_lane1_ts       ),
    .lane1_ts_i_vld				(  usp_lane1_ts_vld  ),
    .lane1_ts_o				    (  dsp_lane1_ts      ),
    .lane1_ts_o_vld				(  dsp_lane1_ts_vld  ),
    .lane2_ts_i				    (  usp_lane2_ts      ),
    .lane2_ts_i_vld				(  usp_lane2_ts_vld  ),
    .lane2_ts_o				    (  dsp_lane2_ts     ),
    .lane2_ts_o_vld				(  dsp_lane2_ts_vld ),
    .lane3_ts_i				    (  usp_lane3_ts      ),
    .lane3_ts_i_vld				(  usp_lane3_ts_vld  ),
    .lane3_ts_o				    (  dsp_lane3_ts      ),
    .lane3_ts_o_vld				(  dsp_lane3_ts_vld  ),
    .linkup                     (                    )
);


delay_shim #(
    .WIDTH(1),
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) lane0_elec_idle_break_delay (
    .clk    (clk),
    .rst    (rst),    
    .in_sig (1'b1),
    .out_sig(lane0_idel_break)
);

delay_shim #(
    .WIDTH(1),
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) lane1_elec_idle_break_delay (
    .clk    (clk),
    .rst    (rst),    
    .in_sig (1'b1),
    .out_sig(lane1_idel_break)
);

delay_shim #(
    .WIDTH(1),
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) lane2_elec_idle_break_delay (
    .clk    (clk),
    .rst    (rst),    
    .in_sig (1'b1),
    .out_sig(lane2_idel_break)
);

delay_shim #(
    .WIDTH(1),
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) lane3_elec_idle_break_delay (
    .clk    (clk),
    .rst    (rst),
    .in_sig (1'b1),
    .out_sig(lane3_idel_break)
);




LTSSM LTSSM_USP(
    .clk                        (clk     ), 
    .rst				        (rst     ),
    
    .lane0_rx_det				(1'b1    ),
    .lane1_rx_det				(1'b1    ),
    .lane2_rx_det				(1'b1    ),
    .lane3_rx_det				(1'b1    ),

    .lane0_idel_break			( lane0_idel_break  ),
    .lane1_idel_break			( lane1_idel_break  ),
    .lane2_idel_break			( lane2_idel_break  ),
    .lane3_idel_break			( lane3_idel_break  ),

    .lane0_rx_det_seq_req		(usp_lane0_rx_det    ),
    .lane1_rx_det_seq_req		(usp_lane1_rx_det    ),
    .lane2_rx_det_seq_req		(usp_lane2_rx_det    ),
    .lane3_rx_det_seq_req		(usp_lane3_rx_det    ),

    .lane0_rx_det_seq_ack		( dsp_lane0_rx_det   ),
    .lane1_rx_det_seq_ack		( dsp_lane1_rx_det   ),
    .lane2_rx_det_seq_ack		( dsp_lane2_rx_det   ),
    .lane3_rx_det_seq_ack		( dsp_lane3_rx_det   ),

    .lane0_ts_i				    ( dsp_lane0_ts       ),
    .lane0_ts_i_vld				( dsp_lane0_ts_vld   ),
    .lane0_ts_o			    	( usp_lane0_ts       ),
    .lane0_ts_o_vld				( usp_lane0_ts_vld   ),
    .lane1_ts_i				    ( dsp_lane1_ts       ),
    .lane1_ts_i_vld				( dsp_lane1_ts_vld   ),
    .lane1_ts_o				    ( usp_lane1_ts       ),
    .lane1_ts_o_vld				( usp_lane1_ts_vld   ),
    .lane2_ts_i				    ( dsp_lane2_ts       ),
    .lane2_ts_i_vld				( dsp_lane2_ts_vld   ),
    .lane2_ts_o				    ( usp_lane2_ts       ),
    .lane2_ts_o_vld				( usp_lane2_ts_vld   ),
    .lane3_ts_i				    ( dsp_lane3_ts       ),
    .lane3_ts_i_vld				( dsp_lane3_ts_vld   ),
    .lane3_ts_o				    ( usp_lane3_ts       ),
    .lane3_ts_o_vld				( usp_lane3_ts_vld   ),
    .linkup                     (    )

);



endmodule
