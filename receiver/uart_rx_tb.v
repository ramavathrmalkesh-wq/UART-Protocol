`timescale 1ns/1ps

module uart_rx_tb;

    // Testbench signals
    reg clk;
    reg arst;
    reg rx;
    wire [7:0] rx_data;
    wire done;

    // Instantiate the uart_rx module
    uart_rx uut (
        .clk(clk),
        .arst(arst),
        .rx(rx),
        .rx_data(rx_data),
        .done(done)
    );

    reg [7:0] data;
    integer i;

    // Generate 50 MHz clock (period = 20 ns)
    always #10 clk = ~clk;

    initial begin
        $display("Starting UART Receiver Test...");
        $dumpfile("uart_rx_tb.vcd");  // For waveform viewing (optional)
        $dumpvars(0, uart_rx_tb);

        clk = 0;
        arst = 1;
        rx = 1; // Line idle initially
        #20;

        arst = 0; // Release reset
        #100;

        data = $urandom_range(0, 255);  // Fixed to proper range
        rx = 0;                         // Start bit
        #8680;

        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];
            #8680;
        end

        rx = 1;                         // Stop bit
        #8680;

        #100;

        data = $urandom_range(0, 255);
        rx = 0;                         // Start bit
        #8680;

        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];
            #8680;
        end

        rx = 1;                         // Stop bit
        #8680;

        $display("Test completed.");
        $finish;
    end

endmodule
