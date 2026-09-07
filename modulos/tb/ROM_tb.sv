`timescale 1ns / 1ps

module ROM_tb;

    // Entradas
    logic [5:0] word_index;

    // Salidas
    logic [95:0] palabra;
    logic [4:0]  largo;

    integer errores;

    // Instancia de la ROM
    ROM dut (
        .word_index(word_index),
        .palabra(palabra),
        .largo(largo)
    );


    // Tarea para comprobar una palabra
    task automatic comprobar_palabra(
        input logic [5:0]  indice,
        input logic [95:0] palabra_esperada,
        input logic [4:0]  largo_esperado
    );
    begin

        word_index = indice;
        #10;

        if ((palabra === palabra_esperada) &&
            (largo === largo_esperado)) begin

            $display(
                "PASS - indice=%0d, largo=%0d",
                indice,
                largo
            );

        end
        else begin

            $display(
                "ERROR - indice=%0d",
                indice
            );

            $display(
                "  palabra obtenida = %h",
                palabra
            );

            $display(
                "  palabra esperada = %h",
                palabra_esperada
            );

            $display(
                "  largo obtenido   = %0d",
                largo
            );

            $display(
                "  largo esperado   = %0d",
                largo_esperado
            );

            errores = errores + 1;

        end

    end
    endtask


    initial begin

        errores = 0;
        word_index = 6'd0;

        #10;


        // MOTOR
        comprobar_palabra(
            6'd0,
            {
                8'h4D, 8'h4F, 8'h54, 8'h4F, 8'h52,
                8'h00, 8'h00, 8'h00, 8'h00,
                8'h00, 8'h00, 8'h00
            },
            5'd5
        );


        // CASA
        comprobar_palabra(
            6'd1,
            {
                8'h43, 8'h41, 8'h53, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00,
                8'h00, 8'h00, 8'h00, 8'h00
            },
            5'd4
        );


        // PROCESADOR
        comprobar_palabra(
            6'd17,
            {
                8'h50, 8'h52, 8'h4F, 8'h43, 8'h45,
                8'h53, 8'h41, 8'h44, 8'h4F, 8'h52,
                8'h00, 8'h00
            },
            5'd10
        );


        // PROTOCOLO
        comprobar_palabra(
            6'd49,
            {
                8'h50, 8'h52, 8'h4F, 8'h54, 8'h4F,
                8'h43, 8'h4F, 8'h4C, 8'h4F,
                8'h00, 8'h00, 8'h00
            },
            5'd9
        );


        // Indice invalido -> CRIPTOGRAFIA
        comprobar_palabra(
            6'd50,
            {
                8'h43, 8'h52, 8'h49, 8'h50, 8'h54, 8'h4F,
                8'h47, 8'h52, 8'h41, 8'h46, 8'h49, 8'h41
            },
            5'd12
        );


        // Otro indice invalido -> CRIPTOGRAFIA
        comprobar_palabra(
            6'd63,
            {
                8'h43, 8'h52, 8'h49, 8'h50, 8'h54, 8'h4F,
                8'h47, 8'h52, 8'h41, 8'h46, 8'h49, 8'h41
            },
            5'd12
        );


        // Resultado final
        if (errores == 0) begin
            $display("==================================");
            $display("TODAS LAS PRUEBAS PASARON");
            $display("==================================");
        end
        else begin
            $display("==================================");
            $display("PRUEBAS FALLIDAS: %0d", errores);
            $display("==================================");
        end


        $finish;

    end

endmodule