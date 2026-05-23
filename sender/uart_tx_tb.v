`timescale 1ns/1ps

module uart_tx_tb;

    // Testbench signals
    reg clk;
    reg aresetn;
    reg start;
    reg [7:0] data;
    wire tx;
    wire done;

    // Instantiate the uart_tx module
    uart_tx uut (
        .clk(clk),
        .arst(aresetn),
        .start(start),
        .data(data),
        .tx(tx),
        .done(done)
    );

    // Generate 50 MHz clock (period = 20 ns)
    always #10 clk = ~clk;

    initial begin
        $display("Starting UART Transmitter Test...");
        $dumpfile("uart_tx_tb.vcd");  // For waveform viewing (optional)
        $dumpvars(0, uart_tx_tb);

        // Initial conditions
        clk = 0;
        aresetn = 1;
        start = 0;
        data = 8'h00;

        // Reset pulse
        #50;
        aresetn = 0;

        // Wait a few cycles
        #100;

        // Send a byte (e.g., 0xA5 = 10100101)
        data = 8'hA5;
        start = 1;

        #20;     // one clock cycle
        start = 0;  // deassert start

        // Wait enough time for transmission (10 bits * 434 cycles * 20 ns)
        // Total = ~87 us (rounded up)
        #50000;

        #100;
        data = 8'hB1;
        #40000;
        start = 1;

        #20;     // one clock cycle
        start = 0;  // deassert start

      #130000;


        $display("Test completed.");
        $finish;
    end

endmodule
