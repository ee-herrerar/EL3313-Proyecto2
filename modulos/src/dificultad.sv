`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2026 21:19:07
// Design Name: 
// Module Name: dificultad
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module dificultad  
#(
    parameter int N  = 500_000_000 
)
(
    input logic clk,
    input logic reset,
    input logic inicio_seleccion,
    input logic stop,
    output logic dificulty_signal     // 0: FACIL, 1: DIFICIL
    );
      
    logic [28:0] counter;
    logic cuenta_activa;

    always_ff @(posedge clk) begin

        if (stop || reset) begin
            counter <= 0;
            cuenta_activa <= 1'b0;
            dificulty_signal <= 1'b0;
        end

        else if (inicio_seleccion) begin
            cuenta_activa <= 1'b1;
        end

        else if (cuenta_activa) begin
            if (counter == N) begin
                counter <= 0;
                dificulty_signal  <= ~dificulty_signal;
            end
            else begin
                counter <= counter + 1;
            end
        end
    end
endmodule

