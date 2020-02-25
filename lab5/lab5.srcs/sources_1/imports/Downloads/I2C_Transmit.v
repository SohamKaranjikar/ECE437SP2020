`timescale 1ns / 1ps

module I2C_Transmit(
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp,
    output ADT7420_A0,
    output ADT7420_A1,
    output I2C_SCL_0,
    inout  I2C_SDA_0,        
    output reg FSM_Clk_reg,    
    output reg ILA_Clk_reg,
    output reg ACK_bit,
    output reg SCL,
    output reg SDA,
    output [7:0] CURR_STATE,
    output reg [7:0] Temp_MSByte,
    output reg [7:0] Temp_LSByte
    );
    
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 100;   
    wire FSM_Clk, ILA_Clk; 
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk) );
                                        
    reg [7:0] SingleByteData = 8'b1001_0000;
    reg [7:0] State = 8'd0;
    reg [3:0] button_reg; 
    reg error_bit = 1'b1;
    reg repeat_start_bit;
    reg reloop_start_bit;
    reg read_lsb;
    reg loop_done;
    reg [7:0] MSB_ADDR = 8'd0;
    reg [7:0] LSB_ADDR = 8'd1;
    reg [3:0] count;
    
       
    localparam STATE_INIT       = 8'd0;    
    assign led[7] = ACK_bit;
    assign led[6] = error_bit;
    assign ADT7420_A0 = 1'b0;
    assign ADT7420_A1 = 1'b0;
    assign I2C_SCL_0 = SCL;
    assign I2C_SDA_0 = SDA; 
    assign CURR_STATE = State;
 
    
    initial  begin
        SCL = 1'b1;
        SDA = 1'b1;
        ACK_bit = 1'b1;
        read_lsb = 1'b0;
        repeat_start_bit = 1'b0;
        reloop_start_bit = 1'b0;
        count = 4'd0;
        loop_done = 1'b0;
        State = STATE_INIT;
    end
    
    always @(*) begin
        button_reg = ~button;  
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;   
    end   
                               
    always @(posedge FSM_Clk) begin                       
        case (State)
            // Press Button[3] to start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT : begin
                 if (button_reg[3] == 1'b1) State <= 8'd1;                    
                 else begin                 
                      SCL <= 1'b1;
                      SDA <= 1'b1;
                      State <= 8'd0;
                      Temp_MSByte <= 8'd0;
                      Temp_LSByte <= 8'd0;
                  end
            end            
            
            // This is the Start sequence            
            8'd1 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  if(loop_done == 1'b1) begin
                      Temp_MSByte <= 8'd0;
                      Temp_LSByte <= 8'd0;
                      loop_done = 1'b0;
                  end
                  State <= State + 1'b1;                                
            end   
            
            8'd2 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                 
            end   

            // transmit bit 7   
            8'd3 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[7];
                  State <= State + 1'b1;                 
            end   

            8'd4 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd5 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd6 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd7 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[6];  
                  State <= State + 1'b1;               
            end   

            8'd8 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd9 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd10 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd11 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[5]; 
                  State <= State + 1'b1;                
            end   

            8'd12 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd13 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd14 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd15 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[4]; 
                  State <= State + 1'b1;                
            end   

            8'd16 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd17 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd18 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd19 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[3]; 
                  State <= State + 1'b1;                
            end   

            8'd20 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd21 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd22 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd23 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[2]; 
                  State <= State + 1'b1;                
            end   

            8'd24 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd25 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd26 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd27 : begin
                  SCL <= 1'b0;
                  SDA <= SingleByteData[1];  
                  State <= State + 1'b1;               
            end   

            8'd28 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd29 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd30 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd31 : begin
                  SCL <= 1'b0;
                  if(repeat_start_bit == 1)
                  begin
                     SDA <= 1'b1;
                     State <= State + 1'b1;
                  end
                  else
                  begin
                      SDA <= SingleByteData[0];      
                      State <= State + 1'b1;   
                  end        
            end   

            8'd32 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd33 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd34 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            8'd35 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd36 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd37 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;        
                  State <= State + 1'b1;
            end   

            8'd38 : begin
                  SCL <= 1'b0;
                  if(repeat_start_bit == 1'b1 && read_lsb == 1'b0) begin
                        State <= 8'd88;
                  end else if (repeat_start_bit == 1 && read_lsb == 1'b1) begin
                      State <= 8'd129;
                  end else begin
                      State <= State + 3'd5;
                  end
                 
            end  
            
                      
//            8'd39 : begin
//                  SCL <= 1'b0;
//                  SDA <= 1'b0;                
//                  State <= State + 1'b1;
//            end   

//            8'd40 : begin
//                  SCL <= 1'b1;
//                  SDA <= 1'b0;
//                  State <= State + 1'b1;
//            end                                    

//            8'd41 : begin
//                  SCL <= 1'b1;
//                  SDA <= 1'b0;
//                  State <= State + 1'b1;                  
//            end
            
//            //change numbrs
//            8'd42 : begin
//                  SCL <= 1'b0;
//                  State <= State + 1'b1;
//            end   
            
            8'd43 : begin
                  SCL <= 1'b0;
                  if(read_lsb == 1'b0) begin
                    SDA <= MSB_ADDR[7];
                  end else begin
                    SDA <= LSB_ADDR[7];
                  end
                  State <= State + 1'b1;
            end  
                    
            8'd44 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd45 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end                                    

            8'd46 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            8'd47 : begin
                  SCL <= 1'b0;
                  if(read_lsb == 1'b0) begin
                    SDA <= MSB_ADDR[6];
                  end else begin
                    SDA <= LSB_ADDR[6];
                  end
                  State <= State + 1'b1;
            end  
                    
            8'd48 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd49 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end                                    

            8'd50 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            8'd51 : begin
                  SCL <= 1'b0;
                  if(read_lsb == 1'b0) begin
                    SDA <= MSB_ADDR[5];
                  end else begin
                    SDA <= LSB_ADDR[5];
                  end
                  State <= State + 1'b1;
            end  
                    
            8'd52 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd53 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end                                    

            8'd54 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            8'd55 : begin
                  SCL <= 1'b0;
                  if(read_lsb == 1'b0) begin
                    SDA <= MSB_ADDR[4];
                  end else begin
                    SDA <= LSB_ADDR[4];
                  end
                  State <= State + 1'b1;
            end  
                    
            8'd56 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd57 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end                                    

            8'd58 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            8'd59 : begin
                  SCL <= 1'b0;
                  if(read_lsb == 1'b0) begin
                    SDA <= MSB_ADDR[3];
                  end else begin
                    SDA <= LSB_ADDR[3];
                  end
                  State <= State + 1'b1;
            end  
                    
            8'd60 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd61 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end                                    

            8'd62 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end   
            
            8'd63 : begin
                  SCL <= 1'b0;
                  if(read_lsb == 1'b0) begin
                    SDA <= MSB_ADDR[2];
                  end else begin
                    SDA <= LSB_ADDR[2];
                  end
                  State <= State + 1'b1;
            end  
                    
            8'd64 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd65 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end                                    

            8'd66 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            8'd67 : begin
                  SCL <= 1'b0;
                  if(read_lsb == 1'b0) begin
                    SDA <= MSB_ADDR[1];
                  end else begin
                    SDA <= LSB_ADDR[1];
                  end
                  State <= State + 1'b1;
            end  
                    
            8'd68 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd69 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end                                    

            8'd70 : begin
                  SCL <= 1'b0;
                  State <= State + 8'd5;                  
            end 
            
            8'd75 : begin
                  SCL <= 1'b0;
                  if(read_lsb == 1'b0) begin
                    SDA <= MSB_ADDR[0];
                  end else begin
                    SDA <= LSB_ADDR[0];
                  end
                  State <= State + 1'b1;
            end  
                    
            8'd76 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd77 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end                                    

            8'd78 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            // read the ACK bit from the sensor and display it on LED[7]
            8'd79 : begin
                  SCL <= 1'b0;
                  SDA <= 1'bz;
                  State <= State + 1'b1;                 
            end   

            8'd80 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd81 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA;        
                  State <= State + 1'b1;
            end   

            8'd82 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            8'd83 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b1;
                  State <= State + 8'd4;                 
            end     
            
            8'd87 : begin
                  SCL <= 1'b1;
                  State <= 8'd1;
                  repeat_start_bit <= 1'b1;
                  
            end
            
            8'd88 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
                    
            8'd89 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd90 : begin
                  SCL <= 1'b1;
                  Temp_MSByte[7] <= SDA;
                  State <= State + 1'b1;
            end                                    

            8'd91 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            8'd92 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
                    
            8'd93 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd94 : begin
                  SCL <= 1'b1;
                  Temp_MSByte[6] <= SDA;
                  State <= State + 1'b1;
            end                                    

            8'd95 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            8'd96 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
                    
            8'd97 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd98 : begin
                  SCL <= 1'b1;
                  Temp_MSByte[5] <= SDA;
                  State <= State + 1'b1;
            end                                    

            8'd99 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            8'd100 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
                    
            8'd101 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd102 : begin
                  SCL <= 1'b1;
                  Temp_MSByte[4] <= SDA;
                  State <= State + 1'b1;
            end                                    

            8'd103 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            8'd104 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
                    
            8'd105 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd106 : begin
                  SCL <= 1'b1;
                  Temp_MSByte[3] <= SDA;
                  State <= State + 1'b1;
            end                                    

            8'd107 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end   
            
            8'd108 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
                    
            8'd109 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd110 : begin
                  SCL <= 1'b1;
                  Temp_MSByte[2] <= SDA;
                  State <= State + 1'b1;
            end                                    

            8'd111 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            8'd112 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
                    
            8'd113 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd114 : begin
                  SCL <= 1'b1;
                  Temp_MSByte[1] <= SDA;
                  State <= State + 1'b1;
            end                                    

            8'd115 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            8'd116 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
                    
            8'd117 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd118 : begin
                  SCL <= 1'b1;
                  Temp_MSByte[0] <= SDA;
                  State <= State + 1'b1;
            end                                    

            8'd119 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            //send NACK
            8'd120 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b1;
                  State <= State + 1'b1;
            end  
                    
            8'd121 : begin
                  SCL <= 1'b1;               
                  State <= State + 1'b1;
            end   

            8'd122 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end                                    

            8'd123 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                  
            end
            
            //stop and go to state 1
            8'd124 : begin
                  read_lsb = 1'b1;
                  repeat_start_bit = 1'b0;
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                 
            end   

            8'd125 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd126 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;  
                  State <= State + 1'b1;
            end
            
            8'd127 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;
                  State <= State + 1'b1;                 
            end
            
            8'd128 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;
                  State <= 1'd1;;                 
            end   
            
            //Read LSB.
            8'd129 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            8'd130 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd131 : begin
                  SCL <= 1'b1;
                  Temp_LSByte[7] <= SDA;
                  State <= State + 1'b1;                 
            end
            
            8'd132 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                 
            end
            
            8'd133 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            8'd134 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd135 : begin
                  SCL <= 1'b1;
                  Temp_LSByte[6] <= SDA;
                  State <= State + 1'b1;                 
            end
            
            8'd136 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                 
            end
            
            8'd137 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            8'd138 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd139 : begin
                  SCL <= 1'b1;
                  Temp_LSByte[5] <= SDA;
                  State <= State + 1'b1;                 
            end
            
            8'd140 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                 
            end
            
            8'd141 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            8'd142 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd143 : begin
                  SCL <= 1'b1;
                  Temp_LSByte[4] <= SDA;
                  State <= State + 1'b1;                 
            end
            
            8'd144 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                 
            end
            
            8'd145 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            8'd146 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd147 : begin
                  SCL <= 1'b1;
                  Temp_LSByte[3] <= SDA;
                  State <= State + 1'b1;                 
            end
            
            8'd148 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                 
            end
            
            8'd149 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            8'd150 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd151 : begin
                  SCL <= 1'b1;
                  Temp_LSByte[2] <= SDA;
                  State <= State + 1'b1;                 
            end
            
            8'd152 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                 
            end
            
            8'd153 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            8'd154 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd155 : begin
                  SCL <= 1'b1;
                  Temp_LSByte[1] <= SDA;
                  State <= State + 1'b1;                 
            end
            
            8'd156 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                 
            end
            
            8'd157 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            8'd158 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end
            
            8'd159 : begin
                  SCL <= 1'b1;
                  Temp_LSByte[0] <= SDA;
                  State <= State + 1'b1;                 
            end
            
            8'd160 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;                 
            end
            
            8'd161 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b1;    
                  State <= State + 1'b1;
            end
            
            8'd162 : begin
                  SCL <= 1'b1;  
                  State <= State + 1'b1;
            end
            
            8'd163 : begin
                  SCL <= 1'b1;  
                  State <= State + 1'b1;
            end
            
            8'd164 : begin
                  SCL <= 1'b0;  
                  State <= State + 1'b1;
            end
            
            //stop and go to state 1
            8'd165 : begin
                  read_lsb = 1'b0;
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                 
            end   

            8'd166 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd167 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;  
                  State <= State + 1'b1;
            end
            
            8'd168 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b1;
                  State <= State + 1'b1;                 
            end
                     
            8'd169 : begin
                  SCL <= 1'b1;
                  State <= 1'd1;
                  repeat_start_bit <= 1'b0;
                  loop_done = 1'b1;
            end
            
            //If the FSM ends up in this state, there was an error in teh FSM code
            //LED[6] will be turned on (signal is active low) in that case.
            default : begin
                  error_bit <= 0;
            end                              
        endcase                           
    end                     
endmodule
