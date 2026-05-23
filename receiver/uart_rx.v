module uart_rx(
    input clk,
    input rx,
    input arst,
    output reg [7:0] rx_data,
    output reg done
);

    parameter IDLE = 2'b00, 
	          START_BIT = 2'b01, 
	          DATA_BITS = 2'b10, 
	          STOP_BIT = 2'b11;

    reg [1:0] state = IDLE;				// 0 = idle, 1 = start bit, 2 = data bits, 3 = stop bit
	reg [2:0] bit_cnt;
	reg [8:0] baud_cnt;

    reg ff_rx1, ff_rx2;

    always @(posedge clk, posedge arst) begin
        if(arst) begin
            state     <= IDLE;
            baud_cnt  <= 9'd0;
            bit_cnt   <= 3'd0;
            rx_data   <= 8'd0;
            done      <= 1'b0;
            ff_rx1    <= 1'b1;
            ff_rx2    <= 1'b1;
        end else begin
            ff_rx1 <= rx;
            ff_rx2 <= ff_rx1;
            case(state)
                IDLE: begin
                    baud_cnt <= 0;
                    bit_cnt <= 0;
                    done <= 0;
                    if(~ff_rx2) begin
                        state <= START_BIT;
                    end else begin
                        state <= IDLE;
                    end
                end
                START_BIT: begin
                    if(baud_cnt == 9'd216) begin
                        if(~ff_rx2) begin
                            baud_cnt <= 0;
                            state <= DATA_BITS;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                        state <= START_BIT;
                    end
                end
                DATA_BITS: begin
                    if(baud_cnt == 9'd433) begin
                        rx_data[bit_cnt] <= ff_rx2;
                        baud_cnt <= 0;
                        if(bit_cnt==3'd7) begin
                            state <= STOP_BIT;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                            state <= DATA_BITS;
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                        state <= DATA_BITS;
                    end
                end
                STOP_BIT: begin
                    if(baud_cnt == 9'd433) begin
                        baud_cnt <= 0;
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