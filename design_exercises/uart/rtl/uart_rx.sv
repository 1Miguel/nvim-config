/********************************************************************************
 * @file uart_rx.sv
 * @brief uart core receiver logic (fsm)
 ********************************************************************************
 * MIT License
 * 
 * Copyright (c) 2026 Miguel Ugsimar
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 ********************************************************************************
 */

typedef enum logic [2:0] {
    UART_RX_STATE_IDLE,
    UART_RX_STATE_START,
    UART_RX_STATE_DATA,
    UART_RX_STATE_PARITY,
    UART_RX_STATE_STOP,
    UART_RX_STATE_DONE
} uart_rx_state_t;


module uart_rx #(
  parameter int DATA_WIDTH=8,
  parameter int TICK_COUNT=16
)(
  input logic clk_i,
  input logic rst_n_i,
  input logic rx_i,
  input logic start_i,
  input logic parity_en_i,
  input logic parity_i,
  input logic num_stop_bit_i,
  input logic baud_tick_i,
  output logic [DATA_WIDTH-1:0] data_o,
  output logic start_o,
  output logic busy_o,
  output logic done_o
);

  localparam int N_SHIFT_BIT_WIDTH=$clog2(DATA_WIDTH);
  localparam int N_TICK_BIT_WIDTH = $clog2(TICK_COUNT);
  localparam logic [N_TICK_BIT_WIDTH:0] MAX_TICK_COUNT = 16;
  localparam logic [N_SHIFT_BIT_WIDTH:0] MAX_SHIFT_COUNT = 8;

  uart_rx_state_t state, next_state;
  logic [DATA_WIDTH-1:0] rx_data, next_rx_data;
  logic [N_TICK_BIT_WIDTH:0] tick, next_tick;
  logic [N_SHIFT_BIT_WIDTH:0] shift_cnt, next_shift_cnt;
  logic parity, next_parity;
  logic rx_bit, next_rx_bit;

  always_ff @(posedge clk_i) begin : reg_blk
    if (!rst_n_i) begin
      state <= UART_RX_STATE_IDLE;
      rx_data <= 0;
      shift_cnt <= 0;
      rx_bit <= 0;
      tick <= 0;
      parity <= 0;
    end else begin
      state <= next_state;
      rx_data <= next_rx_data;
      rx_bit <= next_rx_bit;
      shift_cnt <= next_shift_cnt;
      tick <= next_tick;
      parity <= next_parity;
    end
  end : reg_blk

  always_comb begin : fsm_blk
    next_state = state;
    next_rx_data = rx_data;
    next_shift_cnt = shift_cnt;
    next_tick = tick;
    next_parity = parity;
    next_rx_bit = rx_i;
    busy_o = 0;
    done_o = 0;

    case (state)

      UART_RX_STATE_IDLE: begin
        if (~rx_i) begin
          next_tick = 0;
          next_rx_data = 0;
          next_shift_cnt = 0;
          next_parity = parity_i;
          next_state = UART_RX_STATE_START;
        end
      end // UART_RX_STATE_IDLE

      UART_RX_STATE_START: begin
        busy_o = 1;
        if (rx_i)
          // go back to idle if line was de-asserted
          next_state = UART_RX_STATE_IDLE;
        else begin
          if (baud_tick_i) begin
            if (tick < (MAX_TICK_COUNT - 1))
              next_tick = tick + 1;
            else
              next_state = UART_RX_STATE_DATA;
          end
        end
      end // UART_RX_STATE_START

      UART_RX_STATE_DATA: begin
        busy_o = 1;
        if (baud_tick_i) begin
          if (tick < (MAX_TICK_COUNT - 1))
            next_tick = tick + 1;
          else begin
            // sample rx_i and shift bit in for every max tick count
            next_rx_data = {rx_data[$high(rx_data)-1:0], rx_i};
            next_tick = 0;
            next_shift_cnt = shift_cnt + 1;
            // increment shift count and decide next state
            if (next_shift_cnt == MAX_SHIFT_COUNT) begin
              next_state = parity_en_i
                          ? UART_RX_STATE_PARITY
                          : UART_RX_STATE_STOP;
            end
          end 
      end // UART_RX_STATE_DATA

      UART_RX_STATE_PARITY: begin
      end // UART_RX_STATE_PARITY

      UART_RX_STATE_STOP: begin
      end // UART_RX_STATE_STOP

      UART_RX_STATE_DONE: begin
      end // UART_RX_STATE_DONE

      default: ;

    endcase
  end : fsm_blk

endmodule : uart_rx
