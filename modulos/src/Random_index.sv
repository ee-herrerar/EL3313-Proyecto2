module Random_index #(parameter NUM_WORDS=50)(
        input logic clk,
        input logic rst,
        input logic enable,         // Señal Para Generar Nuevo Índice
        output logic word_index     // Índice Generado
    );
    Lfsr #(.OUTPUT_BITS(6)) lfsr (
        .clk(clk), 
        .rst(rst), 
        .op(op)
    );

    logic [5:0] random_value;
    

    always_ff @(posedge clk) begin
        if (rst) begin
            word_index = 6'd0;
        end
        else if (enable) begin
            random_value <= op;
        end

        if (op < 50) begin
            word_index = random_value;
        end
    end

endmodule
