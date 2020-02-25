`timescale 1ns / 1ps
module lab3_example(
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp  
    );

    reg [3:0] state = 0;
    reg [7:0] led_register = 0; //Represents the Traffic Signals: R1,Y1,G1,R2,Y2,G2,R3,G3;
    reg [3:0] button_reg;
    reg [3:0] last_state = 0;
                
    wire clk;
    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );
    
    assign led = ~led_register; //map led wire to led_register
    localparam STATE_R1       = 4'd0;
    localparam STATE_G1      = 4'd1;
    localparam STATE_Y1      = 4'd2;
    localparam STATE_R2    = 4'd3;
    localparam STATE_G2    =4'd4;
    localparam STATE_Y2     =4'd5;
    localparam STATE_G3 = 4'd6;
    
    //counter to track time in accordance with clock cycles;
    reg [3:0] counter = 4'd0;     
    reg [31:0] clkdiv;
    reg slow_clk;
    
    always @(posedge clk) begin
        clkdiv <= clkdiv + 32'd1;
        if (clkdiv == 32'd100000000) begin
            slow_clk <= ~slow_clk;
            clkdiv <= 0;
        end
        if(button == 4'b0111)
        begin
            pressed <= 1'b1;
        end
        if(reset_pressed == 1'b1)
        begin
            pressed<=1'b0;
        end
    end
    
    //pedestrian light logic R3,G3
    //if the button has been pressed wait until current traffic signals go to red then turn ped light green.
    
    reg pressed;
    reg reset_pressed;
    
    
    initial begin
        clkdiv = 0;
        slow_clk = 0;
        counter = 4'd0;
    end
    
    //FSM goes through states: Red stays on for 1.5s, yellow for .5s, green for 1s
    always @(posedge slow_clk)
    begin       
        button_reg = ~button;
        if (button_reg [3:0] == 4'b0001) state <= STATE_R1; //RESET TO R1 state.
        else if (pressed == 1'b1 && ((last_state == STATE_R1 || last_state == STATE_R2) 
                                    && (state == STATE_R1 || state == STATE_R2))) begin
            state <= STATE_G3;
            reset_pressed <= 1'b1;
            end
        else
        begin
            case (state)
                STATE_R1 : begin
                    if(counter == 4'd2)
                    begin
                        state <= STATE_G1;
                        counter <= 4'd0;
                    end
                    else counter <= counter + 4'd1;
               //     last_state <= STATE_R1;
                    led_register <= 8'b10010010;                                                                        
                end

                STATE_G1 : begin
                    if(counter == 4'd1)
                    begin
                        state <= STATE_Y1;
                        counter <= 4'd0;
                    end
                    else counter <= counter + 4'd1;
                    led_register <= 8'b00110010;                                                                        
                end

                STATE_Y1 : begin
                    if(counter == 4'd0)
                    begin
                        state <= STATE_R2;
                        counter <= 4'd0;
                    end
                    else counter <= counter + 4'd1;
                    last_state <= STATE_R2;
                    led_register <= 8'b01010010;                                                                        
                end

                STATE_R2 : begin 
                    if(counter == 4'd2)
                    begin
                        state <= STATE_G2;
                        counter <= 4'd0;
                    end
                    else counter <= counter + 4'd1;
                   // last_state <= STATE_R1;           
                    led_register <= 8'b10010010;                                                                        
                end
                
                STATE_G2 : begin
                    if(counter == 4'd1)
                    begin
                        state <= STATE_Y2;
                        counter <= 4'd0;
                    end
                    else counter <= counter + 4'd1;               
                    led_register <= 8'b10000110;                                                                        
                end
                
                STATE_Y2 : begin
                    if(counter == 4'd0)
                    begin
                        state <= STATE_R1;
                        counter <= 4'd0;
                    end
                    else counter <= counter + 4'd1;
                    last_state <= STATE_R1;             
                    led_register <= 8'b10001010;                                                                        
                end
                
                STATE_G3 : begin
                    if(counter == 4'd1)
                    begin
                        state <= last_state;
                        counter <= 4'd0;
                    end
                    else counter <= counter + 4'd1;                 
                    led_register <= 8'b10010001;
                    reset_pressed = 1'b0;                                                                        
                end
                
                default: state <= STATE_R1;
                
            endcase
        end                           
    end    
endmodule

