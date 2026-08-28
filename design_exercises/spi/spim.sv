// **************************************************************************************
// @file spim.sv
// @brief Design implementation of a SPI Master core.
//
// status: wip
// **************************************************************************************
// MIT License
//
// Copyright (c) 2026 Miguel Ugsimar
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// **************************************************************************************
//
// A spi master behavior is simple, at one edge we sample the data and at 
// the next clock edge, we lock and shift the data.
// It only consists of 4-lines clk, cs, mosi, miso.
// 
// While writing this, i used analog devices article as reference.
// https://www.analog.com/en/resources/analog-dialogue/articles/introduction-to-spi-interface.html
//
// the design is simple, our spi master will have two data fifo, one for rx
// and one for tx. the operation is simple
//    1. when spim is enabled and a data is loaded an a tx request is raised,
//       spim will initiate a transaction by asserting the cs pin
//    2. spim generates clock, data in write fifo will be flushed
//       (bit-by-bit) to mosi port.
//    3. depending on the mode, we will shift out bits in mosi at one end and
//       sample the bit in miso at another end
//    4. then the data, once locked, will be pushed to rx fifo
// 
// we will also define a couple of status bits:
//    1. write fifo full
//    2. read fifo full
//    3. write underflow (clock to fast)
//    4. read overflow (clock to fast)
//    5. tx ready
//
// **************************************************************************************
// What is supported? for now we will only support `spi mode 0`, no csr
// blocks to support different configuration.
// 
// ... a brief reference to spi modes:
// spi clk edge operation depends on the spi mode see the table below
//
// mode | cpol | cpha | cpol_idle |  sample_edge |  shift_edge
//  0   |  0   |  0   |    0      |    rising    |   falling
//  1   |  0   |  1   |    0      |    falling   |   rising
//  2   |  1   |  0   |    1      |    falling   |   rising
//  3   |  1   |  1   |    1      |    rising    |   falling
//  
//  > cpol - clock polarity sets the polarity of the clock signal during the
//        idle state
//  > cpha - selects the clock phase. Depending on the CPHA bit, the rising
//        or falling clock edge is used to sample and/or shift the data.
//  > cpol_idle - sets the state of the clock at idle (no activity).
//
//  mode 0 (cpol=0, cpha=0)
//          sample   shift
//    idle    |        |
//  i ________|¯¯¯¯¯¯¯¯|________|¯¯¯¯¯¯¯¯|________|¯¯¯¯¯¯¯¯|________|¯¯¯¯¯¯¯¯|
//  mode 1 (cpol=0, cpha=1)
//                  sample    shift
//    idle             |        |
//  i ________|¯¯¯¯¯¯¯¯|________|¯¯¯¯¯¯¯¯|________|¯¯¯¯¯¯¯¯|________|¯¯¯¯¯¯¯¯|
//  mode 2 (cpol=1, cpha=0)
//          sample   shift
//    idle    |        |
//  i ¯¯¯¯¯¯¯¯|________|¯¯¯¯¯¯¯¯|________|¯¯¯¯¯¯¯¯|________|¯¯¯¯¯¯¯¯|________|
//  mode 3 (cpol=1, cpha=1)
//                  sample    shift
//    idle             |        |
//  i ¯¯¯¯¯¯¯¯|________|¯¯¯¯¯¯¯¯|________|¯¯¯¯¯¯¯¯|________|¯¯¯¯¯¯¯¯|________|
//
//  for now we will only support spi mode 0, then in the future we'll make
//  it more configurable
//
//  MOSI: Data output shifting
//
//    given our tx register as
//    +-------------------------------+
//    | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
//    +-------------------------------+
//      ^ we will use the msb to drive mosi
//    at msb first we just do a normal shift to left <<
//    at lsb first we do a circular shift to right >>
//    +-------------------------------+
//    | 0 | 7 | 6 | 5 | 4 | 3 | 2 | 1 |
//    +-------------------------------+
//       bit7 circularly shift to bit pos 0
//
//  MISO: Data input shifting
//
//    given our tx register as
//    +-------------------------------+
//    | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
//    +-------------------------------+
//                                  ^ we will use the last bit to store miso
//    so at msb first, we do normal left shift,
//
//    but if this is an lsb first we do circular shift from left to right, so
//    the last bit will be the msb, continuously shift until the lsb first 
//    falls to the lsb of the data register
//    +-------------------------------+
//    | 0 | 7 | 6 | 5 | 4 | 3 | 2 | 1 |
//    +-------------------------------+
//        bit0 circularly shift to pos 7
//
//  implementation detail:
//    this implements spi in two always block
//      > an sequential block with clocked present state registers
//      > an combinational block that outputs the next state
// **************************************************************************************/

typedef enum logic [2:0] {
    SPIM_STATE_IDLE,
    SPIM_STATE_START,
    SPIM_STATE_P0,
    SPIM_STATE_P1,
    SPIM_STATE_SHIFT,
    SPIM_STATE_SAMPLE
} spim_fsm_state_t;

