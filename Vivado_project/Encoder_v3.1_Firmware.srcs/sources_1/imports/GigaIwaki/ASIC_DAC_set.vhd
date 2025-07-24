----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:05:09 01/10/2016 
-- Design Name: 
-- Module Name:    ASIC_DAC_set - Behavioral 
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

entity ASIC_DAC_set is
	port	(
		CLK					: in	std_logic;
		RST					: in	std_logic;
		ACT					: in	std_logic;
		Run					: out	std_logic;
		Ch						: out	std_logic_vector ( 7 downto 0);
		Data					: in	std_logic_vector ( 7 downto 0);
		
		-- DAC I/O
		DAC_WE				: out	std_logic;
		DAC_CLK				: out	std_logic;
		DAC_RST				: out	std_logic;
		DAC_SD				: out	std_logic
	);
end ASIC_DAC_set;

architecture Behavioral of ASIC_DAC_set is
	signal	CtrlClk		: std_logic;
	signal  regCtrl     : std_logic;
	signal	reg_WE		: std_logic;
	signal	reg_CE		: std_logic;
	signal	reg_RST		: std_logic;
	signal	reg_SD		: std_logic;
	signal	reg_bit		: std_logic;
	signal	reg_Run		: std_logic;
	signal	dly_we		: std_logic;
	signal	reg_Din		: std_logic_vector ( 7 downto 0);
	signal	DataBuf		: std_logic_vector ( 7 downto 0);
	signal	ClkCount	: std_logic_vector ( 6 downto 0);
	signal	ChCount		: std_logic_vector ( 7 downto 0);
	signal	Ch_Num		: std_logic_vector ( 7 downto 0);
	signal	BitCount	: std_logic_vector ( 2 downto 0);
	signal	regState	: std_logic_vector ( 1 downto 0);
	signal	nextState	: std_logic_vector ( 1 downto 0);
begin
DAC_WE		<= reg_WE;
DAC_CLK		<= not (reg_CE and CtrlClk);
DAC_RST		<= not reg_RST;
DAC_SD		<= reg_SD;
Run			<= reg_Run;

process (CLK, RST)
begin
	if RST='1' then
		ClkCount				<= (others => '0');
	elsif CLK'event and CLK='1' then
		if ClkCount < 99 then
			ClkCount			<= ClkCount + 1;
		else
			ClkCount			<= (others => '0');
		end if;
	end if;
end process;

process (CLK)
begin
	if CLK'event and CLK='1' then
		if ClkCount < 49 then
			CtrlClk			<= '1';
		else
			CtrlClk			<= '0';
		end if;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		reg_Run				<= '0';
	elsif CLK'event and CLK='1' then
		if ACT='1' then
			reg_Run			<= '1';
		elsif reg_WE='0' and dly_we='1' then
			reg_Run			<= '0';
		end if;
	end if;
end process;

process (CLK)
begin
	if CLK'event and CLK='1' then
		reg_Din				<= Data;
		dly_we				<= reg_WE;
--		Ch						<= std_logic_vector (x"7f" - ChCount);
		Ch					<= std_logic_vector (Ch_Num);
        regCtrl             <= CtrlClk;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		regState				<= "00";
    elsif CLK'event and CLK='1' then
        if CtrlClk='1' and regCtrl='0' then
    		regState			<= nextState;
        end if;
	end if;
end process;

process (CLK)
begin
    if CLK'event and CLK='1' then
        if CtrlClk='1' and regCtrl='0' then
            case regState is
            when "01"	=>
                reg_WE			<= '1';
                reg_CE			<= '0';
                reg_RST			<= '1';
                reg_SD			<= '0';
		    when "11"	=>
                reg_WE			<= '1';
                reg_CE			<= '1';
                reg_RST			<= '0';
                reg_SD			<= reg_bit;
		    when others	=>
			    reg_WE			<= '0';
			    reg_CE			<= '0';
			    reg_RST			<= '0';
			    reg_SD			<= '0';
            end case;
        end if;
	end if;
end process;

process (CLK)
begin
    if CLK'event and CLK='1' then
    	if CtrlClk='1' and regCtrl='0' then
	   	    reg_bit				<= DataBuf(0);
    	end if;
    end  if;
end process;

process (CLK)
begin
    if CLK'event and CLK='1' then
        if CtrlClk='0' and regCtrl='1' then
    	    case regState is
		    when "11"	=>
			    if BitCount="111" then
				    DataBuf		<= reg_Din;
			    else
				    DataBuf		<= '0' & DataBuf ( 7 downto 1);
			    end if;
		    when others	=>
			    DataBuf			<= reg_Din;
		    end case;
        end if;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		BitCount				<= (others => '0');
    elsif CLK'event and CLK='1' then
        if CtrlClk='1' and regCtrl='0' then
		    if regState="11" then
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
		ChCount				<= (others => '0');
		Ch_Num				<= x"7f";
    elsif CLK'event and CLK='1' then
        if CtrlClk='0' and regCtrl='1' then
		    if regState="00" then
			    ChCount			<= (others => '0');
			    Ch_Num			<= x"7f";
		    elsif regState="11" and BitCount="000" then
			    ChCount			<= ChCount + 1;
			    Ch_Num			<= Ch_Num - 1;
            end if;
		end if;
	end if;
end process;

process (regState, reg_Run, ChCount, BitCount)
begin
	case regState is
	when "00"	=>
		if reg_Run='1' then
			nextState		<= "01";
		else
			nextState		<= "00";
		end if;
	when "01"	=>
		nextState			<= "11";
	when "11"	=>
		if ChCount > 127 and BitCount="111" then
			nextState		<= "10";
		else
			nextState		<= "11";
		end if;
	when others	=>
		if reg_Run='0' then
			nextState		<= "00";
		else
			nextState		<= "10";
		end if;
	end case;
end process;

end Behavioral;

