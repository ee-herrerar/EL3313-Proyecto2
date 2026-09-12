`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.09.2026 17:32:35
// Design Name: 
// Module Name: Letra_Validacion_tb
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


module Letra_Validacion_tb(
    );

    // 1. Declaración de señales para conectar al DUT (Device Under Test)
    logic [95:0] palabra;
    logic [4:0]  largo;
    logic [7:0]  letra;
    
    logic        acierto;
    logic [11:0] coincidencias;
    logic [7:0]  direccion [0:11];
    logic [3:0]  numero_coincidencias;

    // 2. Instanciación del módulo bajo prueba
    Letra_Validacion dut (
        .palabra              (palabra),
        .largo                (largo),
        .letra                (letra),
        .acierto              (acierto),
        .coincidencias        (coincidencias),
        .direccion            (direccion),
        .numero_coincidencias (numero_coincidencias)
    );

    // 3. Proceso del estímulo principal
    initial begin
        // Formato para ver resultados en consola
        $display("\n=======================================================");
        $display("          INICIANDO TESTBENCH DE LetraVali             ");
        $display("=======================================================\n");

        // -------------------------------------------------------------
        // CASO 1: Palabra "C-A-S-A" (4 letras), probar letra 'A'
        // Esperado: 2 coincidencias (índices 1 y 3)
        // -------------------------------------------------------------
        palabra = {"C", "A", "S", "A", 64'b0}; // 4 caracteres + padding
        largo   = 5'd4;
        letra   = "A";
        #10;
        
        imprimir_resultados("CASO 1: Palabra 'CASA', buscar 'A'");
        assert(acierto == 1'b1) else $error("Error en CASO 1: Acierto debía ser 1");
        assert(numero_coincidencias == 4'd2) else $error("Error en CASO 1: Coincidencias debía ser 2");
        assert(coincidencias[1] == 1'b1 && coincidencias[3] == 1'b1) 
            else $error("Error en CASO 1: Máscara de coincidencias incorrecta");


        // -------------------------------------------------------------
        // CASO 2: Misma palabra "CASA", probar letra inexistente 'Z'
        // Esperado: 0 coincidencias, acierto = 0
        // -------------------------------------------------------------
        letra = "Z";
        #10;
        
        imprimir_resultados("CASO 2: Palabra 'CASA', buscar 'Z'");
        assert(acierto == 1'b0) else $error("Error en CASO 2: Acierto debía ser 0");
        assert(numero_coincidencias == 4'd0) else $error("Error en CASO 2: Coincidencias debía ser 0");


        // -------------------------------------------------------------
        // CASO 3: Palabra de 12 letras "A-B-R-A-C-A-D-A-B-R-A-S" (largo = 12), probar 'A'
        // Esperado: 5 coincidencias (índices 0, 3, 5, 7, 10)
        // -------------------------------------------------------------
        palabra = {"A", "B", "R", "A", "C", "A", "D", "A", "B", "R", "A", "S"};
        largo   = 5'd12;
        letra   = "A";
        #10;
        
        imprimir_resultados("CASO 3: Palabra 'ABRACADABRAS', buscar 'A'");
        assert(numero_coincidencias == 4'd5) else $error("Error en CASO 3: Coincidencias debía ser 5");


        // -------------------------------------------------------------
        // CASO 4: Misma palabra, pero recortando 'largo' a 3 letras
        // Aunque hay 'A' más adelante, solo debe evaluar los primeros 3 caracteres
        // Esperado: 1 coincidencia (índice 0)
        // -------------------------------------------------------------
        largo = 5'd3;
        #10;
        
        imprimir_resultados("CASO 4: 'ABRACADABRAS' recortada a largo=3, buscar 'A'");
        assert(numero_coincidencias == 4'd1) else $error("Error en CASO 4: Coincidencias debía ser 1 por el 'largo'");


        $display("=======================================================");
        $display("          PRUEBAS FINALIZADAS CON ÉXITO                ");
        $display("=======================================================\n");
        $finish;
    end

    // 4. Tarea auxiliar para formatear la salida en la consola de Vivado/XSim
    task automatic imprimir_resultados(string caso);
        $display("---- %s ----", caso);
        $display("Acierto: %b | Num Coincidencias: %0d", acierto, numero_coincidencias);
        $display("Máscara de coincidencias (11..0): %12b", coincidencias);
        $write("Direcciones calculadas para coincidencia: ");
        for (int j = 0; j < 12; j++) begin
            if (coincidencias[j]) begin
                $write("[Pos %0d: 0x%h] ", j, direccion[j]);
            end
        end
        $display("\n");
    endtask

endmodule
