`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.09.2026 18:29:27
// Design Name: 
// Module Name: counter_enable
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


module counter_enable
 #(
      parameter int COUNT_1US  = 100,          // Ciclos para 1 microsegundo se enciende la señal de enable
      parameter int COUNT_ENABLE  = 160,         // Ciclos para mantener la señal de enable por 600ns
      parameter int COUNT_60US = 6000         // Ciclos para 60 microsegundos totales
  )
  (
      input  logic clk, reset, 
      input  logic active,
      
      output logic enable,
      output logic flag_60us
   );
 
   
    // Declaración de señales internas
    logic [15:0] counter; 
    
    // Cuerpo del módulo
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin 
            counter <= '0;
        end    
        else if (!active) begin 
            counter <= '0;
        end
        else if (counter >= COUNT_60US-1) begin 
        counter <= '0; 
        end
        else begin
        counter <= counter + 1'b1;
        end
    end
            
    // Lógica combinacional para generar las salidas basadas en el contador
    assign enable    = (counter >= COUNT_1US) && (counter < COUNT_ENABLE);
    assign flag_60us = (counter >= COUNT_60US - 1); 
   
endmodule
