`timescale 1us / 1ps

module ARTAU(
    input radar_echo,
    input scan_for_target,
    input [31:0] jet_speed,
    input [31:0] max_safe_distance,
    input RST,
    input CLK,
    output reg radar_pulse_trigger,
    output reg [31:0] distance_to_target,
    output reg threat_detected,
    output reg [1:0] ARTAU_state
);

reg innerCLK;

reg echo_waits;
reg echo_trigger;

reg[31:0] first_start_time;
reg[31:0] distance_start_time;
reg[31:0] distance_end_time;

reg[31:0] pulse_timer_start;
reg[31:0] listen_timer_start;
reg[31:0] asses_timer_start;

reg[1:0] next_state;
reg[1:0] pulse_counter;

reg[31:0] pulse_time;
reg[31:0] listen_time;
reg[31:0] asses_time;

reg[64:0] speed_of_light;
reg[64:0] microsecond;
reg[7:0]  clock_time;

reg[31:0] distance1;
reg[31:0] distance2;
reg signed [32:0] relative_distance;

initial begin
    innerCLK = 0;
    pulse_counter = 0;
    next_state = 0;
    radar_pulse_trigger = 0;
    speed_of_light = 300000000; // m/s
    microsecond = 1000000; // us
    clock_time = 50; // us

    pulse_time = 300; // us
    listen_time = 2000; // us
    asses_time = 3000; // us

    forever innerCLK = #1 ~innerCLK;
end



always @(posedge radar_echo or posedge echo_trigger) begin
    //$display("RADAR ECHO ", radar_echo, " ARTAU STATE ", ARTAU_state, " next_state ", $realtime - pulse_timer_start);

    case(ARTAU_state)
        2:begin // IDLE STATE
            echo_waits = 0;
            distance_end_time = $realtime;

            if(pulse_counter == 1) begin
                first_start_time = distance_start_time;
                distance1 = ((distance_end_time - distance_start_time) *speed_of_light) / (2 * microsecond);
                distance_to_target = distance1;

                radar_pulse_trigger = 1;
                pulse_timer_start = $realtime;
                next_state = 1; // EMIT STATE
            end else if (pulse_counter  == 2) begin
                distance2 = ((distance_end_time - distance_start_time) *speed_of_light) / (2 * microsecond);
                distance_to_target = distance2;

                relative_distance = (distance2 + ((jet_speed*(distance_end_time- first_start_time))/microsecond) - distance1);
                //$display("DISTANCE 1 ", distance1, " DISTANCE 2 ", distance2, " RELATIVE DISTANCE ", relative_distance);
                if (max_safe_distance > distance2 && relative_distance < 0) begin
                    threat_detected = 1;
                end else begin
                    threat_detected = 0;
                end

                asses_timer_start = $realtime;
                next_state = 3; // ASSESS STATE
            end 
        end

        default:begin
            echo_waits = 1;
        end

    endcase
end

always @(posedge scan_for_target) begin
    //$display("SCAN FOR TARGET ", scan_for_target, " ARTAU STATE ", ARTAU_state, " ", next_state, " ", $realtime);
    case(ARTAU_state)

        0:begin // IDLE STATE
            pulse_timer_start = $realtime;
            pulse_counter = 0;
            radar_pulse_trigger = 1;
            #10;
            next_state = 1; // EMIT STATE
        end

        3: begin // ASSESS STATE
            pulse_timer_start = $realtime;
            pulse_counter = 0;
            radar_pulse_trigger = 1;
            #10;
            next_state = 1; // EMIT STATE
        end

    endcase
end

always @(posedge CLK) begin
    ARTAU_state = next_state;
end


always @(innerCLK) begin
    //$display("ALL");
    case(ARTAU_state)
            1:begin 
                if (radar_pulse_trigger) begin
                    if ($realtime - pulse_timer_start >= pulse_time) begin
                        
                        radar_pulse_trigger = 0;
                        pulse_counter = pulse_counter + 1;

                        listen_timer_start = $realtime;
                        distance_start_time = listen_timer_start;
                        
                        next_state = 2; // LISTEN STATE
                        
                    end
                end
            end
            
            2: begin
                
                if ($realtime - listen_timer_start >= listen_time) begin
                    distance_to_target = 0;
                    next_state = 0; // IDLE STATE
                end else begin
                    if (echo_waits) begin
                        echo_trigger = 1;
                    end
                end
            end

            3: begin // ASSESS STATE
                if ($realtime - asses_timer_start >= asses_time) begin
                    distance_to_target = 0;
                    next_state = 0; // IDLE STATE
                end 
            end

        endcase
end

always @(posedge RST) begin
    if (RST) begin
        radar_pulse_trigger = 0;
        distance_to_target = 0;
        threat_detected = 0;
        ARTAU_state = 0;
        next_state = 0;
    end
end


endmodule