----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:30:30 12/30/2015 
-- Design Name: 
-- Module Name:    Encoder - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Encoder is
	port (
		clk					: in	std_logic;
		rst					: in	std_logic;
		CathodeSig			: in	std_logic;
		XDP_IN				: in	std_logic_vector (15 downto 0);
		run					: in	std_logic;
		hit_flag			: out	std_logic;
		hit_2				: out	std_logic;
		hit_3				: out	std_logic;
		addr				: in	unsigned (10 downto 0);
		dout				: out	std_logic_vector (15 downto 0)
	);
end Encoder;

architecture Behavioral of Encoder is
	component ring_buf_16
	port (
		clka 				: IN 	STD_LOGIC;
		wea 				: IN 	STD_LOGIC_VECTOR ( 0 DOWNTO 0);
		addra 				: IN 	STD_LOGIC_VECTOR (10 DOWNTO 0);
		dina 				: IN 	STD_LOGIC_VECTOR (15 DOWNTO 0);
		douta 				: OUT	STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
	end component;

	signal	regXPD		: std_logic_vector (15 downto 0);
	signal	bufXPD		: std_logic_vector (15 downto 0);
	signal	addrCnt		: unsigned (10 downto 0);
	signal	EndCnt		: unsigned (10 downto 0);
	signal	hit_one		: std_logic_vector ( 3 downto 0);
	signal	hit_two		: std_logic_vector ( 3 downto 0);
	signal	hit_xor		: std_logic_vector ( 3 downto 0);
	signal	hit_tri		: std_logic_vector ( 3 downto 0);
	signal	wea			: std_logic_vector ( 0 downto 0);

	signal	Hit_Cnt		: std_logic_vector (11 downto 0)	:= (others => '0');
	signal	LatchUp_TrgBuf		: std_logic;
begin
hit_xor(0)		<= hit_one(0) xor hit_two(0);
hit_xor(1)		<= hit_one(1) xor hit_two(1);
hit_xor(2)		<= hit_one(2) xor hit_two(2);
hit_xor(3)		<= hit_one(3) xor hit_two(3);

process (clk)
begin
	if clk'event and clk='1' then
		if hit_tri/=x"0" or (hit_two/=x"0" and hit_xor/=x"0") then
			hit_3			<= '1';
		else
			hit_3			<= '0';
		end if;
	end if;
end process;

process (bufXPD( 3 downto  0))
begin
	case bufXPD( 3 downto  0) is
	when	x"0"								=>
		hit_one(0)		<= '0';
		hit_two(0)		<= '0';
		hit_tri(0)		<= '0';
	when	x"1" | x"2" | x"4" | x"8"			=>
		hit_one(0)		<= '1';
		hit_two(0)		<= '0';
		hit_tri(0)		<= '0';
	when	x"7" | x"b" | x"d" | x"e" | x"f"	=>
		hit_one(0)		<= '1';
		hit_two(0)		<= '1';
		hit_tri(0)		<= '1';
	when	others								=>
		hit_one(0)		<= '1';
		hit_two(0)		<= '1';
		hit_tri(0)		<= '0';
	end case;
end process;

process (bufXPD( 7 downto  4))
begin
	case bufXPD( 7 downto  4) is
	when	x"0"								=>
		hit_one(1)		<= '0';
		hit_two(1)		<= '0';
		hit_tri(1)		<= '0';
	when	x"1" | x"2" | x"4" | x"8"			=>
		hit_one(1)		<= '1';
		hit_two(1)		<= '0';
		hit_tri(1)		<= '0';
	when	x"7" | x"b" | x"d" | x"e" | x"f"	=>
		hit_one(1)		<= '1';
		hit_two(1)		<= '1';
		hit_tri(1)		<= '1';
	when	others								=>
		hit_one(1)		<= '1';
		hit_two(1)		<= '1';
		hit_tri(1)		<= '0';
	end case;
end process;

process (bufXPD(11 downto  8))
begin
	case bufXPD(11 downto  8) is
	when	x"0"								=>
		hit_one(2)		<= '0';
		hit_two(2)		<= '0';
		hit_tri(2)		<= '0';
	when	x"1" | x"2" | x"4" | x"8"			=>
		hit_one(2)		<= '1';
		hit_two(2)		<= '0';
		hit_tri(2)		<= '0';
	when	x"7" | x"b" | x"d" | x"e" | x"f"	=>
		hit_one(2)		<= '1';
		hit_two(2)		<= '1';
		hit_tri(2)		<= '1';
	when	others								=>
		hit_one(2)		<= '1';
		hit_two(2)		<= '1';
		hit_tri(2)		<= '0';
	end case;
end process;

process (bufXPD(15 downto 12))
begin
	case bufXPD(15 downto 12) is
	when	x"0"								=>
		hit_one(3)		<= '0';
		hit_two(3)		<= '0';
		hit_tri(3)		<= '0';
	when	x"1" | x"2" | x"4" | x"8"			=>
		hit_one(3)		<= '1';
		hit_two(3)		<= '0';
		hit_tri(3)		<= '0';
	when	x"7" | x"b" | x"d" | x"e" | x"f"	=>
		hit_one(3)		<= '1';
		hit_two(3)		<= '1';
		hit_tri(3)		<= '1';
	when	others								=>
		hit_one(3)		<= '1';
		hit_two(3)		<= '1';
		hit_tri(3)		<= '0';
	end case;
end process;

process (clk)
begin
	if clk'event and clk='1' then
		case hit_one is
		when	x"0" | x"1" | x"2" | x"4" | x"8"	=>		hit_2		<= '0';
		when	others								=>		hit_2		<= '1';
		end case;
	end if;
end process;

process (clk)
begin
	if clk'event and clk='1' then
		if CathodeSig='1' then
			bufXPD( 0)	<= not regXPD( 0);
			bufXPD( 1)	<= not regXPD( 1);
			bufXPD( 2)	<= not regXPD( 2);
			bufXPD( 3)	<= not regXPD( 3);
			bufXPD( 4)	<= not regXPD( 4);
			bufXPD( 5)	<= not regXPD( 5);
			bufXPD( 6)	<= not regXPD( 6);
			bufXPD( 7)	<= not regXPD( 7);
			bufXPD( 8)	<= not regXPD( 8);
			bufXPD( 9)	<= not regXPD( 9);
			bufXPD(10)	<= not regXPD(10);
			bufXPD(11)	<= not regXPD(11);
			bufXPD(12)	<= not regXPD(12);
			bufXPD(13)	<= not regXPD(13);
			bufXPD(14)	<= not regXPD(14);
			bufXPD(15)	<= not regXPD(15);
		else
			bufXPD		<= regXPD;
		end if;
	end if;
end process;

process (clk)
begin
	if clk'event and clk='1' then
		if bufXPD/=x"0000" then
			hit_flag		<= '1';
		else
			hit_flag		<= '0';
		end if;
	end if;
end process;

process (clk)
begin
	if clk'event and clk='1' then
		if run='1' then
			addrCnt		<= EndCnt;
		else
			addrCnt		<= EndCnt - addr;
		end if;
	end if;
end process;

process (clk, rst)
begin
	if rst='1' then
		EndCnt			<= (others => '0');
	elsif clk'event and clk='1' then
		if run='1' then
			EndCnt		<= EndCnt + 1;
		end if;
	end if;
end process;

RBuf_Enc		: ring_buf_16
port map (
	clka 				=> clk,
	wea 				=> wea,
	addra 				=> std_logic_vector(addrCnt),
	dina 				=> bufXPD,
	douta 				=> dout
);
wea(0)		<= run;

--  Chenged  --
XDP_00_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD(  0),	I => XDP_IN(  0) );
XDP_01_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD(  1),	I => XDP_IN(  1) );
XDP_02_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD(  2),	I => XDP_IN(  2) );
XDP_03_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD(  3),	I => XDP_IN(  3) );
XDP_04_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD(  4),	I => XDP_IN(  4) );
XDP_05_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD(  5),	I => XDP_IN(  5) );
XDP_06_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD(  6),	I => XDP_IN(  6) );
XDP_07_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD(  7),	I => XDP_IN(  7) );
XDP_08_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD(  8),	I => XDP_IN(  8) );
XDP_09_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD(  9),	I => XDP_IN(  9) );
XDP_0A_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD( 10),	I => XDP_IN( 10) );
XDP_0B_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD( 11),	I => XDP_IN( 11) );
XDP_0C_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD( 12),	I => XDP_IN( 12) );
XDP_0D_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD( 13),	I => XDP_IN( 13) );
XDP_0E_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD( 14),	I => XDP_IN( 14) );
XDP_0F_IB	: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
					port map	( O => regXPD( 15),	I => XDP_IN( 15) );

end Behavioral;

