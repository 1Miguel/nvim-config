/**
 * @file register_async_rst.sv
 * @brief a basic implementation of register with async reset.
 */

module register_async_rst #(
  
  parameter int unsigned WIDTH = 32,
  parameter int unsigned DEFAULT = 0
) (
    input logic clk_i,
    input logic rst_i,
    input logic [WIDTH-1:0] data_i,
    output logic [WIDTH-1:0] data_o
  );

  logic [WIDTH-1:0] data;

  assign data_o = data;

  // async reset is when reset happens
  // anytime without waiting for clk sync
  always @(posedge clk_i or posedge rst_i) begin 
    if (rst_i)
      data <= DEFAULT;
    else begin
      data <= data_i;
    end

  end

endmodule : register_async_rst
