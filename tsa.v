`timescale 1ns/100ps
`include "define.v"
module tsa(
    input                clk, //1GHz sys clock.
    input                rst,
    input[7:0]           ts_info, //state:[7:4] sub_state[3:0]
    input                ts_update,
    output               ts_update_ack,
    input                ts_stop,    
    input                speed,
    input                mode,
    input[3:0]           lane_num,
    input                to_tsa_ts_sent_enough, //each substate, the controllers knows how many
    input                remote_ts_valid,
    input[127:0]         remote_ts,
    output               tsa_p_a2c,
    output               tsa_p2c,
    output               tsa_c_lw_s2a
    
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
4.output:
received enough remote TSs and ready for state transition
*/
reg[7:0] symbol_nxt[0:15];
reg[7:0] symbol_reg[0:15];

reg[1:0] state_nxt, state_reg;
wire[3:0] curr_state = ts_info[7:4];
wire[3:0] curr_sub_st = ts_info[3:0];
//ts1/2 counter reg
reg[15:0] cnt_nxt, cnt_reg;
reg[15:0] target_nxt, target_reg;

reg tsa_p_a2c_nxt, tsa_p_a2c_reg;
assign tsa_p_a2c = tsa_p_a2c_reg;

reg tsa_p2c_nxt, tsa_p2c_reg;
assign tsa_p2c = tsa_p2c_reg;

reg tsa_c_lw_s2a_nxt, tsa_c_lw_s2a_reg;
assign tsa_c_lw_s2a = tsa_c_lw_s2a_reg;


reg ts_update_ack_nxt, ts_update_ack_reg;
assign ts_update_ack = ts_update_ack_reg;
integer i;
wire[5:0]   rate_support = `RATE_SUPPORT;

wire[127:0] ts_reg = {
        symbol_reg[0],
        symbol_reg[1],
        symbol_reg[2],
        symbol_reg[3],
        symbol_reg[4],
        symbol_reg[5],
        symbol_reg[6],
        symbol_reg[7],
        symbol_reg[8],
        symbol_reg[9],
        symbol_reg[10],
        symbol_reg[11],
        symbol_reg[12],
        symbol_reg[13],
        symbol_reg[14],
        symbol_reg[15]};


always@(posedge clk) begin
    if(rst) begin
        state_reg <= 2'b00;
        cnt_reg <= 0;
        target_reg <= 0;
        ts_update_ack_reg <= 1'b0;     
        tsa_p_a2c_reg <= 0; 
        tsa_p2c_reg <= 0; 
        tsa_c_lw_s2a_reg <= 0;
    end else begin
        state_reg <= state_nxt;
        cnt_reg <= cnt_nxt;
        target_reg <= target_nxt;
        ts_update_ack_reg <= ts_update_ack_nxt;  
        tsa_p_a2c_reg <= tsa_p_a2c_nxt; 
        tsa_p2c_reg <= tsa_p2c_nxt; 
        tsa_c_lw_s2a_reg <= tsa_c_lw_s2a_nxt;
    end
end

always@(posedge clk) begin
    if(rst) begin
        for(i=0;i<16;i=i+1) begin
            symbol_reg[i] <= 0;
        end
    end else begin
        for(i=0;i<16;i=i+1) begin
            symbol_reg[i] <= symbol_nxt[i]; 
        end
    end
end


always@* begin
    state_nxt = state_reg;
    target_nxt = target_reg;
    cnt_nxt = cnt_reg;
    ts_update_ack_nxt = ts_update_ack_reg;   
    tsa_p_a2c_nxt = tsa_p_a2c_reg;
    tsa_p2c_nxt = tsa_p2c_reg;
    tsa_c_lw_s2a_nxt = tsa_c_lw_s2a_reg;
    for(i=0;i<16;i=i+1) begin
        symbol_nxt[i] = symbol_reg[i]; 
    end    
    case(state_reg)
        2'b00: begin // await TS signal
            if(ts_update) begin
                state_nxt = 2'b01; //transmit active
                ts_update_ack_nxt = 1'b1;
                cnt_nxt = 0;
                if(curr_state == `POLL ) begin
                    target_nxt     = curr_sub_st == `POLL_ACTIVE ? `RX_NUM_POLL_ACT2CFG: `RX_NUM_POLL2CFG ;
                    symbol_nxt[0]  = `COM;
                    symbol_nxt[1]  = `PADG12;
                    symbol_nxt[2]  = `PADG12;
                    symbol_nxt[3]  = 8'hFF;
                    symbol_nxt[4]  = {2'b00,rate_support};
                    symbol_nxt[5]  = 8'h00;
                    symbol_nxt[6]  = curr_sub_st == `POLL_ACTIVE ? `TS1_IDTFR : `TS2_IDTFR;
                    symbol_nxt[7]  = curr_sub_st == `POLL_ACTIVE ? `TS1_IDTFR : `TS2_IDTFR;
                    symbol_nxt[8]  = curr_sub_st == `POLL_ACTIVE ? `TS1_IDTFR : `TS2_IDTFR;
                    symbol_nxt[9]  = curr_sub_st == `POLL_ACTIVE ? `TS1_IDTFR : `TS2_IDTFR;
                    symbol_nxt[10] = curr_sub_st == `POLL_ACTIVE ? `TS1_IDTFR : `TS2_IDTFR;
                    symbol_nxt[11] = curr_sub_st == `POLL_ACTIVE ? `TS1_IDTFR : `TS2_IDTFR;
                    symbol_nxt[12] = curr_sub_st == `POLL_ACTIVE ? `TS1_IDTFR : `TS2_IDTFR;
                    symbol_nxt[13] = curr_sub_st == `POLL_ACTIVE ? `TS1_IDTFR : `TS2_IDTFR;
                    symbol_nxt[14] = curr_sub_st == `POLL_ACTIVE ? `TS1_IDTFR : `TS2_IDTFR;
                    symbol_nxt[15] = curr_sub_st == `POLL_ACTIVE ? `TS1_IDTFR : `TS2_IDTFR;
                end  else if(curr_state == `CFG ) begin //set expected TS1s
                    symbol_nxt[0]  = `COM;
                    symbol_nxt[1]  =  mode==`DSP? `PADG12 : `LINK_NUM; //If USP, expect LINK_NUM
                    symbol_nxt[2]  = `PADG12;
                    symbol_nxt[3]  = 8'hFF;
                    symbol_nxt[4]  = {2'b00,rate_support};
                    symbol_nxt[5]  = 8'h00;
                    symbol_nxt[6]  = curr_sub_st == `CFG_COMPLETE ? `TS2_IDTFR : `TS1_IDTFR;
                    symbol_nxt[7]  = curr_sub_st == `CFG_COMPLETE ? `TS2_IDTFR : `TS1_IDTFR;
                    symbol_nxt[8]  = curr_sub_st == `CFG_COMPLETE ? `TS2_IDTFR : `TS1_IDTFR;
                    symbol_nxt[9]  = curr_sub_st == `CFG_COMPLETE ? `TS2_IDTFR : `TS1_IDTFR;
                    symbol_nxt[10] = curr_sub_st == `CFG_COMPLETE ? `TS2_IDTFR : `TS1_IDTFR;
                    symbol_nxt[11] = curr_sub_st == `CFG_COMPLETE ? `TS2_IDTFR : `TS1_IDTFR;
                    symbol_nxt[12] = curr_sub_st == `CFG_COMPLETE ? `TS2_IDTFR : `TS1_IDTFR;
                    symbol_nxt[13] = curr_sub_st == `CFG_COMPLETE ? `TS2_IDTFR : `TS1_IDTFR;
                    symbol_nxt[14] = curr_sub_st == `CFG_COMPLETE ? `TS2_IDTFR : `TS1_IDTFR;
                    symbol_nxt[15] = curr_sub_st == `CFG_COMPLETE ? `TS2_IDTFR : `TS1_IDTFR;
                    target_nxt     = curr_sub_st == `CFG_LW_START ? `RX_NUM_POLL_ACT2CFG: curr_sub_st == `CFG_COMPLETE ? `RX_NUM_CFG_C2I : `RX_NUM_CFG_GENERAL;
                end 
            end
        end

        2'b01: begin
            ts_update_ack_nxt = 1'b0;            
            if(remote_ts_valid) begin
                cnt_nxt = remote_ts == ts_reg ? cnt_reg + 1: cnt_reg;
            end
            if(ts_update & ~ts_update_ack_reg ) begin // this is new update
                state_nxt = 2'b00;
                ts_update_ack_nxt = 1'b1;  
                cnt_nxt = 0;
            end else if(cnt_reg >= target_reg && to_tsa_ts_sent_enough || cnt_reg >= target_reg && target_reg <= `RX_NUM_CFG_GENERAL) begin 
                tsa_p_a2c_nxt = {curr_state,curr_sub_st}=={`POLL,`POLL_ACTIVE} ;
                tsa_p2c_nxt = {curr_state,curr_sub_st}=={`POLL,`POLL_CFG} ;
                tsa_c_lw_s2a_nxt = {curr_state,curr_sub_st}=={`CFG,`CFG_LW_START};
            end
        end

    endcase

end

endmodule
            







