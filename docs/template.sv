`default_nettype none

/**
 * @file template.sv
 * @brief Documented SystemVerilog module template.
 *
 * Doxygen-style comments use /** ... *\/ or ///. Doxygen support for
 * SystemVerilog varies by version and configuration, so keep comments useful
 * as normal source documentation even when documentation generation is not
 * enabled.
 */

/**
 * @brief Stores a value when enabled.
 *
 * @details
 * The register is cleared when the active-low reset is asserted. On each
 * rising clock edge after reset, `data_i` is stored when `enable_i` is high.
 *
 * @tparam WIDTH Width of the data path in bits.
 *
 * @note Reset is asynchronous and active-low.
 */
module template #(
    parameter int unsigned WIDTH = 8
) (
    /// @brief Clock input.
    input  logic             clk_i,

    /// @brief Asynchronous active-low reset.
    input  logic             rst_ni,

    /// @brief Enables loading `data_i` on the next rising clock edge.
    input  logic             enable_i,

    /// @brief Data to store.
    input  logic [WIDTH-1:0] data_i,

    /// @brief Currently stored data.
    output logic [WIDTH-1:0] data_o
);

    /**
     * @brief Register state.
     *
     * The `_q` suffix indicates a clocked value.
     */
    logic [WIDTH-1:0] data_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            data_q <= '0;
        end else if (enable_i) begin
            data_q <= data_i;
        end
    end

    assign data_o = data_q;

endmodule

`default_nettype wire
