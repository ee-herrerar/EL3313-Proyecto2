`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.09.2026 00:55:25
// Design Name: 
// Module Name: mux_lcd
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


module mux_lcd(
    input  logic [1:0] sel,
// Modulo de dificultad
    input  logic [7:0] data_0,
    input  logic       start_0,
    input logic        clear_write_0,
    input logic        mode_0,

// Modulo de guiones 
    input  logic [7:0] data_1,
    input  logic       start_1,
    input logic        mode_1,

// Letras del juego
    input  logic [7:0] data_2,
    input  logic       start_2,
    input logic        mode_2,

// Resultado de ganar o perder
    input  logic [7:0] data_3,
    input  logic       start_3,
    input logic        clear_write_3,
    input logic        mode_3,

    output logic [7:0] data,
    output logic       start,
    output logic        clear_write,
    output logic        mode

);

    always_comb begin

        // Valores por defecto
        data  = 8'b0;
        start = 1'b0;

        case (sel)

            2'b00: begin
                data  = data_0;
                start = start_0;
                clear_write = clear_write_0;
                mode = mode_0;
            end

            2'b01: begin
                data  = data_1;
                start = start_1;
                mode = mode_1;
            end

            2'b10: begin
                data  = data_2;
                start = start_2;
                mode = mode_2;
            end

            2'b11: begin
                data  = data_3;
                start = start_3;
                clear_write = clear_write_3;
                mode = mode_3;
            end

        endcase
    end

endmodule
