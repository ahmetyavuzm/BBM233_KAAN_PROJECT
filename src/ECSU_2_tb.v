`timescale 1us / 1ns

module ECSU_tb;

    // Inputs
    reg CLK;
    reg RST;
    reg thunderstorm;
    reg [5:0] wind;
    reg [1:0] visibility;
    reg signed [7:0] temp;
    
    // Outputs
    wire severe_weather;
    wire emergency_landing_alert;
    wire [1:0] ECSU_state; 
    
    // Instantiate the Unit Under Test (UUT)
    ECSU uut (
        .CLK(CLK),
        .RST(RST),
        .thunderstorm(thunderstorm),
        .wind(wind),
        .visibility(visibility),
        .temperature(temp),
        .severe_weather(severe_weather),
        .emergency_landing_alert(emergency_landing_alert),
        .ECSU_state(ECSU_state)
    );
    
    // Clock generation
    initial begin
        CLK = 0;
        forever #50 CLK = ~CLK; 
    end
    
    // Dump to waveform file
    initial begin
        $dumpfile("ECSU.wave");
        $dumpvars;
    end

    // Function to print values
    task print_values;
        begin
            $display("Time=%t - RST=%b, thunderstorm=%b, wind=%0d, visibility=%0d, temp=%0d, severe_weather=%b, emergency_landing_alert=%b, ECSU_state=%0d",
                      $time, RST, thunderstorm, wind, visibility, temp, severe_weather, emergency_landing_alert, ECSU_state);
        end
    endtask
    
    initial begin
    
        // Initialize Inputs
        RST = 1;
        thunderstorm = 0;
        wind = 0;
        visibility = 2'b00;
        temp = 0;
        
        // Reset the system
        #100;
        RST = 0;
        #200;
        
        // Stimulus
        thunderstorm = 0; wind = 12; visibility = 2'b00; temp = 25;
        #300; print_values();
        thunderstorm = 0; wind = 5; visibility = 2'b00; temp = 25;
        #300; print_values();
        thunderstorm = 0; wind = 5; visibility = 2'b01; temp = 25;
        #300; print_values();
        thunderstorm = 0; wind = 5; visibility = 2'b00; temp = 25;
        #300; print_values();
        thunderstorm = 0; wind = 5; visibility = 2'b01; temp = 25;
        #300; print_values();
        thunderstorm = 1; wind = 5; visibility = 2'b01; temp = 25;
        #0;   print_values();
        #300; print_values();
        thunderstorm = 0; wind = 5; visibility = 2'b01; temp = 25;
        #300; print_values();
        wind = 3; visibility = 2'b00; temp = -5;
        #300; print_values();
        visibility = 2'b11; 
        #300; print_values();
        wind = 25; visibility = 2'b10;
        #500; print_values();
        thunderstorm = 0; wind = 0; visibility = 2'b00; temp = 0; 
        #200; print_values();
        RST = 1;
        #150; print_values();
        RST = 0;
        #300; print_values();
        thunderstorm = 0; wind = 5; visibility = 2'b01; temp = 25;
        #300; print_values();
        thunderstorm = 0; wind = 15; visibility = 2'b01; 
        #30;  print_values();
        temp = 40;
        #0;   print_values();
        #300; print_values();
        thunderstorm = 0; wind = 5; visibility = 2'b01; temp = 25;
        #300; print_values();
        thunderstorm = 0; wind = 25; visibility = 2'b01; temp = -40;
        #0;   print_values();
        #600; print_values();
        
        // End the simulation
        $finish; 
    end

endmodule
