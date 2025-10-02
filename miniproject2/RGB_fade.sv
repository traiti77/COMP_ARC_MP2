// RGB fade

module fade #(
    parameter INC_DEC_INTERVAL = 12000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    parameter INC_DEC_MAX = 200,            // Transition to next state after 200 increments / decrements, which is 0.2s
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_R,
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_G,
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value_B
);

    // Define state variable values
    localparam [2:0] PWM_INC_G = 3'd0;
    localparam [2:0] PWM_DEC_G = 3'd1;
    localparam [2:0] PWM_INC_B = 3'd2;
    localparam [2:0] PWM_DEC_B = 3'd3;
    localparam [2:0] PWM_INC_R = 3'd4;
    localparam [2:0] PWM_DEC_R = 3'd5;

    // Declare state variables
    logic [2:0] current_state = PWM_INC_G;
    logic [2:0] next_state;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        pwm_value_R = PWM_INTERVAL - 1;
        pwm_value_G = 0;
        pwm_value_B = 0;
    end

    // Register the next state of the FSM
    always_ff @(posedge time_to_transition)
        current_state <= next_state;

    // Compute the next state of the FSM
    always_comb begin
        next_state = 3'bxxx;
        case (current_state)
            PWM_INC_G:
                next_state = PWM_DEC_R;
            PWM_DEC_R:
                next_state = PWM_INC_B;
            PWM_INC_B:
                next_state = PWM_DEC_G;
            PWM_DEC_G:
                next_state = PWM_INC_R;
            PWM_INC_R:
                next_state = PWM_DEC_B;
            PWM_DEC_B:
                next_state = PWM_INC_G;
        endcase
    end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        case (current_state)
            PWM_INC_R:
                pwm_value_R <= pwm_value_R + INC_DEC_VAL;
            PWM_DEC_R:
                pwm_value_R <= pwm_value_R - INC_DEC_VAL;
            PWM_INC_G:
                pwm_value_G <= pwm_value_G + INC_DEC_VAL;
            PWM_DEC_G:
                pwm_value_G <= pwm_value_G - INC_DEC_VAL;
            PWM_INC_B:
                pwm_value_B <= pwm_value_B + INC_DEC_VAL;
            PWM_DEC_B:
                pwm_value_B <= pwm_value_B - INC_DEC_VAL;
        endcase
    end

    // Implement counter for timing state transitions
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule
