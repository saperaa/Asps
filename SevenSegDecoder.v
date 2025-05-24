// Seven-Segment Display Decoder
// Converts 4-bit binary input to 7-segment display output
module SevenSegDecoder (
    input wire [3:0] binary_in,  // 4-bit binary input (0-15)
    output reg [6:0] segments    // 7-segment display output (active low)
);
    // Seven-segment encoding for digits 0-15
    // Segments are ordered as: gfedcba (active low)
    always @(*) begin
        case (binary_in)
            4'b0000: segments = 7'b1000000; // 0
            4'b0001: segments = 7'b1111001; // 1
            4'b0010: segments = 7'b0100100; // 2
            4'b0011: segments = 7'b0110000; // 3
            4'b0100: segments = 7'b0011001; // 4
            4'b0101: segments = 7'b0010010; // 5
            4'b0110: segments = 7'b0000010; // 6
            4'b0111: segments = 7'b1111000; // 7
            4'b1000: segments = 7'b0000000; // 8
            4'b1001: segments = 7'b0010000; // 9
           
            default: segments = 7'b1111111; // All segments off
        endcase
    end
endmodule
