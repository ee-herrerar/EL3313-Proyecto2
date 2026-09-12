`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.09.2026 18:26:51
// Design Name: 
// Module Name: counter_100ms
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

module counter_100ms
    #(
        parameter int COUNT_100MS = 10_000_000                 // 10,000,000 ciclos para 100 ms
    )
    (
        input  logic clk,
        input  logic reset,
        input  logic active,      // Controla si el contador está en marcha o en 0
        output logic flag_100ms   // Pulso de 1 ciclo de reloj al completar los 100ms
    );

    logic [24:0] counter;

    // Lógica secuencial del contador
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            counter <= '0;
        end
        else if (!active) begin
            counter <= '0;
        end
        else if (counter >= COUNT_100MS - 1) begin
            counter <= '0;
        end
        else begin
            counter <= counter + 1'b1;
        end
    end

    // Bandera de salida: se enciende en el último ciclo de conteo solo si active está habilitado
    assign flag_100ms = active && (counter == COUNT_100MS - 1);
 
endmodule
