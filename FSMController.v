module FSMController (
    input wire clk,
    input wire reset,
    input wire entry_detected,
    input wire exit_detected,
    input wire IR_entry,         // IR sensor inputs
    input wire IR_exit,          // IR sensor inputs
    input wire [1:0] car_count,
    input wire [1:0] id,
    output reg buffer_read,
    output reg buffer_write
);
    // FSM states with highly descriptive names for better waveform readability
    // Using 3-bit encoding for clear state visualization in waveform
    parameter GARAGE_EMPTY     = 3'b000;  // Empty state (0 cars)
    parameter GARAGE_ONE_CAR   = 3'b001;  // One car state
    parameter GARAGE_TWO_CARS  = 3'b010;  // Two cars state
    parameter GARAGE_FULL      = 3'b011;  // Three cars (full) state
    parameter PROCESS_ENTRY    = 3'b100;  // Processing entry
    parameter PROCESS_EXIT     = 3'b101;  // Processing exit
    parameter CALCULATE_COST   = 3'b110;  // Calculating cost

    // State registers
    reg [2:0] current_state, next_state;

    // State name strings for waveform display (not used in logic)
    reg [8*20:1] state_name;

    // Update state name whenever state changes (for waveform readability)
    always @(current_state) begin
        case (current_state)
            GARAGE_EMPTY:    state_name = "GARAGE_EMPTY";
            GARAGE_ONE_CAR:  state_name = "GARAGE_ONE_CAR";
            GARAGE_TWO_CARS: state_name = "GARAGE_TWO_CARS";
            GARAGE_FULL:     state_name = "GARAGE_FULL";
            PROCESS_ENTRY:   state_name = "PROCESS_ENTRY";
            PROCESS_EXIT:    state_name = "PROCESS_EXIT";
            CALCULATE_COST:  state_name = "CALCULATE_COST";
            default:         state_name = "UNKNOWN_STATE";
        endcase
    end

    // Flag to validate entry based on garage capacity
    reg entry_valid;

    // FSM state register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= GARAGE_EMPTY;  // Start in empty state
        end else begin
            current_state <= next_state;
        end
    end

    // Entry validation logic - only allow entry if garage is not full
    always @(*) begin
        entry_valid = entry_detected && (car_count < 2'b11);
    end

    // Control signal generation - only allow valid car IDs (1-3)
    always @(*) begin
        // Default values
        buffer_write = 1'b0;
        buffer_read = 1'b0;

        // Set buffer operations based on entry/exit events
        if (entry_valid) begin
            // Only write timestamp for valid car IDs (01, 10, 11)
            if (id == 2'b01 || id == 2'b10 || id == 2'b11) begin
                buffer_write = 1'b1;
            end
        end

        if (exit_detected) begin
            // Only read timestamp for valid car IDs (01, 10, 11)
            if (id == 2'b01 || id == 2'b10 || id == 2'b11) begin
                buffer_read = 1'b1;
            end
        end
    end

    // FSM next state logic with improved state names for better waveform readability
    always @(*) begin
        // Default value
        next_state = current_state;

        case (current_state)
            GARAGE_EMPTY: begin  // Empty state (0 cars)
                if (entry_valid) begin
                    next_state = PROCESS_ENTRY;
                end else begin
                    next_state = GARAGE_EMPTY;  // Stay in empty state
                end
            end

            PROCESS_ENTRY: begin
                // Transition based on car count after increment
                if (car_count == 2'b01) begin
                    next_state = GARAGE_ONE_CAR;
                end else if (car_count == 2'b10) begin
                    next_state = GARAGE_TWO_CARS;
                end else if (car_count == 2'b11) begin
                    next_state = GARAGE_FULL;
                end else begin
                    next_state = GARAGE_EMPTY;  // Fallback
                end
            end

            GARAGE_ONE_CAR: begin  // One car state
                if (exit_detected) begin
                    next_state = PROCESS_EXIT;
                end else if (entry_valid) begin
                    next_state = PROCESS_ENTRY;
                end else begin
                    next_state = GARAGE_ONE_CAR;  // Stay in one car state
                end
            end

            GARAGE_TWO_CARS: begin  // Two cars state
                if (exit_detected) begin
                    next_state = PROCESS_EXIT;
                end else if (entry_valid) begin
                    next_state = PROCESS_ENTRY;
                end else begin
                    next_state = GARAGE_TWO_CARS;  // Stay in two cars state
                end
            end

            GARAGE_FULL: begin  // Three cars (full) state
                if (exit_detected) begin
                    next_state = PROCESS_EXIT;
                end else begin
                    next_state = GARAGE_FULL;  // Stay in full state
                end
            end

            PROCESS_EXIT: begin
                next_state = CALCULATE_COST;
            end

            CALCULATE_COST: begin
                // Return to appropriate state based on count after decrement
                if (car_count == 2'b00) begin
                    next_state = GARAGE_EMPTY;
                end else if (car_count == 2'b01) begin
                    next_state = GARAGE_ONE_CAR;
                end else if (car_count == 2'b10) begin
                    next_state = GARAGE_TWO_CARS;
                end else begin
                    next_state = GARAGE_FULL;
                end
            end

            default: next_state = GARAGE_EMPTY;  // Default to empty state
        endcase
    end
endmodule
