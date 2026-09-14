`timescale 1ns / 1ps

module LCD_CONTROL (
    input  logic        clk,
    input  logic        rst,

    input  logic        op_start,
    input  logic        op_rs,
    input  logic        op_clear,
    input  logic        op_home,
    input  logic [7:0]  op_data,

    output logic        op_busy,
    output logic        op_done,

    output logic        write_enable,
    output logic [1:0]  addr,
    output logic [31:0] wdata,
    input  logic [31:0] rdata
);

localparam logic [1:0] ADDR_CONTROL = 2'b00;
localparam logic [1:0] ADDR_DATA    = 2'b01;

typedef enum logic [2:0] {
    IDLE,
    WAIT_READY,
    WRITE_DATA,
    WRITE_CONTROL,
    WAIT_BUSY,
    WAIT_DONE,
    FINISH
} state_t;

state_t state;

logic rs_reg;
logic clear_reg;
logic home_reg;
logic [7:0] data_reg;

always_comb begin
    write_enable = 1'b0;
    addr         = ADDR_CONTROL;
    wdata        = 32'h0000_0000;
    op_busy      = 1'b1;
    op_done      = 1'b0;

    case (state)

        IDLE: begin
            op_busy = 1'b0;
        end

        WAIT_READY: begin
            addr = ADDR_CONTROL;
        end

        WRITE_DATA: begin
            write_enable = 1'b1;
            addr         = ADDR_DATA;
            wdata[7:0]   = data_reg;
        end

        WRITE_CONTROL: begin
            write_enable = 1'b1;
            addr         = ADDR_CONTROL;

            wdata[0] = !(clear_reg || home_reg);
            wdata[1] = rs_reg;
            wdata[2] = clear_reg;
            wdata[3] = home_reg;
        end

        WAIT_BUSY: begin
            addr = ADDR_CONTROL;
        end

        WAIT_DONE: begin
            addr = ADDR_CONTROL;
        end

        FINISH: begin
            op_busy = 1'b0;
            op_done = 1'b1;
        end

        default: begin
            op_busy = 1'b0;
        end

    endcase
end

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        state     <= IDLE;
        rs_reg    <= 1'b0;
        clear_reg <= 1'b0;
        home_reg  <= 1'b0;
        data_reg  <= 8'h00;
    end
    else begin
        case (state)

            IDLE: begin
                if (op_start) begin
                    rs_reg    <= op_rs;
                    clear_reg <= op_clear;
                    home_reg  <= op_home;
                    data_reg  <= op_data;
                    state     <= WAIT_READY;
                end
            end

            WAIT_READY: begin
                if (!rdata[8]) begin
                    if (clear_reg || home_reg)
                        state <= WRITE_CONTROL;
                    else
                        state <= WRITE_DATA;
                end
            end

            WRITE_DATA:
                state <= WRITE_CONTROL;

            WRITE_CONTROL:
                state <= WAIT_BUSY;

            WAIT_BUSY: begin
                if (rdata[8])
                    state <= WAIT_DONE;
            end

            WAIT_DONE: begin
                if (!rdata[8] && rdata[9])
                    state <= FINISH;
            end

            FINISH:
                state <= IDLE;

            default:
                state <= IDLE;

        endcase
    end
end

endmodule