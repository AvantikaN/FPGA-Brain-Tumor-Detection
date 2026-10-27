// ============================================================================
// BOARD CONTROLS
//   KEY[0]        press+release = re-run the processing with current switches
//   SW[1:0]       0 = binary, 1 = eroded, 2 = dilated, 3 = boundary (default)
//   SW[2]         VGA test pattern (red/white checkerboard) - use this first
//   SW[3]         use SW[15:8] as the threshold instead of the default 180
//   SW[15:8]      threshold value when SW[3] is on
//   LEDR[0]       processing done
// ============================================================================

module top (
    input  wire        CLOCK_50,
    input  wire [3:0]  KEY,
    input  wire [17:0] SW,
    output wire [17:0] LEDR,

    output wire [7:0]  VGA_R,
    output wire [7:0]  VGA_G,
    output wire [7:0]  VGA_B,
    output wire        VGA_HS,
    output wire        VGA_VS,
    output wire        VGA_BLANK_N,
    output wire        VGA_SYNC_N,
    output wire        VGA_CLK
);

    // ---------------- pixel clock ----------------
    wire clk_25;

    vga_clock clock_unit (
        .clk_50 (CLOCK_50),
        .clk_25 (clk_25)
    );

    // ---------------- reset: power-on OR KEY[0] ----------------
    reg [7:0] por = 8'hFF;

    always @(posedge CLOCK_50) begin
        if (por != 8'd0) por <= por - 8'd1;
    end

    wire rst_raw = (por != 8'd0) | ~KEY[0];   // KEY is active low on DE-boards

    reg [2:0] rst_sync = 3'b111;

    always @(posedge clk_25) begin
        rst_sync <= {rst_sync[1:0], rst_raw};
    end

    wire rst = rst_sync[2];

    // ---------------- runtime options ----------------
    wire [7:0] thresh_level = SW[3] ? SW[15:8] : 8'd180;
    wire [1:0] view_mode    = SW[1:0];
    wire       test_pattern = SW[2];

    // ---------------- processing ----------------
    wire [13:0] vga_addr;
    wire        pixel_out;
    wire        done;

    braintumor brain_tumor (
        .clk       (clk_25),        // same domain as VGA: no clock crossing
        .rst       (rst),
        .thresh    (thresh_level),
        .mode      (view_mode),
        .vga_addr  (vga_addr),
        .pixel_out (pixel_out),
        .done      (done)
    );

    // ---------------- display ----------------
    vga_controller vga (
        .clk_25       (clk_25),
        .pixel_in     (pixel_out),
        .test_pattern (test_pattern),
        .vga_addr     (vga_addr),
        .VGA_R        (VGA_R),
        .VGA_G        (VGA_G),
        .VGA_B        (VGA_B),
        .VGA_HS       (VGA_HS),
        .VGA_VS       (VGA_VS),
        .VGA_BLANK_N  (VGA_BLANK_N)
    );

    // ADV7123 static controls
    assign VGA_SYNC_N = 1'b0;        // composite sync-on-green disabled
    assign VGA_CLK    = ~clk_25;     // DAC latches RGB on this rising edge

    assign LEDR = {17'b0, done};

endmodule
