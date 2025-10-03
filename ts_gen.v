`timescale 1ns/100ps
`include "define.v"
module ts_gen(
    input                clk, //1GHz sys clock.
    input                rst,
    input[7:0]           ts_info, //state:[7:4] sub_state[3:0]
    input                ts_update,
    input                ts_stop,    
    input                speed,
    output               to_tsa_ts_sent_enough,
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
reg ts_valid_nxt, ts_valid_reg;

assign ts = ts_reg;
assign ts_valid = ts_valid_reg;


wire ts_reg = {
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
        to_tsa_ts_sent_enough_reg <= 0;
        ts_valid_reg <= 1'b0;
    end else begin
        state_reg <= state_nxt;
        cnt_reg <= cnt_nxt;
        target_reg <= target_nxt;
        to_tsa_ts_sent_enough_reg <= to_tsa_ts_sent_enough_nxt;
        ts_valid_reg <= ts_valid_nxt ;
    end
end

always@* begin
    state_nxt = state_reg;
    target_nxt = target_reg;
    ts_valid_nxt = ts_valid_reg;
    for(i=0;i<16;i=i+1) begin
        symbol_nxt[i] = symbol_reg[i]; 
    end
    cnt_nxt = cnt_reg;
    case(state_reg)
        2'b00: begin // await TS signal
            if(ts_update) begin
                state_nxt = 2'b01; //transmit active
                if(curr_state == `POLL ) begin
                    symbol_nxt[0]  = `COM;
                    symbol_nxt[1]  = `PADG12;
                    symbol_nxt[2]  = `PADG12;
                    symbol_nxt[3]  = 8'hFF;
                    symbol_nxt[4]  = {2'b00,rate_support};
                    symbol_nxt[5]  = 8'h00;
                    symbol_nxt[6]  = curr_sub_st == `POLL_ACTIVE ? `D10_2 : `D5_2;
                    symbol_nxt[7]  = curr_sub_st == `POLL_ACTIVE ? `D10_2 : `D5_2;
                    symbol_nxt[8]  = curr_sub_st == `POLL_ACTIVE ? `D10_2 : `D5_2;
                    symbol_nxt[9]  = curr_sub_st == `POLL_ACTIVE ? `D10_2 : `D5_2;
                    symbol_nxt[10] = curr_sub_st == `POLL_ACTIVE ? `D10_2 : `D5_2;
                    symbol_nxt[11] = curr_sub_st == `POLL_ACTIVE ? `D10_2 : `D5_2;
                    symbol_nxt[12] = curr_sub_st == `POLL_ACTIVE ? `D10_2 : `D5_2;
                    symbol_nxt[13] = curr_sub_st == `POLL_ACTIVE ? `D10_2 : `D5_2;
                    symbol_nxt[14] = curr_sub_st == `POLL_ACTIVE ? `D10_2 : `D5_2;
                    symbol_nxt[15] = curr_sub_st == `POLL_ACTIVE ? `D10_2 : `D5_2;
                    target_nxt     = curr_sub_st == `POLL_ACTIVE ? `NUM_POLL_ACT2CFG: `NUM_POLL2CFG ;
                end
            end
        end

        2'b01: begin //transmitting state
            if(cnt_reg >= target_reg) begin //at least 1024 TS1s transmitted
                to_tsa_ts_sent_enough_nxt = 1'b1;
            end
            if(~ts_tx_fifo_full) begin
                ts_valid_nxt = 1'b1;
                cnt_nxt = cnt_reg + 1;
            end else begin
                ts_valid_nxt = 1'b0;
            end

            if(ts_update) begin //better assert two cycles. yes.
                state_nxt = 2'b00;
            end
        end
        
    endcase

end



endmodule
