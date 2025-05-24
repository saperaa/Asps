// Alamein Smart Parking System (ASPS)
// Main module integrating all components
module ASPS_Top (
    input wire clk,             // System clock
    input wire reset,           // System reset
    input wire IR_entry,        // Entry gate IR sensor (1 when no car, 0 when car present)
    input wire IR_exit,         // Exit gate IR sensor (1 when no car, 0 when car present)
    input wire [1:0] id,        // Car ID input
    output wire [1:0] car_count, // Number of cars currently in garage (0-3)
    output wire exit_count,     // Binary sensor value (0 or 1) for exit detection
    output wire [7:0] cost,     // Calculated parking cost (equal to parking time)
    output wire empty_flag,     // Flag indicating garage is empty
    output wire full_flag,      // Flag indicating garage is full
    output wire entry_detected, // Entry detection signal for debugging
    output wire exit_detected,  // Exit detection signal for debugging
    output wire [7:0] current_time_out // Current time value for display
);
    // Internal signals
    wire [7:0] current_time;    // Current time from global counter
    wire [7:0] parking_time;    // Calculated parking time from buffer
    wire buffer_read;           // Signal to read from buffer
    wire buffer_write;          // Signal to write to buffer

    // Global Time Counter
    TimeCounter time_counter (
        .clk(clk),
        .reset(reset),
        .time_value(current_time)
    );

    // Connect current_time to output for display
    assign current_time_out = current_time;

    // Entry/Exit Detection Module
    EntryExitDetector detector (
        .clk(clk),
        .reset(reset),
        .IR_entry(IR_entry),
        .IR_exit(IR_exit),
        .entry_detected(entry_detected),
        .exit_detected(exit_detected)
    );

    // Car Counter Module
    CarCounter counter (
        .clk(clk),
        .reset(reset),
        .entry_detected(entry_detected),
        .exit_detected(exit_detected),
        .car_count(car_count),
        .exit_count(exit_count),
        .empty_flag(empty_flag),
        .full_flag(full_flag)
    );

    // Timestamp Buffer Module - now calculates time difference directly
    TimestampBuffer buffer (
        .clk(clk),
        .reset(reset),
        .write_enable(buffer_write),
        .read_enable(buffer_read),
        .car_id(id),                // Pass car ID for indexing
        .current_time(current_time), // Pass current time from counter
        .data_out(parking_time)     // Output is now the time difference
    );

    // Cost Calculator Module - cost equals parking time
    CostCalculator cost_calc (
        .clk(clk),
        .reset(reset),
        .parking_time(parking_time),
        .exit_detected(exit_detected),
        .cost(cost)
    );

    // Main FSM Controller
    FSMController controller (
        .clk(clk),
        .reset(reset),
        .entry_detected(entry_detected),
        .exit_detected(exit_detected),
        .IR_entry(IR_entry),           // Pass IR sensor inputs to controller
        .IR_exit(IR_exit),             // Pass IR sensor inputs to controller
        .car_count(car_count),
        .id(id),
        .buffer_read(buffer_read),
        .buffer_write(buffer_write)
    );
endmodule