module spim #(
  // N size of registers
  parameter int N=32,
  // io data size
  localparam int N_DATA_BIT_SIZE=8,
  // N size of registers
  localparam int N_SHIFT_CNT_BIT_SIZE=$clog2(N_DATA_BIT_SIZE)
) (
  // system clock
  input logic i_clk,
  // reset pin (active-low)
  input logic i_rst_n,
  // is msb first to transmit?
  input logic i_msb,
  // start of transaction signal
  input logic i_start,
  // inter data idle duration
  input logic [N-1:0] i_data_idle_dur,
  // data to transmit
  input logic [N_DATA_BIT_SIZE-1:0] i_tx_data,
  // spi mode
  input logic [1:0] i_spi_mode,
  // divides the clock freq to generate desired spi_clk freq
  input logic [N-1:0] i_div,
  // spi port
  input logic i_spi_miso,
  output logic o_spi_mosi,
  output logic o_spi_clk,
  output logic o_spi_cs,
  // rx data output location
  output logic [N_DATA_BIT_SIZE-1:0] o_rx_data,
  // done signal, asserted once spi is done transmitting
  output logic o_done
);

  wire cpol;
  wire cpha;
  spim_fsm_state_t state, state_next;
  logic [N_DATA_BIT_SIZE-1:0] rx_data, rx_data_next;
  logic [N_DATA_BIT_SIZE-1:0] tx_data, tx_data_next;
  logic [N-1:0] clk_div_cnt, clk_div_cnt_next;
  logic [N-1:0] data_idle_cnt, data_idle_cnt_next;
  logic [N_SHIFT_CNT_BIT_SIZE:0] shift_cnt, shift_cnt_next;
  logic sclk, sclk_next;

  assign o_spi_mosi = tx_data[$high(tx_data)];
  assign cpha = i_spi_mode[0];
  assign cpol = i_spi_mode[1];
  assign o_rx_data = rx_data;

  always_ff @(posedge i_clk) begin : data_regs
    if (!i_rst_n) begin
      state <= SPIM_STATE_IDLE;
      rx_data <= 0;
      tx_data <= 0;
      clk_div_cnt <= 0;
      data_idle_cnt <= 0;
      shift_cnt <= 0;
      sclk <= 0;
    end
    else begin
      state <= state_next;
      rx_data <= rx_data_next;
      tx_data <= tx_data_next;
      clk_div_cnt <= clk_div_cnt_next;
      data_idle_cnt <= data_idle_cnt_next;
      shift_cnt <= shift_cnt_next;
      sclk <= sclk_next;
    end
  end : data_regs

  // combinational block that contains the FSM logic, based on the current
  // state and input, outputs the next state
  always_comb begin : fsmd

    state_next = state;
    clk_div_cnt_next = clk_div_cnt;
    shift_cnt_next = shift_cnt;
    tx_data_next = tx_data;
    rx_data_next = rx_data;
    sclk_next = sclk;
    data_idle_cnt_next = data_idle_cnt;
    o_done = 0;

    case(state)

      SPIM_STATE_IDLE: begin
        sclk_next = cpol ? 0 : 1;
        if (i_start) begin
          // mosi pin is tied to tx_data lsb, so at msb first we will circular
          // shift the tx_data register
          tx_data_next = (i_msb) ? i_tx_data
                       : {i_tx_data[0], i_tx_data[$high(i_tx_data):1]};
          clk_div_cnt_next = 0;
          shift_cnt_next = 0;
          state_next = SPIM_STATE_START;
        end
      end

      SPIM_STATE_START: begin
        // we will add some delay before we start
        // transmitting, this adds an inter-data delay between packet transmission
        if (data_idle_cnt < i_data_idle_dur) begin
          data_idle_cnt_next = data_idle_cnt + 1;
        end
        else
          state_next = SPIM_STATE_P0;
      end

      SPIM_STATE_P0: begin
        // clock toggle and clk div, only toggle the clock for every div cycle
        if (clk_div_cnt < i_div)
          clk_div_cnt_next = clk_div_cnt + 1;
        else begin
          clk_div_cnt_next = 0;
          // toggle the clock
          sclk_next = ~sclk;
          // check wether we will shift or sample depending on the edge
          // TODO: base on the phase, when to sample and shift
          case ({sclk, sclk_next})
            2'b10: begin // falling, shift
              state_next = SPIM_STATE_SHIFT;
            end
            2'b01: begin // rising, sample
              state_next = SPIM_STATE_SAMPLE;
            end
            default: begin
              // TODO: how to handle impossible states?
              // one idea is to use b'zzz on cases like this
              // but for now we go to idle
              state_next = SPIM_STATE_IDLE;
            end
          endcase
        end
      end

      SPIM_STATE_SHIFT: begin
        tx_data_next = (i_msb) ? {tx_data[0], tx_data[$high(tx_data):1]}
                      : (tx_data << 1);
        rx_data_next = (i_msb) ? {rx_data[0], rx_data[$high(rx_data):1]}
                      : (rx_data << 1);
        state_next = SPIM_STATE_P0;
      end

      SPIM_STATE_SAMPLE: begin
        rx_data_next = {rx_data[$high(rx_data):1], i_spi_miso};
      end

      default: begin
      end

    endcase

  end : fsmd

endmodule : spim
