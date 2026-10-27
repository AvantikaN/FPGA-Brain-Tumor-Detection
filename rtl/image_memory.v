module image_memory (
    input  wire        clk,
    input  wire [13:0] addr,
    output reg  [7:0]  pixel      // valid ONE clock after addr
);

    // The .mif must be 16384 words x 8 bits.
   
	(* ram_init_file = "image.mif" *)
    reg [7:0] image_mem [0:16383];

    // ModelSim cannot read a .mif, so for simulation load the same data from
    // a plain hex file (use mif2hex.py to generate hex2.txt from image2.mif).
    // synthesis translate_off
    initial begin
        $readmemh("hex2.txt", image_mem);
    end
    // synthesis translate_on

    always @(posedge clk) begin
        pixel <= image_mem[addr];
    end

endmodule
