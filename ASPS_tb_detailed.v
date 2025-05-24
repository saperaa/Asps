// Simplified Test Bench for Alamein Smart Parking System
// Provides clear test cases with minimal output
module ASPS_tb_detailed;
    // Inputs
    reg clk;
    reg reset;
    reg IR_entry;
    reg IR_exit;
    reg [1:0] id;

    // Outputs
    wire [1:0] car_count;
    wire [3:0] exit_count;  // Total number of exits
    wire [7:0] cost;
    wire empty_flag;
    wire full_flag;

    // Internal signals for debugging
    wire entry_detected;
    wire exit_detected;

    // Simplified test bench with minimal output

    // For tracking entry/exit times and costs
    reg [31:0] entry_times [1:3];  // Store entry times for cars 1-3
    reg [31:0] exit_times [1:3];   // Store exit times for cars 1-3
    reg [7:0] individual_costs [1:3]; // Store costs for cars 1-3
    reg [7:0] total_cost;          // Accumulated cost from all cars

    // Cost rate parameter
    parameter COST_RATE = 2;       // Cost per time unit

    // Instantiate the Unit Under Test (UUT)
    ASPS_Top uut (
        .clk(clk),
        .reset(reset),
        .IR_entry(IR_entry),
        .IR_exit(IR_exit),
        .id(id),
        .car_count(car_count),
        .exit_count(exit_count),
        .cost(cost),
        .empty_flag(empty_flag),
        .full_flag(full_flag),
        .entry_detected(entry_detected),
        .exit_detected(exit_detected)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period clock
    end

    // Helper tasks

    // Task to display test case header with minimal formatting
    task display_test_header;
        input [8*50:1] test_name;
        begin
            $display("\n# %s", test_name);
        end
    endtask

    // Task to display system state with all information but simplified formatting
    task display_system_state;
        begin
            // Keep all information in the header as requested
            $display("Time | Reset | Entry | Exit | Count | Cost | Empty | Full");
            $display("%4t |   %1b   |   %1b   |  %1b   |   %1d   | %4d |   %1b   |  %1b   ",
                     $time, reset, IR_entry, IR_exit, car_count, cost, empty_flag, full_flag);
            $display("-----------------------------------------------------------------------------");
        end
    endtask

    // Task to simulate a car entering the garage with minimal output
    task car_enter;
        input [1:0] car_id;
        begin
            // Display car entry event
            $display("# Car #%0d entered", car_id);

            // Set car ID
            id = car_id;

            // Car is already at entry gate (IR_entry already 0)
            // Display current system state
            display_system_state();

            // Wait for processing
            #20;

            // Car passes entry beam - this will trigger entry_detected on the next clock
            IR_entry = 1;  // Car passes entry beam
            #10; // Wait for a clock cycle to detect the edge
            entry_times[car_id] = $time;  // Record entry time

            // Wait for another clock cycle to ensure entry_detected is processed
            #10;

            // Display updated system state
            display_system_state();

            // Wait for system to process
            #20;

            // Reset IR_entry to 0 for next car (beam broken)
            IR_entry = 0;
        end
    endtask

    // Task to simulate a car exiting the garage with minimal output
    task car_exit;
        input [1:0] car_id;
        begin
            // Display car exit event
            $display("# Car #%0d exited", car_id);

            // Set car ID
            id = car_id;

            // Display current system state
            display_system_state();

            // Car passes exit beam (triggers exit_detected on rising edge)
            $display("# Exit detection: IR_exit changing from 0 to 1");
            IR_exit = 1;  // Car passes exit beam - this triggers exit_detected
            #10; // Wait for a clock cycle to detect the edge
            exit_times[car_id] = $time;  // Record exit time

            // Wait for another clock cycle to ensure exit_detected is processed
            #10;

            // Wait for processing
            #20;
            $display("# Car count after exit: %0d", car_count);
            $display("# Total exits so far: %0d", exit_count);

            // Display system state with IR_exit = 1 (car passing through exit)
            display_system_state();

            // Reset IR_exit to 0 for next car
            IR_exit = 0;
            #20;

            // Calculate time spent and cost
            individual_costs[car_id] = ((exit_times[car_id] - entry_times[car_id])/10) * COST_RATE;
            if (individual_costs[car_id] == 0) individual_costs[car_id] = COST_RATE; // Minimum cost

            total_cost = total_cost + individual_costs[car_id];

            // Display updated system state with IR_exit = 0 (no car at exit)
            display_system_state();

            // Wait for system to process
            #20;
        end
    endtask

    // Simplified initialization - no waveform dumping
    initial begin
        // No waveform dumping for simplified output
        $dumpfile("asps_simulation.vcd");
        $dumpvars(0, ASPS_tb_detailed);
    end

    // Test scenarios
    initial begin
        // Initialize inputs and variables - start with reset=0 and both beams broken
        reset = 0;
        IR_entry = 0;  // Car present (beam broken)
        IR_exit = 0;   // Car present (beam broken) - initialize to 0 to fix the "always 1" issue
        id = 1;        // Start with car ID 1
        total_cost = 0;

        // Display simulation start
        $display("# SIMULATION STARTED");

        // Display initial state
        display_system_state();
        #10;

        // Apply reset
        reset = 1;
        #20;

        // Release reset
        reset = 0;
        #20;

        // Test Case 1: Car enters the garage
        display_test_header("CAR ENTERS THE GARAGE");
        car_enter(2'b01);  // Car 1 enters

        // Test Case 2: Second car enters
        #30;
        display_test_header("SECOND CAR ENTERS");
        car_enter(2'b10);  // Car 2 enters

        // Test Case 3: Third car enters (garage full)
        #40;
        display_test_header("THIRD CAR ENTERS");
        car_enter(2'b11);  // Car 3 enters

        // Test Case 4: Try to enter when garage is full
        #25;
        display_test_header("TRY TO ENTER WHEN GARAGE IS FULL");

        // Fourth car tries to enter
        id = 2'b01;    // Reuse car ID 1
        IR_entry = 0;  // Car breaks entry beam
        #20;
        IR_entry = 1;  // Car passes entry beam
        #20;
        display_system_state();

        // Reset IR_entry to 0 for next car
        IR_entry = 0;
        #20;

        // Test Case 5: First car exits
        display_test_header("FIRST CAR EXITS");
        car_exit(2'b01);  // Car 1 exits

        // Test Case 6: Second car exits
        #50;
        display_test_header("SECOND CAR EXITS");
        car_exit(2'b10);  // Car 2 exits

        // Test Case 7: Third car exits
        #80;
        display_test_header("THIRD CAR EXITS");
        car_exit(2'b11);  // Car 3 exits

        // Test Case 8: Try to exit when garage is empty
        #20;
        display_test_header("TRY TO EXIT WHEN GARAGE IS EMPTY");

        // Car tries to exit when garage is empty
        id = 2'b01;
        display_system_state();

        // Car passes exit beam (triggers exit_detected on rising edge)
        $display("# Exit detection: IR_exit changing from 0 to 1 (empty garage)");
        IR_exit = 1;   // Car passes exit beam - this triggers exit_detected
        #10; // Wait for a clock cycle to detect the edge

        // Wait for another clock cycle to ensure exit_detected is processed
        #10;
        $display("# Car count after exit attempt: %0d", car_count);
        $display("# Total exits so far: %0d", exit_count);
        // Display system state with IR_exit = 1 (car passing through exit)
        display_system_state();

        // Reset IR_exit to 0 for next car
        IR_exit = 0;
        #20;

        // Display updated system state with IR_exit = 0 (no car at exit)
        display_system_state();

        // Test Case 9: Reset the system
        display_test_header("RESET THE SYSTEM");
        reset = 1;
        #20;
        reset = 0;
        display_system_state();
        #20;

        // End simulation
        #20;
        $display("\n# SIMULATION COMPLETED");
        $finish;
    end

    // Monitor output changes - disabled to use our custom display instead
    initial begin
        // We're using our custom display_system_state task instead of $monitor
        // This gives us better control over the output formatting
    end
endmodule
