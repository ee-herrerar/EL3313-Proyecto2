module Random_index #(
    parameter NUM_WORDS = 50
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       enable,
    input  logic       hardmode,
    output logic [5:0] word_index
);

logic [5:0] op;
logic [5:0] easy_select;
logic [5:0] hard_select;
logic [5:0] next_index;

Lfsr #(
    .OUTPUT_BITS(6)
) lfsr (
    .clk(clk),
    .rst(rst),
    .op(op)
);

always_comb begin
    if (op == 6'd0)
        easy_select = 6'd1;
    else if (op <= NUM_WORDS)
        easy_select = op;
    else
        easy_select = op - NUM_WORDS;

    if (op == 6'd0)
        hard_select = 6'd1;
    else if (op <= 6'd40)
        hard_select = op;
    else
        hard_select = op - 6'd40;
end

always_comb begin
    if (!hardmode) begin
        next_index = easy_select - 6'd1;
    end
    else begin
        case (hard_select)
            6'd1:  next_index = 6'd4;   // PLANTA
            6'd2:  next_index = 6'd5;   // ELEFANTE
            6'd3:  next_index = 6'd6;   // CABALLO
            6'd4:  next_index = 6'd7;   // VENTANA
            6'd5:  next_index = 6'd8;   // TECLADO
            6'd6:  next_index = 6'd9;   // CIRCUITO
            6'd7:  next_index = 6'd10;  // MONITOR
            6'd8:  next_index = 6'd11;  // SENSOR
            6'd9:  next_index = 6'd12;  // ARDUINO
            6'd10: next_index = 6'd13;  // VOLTAJE
            6'd11: next_index = 6'd14;  // CORRIENTE
            6'd12: next_index = 6'd15;  // MEMORIA
            6'd13: next_index = 6'd16;  // DIGITAL
            6'd14: next_index = 6'd17;  // PROCESADOR
            6'd15: next_index = 6'd18;  // CONTROL
            6'd16: next_index = 6'd19;  // SISTEMA
            6'd17: next_index = 6'd21;  // TARJETA
            6'd18: next_index = 6'd22;  // PANTALLA
            6'd19: next_index = 6'd25;  // MODULO
            6'd20: next_index = 6'd26;  // REGISTRO
            6'd21: next_index = 6'd27;  // ENTRADA
            6'd22: next_index = 6'd28;  // SALIDA
            6'd23: next_index = 6'd29;  // LOGICA
            6'd24: next_index = 6'd31;  // PUERTO
            6'd25: next_index = 6'd32;  // SERIAL
            6'd26: next_index = 6'd33;  // CODIGO
            6'd27: next_index = 6'd34;  // ESTADO
            6'd28: next_index = 6'd35;  // SECUENCIA
            6'd29: next_index = 6'd36;  // BINARIO
            6'd30: next_index = 6'd37;  // PROGRAMA
            6'd31: next_index = 6'd39;  // ALGORITMO
            6'd32: next_index = 6'd40;  // FRECUENCIA
            6'd33: next_index = 6'd41;  // RESISTOR
            6'd34: next_index = 6'd42;  // CAPACITOR
            6'd35: next_index = 6'd43;  // INDUCTOR
            6'd36: next_index = 6'd44;  // TRANSISTOR
            6'd37: next_index = 6'd46;  // POTENCIA
            6'd38: next_index = 6'd47;  // IMPEDANCIA
            6'd39: next_index = 6'd48;  // ANTENA
            6'd40: next_index = 6'd49;  // PROTOCOLO
            default: next_index = 6'd4;
        endcase
    end
end

always_ff @(posedge clk) begin
    if (rst)
        word_index <= 6'd0;
    else if (enable)
        word_index <= next_index;
end

endmodule