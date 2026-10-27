module vga_clock (
    input  wire clk_50,
    output reg  clk_25
);

    initial clk_25 = 1'b0;

    always @(posedge clk_50) begin
        clk_25 <= ~clk_25;
    end

endmodule
