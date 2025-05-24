module TimestampBuffer (
    input wire clk,
    input wire reset,
    input wire write_enable,         // Save time when a car enters
    input wire read_enable,          // Retrieve time when a car exits
    input wire [1:0] car_id,         // Car ID (1-3) for indexing the buffer
    input wire [7:0] current_time,   // Current time from global counter
    output reg [7:0] data_out        // Output the timestamp difference (8-bit for synthesis)
);
    // Direct-indexed buffer: store timestamps for 3 cars
    reg [7:0] buffer [0:2];          // Storage for 3 cars (8-bit for hardware implementation)
    reg [2:0] car_present;           // Bit flags to track which car IDs are present

    // Convert external car ID (1-3) to internal index (0-2)
    // For car_id = 01 (1), index = 0
    // For car_id = 10 (2), index = 1
    // For car_id = 11 (3), index = 2
    // Default to 0 for invalid IDs
    reg [1:0] buffer_index;

    // Car ID mapping exactly as specified in documentation
    always @(*) begin
        case (car_id)
            2'b01: buffer_index = 2'b00;  // Car ID 01 (1) -> Index 0
            2'b10: buffer_index = 2'b01;  // Car ID 10 (2) -> Index 1
            2'b11: buffer_index = 2'b10;  // Car ID 11 (3) -> Index 2
            default: buffer_index = 2'b00; // Default to index 0 for invalid IDs
        endcase
    end

    // Combinational logic to calculate time difference immediately
    always @(*) begin
        if (reset) begin
            data_out = 8'd0;
        end else if (read_enable && car_present[buffer_index]) begin
            // Calculate time difference
            if (current_time >= buffer[buffer_index]) begin
                data_out = current_time - buffer[buffer_index];
            end else begin
                // Handle wrap-around case
                data_out = (8'hFF - buffer[buffer_index]) + current_time + 1;
            end

            // Ensure minimum cost of 1 unit for very short parking times
            if (data_out == 8'd0) begin
                data_out = 8'd1;  // Minimum cost of 1 unit
            end
        end else begin
            data_out = 8'd0;  // Default value when not reading or car not present
        end
    end

    // Sequential logic to update buffer and car_present flags
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer[0] <= 8'd0;
            buffer[1] <= 8'd0;
            buffer[2] <= 8'd0;
            car_present <= 3'b000;   // No cars present initially
        end else begin
            // Write operation - store current time indexed by car_id
            if (write_enable) begin
                buffer[buffer_index] <= current_time;    // Save current time for this car
                car_present[buffer_index] <= 1'b1;       // Mark this car as present
            end

            // Read operation - update car_present flag
            if (read_enable && car_present[buffer_index]) begin
                car_present[buffer_index] <= 1'b0;       // Mark this car as no longer present
            end
        end
    end
endmodule
