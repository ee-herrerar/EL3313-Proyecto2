module UART_CONTROL #(
    parameter integer SYS_CLK_FREQ = 100_000_000,
    parameter integer BAUD_RATE    = 115_200
)(
    input  logic       clk,
    input  logic       reset,

    input  logic       rx,
    output logic       tx,

    output logic [7:0] LetraUART,
    output logic       NuevaLetra,

    input  logic       mensaje_start,
    input  logic [2:0] mensaje_id,
    output logic       mensaje_busy,
    output logic       mensaje_done
);

logic [31:0] uart_rdata;
logic [31:0] uart_wdata;
logic [1:0] uart_addr;
logic uart_write_enable;

logic [1:0] rx_addr;
logic [31:0] rx_wdata;
logic rx_write_enable;
logic [31:0] rx_rdata_raw;
logic [31:0] rx_rdata_safe;

logic [1:0] tx_addr;
logic [31:0] tx_wdata;
logic tx_write_enable;
logic [31:0] tx_rdata;

logic tx_byte_start;
logic [7:0] tx_byte_data;
logic tx_byte_busy;
logic tx_byte_done;

logic rx_busy;
logic rx_pending;
logic mensaje_tx_busy;

UART_PERIPH #(
    .SYS_CLK_FREQ(SYS_CLK_FREQ),
    .BAUD_RATE(BAUD_RATE),
    .DBIT(8),
    .SB_TICK(16),
    .CPU_BITS(32)
) uart_periph_inst (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .tx(tx),
    .write_enable(uart_write_enable),
    .wdata_i(uart_wdata),
    .rdata_o(uart_rdata),
    .addr_i(uart_addr)
);

UART_RX_CONTROL rx_control_inst (
    .clk(clk),
    .reset(reset),
    .uart_rdata(rx_rdata_safe),
    .uart_addr(rx_addr),
    .uart_wdata(rx_wdata),
    .uart_write_enable(rx_write_enable),
    .LetraUART(LetraUART),
    .NuevaLetra(NuevaLetra)
);

UART_TX_CONTROL tx_control_inst (
    .clk(clk),
    .reset(reset),
    .start(tx_byte_start),
    .data_byte(tx_byte_data),
    .uart_rdata(tx_rdata),
    .uart_addr(tx_addr),
    .uart_wdata(tx_wdata),
    .uart_write_enable(tx_write_enable),
    .busy(tx_byte_busy),
    .done(tx_byte_done)
);

UART_MENSAJE mensaje_inst (
    .clk(clk),
    .reset(reset),
    .start(mensaje_start),
    .mensaje_id(mensaje_id),
    .tx_busy(mensaje_tx_busy),
    .tx_done(tx_byte_done),
    .tx_start(tx_byte_start),
    .tx_data(tx_byte_data),
    .busy(mensaje_busy),
    .done(mensaje_done)
);

UART_MM_ARBITER arbiter_inst (
    .tx_busy(tx_byte_busy),

    .tx_addr(tx_addr),
    .tx_wdata(tx_wdata),
    .tx_write_enable(tx_write_enable),

    .rx_addr(rx_addr),
    .rx_wdata(rx_wdata),
    .rx_write_enable(rx_write_enable),

    .uart_rdata(uart_rdata),

    .tx_rdata(tx_rdata),
    .rx_rdata(rx_rdata_raw),

    .uart_addr(uart_addr),
    .uart_wdata(uart_wdata),
    .uart_write_enable(uart_write_enable)
);

assign rx_busy =
    (rx_addr == 2'b01) ||
    rx_write_enable ||
    NuevaLetra;

assign rx_pending =
    (!tx_byte_busy) &&
    (!rx_busy) &&
    rx_rdata_raw[1];

assign rx_rdata_safe =
    tx_byte_busy ? 32'd0 : rx_rdata_raw;

assign mensaje_tx_busy =
    tx_byte_busy ||
    rx_busy ||
    rx_pending;

endmodule