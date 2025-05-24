module CostCalculator (
    input wire clk,
    input wire reset,
    input wire [7:0] parking_time,      // Result from entry-exit time difference (8-bit)
    input wire exit_detected,           // Trigger to latch cost
    output reg [7:0] cost               // 8 bits to hold result of multiplication
);
    // Base cost per time unit (can be adjusted)
    parameter BASE_RATE = 2;  // 2 units per time unit

    // Improved cost calculation - multiply parking time by BASE_RATE
    // This makes the timer more useful for cost calculation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cost <= 8'd0;
        end else if (exit_detected) begin
            // Calculate cost as parking time multiplied by BASE_RATE
            cost <= parking_time * BASE_RATE;

            // Ensure a minimum cost of BASE_RATE for visibility
            if (parking_time == 8'd0) begin
                cost <= BASE_RATE;  // Minimum cost
            end
        end
        // No else clause - cost maintains its value when not reset or exit_detected
    end

endmodule