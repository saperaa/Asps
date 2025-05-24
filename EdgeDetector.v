// Edge Detector Module
// Detects rising and falling edges of input signals
module EdgeDetector (
    input wire clk,         // System clock
    input wire reset,       // Reset signal
    input wire signal_in,   // Input signal
    output wire rising_edge, // Rising edge detected
    output wire falling_edge // Falling edge detected
);
    // Register to store previous state
    reg signal_prev;
    
    // Update previous state on each clock
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            signal_prev <= 1'b0;
        end else begin
            signal_prev <= signal_in;
        end
    end
    
    // Edge detection
    assign rising_edge = (signal_in == 1'b1) && (signal_prev == 1'b0);
    assign falling_edge = (signal_in == 1'b0) && (signal_prev == 1'b1);
endmodule
