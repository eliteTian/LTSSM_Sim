`timescale 1ns/100ps
`include "define.v"
module LTSSM_tb;

reg clk;
reg phy_clk;
reg rst;
wire[5:0] speed;

initial begin
    #0 clk = 1'b0;
       phy_clk = 1'b0;
       rst = 1'b0;
    #10
       rst = 1'b1;
    #100
       rst = 1'b0;
end

//1G clk
always
    #0.5 clk = ~clk;

always
    case(speed)
        `G1: #0.2 phy_clk = ~phy_clk;
        `G2: #0.1 phy_clk = ~phy_clk;
        `G3: #0.0625 phy_clk = ~phy_clk;
        `G4: #0.03125 phy_clk = ~phy_clk;
    endcase
    
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

wire        dsp_lane0_idle_break;
wire        dsp_lane1_idle_break;
wire        dsp_lane2_idle_break;
wire        dsp_lane3_idle_break;
wire        usp_lane0_idle_break;
wire        usp_lane1_idle_break;
wire        usp_lane2_idle_break;
wire        usp_lane3_idle_break;

wire        dsp_lane0_rx_det_req;
wire        dsp_lane1_rx_det_req;
wire        dsp_lane2_rx_det_req;
wire        dsp_lane3_rx_det_req;

wire        dsp_lane0_rx_det_ack;
wire        dsp_lane1_rx_det_ack;
wire        dsp_lane2_rx_det_ack;
wire        dsp_lane3_rx_det_ack;

wire        dsp_lane0_rx_det_vld;
wire        dsp_lane1_rx_det_vld;
wire        dsp_lane2_rx_det_vld;
wire        dsp_lane3_rx_det_vld;

wire        usp_lane0_rx_det_req;
wire        usp_lane1_rx_det_req;
wire        usp_lane2_rx_det_req;
wire        usp_lane3_rx_det_req;

wire        usp_lane0_rx_det_ack;
wire        usp_lane1_rx_det_ack;
wire        usp_lane2_rx_det_ack;
wire        usp_lane3_rx_det_ack;

wire        usp_lane0_rx_det_vld;
wire        usp_lane1_rx_det_vld;
wire        usp_lane2_rx_det_vld;
wire        usp_lane3_rx_det_vld;


//FIFO BUSY
wire        usp_lane0_fifo_busy;
wire        usp_lane1_fifo_busy;
wire        usp_lane2_fifo_busy;
wire        usp_lane3_fifo_busy;

wire        dsp_lane0_fifo_busy;
wire        dsp_lane1_fifo_busy;
wire        dsp_lane2_fifo_busy;
wire        dsp_lane3_fifo_busy;



