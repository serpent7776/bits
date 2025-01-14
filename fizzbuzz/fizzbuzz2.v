module fizzbuzz2 #(
	parameter MAX_COUNT = 100
)(
	input wire clk,
	input wire reset,
	output reg fizz,
	output reg buzz,
	output reg num,
	output reg [$clog2(MAX_COUNT):0] number
);

reg [$clog2(MAX_COUNT):0] counter;

always @(posedge clk or posedge reset) begin
	if (reset) begin
		number <= 0;
		counter <= 1;
		fizz <= 0;
		buzz <= 0;
		num <= 0;
	end else begin
		counter <= counter + 1;

		number <= counter;
		fizz <= counter % 3 == 0;
		buzz <= counter % 5 == 0;
		num <= counter % 3 > 0 && counter % 5 > 0;
	end
end

endmodule
