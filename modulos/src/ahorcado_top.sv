module ahorcado_top #(
    parameter integer SYS_CLK_FREQ = 100_000_000,
    parameter integer BAUD_RATE    = 115_200
)(
    input  logic        clk_i,
    input  logic        rst_i,
    input  logic        btn_sel_i,
    input  logic        btn_ok_i,
    input  logic        uart_rx_i,
    output logic        uart_tx_o,
    output logic [5:0]  timer_seconds_o,
    output logic [2:0]  failed_attempts_o,
    output logic        hard_mode_o,
    output logic        game_win_o,
    output logic        game_lose_o,
    output logic [95:0] word_o,
    output logic [4:0]  word_length_o,
    output logic [11:0] revealed_positions_o,
    output logic [4:0]  remaining_letters_o,
    output logic [15:0] led_o,
    output logic        buzzer_o
);

    logic [1:0]  btn_inputs;
    logic [1:0]  btn_level;
    logic        new_rx_level;
    logic        rx_capture_pending;
    logic        rx_clear_pending;
    logic        letter_pending;
    logic        new_rx_clear;
    logic [7:0]  rx_data;
    logic [31:0] uart_rdata;
    logic [31:0] uart_wdata;
    logic [1:0]  uart_addr;
    logic        uart_write_enable;
    logic        nueva_letra;

    assign btn_inputs = {btn_ok_i, btn_sel_i};

    Debouncer #(
        .N(2)
    ) button_debouncer_inst (
        .clk(clk_i),
        .reset(rst_i),
        .btn_in(btn_inputs),
        .btn_out(btn_level)
    );

    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            rx_capture_pending <= 1'b0;
            rx_clear_pending   <= 1'b0;
            letter_pending     <= 1'b0;
            rx_data            <= 8'b0;
        end else begin
            if (new_rx_level && !rx_capture_pending && !rx_clear_pending) begin
                rx_capture_pending <= 1'b1;
            end

            if (rx_capture_pending) begin
                rx_data            <= uart_rdata[7:0];
                rx_capture_pending <= 1'b0;
                rx_clear_pending   <= 1'b1;
                letter_pending     <= 1'b1;
            end else if (rx_clear_pending) begin
                rx_clear_pending <= 1'b0;
            end

            if (letter_pending) begin
                letter_pending <= 1'b0;
            end
        end
    end

    assign nueva_letra       = letter_pending;
    assign new_rx_clear      = rx_clear_pending;
    assign uart_addr         = rx_capture_pending ? 2'b01 : 2'b10;
    assign uart_write_enable = new_rx_clear;
    assign uart_wdata        = 32'b0;
    assign new_rx_level      = uart_rdata[1];

    Uart_periph #(
        .SYS_CLK_FREQ(SYS_CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_periph_inst (
        .clk(clk_i),
        .reset(rst_i),
        .rx(uart_rx_i),
        .tx(uart_tx_o),
        .write_enable(uart_write_enable),
        .wdata_i(uart_wdata),
        .rdata_o(uart_rdata),
        .addr_i(uart_addr)
    );

    Top_Juego game_core_inst (
        .clk(clk_i),
        .RESET(rst_i),
        .BTN_SEL(btn_level[0]),
        .BTN_OK(btn_level[1]),
        .NuevaLetra(nueva_letra),
        .LetraUART(rx_data),
        .TimerS(timer_seconds_o),
        .Fallos(failed_attempts_o),
        .hardmode(hard_mode_o),
        .GameWin(game_win_o),
        .GameLose(game_lose_o),
        .PalabraActual(word_o),
        .LargoPalabra(word_length_o),
        .LetrasReveladas(revealed_positions_o),
        .LetrasRestantes(remaining_letters_o)
    );

    assign led_o = game_win_o ? 16'h0004 :
                   game_lose_o ? 16'h0004 :
                   (remaining_letters_o != 5'd0) ? 16'h0002 : 16'h0001;
    assign buzzer_o = 1'b0;

endmodule
