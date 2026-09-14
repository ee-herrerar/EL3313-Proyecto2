module UART_MM_ARBITER (
    input  logic        tx_busy,

    input  logic [1:0]  tx_addr,
    input  logic [31:0] tx_wdata,
    input  logic        tx_write_enable,

    input  logic [1:0]  rx_addr,
    input  logic [31:0] rx_wdata,
    input  logic        rx_write_enable,

    input  logic [31:0] uart_rdata,

    output logic [31:0] tx_rdata,
    output logic [31:0] rx_rdata,

    output logic [1:0]  uart_addr,
    output logic [31:0] uart_wdata,
    output logic        uart_write_enable
);

always_comb begin
    tx_rdata = uart_rdata;
    rx_rdata = uart_rdata;

    if (tx_busy) begin
        uart_addr         = tx_addr;
        uart_wdata        = tx_wdata;
        uart_write_enable = tx_write_enable;
    end
    else begin
        uart_addr         = rx_addr;
        uart_wdata        = rx_wdata;
        uart_write_enable = rx_write_enable;
    end
end

endmodule