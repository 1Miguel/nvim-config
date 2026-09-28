/**
 * @file register.sv
 * @brief a basic implementation of register with sync reset.
 */

module register_sync_rst #(
  
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

  always @(posedge clk_i) begin 
    if (rst_i)
      data <= DEFAULT;
    else begin
      data <= data_i;
    end

  end

endmodule
