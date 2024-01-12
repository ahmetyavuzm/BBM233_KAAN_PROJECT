/*`timescale 1us / 1ps

module ECSU(
    input CLK,
    input RST,
    input thunderstorm,
    input [5:0] wind,
    input [1:0] visibility,
    input signed [7:0] temperature,
    output reg severe_weather,
    output reg emergency_landing_alert,
    output reg [1:0] ECSU_state
);

// Your code goes here.

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        severe_weather <= 0;
        emergency_landing_alert <= 0;
        ECSU_state <= 0;
    end
    else begin
        
        if (wind <= 10 && visibility == 0) begin 
            // ECSU_state 0: ALL CLEAR
            severe_weather <= 0;
            emergency_landing_alert <= 0;
            ECSU_state <= 0;
        end 
        else if ((wind > 10 && wind <= 15) || (visibility > 0 && visibility < 3)) begin
            severe_weather <= 0;
            emergency_landing_alert <= 0;
            ECSU_state <= 1;
        end
        else if (thunderstorm || temperature < -35 ||temperature > 35 || wind > 15 || visibility == 3) begin
            severe_weather <= 1;
            emergency_landing_alert <= 0;
            ECSU_state <= 2;
        end
        else if(temperature <-40 || temperature >40 || wind > 20) begin
            severe_weather <= 1;
            emergency_landing_alert <= 1;
            ECSU_state <= 3;
        end
    end
end

endmodule

*/


`timescale 1us / 1ps

module ECSU(
    input CLK,
    input RST,
    input thunderstorm,
    input [5:0] wind,
    input [1:0] visibility,
    input signed [7:0] temperature,
    output reg severe_weather,
    output reg emergency_landing_alert,
    output reg [1:0] ECSU_state
);

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        severe_weather <= 0;
        emergency_landing_alert <= 0;
        ECSU_state <= 0;
    end
    else begin
        case (ECSU_state)
            0: begin
                if ((wind > 10 && wind <= 15) || (visibility == 1)) begin
                    severe_weather <= 0;
                    emergency_landing_alert <= 0;
                    ECSU_state <= 1;
                end
                else begin
                    severe_weather <= 0;
                    emergency_landing_alert <= 0;
                    ECSU_state <= 0;
                end 
            end

            1: begin
                if (wind <= 10 && visibility == 0) begin
                    severe_weather <= 0;
                    emergency_landing_alert <= 0;
                    ECSU_state <= 0;
                end 
                else if (thunderstorm || temperature < -35 || temperature > 35 || wind > 15 || visibility == 3) begin
                    severe_weather <= 1;
                    emergency_landing_alert <= 0;
                    ECSU_state <= 2;
                end
                else begin
                    severe_weather <= 0;
                    emergency_landing_alert <= 0;
                    ECSU_state <= 1;
                end
            end

            2: begin
                if (temperature < -40 || temperature > 40 || wind > 20) begin
                    severe_weather <= 1;
                    emergency_landing_alert <= 1;
                    ECSU_state <= 3;
                end
                else begin
                    severe_weather <= 1;
                    emergency_landing_alert <= 0;
                    ECSU_state <= 2;
                end
                // Bu durumda çıkışları güncelleyebilirsiniz.
            end

            3: begin
                // Bu durumda çıkışları güncelleyebilirsiniz.
            end

            default: begin
                // Hata durumu, burada gerekirse çıkışları güncelleyebilirsiniz.
            end
        endcase
    end
end

endmodule
