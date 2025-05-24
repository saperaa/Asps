// Entry/Exit Detector Module
// Detects cars at entry and exit gates using edge detection
module EntryExitDetector (
    input wire clk,
    input wire reset,
    input wire IR_entry,
    input wire IR_exit,
    output reg entry_detected,
    output reg exit_detected
);
    // Store previous state of IR sensors
    reg IR_entry_prev, IR_exit_prev;

    // Edge detection logic with pulse generation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IR_entry_prev <= 1'b0;  // Assume no car initially (reset to 0)
            IR_exit_prev <= 1'b0;   // Assume no car initially (reset to 0)
            entry_detected <= 1'b0;
            exit_detected <= 1'b0;
        end else begin
            // Default values - pulses last only one clock cycle
            entry_detected <= 1'b0;
            exit_detected <= 1'b0;

            // Entry detection - Generate a pulse on rising edge (button press)
            if ((IR_entry_prev == 1'b0) && (IR_entry == 1'b1)) begin
                entry_detected <= 1'b1;  // Generate a pulse for one clock cycle
            end

            // Exit detection - Generate a pulse on falling edge (switch toggled OFF)
            // SW[0] is toggled ON then OFF to simulate exit
            if ((IR_exit_prev == 1'b1) && (IR_exit == 1'b0)) begin
                exit_detected <= 1'b1;  // Generate a pulse for one clock cycle
            end

            // Update previous states
            IR_entry_prev <= IR_entry;
            IR_exit_prev <= IR_exit;
        end
    end
endmodule
