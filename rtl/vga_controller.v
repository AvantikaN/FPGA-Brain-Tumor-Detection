// ============================================================================
// vga_controller.v  -- 640x480 @ 60 Hz, 128x128 image scaled 3x and centred
// ============================================================================

module vga_controller (
    input  wire        clk_25,

    input  wire        pixel_in,      // frame-buffer data, 1 clk after vga_addr
    input  wire        test_pattern,

    output wire [13:0] vga_addr,

    output reg  [7:0]  VGA_R,
    output reg  [7:0]  VGA_G,
    output reg  [7:0]  VGA_B,
    output reg         VGA_HS,
    output reg         VGA_VS,
    output reg         VGA_BLANK_N
);

    // ---------------- 640x480 @ 60 Hz timing ----------------
    localparam H_VISIBLE = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48;
    localparam H_TOTAL   = 800;
    localparam V_VISIBLE = 480, V_FRONT = 10, V_SYNC =  2, V_BACK = 33;
    localparam V_TOTAL   = 525;

    // 128 x 3 = 384.  X = (640-384)/2 = 128,  Y = (480-384)/2 = 48
    localparam X_START = 128, Y_START = 48, SPAN = 384;

    reg [9:0] h, v;
    reg [6:0] ix, iy;      // image column / row  (0..127)
    reg [1:0] x3, y3;      // 3x zoom counters

    initial begin
        h = 0; v = 0; ix = 0; iy = 0; x3 = 0; y3 = 0;
    end

    // Free-running: sync is always present, so the monitor always locks.
    always @(posedge clk_25) begin

        if (h == H_TOTAL-1) begin
            h <= 10'd0;

            if (v == V_TOTAL-1) v <= 10'd0;
            else                v <= v + 10'd1;

            // vertical zoom counter, advanced once per line
            if (v == Y_START-1) begin
                y3 <= 2'd0;
                iy <= 7'd0;
            end
            else if ((v >= Y_START) && (v < Y_START+SPAN-1)) begin
                if (y3 == 2'd2) begin y3 <= 2'd0; iy <= iy + 7'd1; end
                else                  y3 <= y3 + 2'd1;
            end
        end
        else begin
            h <= h + 10'd1;
        end

        // horizontal zoom counter
        if (h == X_START-1) begin
            x3 <= 2'd0;
            ix <= 7'd0;
        end
        else if ((h >= X_START) && (h < X_START+SPAN-1)) begin
            if (x3 == 2'd2) begin x3 <= 2'd0; ix <= ix + 7'd1; end
            else                  x3 <= x3 + 2'd1;
        end
    end

    // address = row*128 + column
    assign vga_addr = {iy, ix};

    // ---------------- control signals for the fetched pixel ----------------
    wire in_img = (h >= X_START) && (h < X_START+SPAN) &&
                  (v >= Y_START) && (v < Y_START+SPAN);

    wire active = (h < H_VISIBLE) && (v < V_VISIBLE);

    wire hs_n = ~((h >= H_VISIBLE+H_FRONT) &&
                  (h <  H_VISIBLE+H_FRONT+H_SYNC));

    wire vs_n = ~((v >= V_VISIBLE+V_FRONT) &&
                  (v <  V_VISIBLE+V_FRONT+V_SYNC));

    // stage 1: delay by one clock so they line up with the RAM output
    reg in_img_1, active_1, hs_1, vs_1;
    reg [6:0] ix_1, iy_1;

    always @(posedge clk_25) begin
        in_img_1 <= in_img;
        active_1 <= active;
        hs_1     <= hs_n;
        vs_1     <= vs_n;
        ix_1     <= ix;
        iy_1     <= iy;
    end

    // stage 2: pixel_in is now valid for the same screen position
    always @(posedge clk_25) begin
        VGA_HS      <= hs_1;
        VGA_VS      <= vs_1;
        VGA_BLANK_N <= active_1;

        if (!active_1) begin
            {VGA_R, VGA_G, VGA_B} <= 24'h000000;
        end
        else if (test_pattern) begin
            if (in_img_1)
                {VGA_R, VGA_G, VGA_B} <= (ix_1[3] ^ iy_1[3]) ? 24'hFFFFFF
                                                             : 24'hFF0000;
            else
                {VGA_R, VGA_G, VGA_B} <= 24'h000040;   // dark blue surround
        end
        else if (in_img_1 && pixel_in) begin
            {VGA_R, VGA_G, VGA_B} <= 24'hFFFFFF;       // boundary = white
        end
        else begin
            {VGA_R, VGA_G, VGA_B} <= 24'h000000;
        end
    end

endmodule
