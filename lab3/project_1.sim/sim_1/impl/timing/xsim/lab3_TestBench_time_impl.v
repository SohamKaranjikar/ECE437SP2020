// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Tue Jan 28 12:06:27 2020
// Host        : ECEB-4022-08 running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               U:/Desktop/ECE437SP2020/lab3/project_1.sim/sim_1/impl/timing/xsim/lab3_TestBench_time_impl.v
// Design      : lab3_example
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7a75tfgg484-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* ECO_CHECKSUM = "cc003ab1" *) (* STATE_ALPHA = "2'b01" *) (* STATE_BRAVO = "2'b10" *) 
(* STATE_CHARLIE = "2'b11" *) (* STATE_INIT = "2'b00" *) 
(* NotValidForBitStream *)
module lab3_example
   (button,
    led,
    sys_clkn,
    sys_clkp);
  input [3:0]button;
  output [7:0]led;
  input sys_clkn;
  input sys_clkp;

  wire \FSM_sequential_state[0]_i_1_n_0 ;
  wire \FSM_sequential_state[1]_i_1_n_0 ;
  wire [3:0]button;
  wire [3:0]button_IBUF;
  wire clk;
  wire clk_BUFG;
  wire [7:0]led;
  wire [5:0]led_OBUF;
  wire \led_register[1]_inv_i_1_n_0 ;
  wire \led_register[2]_inv_i_1_n_0 ;
  wire \led_register[6]_inv_i_1_n_0 ;
  wire \led_register[7]_i_1_n_0 ;
  wire [7:3]led_register__0;
  wire \led_register_reg[6]_inv_lopt_replica_1 ;
  wire [1:0]state__0;
  (* DIFF_TERM = 0 *) (* IBUF_LOW_PWR *) wire sys_clkn;
  (* DIFF_TERM = 0 *) (* IBUF_LOW_PWR *) wire sys_clkp;

initial begin
 $sdf_annotate("lab3_TestBench_time_impl.sdf",,,,"tool_control");
