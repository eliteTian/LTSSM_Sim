`timescale 1ns/100ps
`include "define.v"
//Descripton:
//TS sender. It gets instructions from FSM or TSA to send TSs
//Logic is simple as it is only responsible for sending.
//Given a state and substate, it knows what to send.
//When FSM state/substate changes, it gets signal from FSM
//and update corresponding TSs to send.
//
//When TSA updates, it gets update from TSA to change TS field
//values.

module ts_gen(
    input                clk, //1GHz sys clock.
    input                rst,
    input[7:0]           ts_info, //state:[7:4] sub_state[3:0]
    input                ts_update,
    output               ts_update_ack,
    input                ts_stop,    
    input                speed,
    input                mode,
    input[3:0]           lane_num,
    output               to_tsa_ts_sent_enough,
    input[7:0]           from_tsa_rcv_link_num, //for usp
    input                from_tsa_rcv_link_num_vld,
    input[7:0]           from_tsa_rcv_lane_num, //for usp
    input                from_tsa_rcv_lane_num_vld,
    output               to_tsa_update_ack,
    output               ts_valid,
    output[127:0]        ts,
    input                ts_tx_fifo_full
    
);

//localparam COM = 8'hBC; //8'b101 11100
//localparam PADG12 = 8'hF7;
//such info is needed to generate right TS1s.
wire[3:0] curr_state = ts_info[7:4];
wire[3:0] curr_sub_st = ts_info[3:0];
//ts1/2 counter reg
reg[15:0] cnt_nxt, cnt_reg;
reg[15:0] target_nxt, target_reg;

integer i;


reg[1:0] state_nxt, state_reg;

reg[7:0] symbol_nxt[0:15];
reg[7:0] symbol_reg[0:15];
reg to_tsa_ts_sent_enough_nxt, to_tsa_ts_sent_enough_reg;
assign to_tsa_ts_sent_enough = to_tsa_ts_sent_enough_reg;

reg to_tsa_update_ack_nxt, to_tsa_update_ack_reg;
assign to_tsa_update_ack = to_tsa_update_ack_reg;

reg link_num_acquired_nxt, link_num_acquired_reg;
reg lane_num_acquired_nxt, lane_num_acquired_reg;



reg ts_valid_nxt, ts_valid_reg;
reg ts_update_ack_nxt, ts_update_ack_reg;
assign ts_update_ack = ts_update_ack_reg;

assign ts = ts_reg;
assign ts_valid = ts_valid_reg;

wire tsa_update = from_tsa_rcv_link_num_vld | from_tsa_rcv_lane_num_vld;

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

