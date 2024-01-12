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



always @(posedge CLK or posedge RST) begin
    if (RST) begin
        reg pulse_counter = 0;
        reg pulse_emition_timer = 0;
        reg listen_to_echo_timer = 0;
        reg status_update_timer = 0;
        
        radar_pulse_trigger <= 0;
        threat_detected <= 0;
        distance_to_target <= 0;
        ARTAU_state <= 0;
    end
    else begin
        case (ARTAU_state)

            0:begin
                if(scan_for_target) begin
                
                    pulse_emition_timer <= 0;
                    radar_pulse_trigger <= 1;
                    ARTAU_state <= 1; // EMIT
                end
            end

            1:begin
                
                if(pulse_emition_timer >= #300) begin
                    
                    /*
                    if(pulse_counter >0) begin
                        distance_to_target <= distance_to_target + jet_speed;
                    end else begin
                        distance_to_target <= 0;
                    end
                    */

                    pulse_counter += 1;
                    listen_to_echo_timer <= 0;
                    pulse_emition_timer <= 0;

                    radar_pulse_trigger <= 0;
                    ARTAU_state <= 2; // LISTEN
                end else begin
                    pulse_emition_timer <= pulse_emition_timer + #50;
                end
            end

            2:begin
                
                if(listen_to_echo_timer < #2000) begin // belki <= olabilir
                    listen_to_echo_timer <= listen_to_echo_timer + #50;
                    if(radar_echo && (pulse_counter == 1)) begin
                        ARTAU_state <= 1;
                    end else if (radar_echo && (pulse_counter == 2)) begin
                        
                        //Calculate distance

                        status_update_timer <= 0;
                        pulse_counter <= 0;
                        ARTAU_state <= 3;
                    end 

                end else begin
                    ARTAU_state <= 0;
                end
            end

            3:begin

            end

        endcase
    end
end
// Your code goes here.




endmodule