`timescale 1ns / 1ps

module counter_200us #(
    parameter integer COUNT_200US = 20_000
)(
    input  logic clk,
    input  logic reset,
    input  logic active,
    output logic flag_200us
);

logic [$clog2(COUNT_200US)-1:0] counter;

always_ff @(posedge clk or posedge reset) begin
    if (reset)
        counter <= '0;
    else if (!active)
        counter <= '0;
    else if (counter == COUNT_200US - 1)
        counter <= '0;
    else
        counter <= counter + 1'b1;
end

assign flag_200us = active && (counter == COUNT_200US - 1);

endmodule