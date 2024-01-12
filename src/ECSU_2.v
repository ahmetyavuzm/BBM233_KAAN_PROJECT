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
                    ECSU_state <= 1;
                end
                else if (thunderstorm || temperature < -35 || temperature > 35 || wind > 15 || visibility == 3) begin
                    severe_weather <= 1;
                    ECSU_state <= 2;
                end
                else begin
                    ECSU_state <= 0;
                end 
            end

            1: begin
                if (wind <= 10 && visibility == 0) begin
                    ECSU_state <= 0;
                end 
                else if (thunderstorm || temperature < -35 || temperature > 35 || wind > 15 || visibility == 3) begin
                    severe_weather <= 1;
                    ECSU_state <= 2;
                end
                else begin
                    ECSU_state <= 1;
                end
            end

            2: begin
                if (temperature < -40 || temperature > 40 || wind > 20) begin
                    emergency_landing_alert <= 1;
                    ECSU_state <= 3;
                end
                else if(thunderstorm == 0 && wind <=10 && (temperature >= -35 && temperature <=35) && visibility == 1) begin
                    severe_weather <= 0;
                    ECSU_state <= 1;
                end
                else begin
                    ECSU_state <= 2;
                end
            end

            3: begin
                // No state change
            end

            default: begin
                // Hata durumu, burada gerekirse çıkışları güncelleyebilirsiniz.
            end
        endcase
    end
end

endmodule
