/**
 * @file register_irq_status.sv
 * @brief a basic demonstration of a register with latching
 *        and rw1c logic often used in interrupt status.
   *
 * @author Miguel Ugsimar <jmjugsimar@gmail.com>
 */

module register_irq_status #(
  
  parameter int unsigned WIDTH = 32,
  parameter int unsigned DEFAULT = 0
) (
    input logic clk_i,
    input logic rst_i,
    input logic wen,
    input logic [WIDTH-1:0] data_i,
    output logic [WIDTH-1:0] data_o
  );

  logic [WIDTH-1:0] data;
  logic [WIDTH-1:0] next_data;

  always_ff @(posedge clk_i) begin 
    if (rst_i)
      data <= DEFAULT;
    else begin
      data <= next_data;
    end

  end

  always_comb begin
    next_data = data;
    if (wen) begin
      // write 1 to clear
      next_data = data & ~data_i;
    end
  end

endmodule : register_irq_status
