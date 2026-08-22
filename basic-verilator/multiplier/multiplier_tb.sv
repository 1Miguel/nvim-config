`default_nettype none

/**
 * @file multiplier_tb.sv
 * @brief Self-checking testbench for the multiplier module.
 */
module multiplier_tb;

    localparam int unsigned WIDTH = 4;
    localparam int unsigned OPERAND_WIDTH = WIDTH + 1;

    logic [OPERAND_WIDTH-1:0] a_i;
    logic [OPERAND_WIDTH-1:0] b_i;
    logic [OPERAND_WIDTH-1:0] c_o;

    multiplier #(
        .WIDTH(WIDTH)
    ) dut (
        .a_i(a_i),
        .b_i(b_i),
        .c_o(c_o)
    );

    /**
     * @brief Applies one vector and checks the truncated product.
     *
     * The multiplier output is OPERAND_WIDTH bits wide, so products wider
     * than the output intentionally keep only their least-significant bits.
     */
    task automatic check_product(
        input logic [OPERAND_WIDTH-1:0] a,
        input logic [OPERAND_WIDTH-1:0] b
    );
        logic [(2 * OPERAND_WIDTH)-1:0] expected_product;

        a_i = a;
        b_i = b;
        #1;

        expected_product = a * b;
        if (c_o !== expected_product[OPERAND_WIDTH-1:0]) begin
            $fatal(1, "Mismatch: a=%0d b=%0d expected=%0d got=%0d",
                   a, b, expected_product[OPERAND_WIDTH-1:0], c_o);
        end
    endtask

    initial begin
        check_product('0, '0);
        check_product('0, '1);
        check_product('1, '1);
        check_product(OPERAND_WIDTH'(2), OPERAND_WIDTH'(3));
        check_product({OPERAND_WIDTH{1'b1}}, '1);

        for (int unsigned index = 0; index < 32; index++) begin
            check_product(index, 32 - index);
        end

        $display("Multiplier testbench passed.");
        $finish;
    end

endmodule

`default_nettype wire