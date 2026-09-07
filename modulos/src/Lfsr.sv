module Lfsr #(parameter OUTPUT_BITS = 6)(
    input logic clk,
    input logic rst,
    output logic [OUTPUT_BITS-1:0] op
);
    // Estado Interno del LFSR y Bit Realimentación
    logic [OUTPUT_BITS-1:0] lfsr_reg;
    logic feedback;
    
    assign feedback = lfsr_reg[OUTPUT_BITS-1]^lfsr_reg[OUTPUT_BITS-2];

    always_ff@(posedge clk) begin
        if (rst) begin
            // Reset a Estado Distinto de Cero: OUTPUT_BITS-1'd1
            lfsr_reg <= {{OUTPUT_BITS-1{1'b0}}, 1'b1};
        end
        else begin
            // Salida LFSR
            lfsr_reg <= {lfsr_reg[OUTPUT_BITS-2:0],feedback};
        end
    end
    assign op = lfsr_reg;
endmodule
