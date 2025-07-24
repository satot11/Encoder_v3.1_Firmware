//-------------------------------------------------------------------//
//
//	Copyright(c) 2020 BeeBeans Technologies. All rights reserved.
//
//	System      : System using LAN8810
//
//	Module      : LAN8810_INIT
//
//	Description : Initialze for LAN8810
//
//	file	: LAN8810_INIT.v
//
//	Note	:
//
//	history	:
//		1.0		20201224	---------		Created by M.Ishiwata
//-------------------------------------------------------------------//
`timescale 1ps / 1ps
`default_nettype none


module	LAN8810_INIT
	#(
		parameter	[7:0]	freqency	= 200		// Frequency of CLOCK_IN (MHz)
	)(
		input	wire			I_nRESET,			// in :reset in
		input	wire			CLOCK,				// in :SiTCP Clock
		input	wire	[ 4:0]	PHY_ADDR,			// in :PHY Address[4:0]
		input	wire			SiTCP_PHY_nRST,		// in :PHY Reset from SiTCP
		input	wire			SiTCP_MDC,			// in :MDC form SiTCP
		input	wire			SiTCP_MDIO_OUT,		// in :MDIO_OUT from SiTCP
		input	wire			SiTCP_MDIO_OE,		// in :MDIO_OE from SiTCP
		output	wire			MDC,				// out:MDC to LAN8810
		output	wire			O_MDIO,				// out:To the I port of the MDIO driver
		output	wire			T_MDIO,				// out:To the T port of the MDIO driver
		output	reg				PHY_nRESET,			// out:Reset for LAN8810
		output	reg				O_RESET				// out:reset out
	);
	localparam	[7:0]	load_1us = freqency - 2;

	reg		[ 8:0]	CNT_1us;
	reg		[ 7:0]	CNT_100us;
	reg		[ 7:0]	CNT_10ms;
	reg		[ 2:0]	INIT_STATE;
	reg				INIT_MDC;
	reg				INIT_MDT;
	reg				INIT_MDO;
	reg		[ 6:0]	INC_LOD;
	reg		[ 7:0]	CNT_INC;
	reg		[ 6:0]	CNT_MDIO;
	reg				STATE_INC;
	reg				ENB_MDIO;
	reg		[31:0]	SFT_MDIO;

	assign	MDC		= O_RESET?	INIT_MDC:	SiTCP_MDC;
	assign	O_MDIO	= O_RESET?	INIT_MDO:	SiTCP_MDIO_OUT;
	assign	T_MDIO	= O_RESET?	INIT_MDT:	(~SiTCP_MDIO_OE);

	initial	CNT_1us[8:0]	= {1'b0,load_1us[7:0]};
	initial	CNT_100us[7:0]	= {1'b0,7'd99};
	initial	CNT_10ms[7:0]	= {1'b0,7'd99};
	always @( posedge CLOCK) begin
		CNT_1us[8:0]	<= CNT_1us[8]?		{1'b0,load_1us[7:0]}:	(CNT_1us[8:0] - 9'd1);
		CNT_100us[7:0]	<= CNT_100us[7]?	{1'b0,7'd99}:			(CNT_100us[7:0] - {7'd0,CNT_1us[8]});
		CNT_10ms[7:0]	<= CNT_10ms[7]?		{1'b0,7'd99}:			(CNT_10ms[7:0] - {7'd0,CNT_100us[7]});
	end
//
//	INIT_STATE
//		000		PHY_nRESET = H
//		001		PHY_nRESET = H
//		010		PHY_nRESET = L
//		011		PHY_nRESET = L
//		100		PHY_nRESET = H
//		101		PHY_nRESET = H	MDIO(0) <= 0x4040
//		110		PHY_nRESET = H
//		111		PHY_nRESET = SiTCP_PHY_nRST

	always @( posedge CLOCK or negedge I_nRESET) begin
		if (~I_nRESET) begin
			INIT_STATE[2:0]	<= 3'b000;
			PHY_nRESET		<= 1'b1;
			O_RESET			<= 1'b1;
			INIT_MDC		<= 1'b1;
			INIT_MDT		<= 1'b1;
			INIT_MDO		<= 1'b1;
		end else begin
			INIT_STATE[2:0]	<= STATE_INC?		(INIT_STATE[2:0] + 3'd1):	INIT_STATE[2:0];
			PHY_nRESET		<= ~(
				( INIT_STATE[2:1] == 2'b01)|
				((INIT_STATE[2:0] == 3'b111) & ~SiTCP_PHY_nRST)
			);
			O_RESET			<= ~(INIT_STATE[2:0] == 3'b111);
			INIT_MDC		<= (INIT_STATE[2:0] == 3'b101)?		(INIT_MDC ^ (CNT_1us[8] & ~(INIT_MDC & CNT_MDIO[6]))):	INIT_MDC;
			INIT_MDT		<= ENB_MDIO?	~CNT_MDIO[5]:	INIT_MDT;
			if (ENB_MDIO) begin
				INIT_MDO		<= CNT_MDIO[5]?		SFT_MDIO[31]:	1'b1;
			end
		end
	end
	always @( posedge CLOCK) begin
		INC_LOD[6:0]	<= INIT_STATE[2]?	7'd99:		7'd24;
		CNT_INC[7:0]	<= (INIT_STATE[2] & ~INIT_STATE[0])?	(CNT_INC[7:0] - {7'd0,CNT_10ms[7]}):	{1'b0,INC_LOD[6:0]};
		CNT_MDIO[6:0]	<= (INIT_STATE[2:0] == 3'b101)?			(CNT_MDIO[6:0] + {6'd0,ENB_MDIO}):		7'd0;
		STATE_INC	<= (
			((INIT_STATE[2]   == 1'b0  ) & CNT_100us[7])|
			((INIT_STATE[2:0] == 3'b100) & CNT_INC[7] & CNT_10ms[7])|
			((INIT_STATE[2:0] == 3'b101) & CNT_MDIO[6]  & ENB_MDIO)|
			((INIT_STATE[2:0] == 3'b110) & CNT_INC[7] & CNT_10ms[7])
		);
		ENB_MDIO	<= (INIT_STATE[2:0] == 3'b101) & INIT_MDC & CNT_1us[8];
		if (ENB_MDIO) begin
			SFT_MDIO[31:0]	<= CNT_MDIO[5]?		{SFT_MDIO[30:0],1'b1}:		{2'b01,2'b01,PHY_ADDR[4:0],5'b0_0000,2'b11,16'h4040};
		end
	end

endmodule
`default_nettype wire
