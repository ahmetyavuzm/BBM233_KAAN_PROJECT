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

reg innerCLK;

initial begin
    innerCLK = 0;
    forever innerCLK = #1 ~innerCLK;
end


always @(innerCLK or posedge RST) begin
    if (RST) begin
        severe_weather =0;
        emergency_landing_alert =0;
        ECSU_state =0;
    end
    else begin
        case (ECSU_state)
            0: begin
                if ((wind > 10 && wind <=15) || (visibility == 1) || (visibility == 2)) begin
                    severe_weather =0;
                    emergency_landing_alert =0;
                    if (CLK == 1) begin
                        ECSU_state =1;
                    end
                end
                else if (thunderstorm || temperature < -35 || temperature > 35 || wind > 15 || visibility == 3) begin
                    emergency_landing_alert =0;
                    severe_weather =1;
                    if (CLK == 1) begin
                        ECSU_state =2;
                    end
                end
            end

            1: begin
                if (wind <=10 && visibility == 0) begin  
                    severe_weather =0;
                    emergency_landing_alert =0;
                    if (CLK == 1) begin
                        ECSU_state =0;
                    end
                end 
                else if (thunderstorm || temperature < -35 || temperature > 35 || wind > 15 || visibility == 3) begin
                    emergency_landing_alert =0;
                    severe_weather =1;
                    if (CLK == 1) begin
                        ECSU_state =2;
                    end
                end
            end

            2: begin
                
                
                if (temperature < -40 || temperature > 40 || wind > 20) begin
                    severe_weather =1;
                    emergency_landing_alert =1;
                    if (CLK == 1) begin
                        ECSU_state =3;
                    end
                end
                else if(thunderstorm == 0 && wind <=10 && (temperature >= -35 && temperature <=35) && visibility == 1) begin
                    severe_weather =0;
                    emergency_landing_alert =0;
                    if (CLK == 1) begin
                        ECSU_state =1;
                    end
                end
            end
        endcase
    end
end


endmodule