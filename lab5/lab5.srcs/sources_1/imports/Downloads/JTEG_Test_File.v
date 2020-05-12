`timescale 1ns / 1ps

module JTEG_Test_File(
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp,  
    output ADT7420_A0,
    output ADT7420_A1,
    output I2C_SCL_0,
    inout I2C_SDA_0,
    input   wire    [4:0] okUH,
    output  wire    [2:0] okHU,
    inout   wire    [31:0] okUHU,
    inout   wire    okAA
);

    wire  ILA_Clk, ACK_bit, FSM_Clk, TrigerEvent;    
    wire [23:0] ClkDivThreshold = 1_000;   
    wire SCL, SDA;
    
    //register for viewing state in waveform
    wire [7:0] CURR_STATE;
    
    wire [7:0] MSB_BYTE;
    wire [7:0] LSB_BYTE;
    wire [15:0] Final_Temp;
    wire [12:0] Temptopython;
    wire starttempsig;
    assign Final_Temp = {3'b000,MSB_BYTE,LSB_BYTE[7],LSB_BYTE[6],LSB_BYTE[5], LSB_BYTE[4], LSB_BYTE[3]};
    
    assign TrigerEvent = starttempsig;

    //Instantiate the module that we like to test
    I2C_Transmit I2C_Test1 (
        .button(button),
        .led(led),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),
        .ADT7420_A0(ADT7420_A0),
        .ADT7420_A1(ADT7420_A1),
        .I2C_SCL_0(I2C_SCL_0),
        .I2C_SDA_0(I2C_SDA_0),             
        .FSM_Clk_reg(FSM_Clk),        
        .ILA_Clk_reg(ILA_Clk),
        .ACK_bit(ACK_bit),
        .SCL(SCL),
        .SDA(SDA),
        .CURR_STATE(CURR_STATE),
        .Temp_MSByte(MSB_BYTE),
        .Temp_LSByte(LSB_BYTE),
        .starttempsig(starttempsig)
        );
    
    //Instantiate the ILA module
    ila_0 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0({led, SDA, SCL, ACK_bit}),                             
        .probe1({FSM_Clk, starttempsig}),
        .probe2(CURR_STATE),
        .probe3(MSB_BYTE),
        .probe4(LSB_BYTE),
        .probe5(Final_Temp)
        );
        
     //USB Communication
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
    
    localparam  endPt_count = 1;
    wire [endPt_count*65-1:0] okEHx;  
    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);
    
    okWireOut wire20 (  .okHE(okHE), 
                        .okEH(okEHx[ 0*65 +: 65 ]),
                        .ep_addr(8'h20), 
                        .ep_datain(Final_Temp));
                        
    okWireIn wire10 (   .okHE(okHE), 	
                        .ep_addr(8'h00), 	
                        .ep_dataout(starttempsig));	
    
endmodule