module braintumor (
    input  wire        clk,
    input  wire        rst,

    input  wire [7:0]  thresh,        // binarisation level (live from SW)
    input  wire [1:0]  mode,          // 0=binary 1=eroded 2=dilated 3=boundary

    input  wire [13:0] vga_addr,      // read port for the display
    output reg         pixel_out,     // valid ONE clock after vga_addr

    output reg         done
);

    localparam integer NPIX = 16384;  // 128 x 128
    localparam integer LAT  = 130;    // window fill latency (1 row + 2 pixels)

    // ------------------------------------------------------------------
    // Address generator.  Runs NPIX+LAT cycles: the extra LAT cycles push
    // zeros in so that the last real pixels get flushed out of the window.
    // ------------------------------------------------------------------
    reg [14:0] n;
    reg        running;

    initial begin
        n       = 15'd0;
        running = 1'b1;               // self-starts at power-up, no KEY needed
        done    = 1'b0;
    end

    always @(posedge clk) begin
        if (rst) begin
            n       <= 15'd0;
            running <= 1'b1;
            done    <= 1'b0;
        end
        else if (running) begin
            if (n == NPIX + LAT - 1) begin
                running <= 1'b0;
                done    <= 1'b1;
            end
            else begin
                n <= n + 15'd1;
            end
        end
    end

    // ------------------------------------------------------------------
    // ROM read (registered -> 1 clock latency) and thresholding
    // ------------------------------------------------------------------
    wire [7:0] rom_pixel;

    image_memory mem (
        .clk   (clk),
        .addr  (n[13:0]),
        .pixel (rom_pixel)
    );

    reg  [14:0] n_d;
    reg         shift_en;

    initial begin
        n_d      = 15'd0;
        shift_en = 1'b0;
    end

    always @(posedge clk) begin
        n_d      <= n;
        shift_en <= running & ~rst;
    end

    wire in_range = (n_d < NPIX);     // rom_pixel belongs to sample n_d
    wire bin_raw;

    threshold thresh_unit (
        .pixel_in     (rom_pixel),
        .thresh_level (thresh),
        .binary_pixel (bin_raw)
    );

    wire bin_in = in_range ? bin_raw : 1'b0;

    // ------------------------------------------------------------------
    // 3x3 window
    // ------------------------------------------------------------------
    wire p00, p01, p02, p10, p11, p12, p20, p21, p22;

    window3x3 #(.WIDTH(128)) win (
        .clk (clk), .rst (rst), .en (shift_en), .d (bin_in),
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22)
    );

    // ------------------------------------------------------------------
    // Centre-pixel bookkeeping.  After s shifts, p11 holds sample s-130.
    // ------------------------------------------------------------------
    reg [14:0] s;

    initial s = 15'd0;

    always @(posedge clk) begin
        if (rst)            s <= 15'd0;
        else if (shift_en)  s <= s + 15'd1;
    end

    wire [14:0] cidx     = s - 15'd130;
    wire        c_valid  = (s >= 15'd130) && (cidx < NPIX);
    wire [6:0]  crow     = cidx[13:7];
    wire [6:0]  ccol     = cidx[6:0];
    wire        interior = (crow != 7'd0) && (crow != 7'd127) &&
                           (ccol != 7'd0) && (ccol != 7'd127);

    // ------------------------------------------------------------------
    // Morphology - all three operators share the one window
    // ------------------------------------------------------------------
    wire eroded_pixel, dilated_pixel, boundary_pixel;

    erosion erosion_unit (
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .eroded_pixel(eroded_pixel)
    );

    dilation dilation_unit (
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .dilated_pixel(dilated_pixel)
    );

    boundary boundary_unit (
        .original_pixel (p11),
        .eroded_pixel   (eroded_pixel),
        .boundary_pixel (boundary_pixel)
    );

    reg result;

    always @(*) begin
        case (mode)
            2'd0:    result = p11;              // binary image
            2'd1:    result = eroded_pixel;     // eroded
            2'd2:    result = dilated_pixel;    // dilated
            default: result = boundary_pixel;   // tumour boundary
        endcase
        if (!interior) result = 1'b0;           // clean frame around the image
    end

    // ------------------------------------------------------------------
    // Frame buffer: 16384 x 1 simple dual-port RAM -> 2 M9K blocks.
    // One synchronous write port, one synchronous read port, same clock.
    // ------------------------------------------------------------------
    reg fb [0:NPIX-1];

    // synthesis translate_off
    integer k;
    initial for (k = 0; k < NPIX; k = k + 1) fb[k] = 1'b0;
    // synthesis translate_on

    always @(posedge clk) begin
        if (c_valid) fb[cidx[13:0]] <= result;
        pixel_out <= fb[vga_addr];
    end

    // ------------------------------------------------------------------
    // Simulation-only dump.  NEVER leave $writememh in synthesisable code.
    // ------------------------------------------------------------------
    // synthesis translate_off
    reg dumped;
    initial dumped = 1'b0;
    always @(posedge clk) begin
        if (done && !dumped) begin
            dumped <= 1'b1;
            $display("[braintumor] processing finished at %t", $time);
        end
    end
    // synthesis translate_on

endmodule
