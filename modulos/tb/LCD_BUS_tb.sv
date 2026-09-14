`timescale 1ns / 1ps

module LCD_BUS_tb;

logic clk;
logic reset;

logic op_start;
logic op_rs;
logic op_clear;
logic op_home;
logic [7:0] op_data;

logic op_busy;
logic op_done;

logic write_enable;
logic [1:0] addr;
logic [31:0] wdata;
logic [31:0] rdata;

logic lcd_busy;
logic lcd_done;

logic lcd_start;
logic lcd_rs_write;
logic lcd_clear;
logic lcd_home;
logic [7:0] lcd_data_byte;

logic flag_100ms;
logic flag_5ms;
logic flag_200us;
logic flag_60us;

logic str_100ms;
logic str_5ms;
logic str_200us;
logic str_60us;

logic lcd_rs;
logic lcd_rw;
logic [7:0] lcd_data;

integer errores;
integer data_writes;
integer control_writes;

logic saw_start;
logic saw_clear;
logic saw_home;
logic saw_rs0;
logic saw_rs1;
logic test_done;

LCD_CONTROL control_inst (
    .clk(clk),
    .rst(reset),
    .op_start(op_start),
    .op_rs(op_rs),
    .op_clear(op_clear),
    .op_home(op_home),
    .op_data(op_data),
    .op_busy(op_busy),
    .op_done(op_done),
    .write_enable(write_enable),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata)
);

LCD_PERIPH periph_inst (
    .clk(clk),
    .rst(reset),
    .write_enable(write_enable),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata),
    .lcd_busy(lcd_busy),
    .lcd_done(lcd_done),
    .start(lcd_start),
    .rs(lcd_rs_write),
    .clear(lcd_clear),
    .home(lcd_home),
    .data_byte(lcd_data_byte)
);

FSM_LCD_HD44780 fsm_inst (
    .clk(clk),
    .reset(reset),
    .flag_100ms(flag_100ms),
    .flag_5ms(flag_5ms),
    .flag_200us(flag_200us),
    .flag_60us(flag_60us),
    .start(lcd_start),
    .rs_write(lcd_rs_write),
    .clear_write(lcd_clear),
    .home_write(lcd_home),
    .data_byte(lcd_data_byte),
    .done(lcd_done),
    .busy(lcd_busy),
    .rs(lcd_rs),
    .rw(lcd_rw),
    .str_100ms(str_100ms),
    .str_5ms(str_5ms),
    .str_200us(str_200us),
    .str_60us(str_60us),
    .temp_reg(lcd_data)
);

always #5 clk = ~clk;

always_comb begin
    flag_100ms = str_100ms;
    flag_5ms   = str_5ms;
    flag_200us = str_200us;
    flag_60us  = str_60us;
end

always @(posedge clk) begin
    if (write_enable) begin
        if (addr == 2'b01)
            data_writes = data_writes + 1;

        if (addr == 2'b00) begin
            control_writes = control_writes + 1;

            if (wdata[0])
                saw_start = 1'b1;

            if (wdata[2])
                saw_clear = 1'b1;

            if (wdata[3])
                saw_home = 1'b1;

            if (wdata[0] && !wdata[1])
                saw_rs0 = 1'b1;

            if (wdata[0] && wdata[1])
                saw_rs1 = 1'b1;
        end
    end
end

task automatic reset_system;
begin
    reset    = 1'b1;
    op_start = 1'b0;
    op_rs    = 1'b0;
    op_clear = 1'b0;
    op_home  = 1'b0;
    op_data  = 8'h00;

    repeat (5) @(posedge clk);

    @(negedge clk);
    reset = 1'b0;

    repeat (20) @(posedge clk);
end
endtask

task automatic wait_fsm_ready;
begin
    while (lcd_busy)
        @(posedge clk);
end
endtask

task automatic start_operation(
    input logic rs,
    input logic clear_cmd,
    input logic home_cmd,
    input logic [7:0] data
);
begin
    wait (!op_busy);

    @(negedge clk);

    op_rs    = rs;
    op_clear = clear_cmd;
    op_home  = home_cmd;
    op_data  = data;
    op_start = 1'b1;

    @(negedge clk);
    op_start = 1'b0;
end
endtask

task automatic wait_operation_done;
begin
    wait (op_done);
    @(posedge clk);
end
endtask

task automatic test_busy_rejection;
    logic [7:0] data_anterior;
    logic rs_anterior;
    integer errores_inicio;
begin
    errores_inicio = errores;

    data_anterior = lcd_data_byte;
    rs_anterior   = lcd_rs_write;

    $display("PRUEBA RECHAZO DE ESCRITURA DURANTE BUSY");

    force lcd_busy = 1'b1;

    // Intento ilegal de modificar DATOS
    force write_enable = 1'b1;
    force addr          = 2'b01;
    force wdata         = 32'h0000_0058; // "X"

    @(posedge clk);
    #1;

    if (lcd_data_byte == data_anterior)
        $display("PASS - DATOS ignorado mientras BUSY=1");
    else begin
        $display(
            "FAIL - DATOS cambio durante BUSY: %02h -> %02h",
            data_anterior,
            lcd_data_byte
        );
        errores = errores + 1;
    end

    // Intento ilegal de START + CLEAR + HOME + cambio de RS
    force addr  = 2'b00;
    force wdata = 32'h0000_000D; // start=1, clear=1, home=1, rs=0

    @(posedge clk);
    #1;

    if (!lcd_start && !lcd_clear && !lcd_home)
        $display("PASS - START/CLEAR/HOME ignorados mientras BUSY=1");
    else begin
        $display(
            "FAIL - Operacion aceptada con BUSY=1: start=%b clear=%b home=%b",
            lcd_start,
            lcd_clear,
            lcd_home
        );
        errores = errores + 1;
    end

    if (lcd_rs_write == rs_anterior)
        $display("PASS - RS no cambia mientras BUSY=1");
    else begin
        $display(
            "FAIL - RS cambio durante BUSY: %b -> %b",
            rs_anterior,
            lcd_rs_write
        );
        errores = errores + 1;
    end

    release write_enable;
    release addr;
    release wdata;
    release lcd_busy;

    repeat (3) @(posedge clk);

    if (errores == errores_inicio)
        $display("PASS - LCD_PERIPH rechaza operaciones durante BUSY");
end
endtask

initial begin
    integer inicio_errores;

    clk = 1'b0;
    reset = 1'b1;

    op_start = 1'b0;
    op_rs = 1'b0;
    op_clear = 1'b0;
    op_home = 1'b0;
    op_data = 8'h00;

    errores = 0;
    test_done = 1'b0;

    data_writes = 0;
    control_writes = 0;

    saw_start = 1'b0;
    saw_clear = 1'b0;
    saw_home = 1'b0;
    saw_rs0 = 1'b0;
    saw_rs1 = 1'b0;

    $display("========================================");
    $display("PRUEBA LCD_CONTROL + LCD_PERIPH");
    $display("========================================");

    reset_system();

    wait_fsm_ready();

    $display("PRUEBA ESCRITURA DE DATO");

    inicio_errores = errores;

    start_operation(
        1'b1,
        1'b0,
        1'b0,
        "A"
    );

    wait_operation_done();

    if (lcd_data_byte == "A")
        $display("PASS - Registro DATOS conserva A");
    else begin
        $display(
            "FAIL - Registro DATOS = %02h",
            lcd_data_byte
        );
        errores = errores + 1;
    end

    if (saw_rs1)
        $display("PASS - Escritura de dato usa RS=1");
    else begin
        $display("FAIL - No se detecto RS=1");
        errores = errores + 1;
    end

    if (inicio_errores == errores)
        $display("PASS - Escritura de dato completada");

    $display("PRUEBA COMANDO NORMAL RS=0");

    start_operation(
        1'b0,
        1'b0,
        1'b0,
        8'h80
    );

    wait_operation_done();

    if (saw_rs0)
        $display("PASS - Comando normal usa RS=0");
    else begin
        $display("FAIL - No se detecto RS=0");
        errores = errores + 1;
    end

    $display("PRUEBA CLEAR");

    start_operation(
        1'b0,
        1'b1,
        1'b0,
        8'h00
    );

    wait_operation_done();

    if (saw_clear)
        $display("PASS - CLEAR fue escrito en CONTROL");
    else begin
        $display("FAIL - CLEAR no detectado");
        errores = errores + 1;
    end

    $display("PRUEBA HOME");

    start_operation(
        1'b0,
        1'b0,
        1'b1,
        8'h00
    );

    wait_operation_done();

    if (saw_home)
        $display("PASS - HOME fue escrito en CONTROL");
    else begin
        $display("FAIL - HOME no detectado");
        errores = errores + 1;
    end

    $display("PRUEBA BUSY / DONE");

    start_operation(
        1'b1,
        1'b0,
        1'b0,
        "B"
    );

    wait (op_busy);

    if (op_busy)
        $display("PASS - op_busy activo durante operacion");
    else begin
        $display("FAIL - op_busy no se activo");
        errores = errores + 1;
    end

    wait_operation_done();

    if (op_done)
        $display("PASS - op_done generado");
    else begin
        $display("FAIL - op_done no generado");
        errores = errores + 1;
    end

    $display("PRUEBA REGISTRO CONTROL/ESTADO");

    force addr = 2'b00;
    #1;

    if (rdata[8] == lcd_busy)
        $display("PASS - bit 8 refleja BUSY");
    else begin
        $display("FAIL - bit BUSY incorrecto");
        errores = errores + 1;
    end

    if (rdata[9] == 1'b1)
        $display("PASS - bit 9 refleja DONE");
    else begin
        $display("FAIL - bit DONE incorrecto");
        errores = errores + 1;
    end

    release addr;

    $display("PRUEBA REGISTRO DATOS");

    force addr = 2'b01;
    #1;

    if (rdata[7:0] == "B")
        $display("PASS - Registro DATOS retorna B");
    else begin
        $display(
            "FAIL - Registro DATOS retorna %02h",
            rdata[7:0]
        );
        errores = errores + 1;
    end

    release addr;

    $display("========================================");
    $display("PRUEBA PROTECCION BUSY");
    $display("========================================");

    test_busy_rejection();

    $display("========================================");
    $display("RESUMEN DE TRANSACCIONES");
    $display("========================================");

    $display("Escrituras DATOS   = %0d", data_writes);
    $display("Escrituras CONTROL = %0d", control_writes);

    if (saw_start)
        $display("PASS - START utilizado");
    else begin
        $display("FAIL - START nunca utilizado");
        errores = errores + 1;
    end

    if (saw_clear)
        $display("PASS - CLEAR utilizado");
    else begin
        $display("FAIL - CLEAR nunca utilizado");
        errores = errores + 1;
    end

    if (saw_home)
        $display("PASS - HOME utilizado");
    else begin
        $display("FAIL - HOME nunca utilizado");
        errores = errores + 1;
    end

    if (saw_rs0 && saw_rs1)
        $display("PASS - RS=0 y RS=1 utilizados");
    else begin
        $display("FAIL - No se probaron ambos valores de RS");
        errores = errores + 1;
    end

    $display("========================================");

    if (errores == 0)
        $display("TODAS LAS PRUEBAS DEL PERIFERICO LCD PASARON");
    else
        $display(
            "PRUEBAS LCD FINALIZADAS CON %0d ERRORES",
            errores
        );

    $display("========================================");

    test_done = 1'b1;
    $finish;
end

initial begin
    #10_000_000;

    if (!test_done) begin
        $display("FAIL - TIMEOUT DE SIMULACION LCD_BUS");
        $finish;
    end
end

endmodule