module threshold (
    input  wire [7:0] pixel_in,
    input  wire [7:0] thresh_level,
    output wire       binary_pixel
);

    assign binary_pixel = (pixel_in >= thresh_level) ? 1'b1 : 1'b0;

endmodule
