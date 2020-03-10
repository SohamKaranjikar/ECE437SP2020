`timescale 1ns / 1ps

module JTEG_Test_File(
    input [3:0] button,
    output [7:0] led,
    input sys_clkn,
    input sys_clkp,
    output CVM300_SPI_EN,
    output CVM300_SPI_IN,
    input CVM300_SPI_OUT,
    output CVM300_SPI_CLK,
    input   wire    [4:0] okUH,
    output  wire    [2:0] okHU,
    inout   wire    [31:0] okUHU,
    inout   wire    okAA
);

    wire  ILA_Clk, FSM_Clk, TrigerEvent;    
    wire [23:0] ClkDivThreshold = 1_000;   
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
    //Instantiate the module that we like to test
    SPI_Transmit I2C_Test1 (
        .button(button),
        .led(led),
        .sys_clkn(sys_clkn),
        .sys_clkp(sys_clkp),
        .SPI_CLK_0(CVM300_SPI_CLK),
        .SPI_EN_0(CVM300_SPI_EN),
        .SPI_IN_0(CVM300_SPI_IN),
        .SPI_OUT_0(CVM300_SPI_OUT),             
        .FSM_Clk_reg(FSM_Clk),        
        .ILA_Clk_reg(ILA_Clk),
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
    
    //Instantiate the ILA module
    ila_0 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0(ADDR),                             
        .probe1({FSM_Clk, button[3]}),
        .probe2(CURR_STATE),
        .probe3(DATA_WRITE),
        .probe4(DATA_READ),
        .probe5({C,SPI_IN,SPI_EN,SPI_OUT,SPI_CLK})
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
    
    localparam  endPt_count = 3;
    wire [endPt_count*65-1:0] okEHx;  
    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);
    
    okWireOut wire20 (  .okHE(okHE), 
                        .okEH(okEHx[ 0*65 +: 65 ]),
                        .ep_addr(8'h20), 
                        .ep_datain(DATA_READ));
                        
    okWireOut wire21 (  .okHE(okHE), 
                        .okEH(okEHx[ 1*65 +: 65 ]),
                        .ep_addr(8'h21), 
                        .ep_datain(writecomplete));
    okWireOut wire22 (  .okHE(okHE), 
                        .okEH(okEHx[ 2*65 +: 65 ]),
                        .ep_addr(8'h22), 
                        .ep_datain(readcomplete));

     
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
    
endmodule