module ROM (
    input logic [5:0] word_index,
    output logic [95:0] palabra,
    output logic [4:0] largo 
);

//Implementacion de la ROM
always_comb begin
    case (word_index)

        6'd0: begin //MOTOR
            palabra = {
                8'h4D, 8'h4F, 8'h54, 8'h4F, 8'h52,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd5;
        end

        6'd1: begin //CASA
            palabra = {
                8'h43, 8'h41, 8'h53, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00,
                8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd4;
        end

        6'd2: begin //PERRO
            palabra = {
                8'h50, 8'h45, 8'h52, 8'h52, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd5;
        end

        6'd3: begin //GATO
            palabra = {
                8'h47, 8'h41, 8'h54, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd4;
        end

        6'd4: begin //PLANTA
            palabra = {
                8'h50, 8'h4C, 8'h41, 8'h4E, 8'h54, 8'h41, 
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd6;
        end

        6'd5: begin //ELEFANTE
            palabra = {
                8'h45, 8'h4C, 8'h45, 8'h46, 8'h41, 8'h4E, 8'h54, 8'h45,
                8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd8;
        end
        6'd6: begin //CABALLO
            palabra = {
                8'h43, 8'h41, 8'h42, 8'h41, 8'h4C, 8'h4C, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd7: begin //VENTANA
            palabra = {
                8'h56, 8'h45, 8'h4E, 8'h54, 8'h41, 8'h4E, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd8: begin //TECLADO
            palabra = {
                8'h54, 8'h45, 8'h43, 8'h4C, 8'h41, 8'h44, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd9: begin //CIRCUITO
            palabra = {
                8'h43, 8'h49, 8'h52, 8'h43, 8'h55, 8'h49, 8'h54, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd8;
        end

        6'd10: begin //MONITOR
            palabra = {
                8'h4D, 8'h4F, 8'h4E, 8'h49, 8'h54, 8'h4F, 8'h52,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd11: begin //SENSOR
            palabra = {
                8'h53, 8'h45, 8'h4E, 8'h53, 8'h4F, 8'h52,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd6;
        end

        6'd12: begin //ARDUINO
            palabra = {
                8'h41, 8'h52, 8'h44, 8'h55, 8'h49, 8'h4E, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd13: begin //VOLTAJE
            palabra = {
                8'h56, 8'h4F, 8'h4C, 8'h54, 8'h41, 8'h4A, 8'h45,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd14: begin //CORRIENTE
            palabra = {
                8'h43, 8'h4F, 8'h52, 8'h52, 8'h49, 8'h45, 8'h4E, 8'h54, 8'h45,
                8'h00, 8'h00, 8'h00
            };
            largo = 4'd9;
        end

        6'd15: begin //MEMORIA
            palabra = {
                8'h4D, 8'h45, 8'h4D, 8'h4F, 8'h52, 8'h49, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd16: begin //DIGITAL
            palabra = {
                8'h44, 8'h49, 8'h47, 8'h49, 8'h54, 8'h41, 8'h4C,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd17: begin //PROCESADOR
            palabra = {
                8'h50, 8'h52, 8'h4F, 8'h43, 8'h45, 8'h53, 8'h41, 8'h44, 8'h4F, 8'h52,
                8'h00, 8'h00
            };
            largo = 4'd10;
        end

        6'd18: begin //CONTROL
            palabra = {
                8'h43, 8'h4F, 8'h4E, 8'h54, 8'h52, 8'h4F, 8'h4C,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd19: begin //SISTEMA
            palabra = {
                8'h53, 8'h49, 8'h53, 8'h54, 8'h45, 8'h4D, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd20: begin //FPGA
            palabra = {
                8'h46, 8'h50, 8'h47, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd4;
        end

        6'd21: begin //TARJETA
            palabra = {
                8'h54, 8'h41, 8'h52, 8'h4A, 8'h45, 8'h54, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd22: begin //PANTALLA
            palabra = {
                8'h50, 8'h41, 8'h4E, 8'h54, 8'h41, 8'h4C, 8'h4C, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd8;
        end

        6'd23: begin //BOTON
            palabra = {
                8'h42, 8'h4F, 8'h54, 8'h4F, 8'h4E,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd5;
        end

        6'd24: begin //RELOJ
            palabra = {
                8'h52, 8'h45, 8'h4C, 8'h4F, 8'h4A,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd5;
        end

        6'd25: begin //MODULO
            palabra = {
                8'h4D, 8'h4F, 8'h44, 8'h55, 8'h4C, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd6;
        end

        6'd26: begin //REGISTRO
            palabra = {
                8'h52, 8'h45, 8'h47, 8'h49, 8'h53, 8'h54, 8'h52, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd8;
        end

        6'd27: begin //ENTRADA
            palabra = {
                8'h45, 8'h4E, 8'h54, 8'h52, 8'h41, 8'h44, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd28: begin //SALIDA
            palabra = {
                8'h53, 8'h41, 8'h4C, 8'h49, 8'h44, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd6;
        end

        6'd29: begin //LOGICA
            palabra = {
                8'h4C, 8'h4F, 8'h47, 8'h49, 8'h43, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd6;
        end

        6'd30: begin //CABLE
            palabra = {
                8'h43, 8'h41, 8'h42, 8'h4C, 8'h45,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd5;
        end

        6'd31: begin //PUERTO
            palabra = {
                8'h50, 8'h55, 8'h45, 8'h52, 8'h54, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd6;
        end

        6'd32: begin //SERIAL
            palabra = {
                8'h53, 8'h45, 8'h52, 8'h49, 8'h41, 8'h4C,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd6;
        end

        6'd33: begin //CODIGO
            palabra = {
                8'h43, 8'h4F, 8'h44, 8'h49, 8'h47, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd6;
        end

        6'd34: begin //ESTADO
            palabra = {
                8'h45, 8'h53, 8'h54, 8'h41, 8'h44, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd6;
        end

        6'd35: begin //SECUENCIA
            palabra = {
                8'h53, 8'h45, 8'h43, 8'h55, 8'h45, 8'h4E, 8'h43, 8'h49, 8'h41,
                8'h00, 8'h00, 8'h00
            };
            largo = 4'd9;
        end

        6'd36: begin //BINARIO
            palabra = {
                8'h42, 8'h49, 8'h4E, 8'h41, 8'h52, 8'h49, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd7;
        end

        6'd37: begin //PROGRAMA
            palabra = {
                8'h50, 8'h52, 8'h4F, 8'h47, 8'h52, 8'h41, 8'h4D, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd8;
        end

        6'd38: begin //DATOS
            palabra = {
                8'h44, 8'h41, 8'h54, 8'h4F, 8'h53,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd5;
        end

        6'd39: begin //ALGORITMO
            palabra = {
                8'h41, 8'h4C, 8'h47, 8'h4F, 8'h52, 8'h49, 8'h54, 8'h4D, 8'h4F,
                8'h00, 8'h00, 8'h00
            };
            largo = 4'd9;
        end

        6'd40: begin //FRECUENCIA
            palabra = {
                8'h46, 8'h52, 8'h45, 8'h43, 8'h55, 8'h45, 8'h4E, 8'h43, 8'h49, 8'h41,
                8'h00, 8'h00
            };
            largo = 4'd10;
        end

        6'd41: begin //RESISTOR
            palabra = {
                8'h52, 8'h45, 8'h53, 8'h49, 8'h53, 8'h54, 8'h4F, 8'h52,
                8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd8;
        end

        6'd42: begin //CAPACITOR
            palabra = {
                8'h43, 8'h41, 8'h50, 8'h41, 8'h43, 8'h49, 8'h54, 8'h4F, 8'h52,
                8'h00, 8'h00, 8'h00
            };
            largo = 4'd9;
        end

        6'd43: begin //INDUCTOR
            palabra = {
                8'h49, 8'h4E, 8'h44, 8'h55, 8'h43, 8'h54, 8'h4F, 8'h52,
                8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd8;
        end

        6'd44: begin //TRANSISTOR
            palabra = {
                8'h54, 8'h52, 8'h41, 8'h4E, 8'h53, 8'h49, 8'h53, 8'h54, 8'h4F, 8'h52,
                8'h00, 8'h00
            };
            largo = 4'd10;
        end

        6'd45: begin //DIODO
            palabra = {
                8'h44, 8'h49, 8'h4F, 8'h44, 8'h4F,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd5;
        end

        6'd46: begin //POTENCIA
            palabra = {
                8'h50, 8'h4F, 8'h54, 8'h45, 8'h4E, 8'h43, 8'h49, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd8;
        end

        6'd47: begin //IMPEDANCIA
            palabra = {
                8'h49, 8'h4D, 8'h50, 8'h45, 8'h44, 8'h41, 8'h4E, 8'h43, 8'h49, 8'h41,
                8'h00, 8'h00
            };
            largo = 4'd10;
        end

        6'd48: begin //ANTENA
            palabra = {
                8'h41, 8'h4E, 8'h54, 8'h45, 8'h4E, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
            };
            largo = 4'd6;
        end

        6'd49: begin //PROTOCOLO
            palabra = {
                8'h50, 8'h52, 8'h4F, 8'h54, 8'h4F, 8'h43, 8'h4F, 8'h4C, 8'h4F,
                8'h00, 8'h00, 8'h00
            };
            largo = 4'd9;
        end

        default: begin
            palabra = {
                8'h43, 8'h52, 8'h49, 8'h50, 8'h54, 8'h4F,
                8'h47, 8'h52, 8'h41, 8'h46, 8'h49, 8'h41
            };
            largo = 4'd12;
        end
        endcase
end
endmodule