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
reg run_trigger;

reg[31:0] first_start_time;
reg[31:0] distance_start_time;
reg[31:0] distance_end_time;

reg[31:0] pulse_emition_timer;
reg[31:0] listen_to_echo_timer;
reg[31:0] status_update_timer;

reg[1:0] next_state;
reg[1:0] pulse_counter;


reg[64:0] speed_of_light;
reg[64:0] microsecond;

reg[31:0] distance1;
reg[31:0] distance2;
reg signed [32:0] relative_distance;

initial begin
    pulse_counter = 0;
    pulse_emition_timer = 0;
    listen_to_echo_timer = 0;
    status_update_timer = 0;
    next_state = 0;
    radar_pulse_trigger = 0;
    speed_of_light = 300000000; // m/s
    microsecond = 1000000; // us
end
/*
always @(posedge radar_echo) begin
    if (distance_start_time > 0) begin
        if (distance_end_time > 0) begin
            distance_end_time = $realtime;
            distance2 = ((distance_end_time - distance_start_time) *speed_of_light) / (2 * microsecond);
            distance_to_target = distance2;

            relative_distance = (distance2 + ((jet_speed*(distance_end_time- first_start_time))/microsecond) - distance1);

            if (max_safe_distance > distance2 && relative_distance < 0) begin
                threat_detected = 1;
            end else begin
                threat_detected = 0;
            end

        end else begin
            distance_end_time = $realtime;
            first_start_time = distance_start_time; 
            distance1 = ((distance_end_time - distance_start_time) *speed_of_light) / (2 * microsecond);
            distance_to_target = distance1;
        end
    end
end

always @(negedge radar_pulse_trigger) begin
    distance_start_time = $realtime;
    //$display("trigger: " , $realtime);
end
*/

always @(posedge CLK or negedge CLK) begin
    //$display(timevar);
    timevar = timevar + 1;

    case (ARTAU_state)

            0:begin
                pulse_counter = 0;
            end

            1:begin
                //$display("pulse_emition_timer: %d", timevar- pulse_emition_timer);
                if (timevar - pulse_emition_timer > 6) begin
                    run_trigger = 1;
                end

            end

            2:begin
                if (timevar -listen_to_echo_timer >= 39) begin
                    run_trigger = 1;
                end
            end

            3:begin
                if (timevar - status_update_timer >= 60) begin
                    run_trigger = 1;
                end
            end

        endcase

end




always@(posedge CLK or posedge RST) begin
    if (RST) begin
        radar_pulse_trigger = 0;
        distance_to_target = 0;
        threat_detected = 0;
        ARTAU_state = 0;
        next_state = 0;
    end else begin
        ARTAU_state = next_state;
    end 
end

always @(posedge radar_echo or posedge scan_for_target or run_trigger) begin
    run_trigger = 0;


    case (ARTAU_state)

    0:begin
        if(scan_for_target && !radar_pulse_trigger) begin
            pulse_emition_timer = timevar;
            radar_pulse_trigger = 1;
            next_state = 1; // EMIT
        end
    end

    1:begin
        if (radar_pulse_trigger) begin
            //$display("pulse_emition_timer: %d", timevar- pulse_emition_timer, " pulse_counter: %d", pulse_counter , " listen_to_echo_timer: ", listen_to_echo_timer);
            if(timevar -pulse_emition_timer > 6) begin
                //$display(timevar);
                pulse_counter = pulse_counter + 1;
                radar_pulse_trigger = 0;
                pulse_emition_timer = 0;

                distance_start_time = $realtime;
                listen_to_echo_timer = timevar;
                
                next_state = 2; // LISTEN
                
                
            end
        end
    end

    2:begin
        //distance_end_time = $realtime;
        if ((timevar - listen_to_echo_timer) < 39) begin
            if(radar_echo) begin

                distance_end_time = $realtime;
                //$display("distance_end_time: %d", distance_end_time, " distance_start_time: %d", distance_start_time, " distance_to_target: ", distance_to_target);

                if(pulse_counter == 1) begin
                    first_start_time = distance_start_time;
                    radar_pulse_trigger = 1;
                    pulse_emition_timer = timevar;
                    next_state = 1;
                    
                    distance1 = ((distance_end_time - distance_start_time) *speed_of_light) / (2 * microsecond);
                    distance_to_target = distance1;
                    //$display("distance_end_time: %d", distance_end_time, " distance_start_time: %d", distance_start_time, " distance_to_target: ", distance_to_target);
                
                end else if (pulse_counter == 2) begin

                    
                    status_update_timer = timevar;
                    next_state = 3;

                    distance2 = ((distance_end_time - distance_start_time) *speed_of_light) / (2 * microsecond);
                    distance_to_target = distance2;

                    
                    relative_distance = (distance2 + ((jet_speed*(distance_end_time- first_start_time))/microsecond) - distance1);
                    //$display("distance1: ", distance1, " distance2: ",distance2,  " relative_distance: ", relative_distance);

                    //$display("relative_distance:" , relative_distance);
                    
                    if (max_safe_distance > distance2 && relative_distance < 0) begin
                        threat_detected = 1;
                    end else begin
                        threat_detected = 0;
                    end

                    
                end

                listen_to_echo_timer = timevar;
            end

        end else begin
            threat_detected = 0;
            distance_to_target = 0;
            next_state = 0;
        end

    end

    3:begin
        pulse_counter = 0;
        if(timevar- status_update_timer < 60 || scan_for_target) begin
            if(scan_for_target) begin
                pulse_emition_timer = timevar;
                radar_pulse_trigger = 1;
                next_state = 1; // EMIT
            end
        end else begin
            threat_detected = 0;
            distance_to_target = 0;
            next_state = 0;
        end
    end

    endcase
end

endmodule