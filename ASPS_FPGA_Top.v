// ASPS FPGA Top Module
// Top-level module for DE10-Lite FPGA implementation
module ASPS_FPGA_Top (
    // DE10-Lite board inputs
    input wire MAX10_CLK1_50,     // 50MHz clock
    input wire [1:0] KEY,         // Push buttons (active low)
    input wire [9:0] SW,          // Slide switches

    // DE10-Lite board outputs
    output wire [9:0] LEDR,       // Red LEDs
    output wire [7:0] HEX0,       // Seven-segment display 0
    output wire [7:0] HEX1,       // Seven-segment display 1
    output wire [7:0] HEX2,       // Seven-segment display 2
    output wire [7:0] HEX3,       // Seven-segment display 3
    output wire [7:0] HEX4,       // Seven-segment display 4
    output wire [7:0] HEX5        // Seven-segment display 5
);
    // Signal mapping
    wire clk_50MHz = MAX10_CLK1_50;
    wire reset = SW[0];           // Reset switch (active high)

    // Map buttons and switches to inputs
    wire IR_entry_raw = ~KEY[0];  // Entry sensor (active low on board)
    wire IR_exit_raw = ~KEY[1];   // Exit sensor (active low on board)
    wire [1:0] id = SW[2:1];      // Car ID from switches (SW[1] is LSB, SW[2] is MSB)

    // Internal signals
    wire clk_250ms;               // 250ms clock
    wire IR_entry_debounced;      // Debounced entry sensor
    wire IR_exit_debounced;       // Debounced exit sensor
    wire [1:0] car_count;         // Number of cars in garage
    wire exit_sensor;             // Exit sensor value
    wire [7:0] cost;              // Parking cost
    wire empty_flag;              // Garage empty flag
    wire full_flag;               // Garage full flag
    wire entry_detected;          // Entry detection signal
    wire exit_detected;           // Exit detection signal
    wire [7:0] current_time;      // Current time value from TimeCounter

    // Seven-segment display signals
    wire [6:0] hex0_segments;     // Car count display
    wire [6:0] hex1_segments;     // Cost display (lower digit)
    wire [6:0] hex2_segments;     // Cost display (upper digit)
    wire [6:0] hex3_segments;     // Car ID display
    wire [6:0] hex4_segments;     // Timer display (lower digit)
    wire [6:0] hex5_segments;     // Timer display (upper digit)

    // Clock divider to generate 250ms clock
    ClockDivider clock_div (
        .clk_in(clk_50MHz),
        .reset(reset),
        .clk_out(clk_250ms)
    );

    // Debouncer for entry sensor
    Debouncer entry_debouncer (
        .clk(clk_50MHz),
        .reset(reset),
        .button_in(IR_entry_raw),
        .button_out(IR_entry_debounced)
    );

    // Debouncer for exit sensor
    Debouncer exit_debouncer (
        .clk(clk_50MHz),
        .reset(reset),
        .button_in(IR_exit_raw),
        .button_out(IR_exit_debounced)
    );

    // Main ASPS system
    ASPS_Top asps (
        .clk(clk_250ms),
        .reset(reset),
        .IR_entry(IR_entry_debounced),
        .IR_exit(IR_exit_debounced),
        .id(id),
        .car_count(car_count),
        .exit_count(exit_sensor),
        .cost(cost),
        .empty_flag(empty_flag),
        .full_flag(full_flag),
        .entry_detected(entry_detected),
        .exit_detected(exit_detected),
        .current_time_out(current_time)
    );

    // Seven-segment decoders
    // HEX0 - Car count
    SevenSegDecoder hex0_decoder (
        .binary_in({2'b00, car_count}),
        .segments(hex0_segments)
    );

    // HEX1 - Cost lower digit
    SevenSegDecoder hex1_decoder (
        .binary_in(cost[3:0]),
        .segments(hex1_segments)
    );

    // HEX2 - Cost upper digit
    SevenSegDecoder hex2_decoder (
        .binary_in(cost[7:4]),
        .segments(hex2_segments)
    );

    // HEX3 - Car ID
    SevenSegDecoder hex3_decoder (
        .binary_in({2'b00, id}),
        .segments(hex3_segments)
    );

    // HEX4 - Timer lower digit
    SevenSegDecoder hex4_decoder (
        .binary_in(current_time[3:0]),
        .segments(hex4_segments)
    );

    // HEX5 - Timer upper digit
    SevenSegDecoder hex5_decoder (
        .binary_in(current_time[7:4]),
        .segments(hex5_segments)
    );

    // Map outputs to board
    assign HEX0 = {1'b1, hex0_segments};  // Add decimal point (off)
    assign HEX1 = {1'b1, hex1_segments};  // Add decimal point (off)
    assign HEX2 = {1'b1, hex2_segments};  // Add decimal point (off)
    assign HEX3 = {1'b1, hex3_segments};  // Add decimal point (off)
    assign HEX4 = {1'b1, hex4_segments};  // Add decimal point (off)
    assign HEX5 = {1'b1, hex5_segments};  // Add decimal point (off)

    // Map LEDs
    assign LEDR[0] = empty_flag;          // Empty flag
    assign LEDR[1] = full_flag;           // Full flag
    assign LEDR[2] = entry_detected;      // Entry detected
    assign LEDR[3] = exit_detected;       // Exit detected
    assign LEDR[4] = exit_sensor;         // Exit sensor value
    assign LEDR[9:5] = 5'b00000;          // Unused LEDs off
endmodule
