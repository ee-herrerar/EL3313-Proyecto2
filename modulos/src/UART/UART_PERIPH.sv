// Etapa Top con Mapeo de Memoria (MM) para UART
module UART_PERIPH #(
    parameter SYS_CLK_FREQ = 100_000_000,
    parameter BAUD_RATE    = 115_200,
    parameter DBIT         = 8,
    parameter SB_TICK      = 16,
    parameter CPU_BITS     = 32
)(
    input  logic                clk,
    input  logic                reset,

    input  logic                rx,
    output logic                tx,

    input  logic                write_enable,
    input  logic [CPU_BITS-1:0] wdata_i,
    output logic [CPU_BITS-1:0] rdata_o,
    input  logic [1:0]          addr_i
);

logic rx_done_tick_int;
logic tx_done_tick_int;
logic [DBIT-1:0] dout_int;

logic [DBIT-1:0] reg_tx_data;
logic [DBIT-1:0] reg_rx_data;
logic reg_send;
logic reg_new_rx;

UART_WRAPPER #(
    .SYS_CLK_FREQ(SYS_CLK_FREQ),
    .BAUD_RATE(BAUD_RATE),
    .DBIT(DBIT),
    .SB_TICK(SB_TICK)
) uart_wrapper_inst (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .tx(tx),
    .tx_start(reg_send),
    .din(reg_tx_data),
    .dout(dout_int),
    .rx_done_tick(rx_done_tick_int),
    .tx_done_tick(tx_done_tick_int)
);

always_comb begin
    case (addr_i)
        2'b00:   rdata_o = {{(CPU_BITS-DBIT){1'b0}}, reg_tx_data};
        2'b01:   rdata_o = {{(CPU_BITS-DBIT){1'b0}}, reg_rx_data};
        2'b10:   rdata_o = {{(CPU_BITS-2){1'b0}}, reg_new_rx, reg_send};
        default: rdata_o = '0;
    endcase
end

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        reg_tx_data <= '0;
        reg_rx_data <= '0;
        reg_send    <= 1'b0;
        reg_new_rx  <= 1'b0;
    end
    else begin
        if (write_enable && (addr_i == 2'b00))
            reg_tx_data <= wdata_i[DBIT-1:0];

        if (tx_done_tick_int)
            reg_send <= 1'b0;
        else if (write_enable && (addr_i == 2'b10))
            reg_send <= wdata_i[0];

        if (rx_done_tick_int) begin
            reg_rx_data <= dout_int;
            reg_new_rx  <= 1'b1;
        end
        else if (write_enable && (addr_i == 2'b10))
            reg_new_rx <= wdata_i[1];
    end
end

endmodule