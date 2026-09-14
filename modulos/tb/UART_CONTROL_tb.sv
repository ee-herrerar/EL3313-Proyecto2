`timescale 1ns / 1ps

module UART_Control_tb;

localparam integer SYS_CLK_FREQ = 100_000_000;
localparam integer BAUD_RATE    = 115_200;

localparam time CLK_PERIOD = 10ns;
localparam time BIT_TIME   = 8680ns;

logic clk;
logic reset;

logic rx;
logic tx;

logic [7:0] LetraUART;
logic NuevaLetra;

logic       mensaje_start;
logic [2:0] mensaje_id;
logic       mensaje_busy;
logic       mensaje_done;

logic [7:0] rx_byte;

integer errores;

UART_Control #(
    .SYS_CLK_FREQ(SYS_CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) dut (
    .clk(clk),
    .reset(reset),

    .rx(rx),
    .tx(tx),

    .LetraUART(LetraUART),
    .NuevaLetra(NuevaLetra),

    .mensaje_start(mensaje_start),
    .mensaje_id(mensaje_id),
    .mensaje_busy(mensaje_busy),
    .mensaje_done(mensaje_done)
);

always #(CLK_PERIOD/2) clk = ~clk;


// =========================================================
// ENVIO DE BYTE HACIA EL FPGA
// =========================================================

task automatic uart_send_byte(input logic [7:0] data);
    integer i;
    begin
        rx = 1'b0;
        #(BIT_TIME);

        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];
            #(BIT_TIME);
        end

        rx = 1'b1;
        #(BIT_TIME);
    end
endtask


// =========================================================
// RECEPCION DE BYTE TRANSMITIDO POR EL FPGA
// =========================================================

task automatic uart_receive_byte(output logic [7:0] data);
    integer i;
    begin
        @(negedge tx);

        #(BIT_TIME + BIT_TIME/2);

        for (i = 0; i < 8; i = i + 1) begin
            data[i] = tx;
            #(BIT_TIME);
        end

        if (tx !== 1'b1) begin
            $display("FAIL - Bit de parada incorrecto");
            errores = errores + 1;
        end
    end
endtask


// =========================================================
// BYTE ESPERADO SEGUN MENSAJE
// =========================================================

function automatic logic [7:0] expected_byte(
    input logic [2:0] id,
    input integer index
);

begin
    expected_byte = 8'h00;

    case (id)

        3'd0: begin // FACIL\r\n
            case (index)
                0: expected_byte = "F";
                1: expected_byte = "A";
                2: expected_byte = "C";
                3: expected_byte = "I";
                4: expected_byte = "L";
                5: expected_byte = 8'h0D;
                6: expected_byte = 8'h0A;
            endcase
        end

        3'd1: begin // DIFICIL\r\n
            case (index)
                0: expected_byte = "D";
                1: expected_byte = "I";
                2: expected_byte = "F";
                3: expected_byte = "I";
                4: expected_byte = "C";
                5: expected_byte = "I";
                6: expected_byte = "L";
                7: expected_byte = 8'h0D;
                8: expected_byte = 8'h0A;
            endcase
        end

        3'd2: begin // CORRECTA\r\n
            case (index)
                0: expected_byte = "C";
                1: expected_byte = "O";
                2: expected_byte = "R";
                3: expected_byte = "R";
                4: expected_byte = "E";
                5: expected_byte = "C";
                6: expected_byte = "T";
                7: expected_byte = "A";
                8: expected_byte = 8'h0D;
                9: expected_byte = 8'h0A;
            endcase
        end

        3'd3: begin // INCORRECTA\r\n
            case (index)
                0:  expected_byte = "I";
                1:  expected_byte = "N";
                2:  expected_byte = "C";
                3:  expected_byte = "O";
                4:  expected_byte = "R";
                5:  expected_byte = "R";
                6:  expected_byte = "E";
                7:  expected_byte = "C";
                8:  expected_byte = "T";
                9:  expected_byte = "A";
                10: expected_byte = 8'h0D;
                11: expected_byte = 8'h0A;
            endcase
        end

        3'd4: begin // GANASTE\r\n
            case (index)
                0: expected_byte = "G";
                1: expected_byte = "A";
                2: expected_byte = "N";
                3: expected_byte = "A";
                4: expected_byte = "S";
                5: expected_byte = "T";
                6: expected_byte = "E";
                7: expected_byte = 8'h0D;
                8: expected_byte = 8'h0A;
            endcase
        end

        3'd5: begin // PERDISTE\r\n
            case (index)
                0: expected_byte = "P";
                1: expected_byte = "E";
                2: expected_byte = "R";
                3: expected_byte = "D";
                4: expected_byte = "I";
                5: expected_byte = "S";
                6: expected_byte = "T";
                7: expected_byte = "E";
                8: expected_byte = 8'h0D;
                9: expected_byte = 8'h0A;
            endcase
        end

    endcase
end

endfunction


// =========================================================
// LARGO DE MENSAJE
// =========================================================

function automatic integer message_length(input logic [2:0] id);
begin
    case (id)
        3'd0: message_length = 7;
        3'd1: message_length = 9;
        3'd2: message_length = 10;
        3'd3: message_length = 12;
        3'd4: message_length = 9;
        3'd5: message_length = 10;
        default: message_length = 0;
    endcase
end
endfunction


// =========================================================
// PRUEBA DE MENSAJE COMPLETO
// =========================================================

task automatic test_message(input logic [2:0] id);
    integer i;
    integer largo;
    logic [7:0] recibido;

    begin
        largo = message_length(id);

        $display("PRUEBA MENSAJE ID = %0d", id);

        fork

            begin
                for (i = 0; i < largo; i = i + 1) begin
                    uart_receive_byte(recibido);

                    if (recibido === expected_byte(id, i)) begin
                        $display(
                            "PASS - Byte %0d = 0x%02h",
                            i,
                            recibido
                        );
                    end
                    else begin
                        $display(
                            "FAIL - Byte %0d: recibido 0x%02h, esperado 0x%02h",
                            i,
                            recibido,
                            expected_byte(id, i)
                        );
                        errores = errores + 1;
                    end
                end
            end

            begin
                @(posedge clk);
                mensaje_id    <= id;
                mensaje_start <= 1'b1;

                @(posedge clk);
                mensaje_start <= 1'b0;

                wait(mensaje_done);
                @(posedge clk);
            end

        join

        repeat (20) @(posedge clk);
    end
endtask


// =========================================================
// TEST PRINCIPAL
// =========================================================

initial begin

    clk           = 1'b0;
    reset         = 1'b1;
    rx            = 1'b1;
    mensaje_start = 1'b0;
    mensaje_id    = 3'd0;
    errores       = 0;

    repeat (10) @(posedge clk);
    reset = 1'b0;

    repeat (20) @(posedge clk);


    // =====================================================
    // PRUEBA RX - LETRA A
    // =====================================================

    $display("PRUEBA RX - LETRA A");

    fork
        uart_send_byte(8'h41);

        begin
            @(posedge NuevaLetra);

            if (LetraUART === 8'h41)
                $display("PASS - Letra A recibida");
            else begin
                $display(
                    "FAIL - Se esperaba A, recibido 0x%02h",
                    LetraUART
                );
                errores = errores + 1;
            end
        end
    join

    repeat (20) @(posedge clk);


    // =====================================================
    // PRUEBA RX - LETRA Z
    // =====================================================

    $display("PRUEBA RX - LETRA Z");

    fork
        uart_send_byte(8'h5A);

        begin
            @(posedge NuevaLetra);

            if (LetraUART === 8'h5A)
                $display("PASS - Letra Z recibida");
            else begin
                $display(
                    "FAIL - Se esperaba Z, recibido 0x%02h",
                    LetraUART
                );
                errores = errores + 1;
            end
        end
    join

    repeat (20) @(posedge clk);


    // =====================================================
    // PRUEBAS TX
    // =====================================================

    test_message(3'd0); // FACIL
    test_message(3'd1); // DIFICIL
    test_message(3'd2); // CORRECTA
    test_message(3'd3); // INCORRECTA
    test_message(3'd4); // GANASTE
    test_message(3'd5); // PERDISTE


    // =====================================================
    // RESULTADO FINAL
    // =====================================================

    if (errores == 0)
        $display("TODAS LAS PRUEBAS UART PASARON");
    else
        $display("PRUEBAS UART FINALIZADAS CON %0d ERRORES", errores);

    $finish;

end

endmodule