end
  LUT5 #(
    .INIT(32'hAEAA2AA2)) 
    \FSM_sequential_state[0]_i_1 
       (.I0(state__0[0]),
        .I1(button_IBUF[0]),
        .I2(button_IBUF[2]),
        .I3(button_IBUF[3]),
        .I4(button_IBUF[1]),
        .O(\FSM_sequential_state[0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hAAEA2AA2)) 
    \FSM_sequential_state[1]_i_1 
       (.I0(state__0[1]),
        .I1(button_IBUF[0]),
        .I2(button_IBUF[2]),
        .I3(button_IBUF[3]),
        .I4(button_IBUF[1]),
        .O(\FSM_sequential_state[1]_i_1_n_0 ));
  (* FSM_ENCODED_STATES = "STATE_BRAVO:10,STATE_ALPHA:01,STATE_INIT:00,STATE_CHARLIE:11" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_sequential_state_reg[0] 
       (.C(clk_BUFG),
        .CE(1'b1),
        .D(\FSM_sequential_state[0]_i_1_n_0 ),
        .Q(state__0[0]),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "STATE_BRAVO:10,STATE_ALPHA:01,STATE_INIT:00,STATE_CHARLIE:11" *) 
  FDRE #(
    .INIT(1'b0)) 
    \FSM_sequential_state_reg[1] 
       (.C(clk_BUFG),
        .CE(1'b1),
        .D(\FSM_sequential_state[1]_i_1_n_0 ),
        .Q(state__0[1]),
        .R(1'b0));
  IBUF \button_IBUF[0]_inst 
       (.I(button[0]),
        .O(button_IBUF[0]));
  IBUF \button_IBUF[1]_inst 
       (.I(button[1]),
        .O(button_IBUF[1]));
  IBUF \button_IBUF[2]_inst 
       (.I(button[2]),
        .O(button_IBUF[2]));
  IBUF \button_IBUF[3]_inst 
       (.I(button[3]),
        .O(button_IBUF[3]));
  BUFG clk_BUFG_inst
       (.I(clk),
        .O(clk_BUFG));
  OBUF \led_OBUF[0]_inst 
       (.I(led_OBUF[0]),
        .O(led[0]));
  OBUF \led_OBUF[1]_inst 
       (.I(led_OBUF[1]),
        .O(led[1]));
  OBUF \led_OBUF[2]_inst 
       (.I(led_OBUF[2]),
        .O(led[2]));
  OBUF \led_OBUF[3]_inst 
       (.I(led_OBUF[3]),
        .O(led[3]));
  LUT1 #(
    .INIT(2'h1)) 
    \led_OBUF[3]_inst_i_1 
       (.I0(led_register__0[3]),
        .O(led_OBUF[3]));
  (* OPT_MODIFIED = "SWEEP " *) 
  OBUF \led_OBUF[4]_inst 
       (.I(\led_register_reg[6]_inv_lopt_replica_1 ),
        .O(led[4]));
  OBUF \led_OBUF[5]_inst 
       (.I(led_OBUF[5]),
        .O(led[5]));
  (* OPT_MODIFIED = "SWEEP " *) 
  OBUF \led_OBUF[6]_inst 
       (.I(led_OBUF[4]),
        .O(led[6]));
  OBUF \led_OBUF[7]_inst 
       (.I(led_OBUF[5]),
        .O(led[7]));
  LUT1 #(
    .INIT(2'h1)) 
    \led_OBUF[7]_inst_i_1 
       (.I0(led_register__0[7]),
        .O(led_OBUF[5]));
  LUT2 #(
    .INIT(4'h4)) 
    \led_register[1]_inv_i_1 
       (.I0(state__0[0]),
        .I1(state__0[1]),
        .O(\led_register[1]_inv_i_1_n_0 ));
  LUT2 #(
    .INIT(4'hD)) 
    \led_register[2]_inv_i_1 
       (.I0(state__0[0]),
        .I1(state__0[1]),
        .O(\led_register[2]_inv_i_1_n_0 ));
  LUT2 #(
    .INIT(4'hD)) 
    \led_register[6]_inv_i_1 
       (.I0(state__0[1]),
        .I1(state__0[0]),
        .O(\led_register[6]_inv_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFAFCFFF1FFFFF0F)) 
    \led_register[7]_i_1 
       (.I0(state__0[0]),
        .I1(state__0[1]),
        .I2(button_IBUF[0]),
        .I3(button_IBUF[2]),
        .I4(button_IBUF[3]),
        .I5(button_IBUF[1]),
        .O(\led_register[7]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b1)) 
    \led_register_reg[0]_inv 
       (.C(clk_BUFG),
        .CE(\led_register[7]_i_1_n_0 ),
        .D(state__0[1]),
        .Q(led_OBUF[0]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \led_register_reg[1]_inv 
       (.C(clk_BUFG),
        .CE(\led_register[7]_i_1_n_0 ),
        .D(\led_register[1]_inv_i_1_n_0 ),
        .Q(led_OBUF[1]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \led_register_reg[2]_inv 
       (.C(clk_BUFG),
        .CE(\led_register[7]_i_1_n_0 ),
        .D(\led_register[2]_inv_i_1_n_0 ),
        .Q(led_OBUF[2]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \led_register_reg[3] 
       (.C(clk_BUFG),
        .CE(\led_register[7]_i_1_n_0 ),
        .D(state__0[0]),
        .Q(led_register__0[3]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b1)) 
    \led_register_reg[6]_inv 
       (.C(clk_BUFG),
        .CE(\led_register[7]_i_1_n_0 ),
        .D(\led_register[6]_inv_i_1_n_0 ),
        .Q(led_OBUF[4]),
        .R(1'b0));
  (* OPT_INSERTED_REPDRIVER *) 
  (* OPT_MODIFIED = "SWEEP " *) 
  FDRE #(
    .INIT(1'b1)) 
    \led_register_reg[6]_inv_lopt_replica 
       (.C(clk_BUFG),
        .CE(\led_register[7]_i_1_n_0 ),
        .D(\led_register[6]_inv_i_1_n_0 ),
        .Q(\led_register_reg[6]_inv_lopt_replica_1 ),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \led_register_reg[7] 
       (.C(clk_BUFG),
        .CE(\led_register[7]_i_1_n_0 ),
        .D(state__0[1]),
        .Q(led_register__0[7]),
        .R(1'b0));
  (* BOX_TYPE = "PRIMITIVE" *) 
  (* CAPACITANCE = "DONT_CARE" *) 
  (* IBUF_DELAY_VALUE = "0" *) 
  (* XILINX_LEGACY_PRIM = "IBUFGDS" *) 
  IBUFDS #(
    .IOSTANDARD("DEFAULT")) 
    osc_clk
       (.I(sys_clkp),
        .IB(sys_clkn),
        .O(clk));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
