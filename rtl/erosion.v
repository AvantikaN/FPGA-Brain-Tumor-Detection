module erosion (
    input  wire p00, input wire p01, input wire p02,
    input  wire p10, input wire p11, input wire p12,
    input  wire p20, input wire p21, input wire p22,
    output wire eroded_pixel
);

    assign eroded_pixel = p00 & p01 & p02 &
                          p10 & p11 & p12 &
                          p20 & p21 & p22;

endmodule
