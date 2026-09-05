`timescale 1ns / 1ps

module Timer_tb;

    // Entradas
    logic clk;
    logic rst;
    logic hardmode;
    logic GameOn;

    // Salidas
    logic [5:0] TimerS;
    logic       TimeOut;

    integer errores;
    integer i;


    // DUT
    Timer dut (
        .clk(clk),
        .rst(rst),
        .hardmode(hardmode),
        .GameOn(GameOn),
        .TimerS(TimerS),
        .TimeOut(TimeOut)
    );


    // Clock de 100 MHz
    // Periodo = 10 ns
    always #5 clk = ~clk;


    // --------------------------------------------------
    // Simular el paso de un segundo
    // --------------------------------------------------
    task automatic avanzar_segundo;
    begin

        // Llevar ambos contadores justo antes de completar 1 segundo
        force dut.ContadorCiclos = 17'd99999;
        force dut.ContadorMs     = 11'd999;

        @(posedge clk);
        #1;

        release dut.ContadorCiclos;
        release dut.ContadorMs;

        @(negedge clk);

    end
    endtask


    // --------------------------------------------------
    // Comprobar TimerS
    // --------------------------------------------------
    task automatic comprobar_timer(
        input logic [5:0] esperado
    );
    begin

        if (TimerS === esperado) begin
            $display(
                "PASS - TimerS = %0d",
                TimerS
            );
        end
        else begin
            $display(
                "ERROR - TimerS obtenido = %0d, esperado = %0d",
                TimerS,
                esperado
            );

            errores = errores + 1;
        end

    end
    endtask


    initial begin

        // Valores iniciales
        clk      = 1'b0;
        rst      = 1'b1;
        hardmode = 1'b0;
        GameOn   = 1'b0;

        errores = 0;


        // ==================================================
        // PRUEBA 1 - RESET
        // ==================================================

        $display("----------------------------------");
        $display("PRUEBA RESET");

        #20;
        rst = 1'b0;

        @(posedge clk);
        #1;

        comprobar_timer(6'd0);

        if (TimeOut === 1'b0) begin
            $display("PASS - TimeOut = 0 despues del reset");
        end
        else begin
            $display("ERROR - TimeOut deberia ser 0");
            errores = errores + 1;
        end


        // ==================================================
        // PRUEBA 2 - MODO FACIL
        // ==================================================

        $display("----------------------------------");
        $display("PRUEBA MODO FACIL");

        hardmode = 1'b0;

        // Pulso GameOn
        GameOn = 1'b1;

        @(posedge clk);
        #1;

        GameOn = 1'b0;

        @(posedge clk);
        #1;

        // Debe cargar 60 segundos
        comprobar_timer(6'd60);


        // Pasar 1 segundo
        avanzar_segundo();

        comprobar_timer(6'd59);


        // Pasar otro segundo
        avanzar_segundo();

        comprobar_timer(6'd58);


        // ==================================================
        // PRUEBA 3 - MODO DIFICIL
        // ==================================================

        $display("----------------------------------");
        $display("PRUEBA MODO DIFICIL");

        hardmode = 1'b1;

        // Nuevo pulso de GameOn
        GameOn = 1'b1;

        @(posedge clk);
        #1;

        GameOn = 1'b0;

        @(posedge clk);
        #1;

        // Debe cargar 45 segundos
        comprobar_timer(6'd45);


        // Pasar un segundo
        avanzar_segundo();

        comprobar_timer(6'd44);


        // ==================================================
        // PRUEBA 4 - TIMEOUT
        // ==================================================

        $display("----------------------------------");
        $display("PRUEBA TIMEOUT");

        // Ya pasamos de 45 a 44.
        // Faltan 44 segundos.
        for (i = 0; i < 44; i = i + 1) begin
            avanzar_segundo();
        end

        comprobar_timer(6'd0);

        if (TimeOut === 1'b1) begin
            $display("PASS - TimeOut activado correctamente");
        end
        else begin
            $display("ERROR - TimeOut deberia ser 1");
            errores = errores + 1;
        end


        // ==================================================
        // RESULTADO FINAL
        // ==================================================

        $display("----------------------------------");

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