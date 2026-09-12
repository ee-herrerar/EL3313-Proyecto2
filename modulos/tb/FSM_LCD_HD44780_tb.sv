`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.09.2026 18:16:21
// Design Name: 
// Module Name: FSM_LCD_HD44780_tb
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


module FSM_LCD_HD44780_tb(
 );
 
    // =========================================================
    // SEÑALES
    // =========================================================

    logic clk;
    logic reset;

    logic flag_100ms;
    logic flag_5ms;
    logic flag_200us;
    logic flag_60us;

    logic start;
    logic [7:0] data_byte;
    logic [6:0] direccion [0:11];
    logic [3:0] coincidencias;
    logic mode;
    logic [3:0] clear_write;

    logic done;
    logic busy;
    logic rs;
    logic rw;

    logic str_60us;
    logic str_5ms;
    logic str_200us;
    logic str_100ms;

    logic [7:0] temp_reg;


    // =========================================================
    // DUT
    // =========================================================

    FSM_LCD_HD44780 dut (
        .clk(clk),
        .reset(reset),

        .flag_100ms(flag_100ms),
        .flag_5ms(flag_5ms),
        .flag_200us(flag_200us),
        .flag_60us(flag_60us),

        .start(start),
        .data_byte(data_byte),
        .direccion(direccion),
        .coincidencias(coincidencias),
        .mode(mode),
        .clear_write(clear_write),

        .done(done),
        .busy(busy),
        .rs(rs),
        .rw(rw),

        .str_60us(str_60us),
        .str_5ms(str_5ms),
        .str_200us(str_200us),
        .str_100ms(str_100ms),

        .temp_reg(temp_reg)
    );


    // =========================================================
    // CLOCK
    // 100 MHz -> periodo = 10 ns
    // =========================================================

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // =========================================================
    // TAREAS PARA GENERAR LOS FLAGS
    // =========================================================

    task pulse_100ms;
        begin
            @(negedge clk);
            flag_100ms = 1;
            @(negedge clk);
            flag_100ms = 0;
        end
    endtask


    task pulse_5ms;
        begin
            @(negedge clk);
            flag_5ms = 1;
            @(negedge clk);
            flag_5ms = 0;
        end
    endtask


    task pulse_200us;
        begin
            @(negedge clk);
            flag_200us = 1;
            @(negedge clk);
            flag_200us = 0;
        end
    endtask


    task pulse_60us;
        begin
            @(negedge clk);
            flag_60us = 1;
            @(negedge clk);
            flag_60us = 0;
        end
    endtask


    // =========================================================
    // INICIO DE LA SIMULACIÓN
    // =========================================================

    initial begin

        // -----------------------------------------------------
        // Valores iniciales
        // -----------------------------------------------------

        reset = 1;

        flag_100ms = 0;
        flag_5ms   = 0;
        flag_200us = 0;
        flag_60us  = 0;

        start = 0;
        data_byte = 8'h00;

        coincidencias = 4'd0;

        mode = 1'b1;

        clear_write = 4'b0000;


        // -----------------------------------------------------
        // DIRECCIONES DE PRUEBA
        //
        // Para esta prueba solo tendremos 3 coincidencias.
        //
        // direccion[0] = 5
        // direccion[1] = 12
        // direccion[2] = 20
        // -----------------------------------------------------

        direccion[0] = 7'd5;
        direccion[1] = 7'd12;
        direccion[2] = 7'd20;


        // Las demás no se utilizan en esta prueba
        direccion[3]  = 7'd0;
        direccion[4]  = 7'd0;
        direccion[5]  = 7'd0;
        direccion[6]  = 7'd0;
        direccion[7]  = 7'd0;
        direccion[8]  = 7'd0;
        direccion[9]  = 7'd0;
        direccion[10] = 7'd0;
        direccion[11] = 7'd0;


        // =====================================================
        // RESET
        // =====================================================

        #20;

        reset = 0;

        $display("");
        $display("==============================================");
        $display(" RESET LIBERADO");
        $display("==============================================");


        // =====================================================
        // INICIALIZACIÓN DEL LCD
        // =====================================================

        $display("");
        $display("========== INICIALIZACION ==========");


        // POWER_ON
        $display("[%0t ns] POWER_ON", $time);
        pulse_100ms;


        // FUNCTION_SET_I
        $display("[%0t ns] FUNCTION_SET_I", $time);

        if (temp_reg !== 8'b00110000)
            $display("ERROR: FUNCTION_SET_I");

        pulse_5ms;


        // FUNCTION_SET_II
        $display("[%0t ns] FUNCTION_SET_II", $time);

        if (temp_reg !== 8'b00110000)
            $display("ERROR: FUNCTION_SET_II");

        pulse_200us;


        // FUNCTION_SET_III
        $display("[%0t ns] FUNCTION_SET_III", $time);

        if (temp_reg !== 8'b00110000)
            $display("ERROR: FUNCTION_SET_III");

        pulse_200us;


        // FUNCTION_SET_CONFIGURATION
        $display("[%0t ns] FUNCTION_SET_CONFIGURATION", $time);

        if (temp_reg !== 8'b00111000)
            $display("ERROR: FUNCTION_SET_CONFIGURATION");

        pulse_60us;


        // DISPLAY_OFF
        $display("[%0t ns] DISPLAY_OFF", $time);

        if (temp_reg !== 8'b00001000)
            $display("ERROR: DISPLAY_OFF");

        pulse_60us;


        // CLEAR
        $display("[%0t ns] CLEAR", $time);

        if (temp_reg !== 8'b00000001)
            $display("ERROR: CLEAR");

        pulse_5ms;


        // ENTRY_MODE_SET
        $display("[%0t ns] ENTRY_MODE_SET", $time);

        if (temp_reg !== 8'b00000110)
            $display("ERROR: ENTRY_MODE_SET");

        pulse_60us;


        // DISPLAY_ON
        $display("[%0t ns] DISPLAY_ON", $time);

        if (temp_reg !== 8'b00001100)
            $display("ERROR: DISPLAY_ON");

        pulse_60us;


        // =====================================================
        // WAIT
        // =====================================================

        #1;

        $display("[%0t ns] WAIT_", $time);

        if (busy !== 1'b0)
            $display("ERROR: busy deberia ser 0");

        else
            $display("OK: LCD listo");


        // =====================================================
        // PRUEBA 1
        // ESCRITURA INCREMENTAL
        // =====================================================

        $display("");
        $display("========== ESCRITURA INCREMENTAL ==========");

        mode = 1'b1;
        data_byte = "A";

        @(negedge clk);
        start = 1;

        @(negedge clk);
        start = 0;


        // INC_RAN
        @(posedge clk);

        $display("[%0t ns] INC_RAN", $time);


        // WRITE_INC
        @(posedge clk);

        $display("[%0t ns] WRITE_INC", $time);

        if (rs !== 1'b1)
            $display("ERROR: RS deberia ser 1");

        if (temp_reg !== "A")
            $display("ERROR: dato incorrecto");

        else
            $display("OK: se envio A");


        pulse_60us;


        // Regreso a WAIT
        @(posedge clk);

        $display("[%0t ns] WAIT_", $time);


        // =====================================================
        // PRUEBA 2
        // ESCRITURA ALEATORIA
        // =====================================================

        $display("");
        $display("========== ESCRITURA ALEATORIA ==========");

        mode = 1'b0;

        // Tenemos solamente 3 coincidencias
        coincidencias = 4'd3;

        data_byte = "B";


        // START
        @(negedge clk);
        start = 1;

        @(negedge clk);
        start = 0;


        // -----------------------------------------------------
        // INC_RAN
        // -----------------------------------------------------

        @(posedge clk);

        $display("[%0t ns] INC_RAN -> RANDOM", $time);


        // -----------------------------------------------------
        // PRIMERA DIRECCIÓN
        //
        // coincount = 3
        // direccion[3-1] = direccion[2] = 20
        //
        // temp_reg = 80h | 14h = 94h
        // -----------------------------------------------------

        @(posedge clk);

        $display("[%0t ns] SET_ADDRESS", $time);

        $display("coincount = 3");
        $display("direccion[2] = %0d", direccion[2]);
        $display("temp_reg = %h", temp_reg);

        if (temp_reg !== 8'h94)
            $display("ERROR: se esperaba 94h");

        else
            $display("OK: direccion[2] correcta");


        pulse_60us;


        // -----------------------------------------------------
        // PRIMERA LETRA
        // -----------------------------------------------------

        @(posedge clk);

        $display("[%0t ns] WRITE_RAN", $time);

        if (temp_reg !== "B")
            $display("ERROR: dato incorrecto");

        else
            $display("OK: se envio B");


        pulse_60us;


        // -----------------------------------------------------
        // SEGUNDA DIRECCIÓN
        //
        // coincount = 2
        // direccion[1] = 12
        //
        // temp_reg = 80h | 0Ch = 8Ch
        // -----------------------------------------------------

        @(posedge clk);

        $display("[%0t ns] SET_ADDRESS", $time);

        $display("coincount = 2");
        $display("direccion[1] = %0d", direccion[1]);
        $display("temp_reg = %h", temp_reg);

        if (temp_reg !== 8'h8C)
            $display("ERROR: se esperaba 8Ch");

        else
            $display("OK: direccion[1] correcta");


        pulse_60us;


        // -----------------------------------------------------
        // SEGUNDA LETRA
        // -----------------------------------------------------

        @(posedge clk);

        $display("[%0t ns] WRITE_RAN", $time);

        if (temp_reg !== "B")
            $display("ERROR: dato incorrecto");

        else
            $display("OK: se envio B");


        pulse_60us;


        // -----------------------------------------------------
        // TERCERA DIRECCIÓN
        //
        // coincount = 1
        // direccion[0] = 5
        //
        // temp_reg = 80h | 05h = 85h
        // -----------------------------------------------------

        @(posedge clk);

        $display("[%0t ns] SET_ADDRESS", $time);

        $display("coincount = 1");
        $display("direccion[0] = %0d", direccion[0]);
        $display("temp_reg = %h", temp_reg);

        if (temp_reg !== 8'h85)
            $display("ERROR: se esperaba 85h");

        else
            $display("OK: direccion[0] correcta");


        pulse_60us;


        // -----------------------------------------------------
        // TERCERA LETRA
        // -----------------------------------------------------

        @(posedge clk);

        $display("[%0t ns] WRITE_RAN", $time);

        if (temp_reg !== "B")
            $display("ERROR: dato incorrecto");

        else
            $display("OK: se envio B");


        pulse_60us;


        // Debe regresar a WAIT
        @(posedge clk);

        $display("[%0t ns] WAIT_", $time);


        // =====================================================
        // PRUEBA 3
        // CLEAR_WRITE
        // =====================================================

        $display("");
        $display("========== CLEAR_WRITE ==========");


        @(negedge clk);
        clear_write = 4'b0001;

        @(negedge clk);
        clear_write = 4'b0000;


        @(posedge clk);

        $display("[%0t ns] CLEAR_WRITE", $time);

        if (temp_reg !== 8'b00000001)
            $display("ERROR: CLEAR_WRITE incorrecto");

        else
            $display("OK: comando CLEAR");


        pulse_5ms;


        @(posedge clk);

        $display("[%0t ns] WAIT_", $time);


        // =====================================================
        // FIN
        // =====================================================

        $display("");
        $display("==============================================");
        $display(" SIMULACION TERMINADA");
        $display("==============================================");

        #20;

        $finish;

    end
 
endmodule
