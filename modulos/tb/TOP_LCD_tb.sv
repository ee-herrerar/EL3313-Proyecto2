`timescale 1ns / 1ps

module TOP_LCD_tb;

logic clk;
logic reset;
logic hardmode;
logic GameOn;
logic GameWin;
logic GameLose;
logic [2:0] Fallos;
logic [95:0] PalabraActual;
logic [4:0] LargoPalabra;
logic [11:0] LetrasReveladas;

logic lcd_rs;
logic lcd_rw;
logic lcd_e;
logic [7:0] lcd_data;

integer errores;
integer bus_data_writes;
integer bus_control_writes;
logic saw_clear;
logic saw_rs_data;
logic saw_rs_command;

TOP_LCD dut (
    .clk(clk),
    .reset(reset),
    .hardmode(hardmode),
    .GameOn(GameOn),
    .GameWin(GameWin),
    .GameLose(GameLose),
    .Fallos(Fallos),
    .PalabraActual(PalabraActual),
    .LargoPalabra(LargoPalabra),
    .LetrasReveladas(LetrasReveladas),
    .lcd_rs(lcd_rs),
    .lcd_rw(lcd_rw),
    .lcd_e(lcd_e),
    .lcd_data(lcd_data)
);

always #5 clk = ~clk;

always @(posedge clk) begin
    if (dut.write_enable) begin
        if (dut.addr == 2'b01)
            bus_data_writes = bus_data_writes + 1;

        if (dut.addr == 2'b00) begin
            bus_control_writes = bus_control_writes + 1;

            if (dut.wdata[2])
                saw_clear = 1'b1;

            if (dut.wdata[0] && dut.wdata[1])
                saw_rs_data = 1'b1;

            if (dut.wdata[0] && !dut.wdata[1])
                saw_rs_command = 1'b1;
        end
    end
end

function automatic logic [7:0] facil_char(input integer i);
begin
    case (i)
        0: facil_char = "F";
        1: facil_char = "A";
        2: facil_char = "C";
        3: facil_char = "I";
        4: facil_char = "L";
        default: facil_char = 8'h20;
    endcase
end
endfunction

function automatic logic [7:0] dificil_char(input integer i);
begin
    case (i)
        0: dificil_char = "D";
        1: dificil_char = "I";
        2: dificil_char = "F";
        3: dificil_char = "I";
        4: dificil_char = "C";
        5: dificil_char = "I";
        6: dificil_char = "L";
        default: dificil_char = 8'h20;
    endcase
end
endfunction

function automatic logic [7:0] intentos_char(
    input integer i,
    input logic [3:0] restantes
);
begin
    case (i)
        0: intentos_char = "I";
        1: intentos_char = "N";
        2: intentos_char = "T";
        3: intentos_char = "E";
        4: intentos_char = "N";
        5: intentos_char = "T";
        6: intentos_char = "O";
        7: intentos_char = "S";
        8: intentos_char = ":";
        9: intentos_char = 8'h30 + restantes;
        default: intentos_char = 8'h20;
    endcase
end
endfunction

function automatic logic [7:0] win_char(input integer i);
begin
    case (i)
        0: win_char = "G";
        1: win_char = "A";
        2: win_char = "N";
        3: win_char = "A";
        4: win_char = "S";
        5: win_char = "T";
        6: win_char = "E";
        default: win_char = 8'h20;
    endcase
end
endfunction

function automatic logic [7:0] lose_char(input integer i);
begin
    case (i)
        0: lose_char = "P";
        1: lose_char = "E";
        2: lose_char = "R";
        3: lose_char = "D";
        4: lose_char = "I";
        5: lose_char = "S";
        6: lose_char = "T";
        7: lose_char = "E";
        default: lose_char = 8'h20;
    endcase
end
endfunction

task automatic reset_system;
begin
    reset = 1'b1;
    GameOn = 1'b0;
    GameWin = 1'b0;
    GameLose = 1'b0;
    Fallos = 3'd0;
    LetrasReveladas = 12'b0;

    repeat (10) @(posedge clk);
    @(negedge clk);
    reset = 1'b0;
end
endtask

task automatic pulse_gameon;
begin
    @(negedge clk);
    GameOn = 1'b1;
    @(negedge clk);
    GameOn = 1'b0;
end
endtask

task automatic expect_lcd_byte(input logic [7:0] esperado);
    logic encontrado;
begin
    encontrado = 1'b0;

    while (!encontrado) begin
        @(posedge lcd_e);
        #1;

        if (lcd_rs) begin
            encontrado = 1'b1;

            if (lcd_data !== esperado) begin
                $display(
                    "FAIL - LCD recibido %c (%02h), esperado %c (%02h)",
                    lcd_data, lcd_data, esperado, esperado
                );
                errores = errores + 1;
            end
        end
    end
end
endtask

task automatic expect_facil;
    integer i;
    integer inicio;
begin
    inicio = errores;

    for (i = 0; i < 5; i = i + 1)
        expect_lcd_byte(facil_char(i));

    if (errores == inicio)
        $display("PASS - LCD muestra FACIL");
end
endtask

task automatic expect_dificil;
    integer i;
    integer inicio;
begin
    inicio = errores;

    for (i = 0; i < 7; i = i + 1)
        expect_lcd_byte(dificil_char(i));

    if (errores == inicio)
        $display("PASS - LCD muestra DIFICIL");
end
endtask

task automatic expect_word(
    input logic [7:0] c0,
    input logic [7:0] c1,
    input logic [7:0] c2,
    input logic [7:0] c3
);
    integer inicio;
begin
    inicio = errores;

    expect_lcd_byte(c0);
    expect_lcd_byte(c1);
    expect_lcd_byte(c2);
    expect_lcd_byte(c3);

    if (errores == inicio)
        $display(
            "PASS - Palabra LCD: %c%c%c%c",
            c0, c1, c2, c3
        );
end
endtask

task automatic expect_intentos(input logic [3:0] restantes);
    integer i;
    integer inicio;
begin
    inicio = errores;

    for (i = 0; i < 10; i = i + 1)
        expect_lcd_byte(intentos_char(i, restantes));

    if (errores == inicio)
        $display(
            "PASS - LCD muestra INTENTOS:%0d",
            restantes
        );
end
endtask

task automatic expect_ganaste;
    integer i;
    integer inicio;
begin
    inicio = errores;

    for (i = 0; i < 7; i = i + 1)
        expect_lcd_byte(win_char(i));

    if (errores == inicio)
        $display("PASS - LCD muestra GANASTE");
end
endtask

task automatic expect_perdiste;
    integer i;
    integer inicio;
begin
    inicio = errores;

    for (i = 0; i < 8; i = i + 1)
        expect_lcd_byte(lose_char(i));

    if (errores == inicio)
        $display("PASS - LCD muestra PERDISTE");
end
endtask

initial begin
    clk = 1'b0;
    reset = 1'b1;

    hardmode = 1'b0;
    GameOn = 1'b0;
    GameWin = 1'b0;
    GameLose = 1'b0;
    Fallos = 3'd0;

    PalabraActual = {
        8'h43, 8'h41, 8'h53, 8'h41,
        8'h00, 8'h00, 8'h00, 8'h00,
        8'h00, 8'h00, 8'h00, 8'h00
    };

    LargoPalabra = 5'd4;
    LetrasReveladas = 12'b0;

    errores = 0;
    bus_data_writes = 0;
    bus_control_writes = 0;
    saw_clear = 1'b0;
    saw_rs_data = 1'b0;
    saw_rs_command = 1'b0;

    $display("========================================");
    $display("PRUEBA NUEVO TOP_LCD");
    $display("========================================");

    reset_system();

    $display("PRUEBA SELECCION FACIL");
    expect_facil();

    $display("PRUEBA CAMBIO A DIFICIL");

    @(negedge clk);
    hardmode = 1'b1;

    expect_dificil();

    $display("PRUEBA REGRESO A FACIL");

    @(negedge clk);
    hardmode = 1'b0;

    expect_facil();

    $display("========================================");
    $display("PRUEBA INICIO DE JUEGO");
    $display("========================================");

    fork
        begin
            expect_word("-", "-", "-", "-");
            expect_intentos(4'd6);
        end
        pulse_gameon();
    join

    $display("========================================");
    $display("PRUEBA LETRA A");
    $display("========================================");

    @(negedge clk);
    LetrasReveladas = 12'b0000_0000_1010;

    expect_word("-", "A", "-", "A");
    expect_intentos(4'd6);

    $display("========================================");
    $display("PRUEBA FALLO");
    $display("========================================");

    @(negedge clk);
    Fallos = 3'd1;

    expect_word("-", "A", "-", "A");
    expect_intentos(4'd5);

    $display("========================================");
    $display("PRUEBA LETRA C");
    $display("========================================");

    @(negedge clk);
    LetrasReveladas = 12'b0000_0000_1011;

    expect_word("C", "A", "-", "A");
    expect_intentos(4'd5);

    $display("========================================");
    $display("PRUEBA LETRA S");
    $display("========================================");

    @(negedge clk);
    LetrasReveladas = 12'b0000_0000_1111;

    expect_word("C", "A", "S", "A");
    expect_intentos(4'd5);

    $display("========================================");
    $display("PRUEBA GANASTE");
    $display("========================================");

    @(negedge clk);
    GameWin = 1'b1;

    expect_ganaste();

    @(negedge clk);
    GameWin = 1'b0;

    repeat (10) @(posedge clk);

    $display("========================================");
    $display("PRUEBA BUS DE 32 BITS");
    $display("========================================");

    if (bus_data_writes > 0)
        $display(
            "PASS - Escrituras al registro DATOS: %0d",
            bus_data_writes
        );
    else begin
        $display("FAIL - No hubo escrituras al registro DATOS");
        errores = errores + 1;
    end

    if (bus_control_writes > 0)
        $display(
            "PASS - Escrituras al registro CONTROL: %0d",
            bus_control_writes
        );
    else begin
        $display("FAIL - No hubo escrituras al registro CONTROL");
        errores = errores + 1;
    end

    if (saw_clear)
        $display("PASS - Bit CLEAR utilizado por bus");
    else begin
        $display("FAIL - Nunca se utilizo CLEAR");
        errores = errores + 1;
    end

    if (saw_rs_data)
        $display("PASS - Bus genero escritura RS=1");
    else begin
        $display("FAIL - No se detecto escritura RS=1");
        errores = errores + 1;
    end

    if (saw_rs_command)
        $display("PASS - Bus genero escritura RS=0");
    else begin
        $display("FAIL - No se detecto escritura RS=0");
        errores = errores + 1;
    end

    $display("========================================");
    $display("PRUEBA PERDISTE");
    $display("========================================");

    reset_system();

    expect_facil();

    fork
        begin
            expect_word("-", "-", "-", "-");
            expect_intentos(4'd6);
        end
        pulse_gameon();
    join

    @(negedge clk);
    Fallos = 3'd6;
    GameLose = 1'b1;

    expect_perdiste();

    @(negedge clk);
    GameLose = 1'b0;

    $display("========================================");

    if (errores == 0)
        $display("TODAS LAS PRUEBAS DEL NUEVO TOP_LCD PASARON");
    else
        $display(
            "PRUEBAS TOP_LCD FINALIZADAS CON %0d ERRORES",
            errores
        );

    $display("========================================");

    $finish;
end

initial begin
    #700_000_000;

    $display("FAIL - TIMEOUT DE SIMULACION TOP_LCD");
    $finish;
end

endmodule