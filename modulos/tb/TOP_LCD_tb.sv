`timescale 1ns / 1ps

module TOP_LCD_tb;

logic clk;
logic reset;
logic hardmode;
logic GameOn;
logic GameWin;
logic GameLose;
logic [95:0] PalabraActual;
logic [4:0] LargoPalabra;
logic [11:0] LetrasReveladas;

logic lcd_rs;
logic lcd_rw;
logic lcd_e;
logic [7:0] lcd_data;

integer errores;

TOP_LCD dut (
    .clk(clk),
    .reset(reset),
    .hardmode(hardmode),
    .GameOn(GameOn),
    .GameWin(GameWin),
    .GameLose(GameLose),
    .PalabraActual(PalabraActual),
    .LargoPalabra(LargoPalabra),
    .LetrasReveladas(LetrasReveladas),
    .lcd_rs(lcd_rs),
    .lcd_rw(lcd_rw),
    .lcd_e(lcd_e),
    .lcd_data(lcd_data)
);

always #5 clk = ~clk;

function automatic integer message_length(input logic [2:0] id);
begin
    case (id)
        3'd0: message_length = 5;  // FACIL
        3'd1: message_length = 7;  // DIFICIL
        3'd2: message_length = 4;  // ----
        3'd3: message_length = 7;  // GANASTE
        3'd4: message_length = 8;  // PERDISTE
        default: message_length = 0;
    endcase
end
endfunction

function automatic logic [7:0] expected_byte(
    input logic [2:0] id,
    input integer index
);
begin
    expected_byte = 8'h00;

    case (id)
        3'd0: begin
            case (index)
                0: expected_byte = "F";
                1: expected_byte = "A";
                2: expected_byte = "C";
                3: expected_byte = "I";
                4: expected_byte = "L";
            endcase
        end

        3'd1: begin
            case (index)
                0: expected_byte = "D";
                1: expected_byte = "I";
                2: expected_byte = "F";
                3: expected_byte = "I";
                4: expected_byte = "C";
                5: expected_byte = "I";
                6: expected_byte = "L";
            endcase
        end

        3'd2: expected_byte = "-";

        3'd3: begin
            case (index)
                0: expected_byte = "G";
                1: expected_byte = "A";
                2: expected_byte = "N";
                3: expected_byte = "A";
                4: expected_byte = "S";
                5: expected_byte = "T";
                6: expected_byte = "E";
            endcase
        end

        3'd4: begin
            case (index)
                0: expected_byte = "P";
                1: expected_byte = "E";
                2: expected_byte = "R";
                3: expected_byte = "D";
                4: expected_byte = "I";
                5: expected_byte = "S";
                6: expected_byte = "T";
                7: expected_byte = "E";
            endcase
        end
    endcase
end
endfunction

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

task automatic expect_message(input logic [2:0] id);
    integer i;
    integer errores_inicio;
begin
    errores_inicio = errores;

    for (i = 0; i < message_length(id); i = i + 1)
        expect_lcd_byte(expected_byte(id, i));

    if (errores == errores_inicio)
        $display("PASS - Mensaje LCD ID %0d correcto", id);
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

task automatic reset_system;
begin
    reset = 1'b1;
    GameOn = 1'b0;
    GameWin = 1'b0;
    GameLose = 1'b0;
    LetrasReveladas = 12'b0;

    repeat (10) @(posedge clk);

    @(negedge clk);
    reset = 1'b0;
end
endtask

initial begin
    clk = 1'b0;
    reset = 1'b1;
    hardmode = 1'b0;
    GameOn = 1'b0;
    GameWin = 1'b0;
    GameLose = 1'b0;
    PalabraActual = {8'h43,8'h41,8'h53,8'h41,64'd0};
    LargoPalabra = 5'd4;
    LetrasReveladas = 12'b0;
    errores = 0;

    $display("========================================");
    $display("PRUEBA TOP LCD");
    $display("========================================");

    reset_system();

    $display("PRUEBA INICIALIZACION + FACIL");
    expect_message(3'd0);

    $display("PRUEBA CAMBIO A DIFICIL");
    @(negedge clk);
    hardmode = 1'b1;
    expect_message(3'd1);

    $display("PRUEBA INICIO DE PARTIDA");

    fork
        expect_message(3'd2);
        pulse_gameon();
    join

    $display("PASS - Guiones iniciales correctos");

    $display("PRUEBA LETRA A");

    @(negedge clk);
    LetrasReveladas = 12'b0000_0000_1010;

    expect_lcd_byte("A");
    expect_lcd_byte("A");

    $display("PASS - Ambas A fueron escritas");

    $display("PRUEBA LETRA C");

    @(negedge clk);
    LetrasReveladas = 12'b0000_0000_1011;

    expect_lcd_byte("C");

    $display("PASS - C escrita correctamente");

    $display("PRUEBA LETRA S");

    @(negedge clk);
    LetrasReveladas = 12'b0000_0000_1111;

    expect_lcd_byte("S");

    $display("PASS - S escrita correctamente");

    $display("PRUEBA GANASTE");

    @(negedge clk);
    GameWin = 1'b1;

    expect_message(3'd3);

    @(negedge clk);
    GameWin = 1'b0;

    $display("========================================");
    $display("PRUEBA PERDISTE");
    $display("========================================");

    reset_system();

    hardmode = 1'b0;
    PalabraActual = {8'h43,8'h41,8'h53,8'h41,64'd0};
    LargoPalabra = 5'd4;

    expect_message(3'd0);

    fork
        expect_message(3'd2);
        pulse_gameon();
    join

    @(negedge clk);
    GameLose = 1'b1;

    expect_message(3'd4);

    @(negedge clk);
    GameLose = 1'b0;

    $display("========================================");

    if (errores == 0)
        $display("TODAS LAS PRUEBAS DEL LCD PASARON");
    else
        $display("PRUEBAS LCD FINALIZADAS CON %0d ERRORES", errores);

    $display("========================================");

    $finish;
end

initial begin
    #300_000_000;

    $display("FAIL - TIMEOUT DE SIMULACION LCD");
    $finish;
end

endmodule