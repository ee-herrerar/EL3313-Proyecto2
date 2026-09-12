`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.09.2026 18:28:00
// Design Name: 
// Module Name: Letra_Validacion
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


module Letra_Validacion(
    input logic [95:0] palabra,
    input logic [4:0] largo,
    input logic [7:0] letra,
    output logic acierto,
    output logic [11:0] coincidencias,
    output logic [7:0] direccion [0:11],
    output logic [3:0] numero_coincidencias
); 

// Asumiendo que el texto inicia en la dirección base 0x00 de la primera línea del LCD
localparam logic [7:0] LCD_BASE_ADDR = 8'h00; 

always_comb begin
    acierto = 1'b0;
    coincidencias = 12'b0;
    numero_coincidencias = 4'b0;
    
    for (int i = 0; i < 12; i++) begin
        // Inicializar dirección por defecto para evitar latches
        direccion[i] = 8'h00; 
        
        if (i < largo) begin
            if (palabra[95 - i*8 -: 8] == letra) begin
                coincidencias[i] = 1'b1;
                acierto = 1'b1;
                numero_coincidencias = numero_coincidencias + 1'b1;
                
                // Mapeo directo a dirección DDRAM del LCD
                direccion[i] = LCD_BASE_ADDR + i[7:0]; 
            end
        end
    end
end

endmodule

