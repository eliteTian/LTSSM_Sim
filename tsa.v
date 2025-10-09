`timescale 1ns/100ps
`include "define.v"
//Descripton:
//TS receiver and analyzer. It gets instructions from FSM
//to expect certain TSs. It also alerts TSG to change symbol
//It also generates state transition signals for FSM.
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
    
    output[7:0]          to_tsg_rcv_link_num, //for usp
    output               to_tsg_rcv_link_num_vld,
    output[7:0]          to_tsg_rcv_lane_num, //for usp
    output               to_tsg_rcv_lane_num_vld,
    
    input                from_tsg_update_ack,



    input                remote_ts_valid,
    input[127:0]         remote_ts,
    output               tsa_p_a2c,
    output               tsa_p2c,
    output               tsa_c_ws2wa,
    output               tsa_c_wa2nw,
    output               tsa_c_nw2na,
    output               tsa_c_na2c,
    output               tsa_c_c2i

    
    
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

wire[7:0] w_lane_num = {4'h0,lane_num};

reg[1:0] state_nxt, state_reg;
wire[3:0] curr_state = ts_info[7:4];
wire[3:0] curr_sub_st = ts_info[3:0];
//ts1/2 counter reg
reg[15:0] cnt_nxt, cnt_reg;
reg[15:0] target_nxt, target_reg;

reg[127:0] symbol_mask_nxt, symbol_mask_reg;
reg[127:0] ts2_symbol_mask_nxt, ts2_symbol_mask_reg;

reg tsa_p_a2c_nxt, tsa_p_a2c_reg;
assign tsa_p_a2c = tsa_p_a2c_reg;

reg tsa_p2c_nxt, tsa_p2c_reg;
assign tsa_p2c = tsa_p2c_reg;

reg tsa_c_ws2wa_nxt, tsa_c_ws2wa_reg;
assign tsa_c_ws2wa = tsa_c_ws2wa_reg;

reg tsa_c_wa2nw_nxt, tsa_c_wa2nw_reg;
assign tsa_c_wa2nw = tsa_c_wa2nw_reg;

reg tsa_c_nw2na_nxt, tsa_c_nw2na_reg;
assign tsa_c_nw2na = tsa_c_nw2na_reg;

reg tsa_c_na2c_nxt, tsa_c_na2c_reg;
assign tsa_c_na2c = tsa_c_na2c_reg;

reg tsa_c_c2i_nxt, tsa_c_c2i_reg;
assign tsa_c_c2i = tsa_c_c2i_reg;

reg [7:0] to_tsg_rcv_link_num_nxt, to_tsg_rcv_link_num_reg;
reg [7:0] to_tsg_rcv_lane_num_nxt, to_tsg_rcv_lane_num_reg;

reg to_tsg_rcv_link_num_vld_nxt, to_tsg_rcv_link_num_vld_reg;
reg to_tsg_rcv_lane_num_vld_nxt, to_tsg_rcv_lane_num_vld_reg;


wire [127:0] remote_ts_masked = remote_ts&symbol_mask_reg;
wire [127:0] ts_reg_masked = ts_reg&symbol_mask_reg;


reg ts_update_ack_nxt, ts_update_ack_reg;
assign ts_update_ack = ts_update_ack_reg;
integer i;
wire[5:0]   rate_support = `RATE_SUPPORT;

wire [7:0] symbol0  = remote_ts[127:120];
wire [7:0] symbol1  = remote_ts[119:112];
wire [7:0] symbol2  = remote_ts[111:104];
wire [7:0] symbol3  = remote_ts[103:96];
wire [7:0] symbol4  = remote_ts[95:88];
wire [7:0] symbol5  = remote_ts[87:80];
wire [7:0] symbol6  = remote_ts[79:72];
wire [7:0] symbol7  = remote_ts[71:64];
wire [7:0] symbol8  = remote_ts[63:56];
wire [7:0] symbol9  = remote_ts[55:48];
wire [7:0] symbol10 = remote_ts[47:40];
wire [7:0] symbol11 = remote_ts[39:32];
wire [7:0] symbol12 = remote_ts[31:24];
wire [7:0] symbol13 = remote_ts[23:16];
wire [7:0] symbol14 = remote_ts[15:8];
wire [7:0] symbol15 = remote_ts[7:0];

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
        tsa_c_ws2wa_reg <= 0;
        tsa_c_wa2nw_reg <= 0;
        tsa_c_nw2na_reg <= 0;
        tsa_c_na2c_reg <= 0;
        tsa_c_c2i_reg <= 0;
        symbol_mask_reg <= 0;
        ts2_symbol_mask_reg <= 0;
        to_tsg_rcv_link_num_vld_reg <= 0;
        to_tsg_rcv_link_num_reg <= 0;
        to_tsg_rcv_lane_num_vld_reg <= 0;
        to_tsg_rcv_lane_num_reg <= 0;
    end else begin
        state_reg <= state_nxt;
        cnt_reg <= cnt_nxt;
        target_reg <= target_nxt;
        ts_update_ack_reg <= ts_update_ack_nxt;  
        tsa_p_a2c_reg <= tsa_p_a2c_nxt; 
        tsa_p2c_reg <= tsa_p2c_nxt; 
        tsa_c_ws2wa_reg <= tsa_c_ws2wa_nxt;
        tsa_c_wa2nw_reg <= tsa_c_wa2nw_nxt;
        tsa_c_nw2na_reg <= tsa_c_nw2na_nxt;
        tsa_c_na2c_reg <= tsa_c_na2c_nxt;
        tsa_c_c2i_reg <= tsa_c_c2i_nxt;
        symbol_mask_reg <= symbol_mask_nxt;
        ts2_symbol_mask_reg <= ts2_symbol_mask_nxt;
        to_tsg_rcv_link_num_vld_reg <= to_tsg_rcv_link_num_vld_nxt;
        to_tsg_rcv_link_num_reg <= to_tsg_rcv_link_num_nxt;
        to_tsg_rcv_lane_num_vld_reg <= to_tsg_rcv_lane_num_vld_nxt;
        to_tsg_rcv_lane_num_reg <= to_tsg_rcv_lane_num_nxt;        
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
    default_val_init;
    case(state_reg)
        2'b00: begin // set TS expectations apart from lane/link info.
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
                    
                    symbol_mask_nxt = 128'hFF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF;

                end  else if(curr_state == `CFG ) begin //set expected TS1s

                    symbol_nxt[0]  = `COM;
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
                    case(curr_sub_st)
                        `CFG_LW_START: begin
                            symbol_mask_nxt = 128'hFF_00_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF; //symbol 1 needs to be checked.
                            symbol_nxt[2]  = `PADG12; //received                           
                        end
                        `CFG_LW_ACC: begin
                            symbol_nxt[1]  = to_tsg_rcv_link_num_reg; //received
                            symbol_mask_nxt = 128'hFF_FF_00_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF; //symbol 1 needs to be checked.
                        end
                        `CFG_LN_WAIT: begin
                            //keep mask unchanged as it is already set
                            //previously
                            symbol_mask_nxt = 128'hFF_FF_00_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF; //symbol 1 needs to be checked.
                            ts2_symbol_mask_nxt = 128'hFF_FF_00_FF_FF_FF_00_00_00_00_00_00_00_00_00_00;
                        end
                        `CFG_COMPLETE: begin
                            if(mode==`USP) begin
                                symbol_nxt[1]  = to_tsg_rcv_link_num_reg; //received
                                symbol_nxt[2]  = to_tsg_rcv_lane_num_reg;
                            end else begin
                                symbol_nxt[1]  = `LINK_NUM; //received
                                symbol_nxt[2]  = w_lane_num;
                            end
                            symbol_mask_nxt = 128'hFF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF_FF; //symbol 1 needs to be checked.
                        end
                        

                    endcase

                end 
            end
        end

        2'b01: begin //Receive ts from partner.
            ts_update_ack_nxt = 1'b0;            

            if(curr_state==`POLL) begin
                
                if(remote_ts_valid) begin
                    //cnt_nxt = remote_ts&symbol_mask_reg == ts_reg&symbol_mask_reg ? cnt_reg + 1: cnt_reg;
                    cnt_nxt = remote_ts == ts_reg ? cnt_reg + 1: cnt_reg;
                end

                if(ts_update & ~ts_update_ack_reg ) begin // this is new update
                    state_nxt = 2'b00;
                    ts_update_ack_nxt = 1'b1;  
                    cnt_nxt = 0;
                end else if(cnt_reg >= target_reg && to_tsa_ts_sent_enough || cnt_reg >= target_reg && target_reg <= `RX_NUM_CFG_GENERAL) begin 
                    tsa_p_a2c_nxt = {curr_state,curr_sub_st}=={`POLL,`POLL_ACTIVE} ;
                    tsa_p2c_nxt = {curr_state,curr_sub_st}=={`POLL,`POLL_CFG} ;
                    cnt_nxt = 0;
                   // tsa_c_ws2wa_nxt = {curr_state,curr_sub_st}=={`CFG,`CFG_LW_START};
                end

            end
                
            if(curr_state==`CFG) begin
                //CFG_LW_START:
                // DSP: The Transmitter sends TS1 Ordered Sets with selected Link numbers and sets Lane numbers to PAD on all the
                // active Downstream Lane
                // Transition:
                //If any Lanes first received at least one or more TS1 Ordered Sets with a Link and Lane number set to PAD, the
                //next state is Configuration.Linkwidth.Accept immediately after any of those same Downstream Lanes receive
                //two consecutive TS1 Ordered Sets with a non-PAD Link number that matches any of the transmitted Link
                //numbers, and with a Lane number set to PAD.
                
                // USP:The Transmitter sends out TS1 Ordered Sets with Link numbers and Lane numbers 
                // set to PAD on all the active Upstream Lanes
                // Transition
                //If any Lane receives two consecutive TS1 Ordered Sets with Link numbers that are different than PAD and Lane
                //number set to PAD, a single Link number is selected and Lane number set to PAD are transmitted on all Lanes
                //that both detected a Receiver and also received two consecutive TS1 Ordered Sets with Link numbers that are
                //different than PAD and Lane number set to PAD. Any left over Lanes that detected a Receiver during Detect
                //must transmit TS1 Ordered Sets with the Link and Lane number set to PAD. The next state is
                //Configuration.Linkwidth.Accept:

                case(curr_sub_st)
                    `CFG_LW_START: begin
                        if(mode==`DSP) begin //DSP RX expect in the beginning link = PAD, and later link = nonPAD, when nonPAD link is received, alerts FSM.
                            if(remote_ts_valid) begin // TS1 received
                             //   if (remote_ts&symbol_mask_reg == ts_reg&symbol_mask_reg) begin // Check if it's a valid TS1  
                                if (ts_reg_masked == remote_ts_masked) begin
                                    cnt_nxt = symbol1 ==`LINK_NUM ? cnt_reg + 1 : cnt_reg; //Check if the link num is expected
                                end
                            end

                            if(cnt_reg >= target_reg) begin // at least 2 echoed link num received
                                tsa_c_ws2wa_nxt = 1'b1;
                                cnt_nxt = 0;
                            end



                        end else begin //USP RX expect nonPAD link all the time, if it accepts, alert USP TX to echo nonPAD link.
                            
                            if(remote_ts_valid) begin
                               // if (remote_ts&symbol_mask_reg == ts_reg&symbol_mask_reg) begin
                                if (ts_reg_masked == remote_ts_masked) begin //
                                    cnt_nxt = cnt_reg + 1;
                                    to_tsg_rcv_link_num_nxt = symbol1;
                                    to_tsg_rcv_link_num_vld_nxt = 1'b1;
                                end
                            end
                            //to_tsg_rcv_link_num_vld_nxt = from_tsg_update_ack? 1'b0 : to_tsg_rcv_link_num_vld_reg;

                            if(cnt_reg >= target_reg) begin // at least 2 echoed link num received
                                tsa_c_ws2wa_nxt = 1'b1;
                                cnt_nxt = 0;

                            end

                            

                        end
                    end

                    `CFG_LW_ACC: begin
                        if(mode==`DSP) begin// transition to wait directly , state change is automatic.
                            tsa_c_wa2nw_nxt = 1'b1;
                            cnt_nxt = 0;

                        end else begin //USP RX expect non PAD lane and start sending back non PAD lane before transition. so transition here is receive nonpad lane
                            if(remote_ts_valid) begin
                               // if (remote_ts&symbol_mask_reg == ts_reg&symbol_mask_reg) begin
                                if (ts_reg_masked == remote_ts_masked) begin
                                    cnt_nxt = symbol2==w_lane_num? cnt_reg + 1 : cnt_nxt;
                                    to_tsg_rcv_lane_num_nxt = symbol2;
                                    to_tsg_rcv_lane_num_vld_nxt = symbol2==w_lane_num? 1'b1 : 1'b0;
                                end
                            end

                            if(cnt_reg >= target_reg) begin // at least 2 echoed link num received
                                tsa_c_wa2nw_nxt = 1'b1;
                                cnt_nxt = 0;
                            end


                        end

                    end

                    `CFG_LN_WAIT: begin
                        if(mode==`DSP) begin //DSP RX expect in the beginning link = PAD, and later link = nonPAD, when nonPAD link is received, alerts FSM.
                            if(remote_ts_valid) begin // TS1 received
                             //   if (remote_ts&symbol_mask_reg == ts_reg&symbol_mask_reg) begin // Check if it's a valid TS1  
                                if (ts_reg_masked == remote_ts_masked) begin
                                    cnt_nxt = symbol2 != `PADG12 ? cnt_reg + 1 : cnt_reg; //Check if the lane num is nonPAD/ different from what it received when first in the state 
                                end
                            end

                            if(cnt_reg >= target_reg) begin // at least 2 echoed lane num received
                                tsa_c_nw2na_nxt = 1'b1;
                                cnt_nxt = 0;
                            end
                                                       
                        end else begin //USP RX expect nonPAD link all the time, if it accepts, alert USP TX to echo nonPAD link.
                            
                            if(remote_ts_valid) begin // TS1 received
                             //   if (remote_ts&symbol_mask_reg == ts_reg&symbol_mask_reg) begin // Check if it's a valid TS1  
                                if (ts_reg_masked == remote_ts_masked) begin // else if(ts_reg == ) ADD TS2 here. USP.laneNum.wait can expect TS2 to enter accept.
                                    if (symbol2 != to_tsg_rcv_lane_num_reg) begin
                                        cnt_nxt = cnt_reg + 1; //Check if the lane num is different from the firstly received 
                                    end 
                                end else begin //else, it is receiving the same lane number, so expecting TS2s. at this point lane num won't change
                                    if (symbol2 == to_tsg_rcv_lane_num_reg) begin //check valid ts2 only when lane num match
                                        if((ts2_symbol_mask_reg & remote_ts) == (ts2_symbol_mask_reg & ts_reg) && symbol6 == `TS2_IDTFR && symbol7 == `TS2_IDTFR &&
                                            symbol8 == `TS2_IDTFR &&symbol9 == `TS2_IDTFR &&symbol10 == `TS2_IDTFR &&symbol11 == `TS2_IDTFR && symbol12 == `TS2_IDTFR &&
                                            symbol13 == `TS2_IDTFR && symbol14 == `TS2_IDTFR && symbol15 == `TS2_IDTFR) begin
                                            cnt_nxt = cnt_reg + 1;
                                        end
                                    end
                                end
                                
                            end

                            if(cnt_reg >= target_reg) begin // at least 2 echoed link num received
                                tsa_c_nw2na_nxt = 1'b1;
                                cnt_nxt = 0;
                            end
                            

                        end
                    end //end CFG_LN_WAIT

                    `CFG_LN_ACC: begin
                        if(mode==`DSP) begin // Expect same TS1 with same lane and link Num
                            if(remote_ts_valid) begin //
                                if (ts_reg_masked == remote_ts_masked) begin
                                    cnt_nxt = symbol2 == w_lane_num ? cnt_reg + 1 : cnt_reg; //Check if the lane num is the same as local lane num
                                end // else
                            end

                            if(cnt_reg >= target_reg ) begin // at least 2 echoed lane num received
                                tsa_c_na2c_nxt = 1'b1; // add back to lanenum.wait case
                                cnt_nxt = 0;
                            end
                                                       
                        end else begin //USP RX expect nonPAD link all the time, if it accepts, alert USP TX to echo nonPAD link.
                            
                            if(remote_ts_valid) begin 
                                if (ts_reg_masked == remote_ts_masked) begin // TS1, meaning lane num different
                                       if (symbol2 != to_tsg_rcv_lane_num_reg) begin
                                           cnt_nxt = cnt_reg + 1; //Check if the lane num is different from the firstly received 
                                       end 
                                end else begin //else, it is receiving the same lane number, so expecting TS2s. at this point lane num won't change
                                    if (symbol2 == to_tsg_rcv_lane_num_reg) begin //check valid ts2 only when lane num match
                                        if((ts2_symbol_mask_reg & remote_ts) == (ts2_symbol_mask_reg & ts_reg) && symbol6 == `TS2_IDTFR && symbol7 == `TS2_IDTFR &&
                                            symbol8 == `TS2_IDTFR &&symbol9 == `TS2_IDTFR &&symbol10 == `TS2_IDTFR &&symbol11 == `TS2_IDTFR && symbol12 == `TS2_IDTFR &&
                                            symbol13 == `TS2_IDTFR && symbol14 == `TS2_IDTFR && symbol15 == `TS2_IDTFR) begin
                                            cnt_nxt = cnt_reg + 1;
                                        end
                                    end
                                end
                            end
                            if(cnt_reg >= target_reg) begin // at least 2 echoed link num received
                                tsa_c_na2c_nxt = 1'b1;
                                cnt_nxt = 0;
                            end
                        end
                    end //end CFG_LN_WCC

                    `CFG_COMPLETE: begin
                        if(mode==`DSP) begin // Expect same TS1 with same lane and link Num
                            if(remote_ts_valid) begin //
                                if (ts_reg_masked == remote_ts_masked) begin
                                    cnt_nxt = cnt_reg + 1; //Check if the lane num is the same as local lane num
                                end // else
                            end

                            if(cnt_reg >= target_reg && to_tsa_ts_sent_enough) begin // at least 2 echoed lane num received
                                tsa_c_c2i_nxt = 1'b1; // add back to lanenum.wait case
                                cnt_nxt = 0;
                            end
                                                       
                        end else begin //USP RX expect nonPAD link all the time, if it accepts, alert USP TX to echo nonPAD link.
                            
                            if(remote_ts_valid) begin //
                                if (ts_reg_masked == remote_ts_masked) begin
                                    cnt_nxt = cnt_reg + 1; //Check if the lane num is the same as local lane num
                                end // else
                            end

                            if(cnt_reg >= target_reg && to_tsa_ts_sent_enough ) begin // at least 2 echoed lane num received
                                tsa_c_c2i_nxt = 1'b1; // add back to lanenum.wait case
                                cnt_nxt = 0;
                            end

                        end
                    end //end CFG_LN_WCC
                    
                    
                    
                        
                endcase

                if(ts_update & ~ts_update_ack_reg ) begin // this is new update
                    state_nxt = 2'b00;
                    ts_update_ack_nxt = 1'b1;  
                    cnt_nxt = 0;
                end 
                    
            end //if(curr_state==`CFG) begin



        end

    endcase

end

assign to_tsg_rcv_link_num_vld = to_tsg_rcv_link_num_vld_reg;
assign to_tsg_rcv_link_num = to_tsg_rcv_link_num_reg;

assign to_tsg_rcv_lane_num_vld = to_tsg_rcv_lane_num_vld_reg;
assign to_tsg_rcv_lane_num = to_tsg_rcv_lane_num_reg;

task default_val_init;
begin
    state_nxt = state_reg;
    target_nxt = target_reg;
    cnt_nxt = cnt_reg;
    ts_update_ack_nxt = ts_update_ack_reg;   
    tsa_p_a2c_nxt = tsa_p_a2c_reg;
    tsa_p2c_nxt = tsa_p2c_reg;
    tsa_c_ws2wa_nxt = tsa_c_ws2wa_reg;
    tsa_c_wa2nw_nxt = tsa_c_wa2nw_reg;
    tsa_c_nw2na_nxt = tsa_c_nw2na_reg;
    tsa_c_na2c_nxt = tsa_c_na2c_reg;   
    tsa_c_c2i_nxt = tsa_c_c2i_reg;   
    symbol_mask_nxt = symbol_mask_reg;
    ts2_symbol_mask_nxt = ts2_symbol_mask_reg;
    to_tsg_rcv_link_num_vld_nxt = to_tsg_rcv_link_num_vld_reg;
    to_tsg_rcv_link_num_nxt = to_tsg_rcv_link_num_reg;
    to_tsg_rcv_lane_num_vld_nxt = to_tsg_rcv_lane_num_vld_reg;
    to_tsg_rcv_lane_num_nxt = to_tsg_rcv_lane_num_reg;
    for(i=0;i<16;i=i+1) begin
        symbol_nxt[i] = symbol_reg[i]; 
    end
end
endtask


endmodule
            







