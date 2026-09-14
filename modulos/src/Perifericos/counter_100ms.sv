`timescale 1ns / 1ps

module counter_100ms #(
    parameter int COUNT_100MS = 10_000_000
)(
    input  logic clk,
    input  logic reset,
    input  logic active,
    output logic flag_100ms
);

logic [$clog2(COUNT_100MS)-1:0] counter;

always_ff @(posedge clk or posedge reset) begin
    if (reset)
        counter <= '0;
    else if (!active)
        counter <= '0;
    else if (counter == COUNT_100MS - 1)
        counter <= '0;
    else
        counter <= counter + 1'b1;
end

assign flag_100ms = active && (counter == COUNT_100MS - 1);

endmodule