`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.09.2026 00:40:29
// Design Name: 
// Module Name: peripheral_lcd_tb
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


module peripheral_lcd_tb(
 );
    // Señales de prueba (Inputs del DUT)
    logic        clk_i;
    logic        rst_i;
    logic        write_enable_i;
    logic [1:0]  addr_i;
    logic [31:0] wdata_i;

    // Salidas del DUT
    logic        lcd_rs;
    logic        lcd_rw;
    logic [7:0]  lcd_db;

    // Instancia del Módulo (DUT)
    peripheral_lcd dut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .write_enable_i(write_enable_i),
        .addr_i(addr_i),
        .wdata_i(wdata_i),
        .lcd_rs(lcd_rs),
        .lcd_rw(lcd_rw),
        .lcd_db(lcd_db)
  );

    // 1. Generación de Reloj (Periodo de 10ns -> 100 MHz)
    always #5 clk_i = ~clk_i;

    // 2. Secuencia de Pruebas
    initial begin
        // Inicialización de señales
        clk_i = 0;
        rst_i = 1;
        write_enable_i = 0;
        addr_i = 2'b00;
        wdata_i = 32'd0;

        // Reset inicial
        #20;
        rst_i = 0;
        $display("[%0t ns] --- Inicio de Pruebas: Peripheral Reset Liberado ---", $time);

        // --- PRUEBA 1: Verificar el Estado Inicial / Reset ---
        #10;
        if (lcd_rs === 1'b0 && lcd_rw === 1'b0 && lcd_db === 8'h00)
            $display("[%0t ns] PASO 1: Reset exitoso (RS=%b, RW=%b, DB=0x%h)", $time, lcd_rs, lcd_rw, lcd_db);
        else
            $error("[%0t ns] ERROR 1: Fallo en valores por defecto post-reset", $time);

        // --- PRUEBA 2: Escritura en Registro de CONTROL (addr = 2'b00) ---
        // Asignamos RS = 1 (bit 1) y RW = 0 (bit 0) -> 32'h0000_0002
        $display("\n[%0t ns] ---> PRUEBA 2: Escritura en Registro CONTROL (RS=1, RW=0)", $time);
        @(posedge clk_i);
        write_enable_i = 1'b1;
        addr_i         = 2'b00;
        wdata_i        = 32'h0000_0002;

        @(posedge clk_i);
        write_enable_i = 1'b0; // Deshabilitar escritura
        #1; // Pequeño margen para propagación de lógica combinacional
        if (lcd_rs === 1'b1 && lcd_rw === 1'b0)
            $display("[%0t ns] PASO 2: Control actualizado correctamente (RS=%b, RW=%b)", $time, lcd_rs, lcd_rw);
        else
            $error("[%0t ns] ERROR 2: RS/RW no coinciden. Obtenido RS=%b, RW=%b", $time, lcd_rs, lcd_rw);

        // --- PRUEBA 3: Escritura en Registro de DATOS (addr = 2'b01) ---
        // Enviamos el carácter ASCII 'H' (8'h48)
        $display("\n[%0t ns] ---> PRUEBA 3: Escritura en Registro DATOS (Byte=0x48)", $time);
        @(posedge clk_i);
        write_enable_i = 1'b1;
        addr_i         = 2'b01;
        wdata_i        = 32'h0000_0048;
        
        @(posedge clk_i);
        write_enable_i = 1'b0;
        #1;
        if (lcd_db === 8'h48)
            $display("[%0t ns] PASO 3: Dato de salida correcto (lcd_db = 0x%h)", $time, lcd_db);
        else
            $error("[%0t ns] ERROR 3: Dato no coincide. Esperado=0x48, Obtenido=0x%h", $time, lcd_db);

        // --- PRUEBA 4: Intentar escribir sin Enable (write_enable_i = 0) ---
        $display("\n[%0t ns] ---> PRUEBA 4: Bloqueo cuando write_enable_i = 0", $time);
        @(posedge clk_i);
        write_enable_i = 1'b0; // Deshabilitado
        addr_i         = 2'b01;
        wdata_i        = 32'h0000_00FF; // Intento escribir 0xFF

        @(posedge clk_i);
        #1;
        if (lcd_db === 8'h48) // Debe mantener el valor previo (0x48)
            $display("[%0t ns] PASO 4: Escritura bloqueada correctamente, dato se mantuvo en 0x%h", $time, lcd_db);
        else
            $error("[%0t ns] ERROR 4: El registro cambió a pesar de estar en write_enable_i=0 (lcd_db=0x%h)", $time, lcd_db);

        // --- PRUEBA 5: Dirección no mapeada (addr = 2'b10) ---
        $display("\n[%0t ns] ---> PRUEBA 5: Intento de escritura en dirección inválida (2'b10)", $time);
        @(posedge clk_i);
        write_enable_i = 1'b1;
        addr_i         = 2'b10;
        wdata_i        = 32'hFFFF_FFFF;

        @(posedge clk_i);
        write_enable_i = 1'b0;
        #1;
        if (lcd_db === 8'h48 && lcd_rs === 1'b1)
            $display("[%0t ns] PASO 5: Registros intactos tras escribir en dirección no válida", $time);
        else
            $error("[%0t ns] ERROR 5: Los registros fueron alterados por una dirección no mapeada", $time);

        #50;
        $display("\n[%0t ns] *** TODAS LAS PRUEBAS FINALIZADAS ***\n", $time);
        $finish;
    end


endmodule