LTSSM LTSSM_DSP(
    .clk                        (  clk   ),
    .rst				        (  rst   ),
    .mode                       (  `DSP  ),
    .lane0_rx_det				( dsp_lane0_rx_det_vld  ),
    .lane1_rx_det				( dsp_lane1_rx_det_vld  ),
    .lane2_rx_det				( dsp_lane2_rx_det_vld  ),
    .lane3_rx_det				( dsp_lane3_rx_det_vld  ),

    .lane0_idle_break			( dsp_lane0_idle_break  ),
    .lane1_idle_break			( dsp_lane1_idle_break  ),
    .lane2_idle_break			( dsp_lane2_idle_break  ),
    .lane3_idle_break			( dsp_lane3_idle_break  ),

    .lane0_rx_det_seq_req		( dsp_lane0_rx_det_req    ),
    .lane1_rx_det_seq_req		( dsp_lane1_rx_det_req    ),
    .lane2_rx_det_seq_req		( dsp_lane2_rx_det_req    ),
    .lane3_rx_det_seq_req		( dsp_lane3_rx_det_req    ),

    .lane0_rx_det_seq_ack		( dsp_lane0_rx_det_ack    ),
    .lane1_rx_det_seq_ack		( dsp_lane1_rx_det_ack    ),
    .lane2_rx_det_seq_ack		( dsp_lane2_rx_det_ack    ),
    .lane3_rx_det_seq_ack		( dsp_lane3_rx_det_ack    ),

    .lane0_ts_i				    ( usp_lane0_ts       ),
    .lane0_ts_i_vld				( usp_lane0_ts_vld   ),
    .lane0_ts_o			    	( dsp_lane0_ts       ),
    .lane0_ts_o_vld				( dsp_lane0_ts_vld   ),
    .lane1_ts_i				    ( usp_lane1_ts       ),
    .lane1_ts_i_vld				( usp_lane1_ts_vld   ),
    .lane1_ts_o				    ( dsp_lane1_ts       ),
    .lane1_ts_o_vld				( dsp_lane1_ts_vld   ),
    .lane2_ts_i				    ( usp_lane2_ts       ),
    .lane2_ts_i_vld				( usp_lane2_ts_vld   ),
    .lane2_ts_o				    ( dsp_lane2_ts       ),
    .lane2_ts_o_vld				( dsp_lane2_ts_vld   ),
    .lane3_ts_i				    ( usp_lane3_ts       ),
    .lane3_ts_i_vld				( usp_lane3_ts_vld   ),
    .lane3_ts_o				    ( dsp_lane3_ts       ),
    .lane3_ts_o_vld				( dsp_lane3_ts_vld   ),

    .lane0_tx_fifo_full         ( dsp_lane0_fifo_busy      ),           
    .lane1_tx_fifo_full         ( dsp_lane1_fifo_busy      ),
    .lane2_tx_fifo_full         ( dsp_lane2_fifo_busy      ),
    .lane3_tx_fifo_full         ( dsp_lane3_fifo_busy      ),
    .curr_speed                 (speed),
    .linkup                     (                    )
);


elec_idle #(
    .WIDTH(1),
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) usp_lane0_elec_idle (
    .clk    (clk),
    .rst    (rst),    
    .in_sig (1'b1),
    .out_sig(dsp_lane0_idle_break)
);

elec_idle #(
    .WIDTH(1),
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) usp_lane1_elec_idle (
    .clk    (clk),
    .rst    (rst),    
    .in_sig (1'b1),
    .out_sig(dsp_lane1_idle_break)
);

elec_idle #(
    .WIDTH(1),
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) usp_lane2_elec_idle (
    .clk    (clk),
    .rst    (rst),    
    .in_sig (1'b1),
    .out_sig(dsp_lane2_idle_break)
);

elec_idle #(
    .WIDTH(1),
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) usp_lane3_elec_idle (
    .clk    (clk),
    .rst    (rst),
    .in_sig (1'b1),
    .out_sig(dsp_lane3_idle_break)
);

elec_idle #(
    .WIDTH(1),
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) dsp_lane0_elec_idle (
    .clk    (clk),
    .rst    (rst),    
    .in_sig (1'b1),
    .out_sig(usp_lane0_idle_break)
);

elec_idle #(
    .WIDTH(1),
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) dsp_lane1_elec_idle (
    .clk    (clk),
    .rst    (rst),    
    .in_sig (1'b1),
    .out_sig(usp_lane1_idle_break)
);

elec_idle #(
    .WIDTH(1),
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) dsp_lane2_elec_idle (
    .clk    (clk),
    .rst    (rst),    
    .in_sig (1'b1),
    .out_sig(usp_lane2_idle_break)
);

elec_idle #(
    .WIDTH(1),
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) dsp_lane3_elec_idle (
    .clk    (clk),
    .rst    (rst),
    .in_sig (1'b1),
    .out_sig(usp_lane3_idle_break)
);

//rx det circuit dsp
rx_det_circuit#(
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) dsp_rx_det0 (
    .clk                (clk),
    .rst                (rst),
    .rx_present         (1'b1),
    .rx_det_req         (dsp_lane0_rx_det_req),
    .rx_det_ack         (dsp_lane0_rx_det_ack),
    .rx_det_vld         (dsp_lane0_rx_det_vld)
);

rx_det_circuit#(
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) dsp_rx_det1 (
    .clk                (clk),
    .rst                (rst),
    .rx_present         (1'b1),
    .rx_det_req         (dsp_lane1_rx_det_req),
    .rx_det_ack         (dsp_lane1_rx_det_ack),
    .rx_det_vld         (dsp_lane1_rx_det_vld)
);

rx_det_circuit#(
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) dsp_rx_det2 (
    .clk                (clk),
    .rst                (rst),
    .rx_present         (1'b1),
    .rx_det_req         (dsp_lane2_rx_det_req),
    .rx_det_ack         (dsp_lane2_rx_det_ack),
    .rx_det_vld         (dsp_lane2_rx_det_vld)
);

rx_det_circuit#(
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) dsp_rx_det3 (
    .clk                (clk),
    .rst                (rst),
    .rx_present         (1'b1),
    .rx_det_req         (dsp_lane3_rx_det_req),
    .rx_det_ack         (dsp_lane3_rx_det_ack),
    .rx_det_vld         (dsp_lane3_rx_det_vld)
);

///////////////////
//
//rx det circuit usp
rx_det_circuit#(
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) usp_rx_det0 (
    .clk                (clk),
    .rst                (rst),
    .rx_present         (1'b1),
    .rx_det_req         (usp_lane0_rx_det_req),
    .rx_det_ack         (usp_lane0_rx_det_ack),
    .rx_det_vld         (usp_lane0_rx_det_vld)
);

rx_det_circuit#(
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) usp_rx_det1 (
    .clk                (clk),
    .rst                (rst),
    .rx_present         (1'b1),
    .rx_det_req         (usp_lane1_rx_det_req),
    .rx_det_ack         (usp_lane1_rx_det_ack),
    .rx_det_vld         (usp_lane1_rx_det_vld)
);

rx_det_circuit#(
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) usp_rx_det2 (
    .clk                (clk),
    .rst                (rst),
    .rx_present         (1'b1),
    .rx_det_req         (usp_lane2_rx_det_req),
    .rx_det_ack         (usp_lane2_rx_det_ack),
    .rx_det_vld         (usp_lane2_rx_det_vld)
);

rx_det_circuit#(
    .DELAY_CYCLES(500)  // 500 clock cycles delay
) usp_rx_det3 (
    .clk                (clk),
    .rst                (rst),
    .rx_present         (1'b1),
    .rx_det_req         (usp_lane3_rx_det_req),
    .rx_det_ack         (usp_lane3_rx_det_ack),
    .rx_det_vld         (usp_lane3_rx_det_vld)
);

///////////////////


LTSSM LTSSM_USP(
    .clk                        ( clk     ), 
    .rst				        ( rst     ),
    .mode                       (  `USP  ),
    
    .lane0_rx_det				( usp_lane0_rx_det_vld    ),
    .lane1_rx_det				( usp_lane1_rx_det_vld    ),
    .lane2_rx_det				( usp_lane2_rx_det_vld    ),
    .lane3_rx_det				( usp_lane3_rx_det_vld    ),

    .lane0_idle_break			( usp_lane0_idle_break  ),
    .lane1_idle_break			( usp_lane1_idle_break  ),
    .lane2_idle_break			( usp_lane2_idle_break  ),
    .lane3_idle_break			( usp_lane3_idle_break  ),

    .lane0_rx_det_seq_req		( usp_lane0_rx_det_req    ),
    .lane1_rx_det_seq_req		( usp_lane1_rx_det_req    ),
    .lane2_rx_det_seq_req		( usp_lane2_rx_det_req    ),
    .lane3_rx_det_seq_req		( usp_lane3_rx_det_req    ),

    .lane0_rx_det_seq_ack		( usp_lane0_rx_det_ack   ),
    .lane1_rx_det_seq_ack		( usp_lane1_rx_det_ack   ),
    .lane2_rx_det_seq_ack		( usp_lane2_rx_det_ack   ),
    .lane3_rx_det_seq_ack		( usp_lane3_rx_det_ack   ),

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

    .lane0_tx_fifo_full         ( usp_lane0_fifo_busy   ),
    .lane1_tx_fifo_full         ( usp_lane1_fifo_busy   ),
    .lane2_tx_fifo_full         ( usp_lane2_fifo_busy   ),
    .lane3_tx_fifo_full         ( usp_lane3_fifo_busy   ),
    .curr_speed                 (speed),
    .linkup                     (    )

);

