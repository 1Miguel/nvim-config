/********************************************************************************
 * @file uart_tx.sv
 * @brief uart core transmitter logic (fsm)
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
    UART_TX_STATE_IDLE,
    UART_TX_STATE_START,
    UART_TX_STATE_DATA,
    UART_TX_STATE_PARITY,
    UART_TX_STATE_STOP,
    UART_TX_STATE_DONE
} uart_tx_state_t;


module uart_tx #(
  parameter int DATA_WIDTH=8,
  parameter int TICK_COUNT=16
)(
  input logic clk_i,
  input logic rst_n_i,
  input logic [DATA_WIDTH-1:0] data_i,
  input logic start_i,
  input logic parity_en_i,
  input logic parity_i,
  input logic num_stop_bit_i,
  input logic baud_tick_i,
  output logic tx_o,
  output logic busy_o,
  output logic done_o
);

  localparam int N_SHIFT_BIT_WIDTH=$clog2(DATA_WIDTH);
  localparam int N_TICK_BIT_WIDTH = $clog2(TICK_COUNT);
  localparam logic [N_TICK_BIT_WIDTH:0] MAX_TICK_COUNT = 16;
  localparam logic [N_SHIFT_BIT_WIDTH:0] MAX_SHIFT_COUNT = 8;

  uart_tx_state_t state, next_state;
  logic [DATA_WIDTH-1:0] tx_data, next_tx_data;
  logic [N_TICK_BIT_WIDTH:0] tick, next_tick;
  logic [N_SHIFT_BIT_WIDTH:0] shift_cnt, next_shift_cnt;
  logic parity, next_parity;
  logic tx_bit, next_tx_bit;

  assign tx_o = tx_bit;

  always_ff @(posedge clk_i) begin : reg_blk
    if (!rst_n_i) begin
      state <= UART_TX_STATE_IDLE;
      tx_data <= 0;
      shift_cnt <= 0;
      tx_bit <= 1;
      tick <= 0;
      parity <= 0;
    end else begin
      state <= next_state;
      tx_data <= next_tx_data;
      shift_cnt <= next_shift_cnt;
      tx_bit <= next_tx_bit;
      tick <= next_tick;
      parity <= next_parity;
    end
  end : reg_blk

  always_comb begin : fsm_blk
    next_state = state;
    next_tx_data = tx_data;
    next_shift_cnt = shift_cnt;
    next_tick = tick;
    next_tx_bit = tx_bit;
    next_parity = parity;
    busy_o = 0;
    done_o = 0;

    case (state)

      UART_TX_STATE_IDLE: begin
        // at idle, tx bit must be driven to high
        next_tx_bit = 1;
        if (start_i) begin
          next_tx_bit = 0;
          next_tx_data = data_i;
          next_shift_cnt = 0;
          next_parity = parity_i;
          next_state = UART_TX_STATE_START;
        end
      end // UART_TX_STATE_IDLE

      UART_TX_STATE_START: begin
        busy_o = 1;
        if (baud_tick_i) begin
          // uart tx start phase, pull the tx/rx line
          // for 1 baud cycle (16x)
          if (tick < (MAX_TICK_COUNT - 1))
            next_tick = tick + 1;
          else begin
            next_tick = 0;
            next_tx_bit = tx_data[0];
            next_parity = parity ^ tx_data[0];
            next_state = UART_TX_STATE_DATA;
          end
        end
      end // UART_TX_STATE_START

      UART_TX_STATE_DATA: begin
        busy_o = 1;
        if (baud_tick_i) begin
          if (tick < (MAX_TICK_COUNT - 1))
            next_tick = tick + 1;
          else begin
            // baud tick has been reached, prepare transmitting
            // the next bit (lsb first) and calculate the parity
            next_tick = 0;
            next_shift_cnt = shift_cnt + 1;
            if (next_shift_cnt == MAX_SHIFT_COUNT) begin
              next_tick = 0;
              // have we transmitted all data bits?
              // decide if go to parity or stop
              next_state = parity_en_i
                          ? UART_TX_STATE_PARITY
                          : UART_TX_STATE_STOP;
            end else begin
              next_tx_data = tx_data >> 1;
              next_tx_bit = next_tx_data[0];
              next_parity = parity ^ next_tx_data[0];
            end
          end
        end
      end // UART_TX_STATE_DATA

      UART_TX_STATE_PARITY: begin
        busy_o = 1;
        next_tx_bit = parity;
        if (baud_tick_i)
          next_tick = tick + 1;
        else begin
          next_tick = 0;
          next_state = UART_TX_STATE_STOP;
        end
      end // UART_TX_STATE_PARITY

      UART_TX_STATE_STOP: begin
        busy_o = 1;
        next_tx_bit = 1;
        if (baud_tick_i)
          if (tick < ((MAX_TICK_COUNT << num_stop_bit_i) - 1))
            next_tick = tick + 1;
          else
            next_state = UART_TX_STATE_DONE;
      end // UART_TX_STATE_STOP

      UART_TX_STATE_DONE: begin
        next_state = UART_TX_STATE_IDLE;
        done_o = 1;
      end // UART_TX_STATE_DONE

      default: ;

    endcase
  end : fsm_blk

endmodule : uart_tx
