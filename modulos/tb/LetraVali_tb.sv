`timescale 1ns / 1ps

module LetraVali_tb;

    // Entradas
    logic [95:0] palabra;
    logic [4:0]  largo;
    logic [7:0]  letra;

    // Salidas
    logic        acierto;
    logic [11:0] coincidencias;

    integer errores;

    // Instancia del DUT
    LetraVali dut (
        .palabra(palabra),
        .largo(largo),
        .letra(letra),
        .acierto(acierto),
        .coincidencias(coincidencias)
    );


    // Tarea para comprobar cada caso
    task automatic comprobar_letra(
        input logic [95:0] palabra_test,
        input logic [4:0]  largo_test,
        input logic [7:0]  letra_test,
        input logic        acierto_esperado,
        input logic [11:0] coincidencias_esperadas
    );
    begin

        palabra = palabra_test;
        largo   = largo_test;
        letra   = letra_test;

        #10;

        if ((acierto === acierto_esperado) &&
            (coincidencias === coincidencias_esperadas)) begin

            $display(
                "PASS - letra=%c, acierto=%b, coincidencias=%b",
                letra,
                acierto,
                coincidencias
            );

        end
        else begin

            $display("ERROR - letra=%c", letra);

            $display(
                "  acierto obtenido       = %b",
                acierto
            );

            $display(
                "  acierto esperado       = %b",
                acierto_esperado
            );

            $display(
                "  coincidencias obtenidas = %b",
                coincidencias
            );

            $display(
                "  coincidencias esperadas = %b",
                coincidencias_esperadas
            );

            errores = errores + 1;

        end

    end
    endtask


    initial begin

        errores = 0;

        palabra = 96'b0;
        largo   = 5'b0;
        letra   = 8'b0;

        #10;


        // CASA - probar A
        comprobar_letra(
            {
                8'h43, 8'h41, 8'h53, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00,
                8'h00, 8'h00, 8'h00, 8'h00
            },
            5'd4,
            8'h41,              // A
            1'b1,
            12'b000000001010
        );


        // CASA - probar C
        comprobar_letra(
            {
                8'h43, 8'h41, 8'h53, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00,
                8'h00, 8'h00, 8'h00, 8'h00
            },
            5'd4,
            8'h43,              // C
            1'b1,
            12'b000000000001
        );


        // CASA - probar S
        comprobar_letra(
            {
                8'h43, 8'h41, 8'h53, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00,
                8'h00, 8'h00, 8'h00, 8'h00
            },
            5'd4,
            8'h53,              // S
            1'b1,
            12'b000000000100
        );


        // CASA - probar una letra que no existe
        comprobar_letra(
            {
                8'h43, 8'h41, 8'h53, 8'h41,
                8'h00, 8'h00, 8'h00, 8'h00,
                8'h00, 8'h00, 8'h00, 8'h00
            },
            5'd4,
            8'h5A,              // Z
            1'b0,
            12'b000000000000
        );


        // ELEFANTE - probar E
        comprobar_letra(
            {
                8'h45, 8'h4C, 8'h45, 8'h46,
                8'h41, 8'h4E, 8'h54, 8'h45,
                8'h00, 8'h00, 8'h00, 8'h00
            },
            5'd8,
            8'h45,              // E
            1'b1,
            12'b000010000101
        );


        // PROCESADOR - probar O
        comprobar_letra(
            {
                8'h50, 8'h52, 8'h4F, 8'h43, 8'h45,
                8'h53, 8'h41, 8'h44, 8'h4F, 8'h52,
                8'h00, 8'h00
            },
            5'd10,
            8'h4F,              // O
            1'b1,
            12'b000100000100
        );


        // CRIPTOGRAFIA - probar A
        comprobar_letra(
            {
                8'h43, 8'h52, 8'h49, 8'h50, 8'h54, 8'h4F,
                8'h47, 8'h52, 8'h41, 8'h46, 8'h49, 8'h41
            },
            5'd12,
            8'h41,              // A
            1'b1,
            12'b100100000000
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