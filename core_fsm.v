module core_fsm(
    input               clk, //1GHz sys clock.
    input               rst,
    //DETECT STATE
    input[LANE_NUM-1:0]     elec_idle_break,
    output[LANE_NUM-1:0]    rx_det_seq_req,
    input[LANE_NUM-1:0]     rx_det_seq_ack,
    input[LANE_NUM-1:0]     rx_det_valid,
    //POLL STATE
    output[7:0]         ts_info, //state:[7:4] sub_state[3:0]
    output              ts_start,
    output[5:0]         speed,
    input[LANE_NUM-1:0] ts1_p2c,
    input[LANE_NUM-1:0] ts1_p2c,
    

    input               p2d,
    input               p2c,
    input               c2p,

);
reg[31:0] cnt;
reg pulse_set_reg; pulse_set_nxt;

localparam DETECT = 4'h0, POLL = 4'h1, CFG = 4'h2;
localparam D_ACTIVE = 2'b01, D_QUIET = 2'b00;
localparam POLL_ACTIVE = 2'b01, POLL_CFG = 2'b00, POLL_SPEED, POLL_COMP;

reg[3:0] state_nxt, state_reg;
reg[1:0] detect_subst_nxt, detect_subst_reg;
reg[1:0] poll_subst_nxt, poll_subst_reg;
reg[7:0] ts_info_nxt, ts_info_reg;

reg[31:0] lane0_info_reg, lane1_info_reg, lane2_info_reg, lane3_info_reg;
reg[31:0] lane0_info_nxt, lane1_info_nxt, lane2_info_nxt, lane3_info_nxt;


//core LTSSM state transition.
always@(posedge clk) begin
    if(rst) begin
        state_reg <= DETECT;
        detect_subst_reg <= D_QUIET;
    end else begin
        state_reg <= state_nxt;
        detect_subst_reg <= detect_subst_nxt;
    end
end
//signals updating
always@(posedge clk) begin
    if(rst) begin
        pulse_set_reg <= DETECT;
    end else begin
        pulse_set_reg <= pulse_set_nxt;
    end
end

/*state transition
Detect.quiet -> Detect.active : any lane has elec idle break. or 12ms timeout.
Detect.active -> Poll: 1.

*/
//

always@(posedge clk) begin
    if(rst) begin
        cnt <= 32'hffffffff;
    end else begin
        if(cnt_start_reg) begin
            cnt <= timeout_val_reg;
        end else if(cnt_rst) begin
            cnt <= 0;
        end else begin
            cnt <= cnt - 1;
        end
    end
end

wire timeout = ~&cnt;

always@*
    state_nxt = state_reg;
    cnt_start_nxt = cnt_start_reg;
    timeout_val_nxt = timeout_val_reg;
    pulse_set_nxt = pulse_set_reg;
    case(state_reg)
        DETECT: begin
            case(detect_subst_reg)
                D_QUIET: begin
                    if(~pulse_set_reg) begin //set counter, generate a single pulse to start counter
                        pulse_set_nxt = 1'b1;
                        cnt_start_nxt = 1'b1;
                        timeout_val_nxt = 'd12000000; //set as 12us to speed up sim;
                    end else begin
                        cnt_start_nxt = 1'b0;
                        pulse_set_nxt = 1'b0;
                    end

                    if(~|elec_idle_break || timeout) begin
                        detect_subst_nxt = D_ACTIVE;
                    end
                end
                D_ACTIVE: begin
                    if(~pulse_set_reg) begin //set counter, generate a single pulse to start counter
                        pulse_set_nxt = 1'b1;
                        cnt_start_nxt = 1'b1;
                        timeout_val_nxt = 'd12000; //set as 12us to speed up sim;
                    end else begin
                        cnt_start_nxt = 1'b0;
                        pulse_set_nxt = 1'b0;
                    end

                    rx_det_seq_req_nxt = &rx_det_seq_ack ?  4'h0: 4'hF;

                    if(&rx_det_valid) begin //case 1, all lanes detect a valid receiver
                      //  detect_subst_nxt = D_ACTIVE;
                        state_nxt = POLL;
                        detect_subst_nxt = D_QUIET;                        
                    end
                    if(timeout) begin
                        detect_subst_nxt = D_QUIET;
                    end
                end

        POLL: begin
            case(poll_subst_reg)
                POLL_ACTIVE: begin
                    if(~pulse_set_reg) begin //set timer, generate a single pulse to start counter
                        pulse_set_nxt = 1'b1;
                        cnt_start_nxt = 1'b1;
                        timeout_val_nxt = 'd24000000; //set as 12us to speed up sim;
                        ts_info_nxt = {4'b0001,4'b0000};
                        ts_start_nxt = 1'b1;
                    end else begin
                        cnt_start_nxt = 1'b0;
                        pulse_set_nxt = 1'b0;
                        ts_start_nxt = 1'b0;
                    end

                    if(&ts1_p2c) begin
                        poll_subst_nxt = POLL_CFG;
                    end
                    if(timeout) begin
                        state_nxt = DETECT;
                    end                    
                end
                POLL_CFG: begin
                    if(~pulse_set_reg) begin //set timer, generate a single pulse to start counter
                        pulse_set_nxt = 1'b1;
                        cnt_start_nxt = 1'b1;
                        timeout_val_nxt = 'd24000000; //set as 12us to speed up sim;
                        ts_info_nxt = {4'b0001,4'b0001};
                        ts_start_nxt = 1'b1;
                    end else begin
                        cnt_start_nxt = 1'b0;
                        pulse_set_nxt = 1'b0;
                        ts_start_nxt = 1'b0;
                    end

                    if(&ts1_p2c) begin
                        poll_subst_nxt = POLL_CFG;

                    end
                end
            endcase
        endcase

                    


            





