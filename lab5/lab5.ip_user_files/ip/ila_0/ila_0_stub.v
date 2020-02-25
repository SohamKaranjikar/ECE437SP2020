// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Feb 21 18:25:33 2020
// Host        : ECEB-4022-10 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               U:/Desktop/ECE437SP2020/lab5/lab5.srcs/sources_1/ip/ila_0/ila_0_stub.v
// Design      : ila_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a75tfgg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2018.3" *)
module ila_0(clk, probe0, probe1, probe2, probe3, probe4, probe5)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[10:0],probe1[1:0],probe2[7:0],probe3[7:0],probe4[7:0],probe5[15:0]" */;
  input clk;
  input [10:0]probe0;
  input [1:0]probe1;
  input [7:0]probe2;
  input [7:0]probe3;
  input [7:0]probe4;
  input [15:0]probe5;
endmodule
