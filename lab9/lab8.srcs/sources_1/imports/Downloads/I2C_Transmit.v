`timescale 1ns / 1ps

module SPI_Transmit(
    input FSM_Clk,
    output SPI_CLK_0,
    output SPI_EN_0,
    output  SPI_IN_0,
    input SPI_OUT_0,
    input [6:0] ADDR,
    input [7:0] DATA_WRITE,
    output reg [7:0] DATA_READ,
    output reg SPI_CLK,
    output reg SPI_IN,
    output reg SPI_EN,
    input START_BIT,
    input C,
    output writecomplete,
    output readcomplete,
    output [7:0] CURR_STATE
    );
    
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
                                        
    reg [7:0] State;
    reg writecomplete, readcomplete;
    
       
    localparam STATE_INIT = 8'd0;
    assign SPI_CLK_0 = SPI_CLK;
    assign SPI_IN_0 = SPI_IN;
    assign SPI_EN_0 = SPI_EN; 
    assign CURR_STATE = State;
    
    initial  begin
        SPI_EN = 1'b0;
        SPI_CLK = 1'b0;
        SPI_IN = 1'b0;
        State = STATE_INIT;
    end 
                               
    always @(posedge FSM_Clk) begin                 
        case (State)
            // Press Button[3] to start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                 if (START_BIT == 1'b1) State <= 8'd1;                    
                 else begin                 
                      SPI_EN = 1'b0;
                      SPI_CLK = 1'b0;
                  end
            end            
            
            // This is the Start sequence            
            8'd1 : begin
                  writecomplete <= 1'b0;
                  readcomplete <= 1'b0;
                  SPI_EN <= 1'b1;
                  SPI_CLK <= 1'b0;    
                  State <= State + 1'b1;                          
            end   
            
            8'd2 : begin
                  SPI_CLK <= 1'b0;
                  SPI_IN <= C;
                  State <= State + 1'b1;             
            end   

             
            8'd3 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;                 
            end   

            8'd4 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;
            end   

            // transmit bit 7 of ADDR  
            8'd5 : begin
                  SPI_CLK <= 1'b0;
                  SPI_IN <= ADDR[6];
                  State <= State + 1'b1;
            end   

            8'd6 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd7 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;               
            end   

            8'd8 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd9 : begin
                  SPI_CLK <= 1'b0;
                  SPI_IN <= ADDR[5];
                  State <= State + 1'b1;
            end   

            8'd10 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;
            end   

            8'd11 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;              
            end   

            8'd12 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd13 : begin
                  SPI_CLK <= 1'b0;
                  SPI_IN <= ADDR[4];
                  State <= State + 1'b1;
            end   

            8'd14 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;
            end   

            8'd15 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;              
            end   

            8'd16 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;    
            end   

            8'd17 : begin
                  SPI_CLK <= 1'b0;
                  SPI_IN <= ADDR[3];
                  State <= State + 1'b1;
            end   

            8'd18 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;  
            end   

            8'd19 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;                  
            end   

            8'd20 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;  
            end   

            8'd21 : begin
                  SPI_CLK <= 1'b0;
                  SPI_IN <= ADDR[2];
                  State <= State + 1'b1;
            end   

            8'd22 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1; 
            end  
            
            8'd23 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;                
            end   

            8'd24 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1; 
            end   

            8'd25 : begin
                  SPI_CLK <= 1'b0;
                  SPI_IN <= ADDR[1];
                  State <= State + 1'b1;
            end   

            8'd26 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1; 
            end  
 
            8'd27 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;               
            end   

            8'd28 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1; 
            end   

            8'd29 : begin
                  SPI_CLK <= 1'b0;
                  SPI_IN <= ADDR[0];
                  State <= State + 1'b1;
            end   

            8'd30 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;
            end
            
            8'd31 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;     
            end   

            8'd32 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;
            end   

            //write or read data depending on "C"
            8'd33 : begin
                  SPI_CLK <= 1'b0;
                  if(C == 1'b1) begin
                        SPI_IN <= DATA_WRITE[7];
                  end  
                  State <= State + 1'b1;
            end   

            8'd34 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;
            end  
                        
            8'd35 : begin
                  SPI_CLK <= 1'b1;
                  if(C == 1'b0) begin
                        DATA_READ[7] <= SPI_OUT_0;
                  end
                  State <= State + 1'b1;                
            end   

            8'd36 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd37 : begin
                  SPI_CLK <= 1'b0;
                  if(C == 1'b1) begin
                        SPI_IN <= DATA_WRITE[6];
                  end  
                  State <= State + 1'b1;
            end   

            8'd38 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;
            end  
                        
            8'd39 : begin
                  SPI_CLK <= 1'b1;
                  if(C == 1'b0) begin
                        DATA_READ[6] <= SPI_OUT_0;
                  end
                  State <= State + 1'b1;                
            end   

            8'd40 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd41 : begin
                  SPI_CLK <= 1'b0;
                  if(C == 1'b1) begin
                        SPI_IN <= DATA_WRITE[5];
                  end  
                  State <= State + 1'b1;
            end   

            8'd42 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;
            end  
                        
            8'd43 : begin
                  SPI_CLK <= 1'b1;
                  if(C == 1'b0) begin
                        DATA_READ[5] <= SPI_OUT_0;
                  end
                  State <= State + 1'b1;                
            end   

            8'd44 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd45 : begin
                  SPI_CLK <= 1'b0;
                  if(C == 1'b1) begin
                        SPI_IN <= DATA_WRITE[4];
                  end  
                  State <= State + 1'b1;
            end   

            8'd46 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;
            end  
                        
            8'd47 : begin
                  SPI_CLK <= 1'b1;
                  if(C == 1'b0) begin
                        DATA_READ[4] <= SPI_OUT_0;
                  end
                  State <= State + 1'b1;                
            end   

            8'd48 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd49 : begin
                  SPI_CLK <= 1'b0;
                  if(C == 1'b1) begin
                        SPI_IN <= DATA_WRITE[3];
                  end  
                  State <= State + 1'b1;
            end   

            8'd50 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;
            end  
                        
            8'd51 : begin
                  SPI_CLK <= 1'b1;
                  if(C == 1'b0) begin
                        DATA_READ[3] <= SPI_OUT_0;
                  end
                  State <= State + 1'b1;                
            end   

            8'd52 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd53 : begin
                  SPI_CLK <= 1'b0;
                  if(C == 1'b1) begin
                        SPI_IN <= DATA_WRITE[2];
                  end  
                  State <= State + 1'b1;
            end   

            8'd54 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;
            end  
                        
            8'd55 : begin
                  SPI_CLK <= 1'b1;
                  if(C == 1'b0) begin
                        DATA_READ[2] <= SPI_OUT_0;
                  end
                  State <= State + 1'b1;                
            end   

            8'd56 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd57 : begin
                  SPI_CLK <= 1'b0;
                  if(C == 1'b1) begin
                        SPI_IN <= DATA_WRITE[1];
                  end  
                  State <= State + 1'b1;
            end   

            8'd58 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;
            end  
                        
            8'd59 : begin
                  SPI_CLK <= 1'b1;
                  if(C == 1'b0) begin
                        DATA_READ[1] <= SPI_OUT_0;
                  end
                  State <= State + 1'b1;                
            end   

            8'd60 : begin
                  SPI_CLK <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd61 : begin
                  SPI_CLK <= 1'b0;
                  if(C == 1'b1) begin
                        SPI_IN <= DATA_WRITE[0];
                        writecomplete <= 1'b1;
                  end  
                  State <= State + 1'b1;
            end   

            8'd62 : begin
                  SPI_CLK <= 1'b0;
                  State <= State + 1'b1;
            end  
                        
            8'd63 : begin
                  SPI_CLK <= 1'b1;
                  if(C == 1'b0) begin
                        DATA_READ[0] <= SPI_OUT_0;
                        readcomplete <= 1'b1;
                  end
                  State <= State + 1'b1;                
            end   

            8'd64 : begin
                  SPI_CLK <= 1'b1;
                  if(START_BIT == 1'b0) begin
                        State <= STATE_INIT;
                  end
                  else begin
                        State <= State;
                  end
            end
            
            //If the FSM ends up in this state, there was an error in teh FSM code
            //LED[6] will be turned on (signal is active low) in that case.
            default : begin
                  
            end                              
        endcase                           
    end                     
endmodule
