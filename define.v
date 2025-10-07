`define LANE_NUM                4
`define LINK_NUM                8'h00
`define USP                     1'b1
`define DSP                     1'b0

`define COM                     8'hBC
`define PADG12                  8'hF7
`define D10_2                   8'h4A
`define D5_2                    8'h45
`define TS1_IDTFR               `D10_2
`define TS2_IDTFR               `D5_2

`define RATE_SUPPORT            6'h3E

`define G1                      6'h01
`define G2                      6'h02
`define G3                      6'h04
`define G4                      6'h08
`define G5                      6'h10

`define TX_NUM_POLL_ACT2CFG     16'd1024
`define TX_NUM_POLL2CFG         16'd16
`define TX_NUM_CFG_LWS2LWA      16'd1024 // spec has not set



`define RX_NUM_POLL_ACT2CFG     16'd8
`define RX_NUM_POLL2CFG         16'd8
`define RX_NUM_CFG_LWS2LWA      16'd1 
`define RX_NUM_CFG_GENERAL      16'd2
`define RX_NUM_CFG_C2I          16'd8


`define DETECT                  4'h0 
`define POLL                    4'h1 
`define CFG                     4'h2

`define D_ACTIVE                2'b01
`define D_QUIET                 2'b00

`define POLL_ACTIVE             4'b0000 
`define POLL_CFG                4'b0001
`define POLL_SPEED              4'b0010
`define POLL_COMP               4'b0011

`define CFG_LW_START            4'b0000
`define CFG_LW_ACC              4'b0001
`define CFG_LN_ACC              4'b0011
`define CFG_LN_WAIT             4'b0111
`define CFG_COMPLETE            4'b1110
`define CFG_IDLE                4'b1100
  
