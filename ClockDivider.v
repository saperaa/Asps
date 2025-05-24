// Clock Divider Module
// Divides the main FPGA clock to generate a 250ms clock
module ClockDivider (
    input wire clk_in,      // Input clock (50 MHz for DE10-Lite)
    input wire reset,       // Reset signal
    output reg clk_out      // Output clock (250ms period)
);
    // For 50MHz input clock to get 250ms period (4Hz):
    // 50,000,000 / 4 = 12,500,000 cycles
    // Need to toggle every 12,500,000 / 2 = 6,250,000 cycles
    parameter DIVIDER = 6250000;
    
    // Counter for clock division
    reg [31:0] counter;
    
    // Clock division logic
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 32'd0;
            clk_out <= 1'b0;
        end else begin
            if (counter >= DIVIDER - 1) begin
                counter <= 32'd0;
                clk_out <= ~clk_out;  // Toggle output clock
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end
endmodule
