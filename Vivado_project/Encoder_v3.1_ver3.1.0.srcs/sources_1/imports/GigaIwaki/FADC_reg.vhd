----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:23:00 12/30/2015 
-- Design Name: 
-- Module Name:    FADC_reg - Behavioral 
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

entity FADC_reg is
	port (
		CLK					: in	std_logic;
		rst					: in	std_logic;
		run					: in	std_logic;
		Addr				: in	unsigned ( 9 downto 0);
		Dout_A				: out	std_logic_vector ( 9 downto 0);
		Dout_B				: out	std_logic_vector ( 9 downto 0);
		Dout_C				: out	std_logic_vector ( 9 downto 0);
		Dout_D				: out	std_logic_vector ( 9 downto 0);
		
		-- FADC I/F
		FADC_CLK			: out	std_logic;
		FADC_Set			: out	std_logic_vector ( 1 downto 0);
		FADC_Data_A			: in	std_logic_vector ( 9 downto 0);
		FADC_Data_B			: in	std_logic_vector ( 9 downto 0);
		FADC_Data_C			: in	std_logic_vector ( 9 downto 0);
		FADC_Data_D			: in	std_logic_vector ( 9 downto 0)
	);
end FADC_reg;

architecture Behavioral of FADC_reg is
	component ring_buf_10
	PORT (
		clka 				: IN 	STD_LOGIC;
		wea 				: IN 	STD_LOGIC_VECTOR ( 0 DOWNTO 0);
		addra 				: IN 	STD_LOGIC_VECTOR ( 9 DOWNTO 0);
		dina 				: IN 	STD_LOGIC_VECTOR ( 9 DOWNTO 0);
		douta 				: OUT STD_LOGIC_VECTOR ( 9 DOWNTO 0)
	);
  end component;
  
  signal		regWe		: std_logic_vector ( 0 downto 0);
  signal		regFCLK		: std_logic;
  signal		regAddr		: unsigned ( 9 downto 0);
  signal		bufAddr		: unsigned ( 9 downto 0);
begin
FADC_CLK		<= regFCLK;
FADC_Set		<= "01";

process (CLK, rst)
begin
	if rst='1' then
		regFCLK				<= '0';
	elsif CLK'event and CLK='1' then
		regFCLK				<= not regFCLK;
	end if;
end process;

process (CLK)
begin
	if CLK'event and CLK='1' then
		regWe(0)			<= (not regFCLK) and run;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		regAddr				<= (others => '0');
	elsif CLK'event and CLK='1' then
		if run='1' and regFCLK='1' then
			regAddr			<= regAddr + 1;
		end if;
	end if;
end process;

process (CLK)
begin
	if CLK'event and CLK='1' then
		if run='1' then
			bufAddr			<= regAddr;
		else
			bufAddr			<= regAddr - Addr;
		end if;
	end if;
end process;

RBuf_A	: ring_buf_10
port map (
	clka 					=> CLK,
	wea 					=> regWe,
	addra 				    => std_logic_vector(bufAddr),
	dina 					=> FADC_Data_A,
	douta 				    => Dout_A
);

RBuf_B	: ring_buf_10
port map (
	clka 					=> CLK,
	wea 					=> regWe,
	addra 				    => std_logic_vector(bufAddr),
	dina 					=> FADC_Data_B,
	douta 				    => Dout_B
);

RBuf_C	: ring_buf_10
port map (
	clka 					=> CLK,
	wea 					=> regWe,
	addra 				    => std_logic_vector(bufAddr),
	dina 					=> FADC_Data_C,
	douta 				    => Dout_C
);

RBuf_D	: ring_buf_10
port map (
	clka 					=> CLK,
	wea 					=> regWe,
	addra 				    => std_logic_vector(bufAddr),
	dina 					=> FADC_Data_D,
	douta 				    => Dout_D
);

end Behavioral;

