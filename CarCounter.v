// Car Counter Module
// Counts cars in the garage, maintains empty/full flags, and provides exit sensor value
module CarCounter (
    input wire clk,
    input wire reset,
    input wire entry_detected,
    input wire exit_detected,
    output reg [1:0] car_count,
    output reg exit_count,  // Binary sensor value (0 or 1) for exit detection
    output wire empty_flag,
    output wire full_flag
);
    // Counter logic for car_count
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            car_count <= 2'b00;
        end else begin
            // Handle entry
            if (entry_detected && car_count < 2'b11) begin
                car_count <= car_count + 1'b1;
            end
            // Handle exit
            else if (exit_detected && car_count > 2'b00) begin
                car_count <= car_count - 1'b1;
            end
        end
    end

    // Logic for exit_count as a binary sensor
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            exit_count <= 1'b0;
        end else begin
            // Set exit_count to 1 when a car exits and there are cars in the garage
            // Otherwise, set it to 0
            if (exit_detected && car_count > 2'b00) begin
                exit_count <= 1'b1;
            end else begin
                exit_count <= 1'b0;
            end
        end
    end

    // Immediate flag assignment based on current count
    assign empty_flag = (car_count == 2'b00);
    assign full_flag = (car_count == 2'b11);
endmodule
