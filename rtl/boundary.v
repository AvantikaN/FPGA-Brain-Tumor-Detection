module boundary (
    input  wire original_pixel,
    input  wire eroded_pixel,
    output wire boundary_pixel
);

    assign boundary_pixel = original_pixel & ~eroded_pixel;

endmodule
