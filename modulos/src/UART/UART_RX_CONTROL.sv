module UART_RX_CONTROL (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] uart_rdata,

    output logic [1:0]  uart_addr,
    output logic [31:0] uart_wdata,
    output logic        uart_write_enable,

    output logic [7:0]  LetraUART,
    output logic        NuevaLetra
);

typedef enum logic [1:0] {
    CHECK_RX,
    CAPTURE_RX,
    CLEAR_RX,
    NOTIFY_RX
} state_t;

state_t state, next_state;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state     <= CHECK_RX;
        LetraUART <= 8'd0;
    end
    else begin
        state <= next_state;

        if (state == CAPTURE_RX)
            LetraUART <= uart_rdata[7:0];
    end
end

always_comb begin
    next_state        = state;
    uart_addr         = 2'b10;
    uart_wdata        = 32'd0;
    uart_write_enable = 1'b0;
    NuevaLetra        = 1'b0;

    case (state)

        CHECK_RX: begin
            uart_addr = 2'b10;

            if (uart_rdata[1])
                next_state = CAPTURE_RX;
        end

        CAPTURE_RX: begin
            uart_addr = 2'b01;
            next_state = CLEAR_RX;
        end

        CLEAR_RX: begin
            uart_addr         = 2'b10;
            uart_wdata        = 32'd0;
            uart_write_enable = 1'b1;
            next_state        = NOTIFY_RX;
        end

        NOTIFY_RX: begin
            NuevaLetra = 1'b1;
            next_state = CHECK_RX;
        end

        default: begin
            next_state = CHECK_RX;
        end

    endcase
end

endmodule