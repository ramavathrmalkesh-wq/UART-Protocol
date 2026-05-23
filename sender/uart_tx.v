module uart_tx(
	input clk,
	input arst,
	input start,
	input [7:0]data,
	output reg tx,
	output reg done
);

	parameter IDLE = 2'b00, 
	          START_BIT = 2'b01, 
	          DATA_BITS = 2'b10, 
	          STOP_BIT = 2'b11;


	reg [1:0] state = IDLE;				// 0 = idle, 1 = start bit, 2 = data bits, 3 = stop bit
	reg [7:0] r_data;
	reg [2:0] bit_cnt;
	reg [8:0] baud_cnt;

	always @(posedge clk , posedge arst) begin
		if(arst) begin
			state <= IDLE;
			r_data <= 8'd0;
			baud_cnt <= 9'd0;
			bit_cnt <= 3'd0;
			tx <= 1'b1;
		end else begin
			case(state) 
				IDLE: begin
					tx <= 1'b1;
					done <= 1'b0;
					baud_cnt <= 9'd0;
					if(start == 1'b1) begin
						state <= START_BIT;
						r_data <= data;
					end else begin
						state <= IDLE;
					end
				end

				START_BIT: begin
					tx <= 1'b0;
					if(baud_cnt == 9'd434) begin
						baud_cnt <= 9'd0;
						bit_cnt <= 3'd0;
						state <= DATA_BITS;
					end else begin
						baud_cnt <= baud_cnt + 1'b1;
						state <= START_BIT;
					end
				end

				DATA_BITS: begin
					tx <= r_data[bit_cnt];
					if(baud_cnt == 9'd434) begin
						if(bit_cnt == 3'd7) begin
							bit_cnt <= 3'd0;
							state <= STOP_BIT;
						end else begin
							bit_cnt <= bit_cnt + 1'b1;
							state <= DATA_BITS;
						end
						baud_cnt <= 9'd0;
					end else begin
						baud_cnt <= baud_cnt + 1'b1;
						state <= DATA_BITS;
					end
				end

				STOP_BIT: begin
					tx <= 1'b1;
					if(baud_cnt == 9'd434) begin
						baud_cnt <= 9'd0;
						done <= 1'b1;
						state <= IDLE;
					end else begin
						baud_cnt <= baud_cnt + 1'b1;
						state <= STOP_BIT;
					end
				end

			endcase
		end
	end

endmodule





// module uart_tx(
// 	input clk,
// 	input arstn,
// 	input start,
// 	input [7:0]data,
// 	output reg tx,
// 	output reg done
// );

// 	reg state;				// 0 = idle, 1 = sending
// 	reg [7:0] r_data;
// 	reg [8:0] baud_cnt;
// 	reg bit_flag;
// 	reg [3:0] bit_cnt;
	
//     // State & bit count logic
//    always @(posedge clk or negedge arstn) begin
// 		if (!arstn) begin
// 			state <= 1'b0;
//          	bit_cnt <= 4'd0;
//          	r_data <= 8'd0;
// 		end else begin
// 			if (state == 1'b0) begin
// 				if (start) begin
// 					state <= 1'b1;
//                		r_data <= data;
//                		bit_cnt <= 4'd0;
//             	end
// 			end else begin  // state == 1 (sending)
// 				if (bit_flag) begin
// 					bit_cnt <= bit_cnt + 1'b1;
//                		if (bit_cnt == 4'd9)  // stop bit just sent
// 						state <= 1'b0;
// 				end
//          	end
// 		end
//    end
	
// 	// baud counter logic
// 	always @(posedge clk, negedge arstn) begin
// 		if(~arstn) begin
// 			baud_cnt <= 9'd0;
// 			bit_flag <= 1'b0;
// 		end else begin
// 			bit_flag <= 1'b0;
// 			if(state) begin
// 				if(baud_cnt == 9'd434) begin
// 					baud_cnt <= 9'd0;
// 					bit_flag <= 1'b1;
// 				end else begin
// 					baud_cnt <= baud_cnt + 1'b1;
// 				end
// 			end else begin
// 				baud_cnt <= 9'd0;
// 			end
// 		end	
// 	end
	
// 	// tx logic
// 	always @(posedge clk, negedge arstn) begin
// 		if(~arstn) begin
// 			tx <= 1'b1;
// 			done <= 1'b0;
// 		end else begin
// 			done <= 1'b0;
// 			if(bit_flag && state) begin
// 				case(bit_cnt)
// 					4'd0: tx <= 1'b0;
// 					4'd1: tx <= r_data[0];
// 					4'd2: tx <= r_data[1];
// 					4'd3: tx <= r_data[2];
// 					4'd4: tx <= r_data[3];
// 					4'd5: tx <= r_data[4];
// 					4'd6: tx <= r_data[5];
// 					4'd7: tx <= r_data[6];
// 					4'd8: tx <= r_data[7];
// 					4'd9: tx <= 1'b1;
// 					default: tx <= 1'b1;
// 				endcase
// 				if (bit_cnt == 4'd9) done <= 1'b1;
// 			end else if(~state) begin
// 				tx <= 1'b1;
// 			end
// 		end 
// 	end
// endmodule