`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.09.2026 00:38:50
// Design Name: 
// Module Name: peripheral_lcd
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


module peripheral_lcd(
    input  logic        clk_i,
    input  logic        rst_i,
    input  logic        write_enable_i,
    input  logic [1:0]  addr_i,
    input  logic [31:0] wdata_i,

    // Conexiones directas a los pines físicos del LCD
    output logic        lcd_rs,
    output logic        lcd_rw,
    output logic [7:0]  lcd_db
);

    // Registros internos del periférico
    logic [31:0] control_reg;
    logic [31:0] data_reg;

    // Actualización de registros internos al escribir
    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            control_reg <= 32'd0;
            data_reg    <= 32'd0;
        end else if (write_enable_i) begin
            case (addr_i)
                2'b00: control_reg <= wdata_i; // Guarda registro de CONTROL
                2'b01: data_reg    <= wdata_i; // Guarda registro de DATOS
                default: ;
            endcase
        end
    end

    // Asignación continua de registros hacia los pines físicos
    assign lcd_rs = control_reg[1]; // Bit 1: RS (0 = Instrucción, 1 = Dato)
    assign lcd_rw = control_reg[0]; // Bit 0: RW
    assign lcd_db = data_reg[7:0];  // Bits 7:0: Bus de datos LCD

endmodule

