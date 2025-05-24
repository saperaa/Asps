// Time Counter Module
// Provides a global time reference for the parking system
module TimeCounter (
    input wire clk,         // System clock
    input wire reset,       // Reset signal
    output reg [7:0] time_value // Current time value (8-bit)
);
    // Counter for more precise timing
    reg [1:0] prescaler;  // Small prescaler for visible but not too fast updates

    // Use prescaler to increment time_value at a reasonable rate
    // For 250ms clock, increment every 4 cycles (1 second) for better visibility
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            time_value <= 8'd0;
            prescaler <= 2'd0;
        end else begin
            // Increment prescaler on every clock
            prescaler <= prescaler + 1'b1;

            // Increment time_value every 4 clock cycles (1 second)
            if (prescaler == 2'd3) begin
                time_value <= time_value + 1'b1;
            end
        end
    end
endmodule