wire[5:0]   rate_support = `RATE_SUPPORT;
wire[7:0]   w_lane_num = {4'h0,lane_num};
    
//state machine sequential logic
always@(posedge clk) begin
    if(rst) begin
        state_reg <= 2'b00;
    end else begin
        state_reg <= state_nxt;
    end
end
//symbol update
//can possibly be made into pure comb logic 
//to consume less dffs
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

always@(posedge clk) begin
    if(rst) begin
        state_reg <= 2'b00;
        cnt_reg <= 0;
        target_reg <= 0;
        to_tsa_update_ack_reg <= 0;
        to_tsa_ts_sent_enough_reg <= 0;        
        ts_valid_reg <= 1'b0;
        ts_update_ack_reg <= 1'b0;
        link_num_acquired_reg <= 0;
        lane_num_acquired_reg <= 0;           
    end else begin
        state_reg <= state_nxt;
        cnt_reg <= cnt_nxt;
        target_reg <= target_nxt;
        to_tsa_update_ack_reg <= to_tsa_update_ack_nxt;
        to_tsa_ts_sent_enough_reg <= to_tsa_ts_sent_enough_nxt;        
        ts_valid_reg <= ts_valid_nxt ;
        ts_update_ack_reg <= ts_update_ack_nxt;
        link_num_acquired_reg <= link_num_acquired_nxt;
        lane_num_acquired_reg <= lane_num_acquired_nxt;        
    end
end

always@* begin
    state_nxt = state_reg;
    target_nxt = target_reg;
    ts_valid_nxt = ts_valid_reg; 
    to_tsa_ts_sent_enough_nxt = to_tsa_ts_sent_enough_reg;
    to_tsa_update_ack_nxt = to_tsa_update_ack_reg;    
    ts_update_ack_nxt = ts_update_ack_reg;
    link_num_acquired_nxt = link_num_acquired_reg;
    lane_num_acquired_nxt = lane_num_acquired_reg;
    for(i=0;i<16;i=i+1) begin
        symbol_nxt[i] = symbol_reg[i]; 
    end
    cnt_nxt = cnt_reg;
    case(state_reg)
        2'b00: begin // await TS signal
            if(ts_update || tsa_update) begin
                state_nxt = 2'b01; //transmit active
                ts_update_ack_nxt = ts_update;
                to_tsa_update_ack_nxt = tsa_update; //LinkNum Double Handshake: Phase4. Slave does deassertion in a new state by following req. It can be explicitly 0.
                to_tsa_ts_sent_enough_nxt = 1'b0;
                if(curr_state == `POLL ) begin
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
                    target_nxt     = curr_sub_st == `POLL_ACTIVE ? `TX_NUM_POLL_ACT2CFG: `TX_NUM_POLL2CFG ;
                end else if(curr_state == `CFG ) begin
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
                    target_nxt     = curr_sub_st == `CFG_COMPLETE ? `TX_NUM_CFG_C2I : `RX_NUM_CFG_GENERAL;
                    case(curr_sub_st)
                        `CFG_LW_START: begin
                            if(mode==`DSP) begin //DSP, send link = nonPAD;
                                symbol_nxt[1]  = `LINK_NUM;
                                symbol_nxt[2]  = `PADG12;
                            end else begin // USP, initially send link = PAD, then once received link = nonPAD, send nonPAD.
                                symbol_nxt[1]  = `PADG12;
                                symbol_nxt[2]  = `PADG12;

                            end
                        end
                        `CFG_LW_ACC: begin
                            if(mode==`DSP) begin //DSP, send lane = nonPAD;
                                symbol_nxt[1]  = `LINK_NUM;
                                symbol_nxt[2]  = w_lane_num; //each lane has it's own
                            end else begin
                                symbol_nxt[1]  =  link_num_acquired_reg? from_tsa_rcv_link_num: `PADG12;  //USP accept link num                       
                                symbol_nxt[2]  =  lane_num_acquired_reg? from_tsa_rcv_lane_num: `PADG12;  //USP accept lane num
                            end
                        end
                        `CFG_LN_WAIT: begin
                            if(mode==`USP) begin
                                symbol_nxt[1]  = `LINK_NUM;                                
                                symbol_nxt[2]  = lane_num_acquired_reg? from_tsa_rcv_lane_num: `PADG12;
                            end
                        end
                        `CFG_LN_ACC: begin
                            to_tsa_update_ack_nxt = 0;
                            //check state only, keep what is sending.


                        end

                        `CFG_COMPLETE: begin
                            // keep what is sending but only starting to do
                            // TS2s.
                            to_tsa_update_ack_nxt = 0;
                        end

                        `CFG_IDLE: begin
                            
                        end
                    
                    endcase


                end
            end
        end

        2'b01: begin //transmitting state
            ts_update_ack_nxt = 1'b0;
            to_tsa_update_ack_nxt = 1'b0;
            if(cnt_reg >= target_reg) begin //at least 1024 TS1s transmitted
                to_tsa_ts_sent_enough_nxt = 1'b1;
            end

            if(~ts_tx_fifo_full) begin
                ts_valid_nxt = 1'b1;
                cnt_nxt = cnt_reg + 1;
            end else begin
                ts_valid_nxt = 1'b0;
            end

            if(ts_update & ~ts_update_ack_reg  ) begin // there is new update
                state_nxt = 2'b00;
                ts_update_ack_nxt = 1'b1;
                cnt_nxt = 0;
                to_tsa_ts_sent_enough_nxt = 1'b0;
            end
            
            if( tsa_update & ~to_tsa_update_ack_reg ) begin
                state_nxt = 2'b00;
                to_tsa_update_ack_nxt = 1'b1; //LinkNum Double Handshake: Slave Ack, because it goes to the next state, next state it awaits req deassertion.
                cnt_nxt = 0;
                to_tsa_ts_sent_enough_nxt = 1'b0;
                link_num_acquired_nxt = from_tsa_rcv_link_num_vld ? 1'b1: link_num_acquired_reg ;
                lane_num_acquired_nxt = from_tsa_rcv_lane_num_vld ? 1'b1: lane_num_acquired_reg ;
            end

        end
        
    endcase

end



endmodule
