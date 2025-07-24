----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:19:59 01/11/2016 
-- Design Name: 
-- Module Name:    DACset - Behavioral 
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity DACset is
	generic (
		Addr				: in	std_logic_vector (7 downto 0)
	);
	port (
		CLK					: in	std_logic;
		RST					: in	std_logic;
		ACT					: in	std_logic;
		Run					: out	std_logic;
		Ch					: out	std_logic_vector ( 7 downto 0);
		Data				: in	std_logic_vector ( 7 downto 0);
		
		-- DAC I/O
		DAC_SYNC			: out	std_logic;
		DAC_CLK				: out	std_logic;
		DAC_DIN				: out	std_logic
	);
end DACset;

architecture Behavioral of DACset is
	type	VthState		is (	stay,	u_rd,	d_rd,	ctrl,	wrun );

	signal	CtrlClk         : std_logic;
	signal  reg_cclk        : std_logic;
	signal	reg_sync        : std_logic;
	signal	reg_ce          : std_logic;
	signal	reg_din         : std_logic;
	signal	reg_Run         : std_logic;
	signal	dly_ce          : std_logic;
	signal	regState		: VthState;
	signal	nextState       : VthState;
	signal	ClkCount		: std_logic_vector ( 3 downto 0);
	signal	BitCount		: std_logic_vector ( 3 downto 0);
	signal	DAC_Data		: std_logic_vector (15 downto 0);
begin
DAC_CLK		<= CtrlClk		when reg_sync='0'	else	'1';
Run			<= reg_Run;

process (CLK, RST)
begin
	if RST='1' then
        ClkCount                 <= (others => '0');
	elsif CLK'event and CLK='1' then
		if ClkCount > 8 then
            ClkCount             <= (others => '0');
		else
			ClkCount             <= ClkCount + 1;
		end if;
	end if;
end process;

process (CLK)
begin
	if CLK'event and CLK='1' then
		if ClkCount < 5 then
			CtrlClk              <= '1';
		else
			CtrlClk              <= '0';
		end if;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		Ch                       <= (others => '0');
	elsif CLK'event and CLK='1' then
		case regState is
		when u_rd	=>
			Ch                   <= Addr;
		when d_rd	=>
			Ch                   <= Addr + '1';
		when others	=>
			Ch                   <= (others => '0');
		end case;
	end if;
end process;

process (CLK)
begin
	if CLK'event and CLK='1' then
		dly_ce                   <= reg_ce;
		DAC_SYNC                 <= reg_sync;
		reg_cclk                 <= CtrlClk;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		reg_Run                  <= '0';
	elsif CLK'event and CLK='1' then
		if ACT='1' then
			reg_Run              <= '1';
		elsif reg_ce='0' and dly_ce='1' then
			reg_Run              <= '0';
		end if;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		regState                 <= stay;
	elsif CLK'event and CLK='1' then
	    if CtrlClk='0' and reg_cclk='1' then
      		regState             <= nextState;
        end if;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		DAC_Data                       <= (others => '0');
	elsif CLK'event and CLK='1' then
        if CtrlClk='1' and reg_cclk='0' then
       	    if regState=u_rd then
           	    DAC_Data (15 downto 8)	<= "00" & Data ( 5 downto 0);
            elsif regState=d_rd then
		        DAC_Data ( 7 downto 0)	<= Data;
            elsif regState=ctrl then
                DAC_Data				<= DAC_Data (14 downto 0) & '0';
            end if;
        end if;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		BitCount				<= (others => '0');
	elsif CLK'event and CLK='1' then
        if CtrlClk='1' and reg_cclk='0' then
            if regState=ctrl then
	           BitCount			<= BitCount + 1;
            else
               BitCount			<= (others => '0');
            end if;
		end if;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		reg_sync				<= '1';
		reg_ce				<= '0';
	elsif CLK'event and CLK='1' then
        if CtrlClk='1' and reg_cclk='0' then
            if regState=ctrl then
                reg_sync			<= '0';
                reg_ce			<= '1';
            else
                reg_sync			<= '1';
                reg_ce			<= '0';
            end if;
		end if;
	end if;
end process;

process (CLK)
begin
	if CLK'event and CLK='1' then
        if CtrlClk='0' and reg_cclk='1' then
       		reg_din				<= DAC_Data(15);
       		DAC_DIN				<= reg_din;
        end if;
	end if;
end process;

process (regState, reg_Run, BitCount)
begin
	case regState is
	when	stay	=>
		if reg_Run='1' then
			nextState		<= u_rd;
		else
			nextState		<= stay;
		end if;
	when	u_rd	=>
		nextState			<= d_rd;
	when	d_rd	=>
		nextState			<= ctrl;
	when	ctrl	=>
		if BitCount < 15 then
			nextState		<= ctrl;
		else
			nextState		<= wrun;
		end if;
	when	wrun	=>
		if reg_Run='0' then
			nextState		<= stay;
		else
			nextState		<= wrun;
		end if;
	end case;
end process;

end Behavioral;

