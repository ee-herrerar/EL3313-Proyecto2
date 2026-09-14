module UART_TX_CONTROL (
    input  logic        clk,
    input  logic        reset,

    input  logic        start,
    input  logic [7:0]  data_byte,

    input  logic [31:0] uart_rdata,

    output logic [1:0]  uart_addr,
    output logic [31:0] uart_wdata,
    output logic        uart_write_enable,

    output logic        busy,
    output logic        done
);

typedef enum logic [2:0] {
    IDLE,
    WRITE_DATA,
    START_TX,
    WAIT_START,
    WAIT_DONE,
    FINISH
} state_t;

state_t state, next_state;

logic [7:0] data_reg;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        state    <= IDLE;
        data_reg <= 8'd0;
    end
    else begin
        state <= next_state;

        if (state == IDLE && start)
            data_reg <= data_byte;
    end
end

always_comb begin
    next_state        = state;
    uart_addr         = 2'b10;
    uart_wdata        = 32'd0;
    uart_write_enable = 1'b0;
    busy              = 1'b1;
    done              = 1'b0;

    case (state)

        IDLE: begin
            busy = 1'b0;

            if (start)
                next_state = WRITE_DATA;
        end

        WRITE_DATA: begin
            uart_addr         = 2'b00;
            uart_wdata        = {24'd0, data_reg};
            uart_write_enable = 1'b1;
            next_state        = START_TX;
        end

        START_TX: begin
            uart_addr         = 2'b10;
            uart_wdata        = 32'h00000001;
            uart_write_enable = 1'b1;
            next_state        = WAIT_START;
        end

        WAIT_START: begin
            uart_addr = 2'b10;

            if (uart_rdata[0])
                next_state = WAIT_DONE;
        end

        WAIT_DONE: begin
            uart_addr = 2'b10;

            if (!uart_rdata[0])
                next_state = FINISH;
        end

        FINISH: begin
            busy = 1'b0;
            done = 1'b1;
            next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end

    endcase
end

endmodule