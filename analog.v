`timescale 1ns/100ps
module delay_shim #(
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

