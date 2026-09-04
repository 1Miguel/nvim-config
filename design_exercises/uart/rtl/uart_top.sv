
module uart_top #(
  parameter int DATA_WIDTH=8,
  parameter int TICK_COUNT=16
)(
  input logic clk_i,
  input logic rst_n_i,
  input logic [DATA_WIDTH-1:0] tx_data_i,
  input logic tx_start_i,
  input logic parity_en_i,
  input logic parity_i,
  input logic num_stop_bit_i,
  output logic tx_o,
  output logic tx_busy_o,
  output logic tx_done_o
);
  logic baud_tick;

  uart_clock_div #(
    .N(8)
  ) u_uart_clock_div(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .div_i(16),
    .clk_o(baud_tick)
  );
  //$display("hello");
  uart_tx #(
    .DATA_WIDTH(DATA_WIDTH),
    .TICK_COUNT(TICK_COUNT)
  ) u_uart_tx(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .data_i(tx_data_i),
    .start_i(tx_start_i),
    .parity_en_i(parity_en_i),
    .parity_i(parity_i),
    .num_stop_bit_i(num_stop_bit_i),
    .baud_tick_i(baud_tick),
    .tx_o(tx_o),
    .busy_o(tx_busy_o),
    .done_o(tx_done_o)
  );

endmodule

