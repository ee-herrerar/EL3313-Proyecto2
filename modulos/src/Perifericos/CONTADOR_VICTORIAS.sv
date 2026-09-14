`timescale 1ns / 1ps

module CONTADOR_VICTORIAS (
    input  logic       clk,
    input  logic       reset,
    input  logic       GameWin,
    output logic [3:0] wins_tens,
    output logic [3:0] wins_ones
);

logic GameWinPrev;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        wins_tens   <= 4'd0;
        wins_ones   <= 4'd0;
        GameWinPrev <= 1'b0;
    end
    else begin
        GameWinPrev <= GameWin;

        if (GameWin && !GameWinPrev) begin
            if (wins_tens == 4'd9 && wins_ones == 4'd9) begin
                wins_tens <= 4'd0;
                wins_ones <= 4'd0;
            end
            else if (wins_ones == 4'd9) begin
                wins_ones <= 4'd0;
                wins_tens <= wins_tens + 1'b1;
            end
            else
                wins_ones <= wins_ones + 1'b1;
        end
    end
end

endmodule