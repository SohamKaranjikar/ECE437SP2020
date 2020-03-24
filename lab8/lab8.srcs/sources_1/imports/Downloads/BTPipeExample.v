`timescale 1ns / 1ps

module BTPipeExample(
    input   wire    [4:0] okUH,
    output  wire    [2:0] okHU,
    inout   wire    [31:0] okUHU,
    inout   wire    okAA,
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp,
	output CVM300_SPI_EN,
    output CVM300_SPI_IN,
    input CVM300_SPI_OUT,
    output CVM300_SPI_CLK,
    input [9:0] CVM300_D,
    input CVM300_CLK_OUT,
    input CVM300_Line_valid,
    input CVM300_Data_valid,
    output CVM300_CLK_IN,
    output reg CVM300_FRAME_REQ
    );
    
    wire okClk;            //These are FrontPanel wires needed to IO communication    
    wire [112:0]    okHE;  //These are FrontPanel wires needed to IO communication    
    wire [64:0]     okEH;  //These are FrontPanel wires needed to IO communication     
    //This is the OK host that allows data to be sent or recived    
    okHost hostIF (
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okClk(okClk),
        .okAA(okAA),
        .okHE(okHE),
        .okEH(okEH)
    );
	
	//SPI Transmit Modules and code
    wire TrigerEvent;    
    wire [23:0] SPIClkDivThreshold = 1_000;   
    wire SPI_CLK, SPI_EN, SPI_IN, SPI_OUT;
    assign SPI_OUT = CVM300_SPI_OUT;
    wire START_BIT;           
    wire C;         
    wire [7:0] DATA_READ;   
    wire [7:0] DATA_WRITE;   
    wire [7:0] CURR_STATE;    
    wire [6:0] ADDR;
    wire writecomplete;
    wire readcomplete;          
    reg  SPI_FSM_Clk, CVM_Clk;
    wire FRAME_REQ;
    //Instantiate the module that we like to test
    SPI_Transmit I2C_Test1 (
        .FSM_Clk(SPI_FSM_Clk),
        .SPI_CLK_0(CVM300_SPI_CLK),
        .SPI_EN_0(CVM300_SPI_EN),
        .SPI_IN_0(CVM300_SPI_IN),
        .SPI_OUT_0(CVM300_SPI_OUT),
        .CURR_STATE(CURR_STATE),
        .ADDR(ADDR),
        .DATA_WRITE(DATA_WRITE),
        .DATA_READ(DATA_READ),
        .C(C),
        .START_BIT(START_BIT),
        .SPI_CLK(SPI_CLK),
        .SPI_EN(SPI_EN),
        .writecomplete(writecomplete), 
        .readcomplete(readcomplete),
        .SPI_IN(SPI_IN)
        );
    //Depending on the number of outgoing endpoints, adjust endPt_count accordingly.
    //In this example, we have 1 output endpoints, hence endPt_count = 1.
    localparam  endPt_count = 5;
    wire [endPt_count*65-1:0] okEHx;  
    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);    
    
    //Instantiate the ClockGenerator module, where three signals are generate:
    //High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 2;
    wire [23:0] ClkDivThresholdSPI = 50;  
    wire [23:0] ClkDivThresholdCVM = 5;   
    reg [23:0] ClkDivSPI = 24'd0;
    reg [23:0] ClkDivCVM = 24'd0;    
    wire FSM_Clk, ILA_Clk;
    assign CVM300_CLK_IN = CVM_Clk;
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk) );
    always @(posedge FSM_Clk) begin
        if (ClkDivSPI == ClkDivThresholdSPI) begin
         SPI_FSM_Clk <= !SPI_FSM_Clk;                   
         ClkDivSPI <= 0;
       end else begin
         ClkDivSPI <= ClkDivSPI + 1'b1;             
       end
    end
    
    always @(posedge FSM_Clk) begin
        if (ClkDivCVM == ClkDivThresholdCVM) begin
         CVM_Clk <= !CVM_Clk;                   
         ClkDivCVM <= 0;
       end else begin
         ClkDivCVM <= ClkDivCVM + 1'b1;             
       end
    end
                                                                                  
    localparam STATE_INIT                = 8'd0;
    localparam STATE_RESET               = 8'd1;   
    localparam STATE_DELAY               = 8'd2;
    localparam STATE_RESET_FINISHED      = 8'd3;
    localparam STATE_ENABLE_WRITING      = 8'd4;
    localparam STATE_COUNT               = 8'd5;
    localparam STATE_FINISH              = 8'd6;
   
    reg [31:0] counter = 8'd0;
    reg [15:0] counter_delay = 16'd0;
    reg [7:0] State = STATE_INIT;
    reg [7:0] led_register = 0;
    reg [3:0] button_reg, write_enable_counter;  
    reg write_reset, read_reset, write_enable;
    wire [31:0] Reset_Counter;
    wire [31:0] DATA_Counter;    
    wire FIFO_read_enable, FIFO_BT_BlockSize_Full, FIFO_full, FIFO_empty, BT_Strobe;
    wire [31:0] FIFO_data_out;
    
    assign led[0] = ~FIFO_empty; 
    assign led[1] = ~FIFO_full;
    assign led[2] = ~FIFO_BT_BlockSize_Full;
    assign led[3] = ~FIFO_read_enable;  
    assign led[7] = ~read_reset;
    assign led[6] = ~write_reset;
    initial begin
        write_reset <= 1'b0;
        read_reset <= 1'b0;
        write_enable <= 1'b1;    
    end
    reg [7:0] CVM_State = 8'd0;
    reg [7:0] CVM_State2 = 8'd0;
    reg [31:0] CVM_4Pixels = 8'd0;
    reg imgreadcomplete;
    //get Image data from Sensor
    always @(posedge CVM300_CLK_IN) begin
        if(FRAME_REQ == 1'b1) begin
            CVM_State <= 8'd1;
        end
        
        case(CVM_State)
            8'd0:   begin
                CVM300_FRAME_REQ <= 1'b0;
                write_reset <= 1'b1;
                read_reset <= 1'b1;
                if(FRAME_REQ == 1'b1) begin
                    CVM_State <= 8'd1;
                end
            end
            
            8'd1:   begin
                write_reset <= 1'b1;
                read_reset <= 1'b1;
                write_enable <= 1'b0;
                CVM_State <= 8'd2;
            end
            
            8'd2:   begin
                write_reset <= 1'b0;
                read_reset <= 1'b0;
                CVM_State <= 8'd3;
            end
            
            8'd3:   begin
            end
        endcase            
    end
    
    reg[17:0] pixelcounter = 18'd0;
    
    initial  begin
        write_enable = 1'b0;
        imgreadcomplete = 1'b0;
    end 
    
    always @(negedge CVM300_CLK_OUT) begin
        if(CVM_State == 8'd3) begin
            CVM_State2 <= 8'd1;
        end
        
        case(CVM_State2)
            8'd0:   begin
                CVM300_FRAME_REQ <= 1'b0;
                if(CVM_State == 8'd3) begin
                    CVM_State2 <= 8'd1;
                end
            end
            
            8'd1:   begin
                CVM300_FRAME_REQ <= 1'b1;
                CVM_State2 <= 8'd2;
            end
            
            8'd2:   begin
                write_enable <= 1'b0; //maybe move this to next state?
                
                if(pixelcounter >= 18'd79056) begin
                    CVM_State2 <= 8'd6;
                end
                else if(CVM300_Data_valid && CVM300_Line_valid) begin
                    CVM_4Pixels[7:0] = CVM300_D[7:0];
                    pixelcounter <= pixelcounter + 1'd1;
                    CVM_State2 <= 8'd3;
                end
            end
            
            8'd3:   begin
                if(CVM300_Data_valid && CVM300_Line_valid) begin
                    CVM_4Pixels[15:8] = CVM300_D[7:0];
                    pixelcounter <= pixelcounter + 1'd1;
                    CVM_State2 <= 8'd4;
                end
            end
            
            8'd4:   begin
                if(CVM300_Data_valid && CVM300_Line_valid) begin
                    CVM_4Pixels[23:16] = CVM300_D[7:0];
                    pixelcounter <= pixelcounter + 1'd1;
                    CVM_State2 <= 8'd5;
                end
            end
            
            8'd5:   begin
                if(CVM300_Data_valid && CVM300_Line_valid) begin
                    CVM_4Pixels[31:24] = CVM300_D[7:0];
                    pixelcounter <= pixelcounter + 1'd1;
                    CVM_State2 <= 8'd2;
                    write_enable <= 1'b1;
                end
            end
            
            8'd6:   begin
                write_enable <= 1'b0;
                imgreadcomplete <= 1'b1;
            end
        endcase
        
    end
                                         
//    always @(posedge FSM_Clk) begin     
//        button_reg <= ~button;   // Grab the values from the button, complement and store them in register                
//        if (Reset_Counter[0] == 1'b1) State <= STATE_RESET;
        
//        case (State)
//            STATE_INIT:   begin                              
//                write_reset <= 1'b1;
//                read_reset <= 1'b1;
//                write_enable <= 1'b0;
//                if (Reset_Counter[0] == 1'b1) State <= STATE_RESET;                
//            end
            
//            STATE_RESET:   begin
//                counter <= 0;
//                counter_delay <= 0;
//                write_reset <= 1'b1;
//                read_reset <= 1'b1;
//                write_enable <= 1'b0;                
//                if (Reset_Counter[0] == 1'b0) State <= STATE_RESET_FINISHED;             
//            end                                     
 
//           STATE_RESET_FINISHED:   begin
//                write_reset <= 1'b0;
//                read_reset <= 1'b0;                 
//                State <= STATE_DELAY;                                   
//            end   
                          
//            STATE_DELAY:   begin
//                if (counter_delay == 16'b0000_1111_1111_1111)  State <= STATE_ENABLE_WRITING;
//                else counter_delay <= counter_delay + 1;
//            end
            
//             STATE_ENABLE_WRITING:   begin
//                //write_enable <= 1'b1;
//                write_enable_counter <= 1'b0;
//                State <= STATE_COUNT;
//             end
                                  
//             STATE_COUNT:   begin
//                counter <= counter + 1;                
//                if (write_enable_counter == 5) begin
//                    write_enable <= 1'b1;
//                    write_enable_counter <= 0;
//                end else begin
//                    write_enable_counter <= write_enable_counter +1;                    
//                    write_enable <= 0;
//                end                                    
//                if (counter == 1024*18)  State <= STATE_FINISH;         
//             end
            
//             STATE_FINISH:   begin                         
//                 write_enable <= 1'b0;                                                           
//            end

//        endcase
//    end    
       
    fifo_generator_0 FIFO_for_Counter_BTPipe_Interface (
        .wr_clk(CVM_CLOCK_OUT),
        .wr_rst(write_reset),
        .rd_clk(okClk),
        .rd_rst(read_reset),
        .din(CVM_4Pixels),
        .wr_en(write_enable),
        .rd_en(FIFO_read_enable),
        .dout(FIFO_data_out),
        .full(FIFO_full),
        .empty(FIFO_empty),       
        .prog_full(FIFO_BT_BlockSize_Full)        
    );
      
    okBTPipeOut CounterToPC (
        .okHE(okHE), 
        .okEH(okEHx[ 0*65 +: 65 ]),
        .ep_addr(8'ha0), 
        .ep_datain(FIFO_data_out), 
        .ep_read(FIFO_read_enable),
        .ep_blockstrobe(BT_Strobe), 
        .ep_ready(FIFO_BT_BlockSize_Full)
    );
	
	 okWireOut wire20 (  .okHE(okHE), 
                        .okEH(okEHx[ 1*65 +: 65 ]),
                        .ep_addr(8'h20), 
                        .ep_datain(DATA_READ));
                        
    okWireOut wire21 (  .okHE(okHE), 
                        .okEH(okEHx[ 2*65 +: 65 ]),
                        .ep_addr(8'h21), 
                        .ep_datain(writecomplete));
    okWireOut wire22 (  .okHE(okHE), 
                        .okEH(okEHx[ 3*65 +: 65 ]),
                        .ep_addr(8'h22), 
                        .ep_datain(readcomplete));
                        
    okWireOut wire23 (  .okHE(okHE), 
                        .okEH(okEHx[ 4*65 +: 65 ]),
                        .ep_addr(8'h23), 
                        .ep_datain(imgreadcomplete));                    

     
     okWireIn wire10 (   .okHE(okHE), 
                        .ep_addr(8'h00), 
                        .ep_dataout(ADDR));
                        
     okWireIn wire11 (   .okHE(okHE), 
                        .ep_addr(8'h01), 
                        .ep_dataout(C));
                        
     okWireIn wire12 (   .okHE(okHE), 
                        .ep_addr(8'h02), 
                        .ep_dataout(DATA_WRITE));
    
     okWireIn wire13 (   .okHE(okHE), 
                        .ep_addr(8'h03), 
                        .ep_dataout(START_BIT));
    
    okWireIn wire14 (   .okHE(okHE), 
                        .ep_addr(8'h04), 
                        .ep_dataout(Reset_Counter));
    okWireIn wire15 (  .okHE(okHE), 
                        .ep_addr(8'h05), 
                        .ep_dataout(FRAME_REQ));                                                 
endmodule
