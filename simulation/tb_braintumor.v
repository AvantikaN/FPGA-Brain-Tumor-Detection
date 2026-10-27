`timescale 1ns/1ps
// ============================================================================
// tb_braintumor.v -- runs the streaming pipeline and dumps the frame buffer
//
//   vlog *.v ; vsim -c tb_braintumor -do "run -all"
//
// Needs hex2.txt in the simulation directory (python3 mif2hex.py image2.mif).
// ============================================================================

module tb_braintumor;

    reg         clk = 1'b0;
    reg         rst = 1'b1;
    reg  [7:0]  thresh = 8'd180;
    reg  [1:0]  mode   = 2'd3;
    reg  [13:0] vga_addr = 14'd0;

    wire pixel_out, done;

    integer f, i, ones;

    braintumor dut (
        .clk (clk), .rst (rst),
        .thresh (thresh), .mode (mode),
        .vga_addr (vga_addr), .pixel_out (pixel_out), .done (done)
    );

    always #20 clk = ~clk;     // 25 MHz

    initial begin
        repeat (4) @(posedge clk);
        rst = 1'b0;

        wait (done);
        $display("[tb] processing complete");

        ones = 0;
        f = $fopen("boundary_fpga.txt", "w");

        for (i = 0; i < 16384; i = i + 1) begin
            vga_addr = i[13:0];
            @(posedge clk);
            @(posedge clk);
            $fwrite(f, "%b\n", pixel_out);
            if (pixel_out) ones = ones + 1;
        end

        $fclose(f);
        $display("[tb] boundary pixels set = %0d", ones);
        if (ones == 0)
            $display("[tb] WARNING: frame buffer is empty - check the image data or lower the threshold");
        $finish;
    end

endmodule