serdes dsp_serdes_0 (
    .clk(clk),          // system clock
    .phy_clk(phy_clk),      // PHY clock
    .rst(rst),          // reset
    .data_valid(dsp_lane0_ts_vld),   // input data valid signal
    .speed(speed),        // speed control
    .speed_change(), // speed change indicator
    .busy(dsp_lane0_fifo_busy)          // busy output
);

serdes dsp_serdes_1 (
    .clk(clk),          // system clock
    .phy_clk(phy_clk),      // PHY clock
    .rst(rst),          // reset
    .data_valid(dsp_lane1_ts_vld),   // input data valid signal
    .speed(speed),        // speed control
    .speed_change(), // speed change indicator
    .busy(dsp_lane1_fifo_busy)          // busy output
);

serdes dsp_serdes_2 (
    .clk(clk),          // system clock
    .phy_clk(phy_clk),      // PHY clock
    .rst(rst),          // reset
    .data_valid(dsp_lane2_ts_vld),   // input data valid signal
    .speed(speed),        // speed control
    .speed_change(), // speed change indicator
    .busy(dsp_lane2_fifo_busy)          // busy output
);

serdes dsp_serdes_3 (
    .clk(clk),          // system clock
    .phy_clk(phy_clk),      // PHY clock
    .rst(rst),          // reset
    .data_valid(dsp_lane3_ts_vld),   // input data valid signal
    .speed(speed),        // speed control
    .speed_change(), // speed change indicator
    .busy(dsp_lane3_fifo_busy)          // busy output
);


