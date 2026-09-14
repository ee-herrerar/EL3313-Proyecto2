module UART_WRAPPER #(
    parameter SYS_CLK_FREQ = 100_000_000,
    parameter BAUD_RATE    = 115_200,
    parameter DBIT         = 8,
    parameter SB_TICK      = 16
)(
    input  logic            clk,
    input  logic            reset,

    input  logic            rx,
    output logic            tx,

    input  logic            tx_start,
    input  logic [DBIT-1:0] din,
    output logic [DBIT-1:0] dout,
    output logic            rx_done_tick,
    output logic            tx_done_tick
);

logic s_tick;

UART_GENERADOR_BAUDIOS #(
    .SYS_CLK_FREQ(SYS_CLK_FREQ),
    .BAUD_RATE(BAUD_RATE),
    .OVERSAMPLE(SB_TICK)
) baud_gen_inst (
    .clk(clk),
    .reset(reset),
    .s_tick(s_tick)
);

UART_RX #(
    .DBIT(DBIT),
    .SB_TICK(SB_TICK)
) uart_rx_inst (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .s_tick(s_tick),
    .rx_done_tick(rx_done_tick),
    .dout(dout)
);

UART_TX #(
    .DBIT(DBIT),
    .SB_TICK(SB_TICK)
) uart_tx_inst (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .s_tick(s_tick),
    .din(din),
    .tx_done_tick(tx_done_tick),
    .tx(tx)
);

endmodule