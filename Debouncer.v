// Button Debouncer Module
// Eliminates button bounce using a synchronizer and counter
module Debouncer (
    input wire clk,         // System clock
    input wire reset,       // Reset signal
    input wire button_in,   // Raw button input
    output reg button_out   // Debounced button output
);
    // Parameters for debounce timing
    // Reduced debounce time for more responsive button detection
    // For 50MHz clock, 50,000 cycles = 1ms debounce time
    parameter DEBOUNCE_CYCLES = 50000;

    // Synchronizer registers
    reg sync_1, sync_2;

    // Counter for debounce timing
    reg [31:0] counter;

    // Synchronizer to prevent metastability
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sync_1 <= 1'b0;
            sync_2 <= 1'b0;
        end else begin
            sync_1 <= button_in;
            sync_2 <= sync_1;
        end
    end

    // Debounce logic with counter
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 32'd0;
            button_out <= 1'b0;
        end else begin
            // If synchronized input is different from current output
            if (sync_2 != button_out) begin
                // Start/continue counting
                if (counter < DEBOUNCE_CYCLES - 1) begin
                    counter <= counter + 1'b1;
                end else begin
                    // Counter reached threshold, update output
                    counter <= 32'd0;
                    button_out <= sync_2;
                end
            end else begin
                // Input matches output, reset counter
                counter <= 32'd0;
            end
        end
    end
endmodule
