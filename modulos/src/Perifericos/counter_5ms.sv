`timescale 1ns / 1ps

module counter_5ms #(
    parameter integer COUNT_5MS = 500_000
)(
    input  logic clk,
    input  logic reset,
    input  logic active,
    output logic flag_5ms
);

logic [$clog2(COUNT_5MS)-1:0] counter;

always_ff @(posedge clk or posedge reset) begin
    if (reset)
        counter <= '0;
    else if (!active)
        counter <= '0;
    else if (counter == COUNT_5MS - 1)
        counter <= '0;
    else
        counter <= counter + 1'b1;
end

assign flag_5ms = active && (counter == COUNT_5MS - 1);

endmodule