serdes usp_serdes_0 (
    .clk(clk),          // system clock
    .phy_clk(phy_clk),      // PHY clock
    .rst(rst),          // reset
    .data_valid(usp_lane0_ts_vld),   // input data valid signal
    .speed(speed),        // speed control
    .speed_change(), // speed change indicator
    .busy(usp_lane0_fifo_busy)          // busy output
);

serdes usp_serdes_1 (
    .clk(clk),          // system clock
    .phy_clk(phy_clk),      // PHY clock
    .rst(rst),          // reset
    .data_valid(usp_lane1_ts_vld),   // input data valid signal
    .speed(speed),        // speed control
    .speed_change(), // speed change indicator
    .busy(usp_lane1_fifo_busy)          // busy output
);

serdes usp_serdes_2 (
    .clk(clk),          // system clock
    .phy_clk(phy_clk),      // PHY clock
    .rst(rst),          // reset
    .data_valid(usp_lane2_ts_vld),   // input data valid signal
    .speed(speed),        // speed control
    .speed_change(), // speed change indicator
    .busy(usp_lane2_fifo_busy)          // busy output
);

serdes usp_serdes_3 (
    .clk(clk),          // system clock
    .phy_clk(phy_clk),      // PHY clock
    .rst(rst),          // reset
    .data_valid(usp_lane3_ts_vld),   // input data valid signal
    .speed(speed),        // speed control
    .speed_change(), // speed change indicator
    .busy(usp_lane3_fifo_busy)          // busy output
);




endmodule
