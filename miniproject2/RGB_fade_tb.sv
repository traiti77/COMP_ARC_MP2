//RGB fade mini project 2
`timescale 10ns/10ns
`include "top.sv"

module RGB_fade_tb;

    parameter PWM_INTERVAL = 1200;     // CLK freq is 12MHz, so 1200 cycles is 100us

    logic    clk = 0;
    logic    red;
    logic    green;
    logic    blue;

    top # (
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u0 (
        .clk            (clk), 
        .red            (red),
        .green          (green),
        .blue           (blue)
    );
// sets up simulation and determines when it terminates
    initial begin
        $dumpfile("RGB_fade.vcd");
        $dumpvars(0, RGB_fade_tb);
        #60000000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end
    
endmodule