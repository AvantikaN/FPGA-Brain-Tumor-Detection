module window3x3 #(
    parameter integer WIDTH = 128      // image width in pixels
)(
    input  wire clk,
    input  wire rst,
    input  wire en,                    // advance one pixel
    input  wire d,                     // incoming binary pixel

    output reg  p00, output reg p01, output reg p02,
    output reg  p10, output reg p11, output reg p12,
    output reg  p20, output reg p21, output reg p22
);

    reg [WIDTH-1:0] line0;   // delays d by WIDTH  (one row)
    reg [WIDTH-1:0] line1;   // delays d by 2*WIDTH (two rows)

    initial begin
        line0 = {WIDTH{1'b0}};
        line1 = {WIDTH{1'b0}};
        {p00,p01,p02,p10,p11,p12,p20,p21,p22} = 9'b0;
    end

    always @(posedge clk) begin
        if (rst) begin
            line0 <= {WIDTH{1'b0}};
            line1 <= {WIDTH{1'b0}};
            {p00,p01,p02,p10,p11,p12,p20,p21,p22} <= 9'b0;
        end
        else if (en) begin
            // top row    (two rows behind)
            p00 <= p01;  p01 <= p02;  p02 <= line1[WIDTH-1];
            // middle row (one row behind)  -> p11 is the centre pixel
            p10 <= p11;  p11 <= p12;  p12 <= line0[WIDTH-1];
            // bottom row (current row)
            p20 <= p21;  p21 <= p22;  p22 <= d;

            line1 <= {line1[WIDTH-2:0], line0[WIDTH-1]};
            line0 <= {line0[WIDTH-2:0], d};
        end
    end

endmodule
