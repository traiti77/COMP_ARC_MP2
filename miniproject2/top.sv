`include "RGB_fade.sv"
`include "RGB_pwm.sv"

// RGB Fade top level module

module top #(
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_R, pwm_value_G, pwm_value_B;
    logic pwm_out_R, pwm_out_G, pwm_out_B;

    fade #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u1 (
        .clk            (clk), 
        .pwm_value_R      (pwm_value_R),
        .pwm_value_G      (pwm_value_G),
        .pwm_value_B      (pwm_value_B)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2R (
        .clk            (clk), 
        .pwm_value      (pwm_value_R), 
        .pwm_out        (pwm_out_R)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2B (
        .clk            (clk), 
        .pwm_value      (pwm_value_B), 
        .pwm_out        (pwm_out_B)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2G (
        .clk            (clk), 
        .pwm_value      (pwm_value_G), 
        .pwm_out        (pwm_out_G)
    );


    assign RGB_R = ~pwm_out_R;
    assign RGB_G = ~pwm_out_G;
    assign RGB_B = ~pwm_out_B;

endmodule