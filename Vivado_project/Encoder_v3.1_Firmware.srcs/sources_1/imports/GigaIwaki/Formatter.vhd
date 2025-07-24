----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:01:22 12/31/2015 
-- Design Name: 
-- Module Name:    Formatter - Behavioral 
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

entity Formatter is
	generic (
		ClkDepth              : unsigned ( 10 downto 0)
	);
	port (
		CLK	                  : in	std_logic;
		RST					  : in	std_logic;
		Trigger	              : in	std_logic;
		CntReset              : in	std_logic;
		Run	                  : out	std_logic;
		D_Exist               : in	std_logic;
		EncAddr               : out	unsigned ( 10 downto 0);
		FadcAddr              : out	unsigned (  9 downto 0);
		HitData	              : in	std_logic_vector (127 downto 0);
		FADC_A                : in	std_logic_vector (  9 downto 0);
		FADC_B                : in	std_logic_vector (  9 downto 0);
		FADC_C                : in	std_logic_vector (  9 downto 0);
		FADC_D                : in	std_logic_vector (  9 downto 0);
		valid                 : in	std_logic;
		GSOcounter            : in	std_logic_vector ( 31 downto 0);
		WriteEna              : out	std_logic;
		Dout                  : out	std_logic_vector ( 31 downto 0)
	);
end Formatter;

architecture Behavioral of Formatter is
	type		FmtrState	is	(	AcqData,	Header0,	Header1,	Header2,	Header3,
									FADC_01,	FADC_23,	EncDt_0,	EncDt_1,	Fotter	);
	type		EncState	is	(	ClkData,	Enc_0,	Enc_1,	Enc_2,	Enc_3,	Dwait	);

	signal	regState        : FmtrState;
	signal	nextState		: FmtrState;
	signal	regEncode		: EncState;
	signal	nextEncode		: EncState;
	signal	ECntRst			: std_logic;
	signal	reg_we			: std_logic;
	signal	clk100us		: std_logic;
	signal  reg100us        : std_logic;
	signal	hit_flag		: std_logic;
	signal	TrgFlag			: std_logic;
	signal  regTrigger      : std_logic;
	signal	regDout			: std_logic_vector ( 31 downto 0);
	signal	EvtCount		: std_logic_vector ( 31 downto 0);
	signal	cnt100us		: std_logic_vector ( 13 downto 0);
	signal	ClkCount		: std_logic_vector ( 31 downto 0);
	signal	LatchedCnt		: std_logic_vector ( 31 downto 0);
	signal	preF_A			: std_logic_vector (  9 downto 0);
	signal	preF_B			: std_logic_vector (  9 downto 0);
	signal	preF_C			: std_logic_vector (  9 downto 0);
	signal	preF_D			: std_logic_vector (  9 downto 0);
	signal	EncHitData		: std_logic_vector ( 31 downto 0);
	signal	EncClock		: std_logic_vector ( 10 downto 0);
	signal	regHitData		: std_logic_vector (127 downto 0);
	signal	regGSOcount		: std_logic_vector ( 31 downto 0);
	signal	regFadcAddr		: unsigned ( 9 downto 0);
	signal	regEncAddr		: unsigned (10 downto 0);
begin
EncAddr		<= regEncAddr;
FadcAddr	<= regFadcAddr;
ECntRst		<= RST or CntReset;

process (CLK, RST)
begin
	if RST='1' then
		regState              <= AcqData;
		regEncode			  <= ClkData;
		WriteEna              <= '0';
		Dout                  <= (others => '0');
	elsif CLK'event and CLK='1' then
		regState              <= nextState;
		regEncode             <= nextEncode;
		WriteEna              <= reg_we;
		Dout                  <= regDout;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		Run                  <= '0';
	elsif CLK'event and CLK='1' then
		if regState=AcqData then
            Run              <= '1';
		else
			Run              <= '0';
		end if;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		reg_we				<= '0';
	elsif CLK'event and CLK='1' then
		if regState/=AcqData and regEncode/=Dwait then
			if regState=EncDt_1 and regEncode=ClkData and hit_flag='0' then
				reg_we		<= '0';
			else
				reg_we		<= valid;
			end if;
		else
			reg_we			<= '0';
		end if;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		regDout				<= (others => '0');
	elsif CLK'event and CLK='1' then
		case regState is
		when	Header1	=>		regDout	<= EvtCount;
		when	Header2	=>		regDout	<= LatchedCnt;
		when    Header3	=>      regDout	<= regGSOcount;
		when	FADC_01	=>		regDout	<= "010000" & PreF_A & "010100" & PreF_B;
		when	FADC_23	=>		regDout	<= "011000" & PreF_C & "011100" & PreF_D;
		when	EncDt_0	=>		regDout	<= x"1603" & x"1" & '0' & std_logic_vector(ClkDepth);
		when	EncDt_1	=>		regDout	<= EncHitData;
		when	Fotter	=>		regDout	<= x"75504943";
		when	others	=>		regDout	<= x"eb90" & x"19" & x"64";
		end case;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		regFadcAddr			<= ClkDepth (10 downto 1);
	elsif CLK'event and CLK='1' then
		if regState=FADC_01 then
			if valid='1' then
				regFadcAddr	<= regFadcAddr - 1;
			end if;
		elsif regState /= FADC_23 then
			regFadcAddr		<= ClkDepth (10 downto 1);
		end if;
	end if;
end process;

process (CLK)
begin
	if CLK'event and CLK='1' then
		if regState = FADC_01 then
			PreF_A			<= FADC_A;
			PreF_B			<= FADC_B;
			PreF_C			<= FADC_C;
			PreF_D			<= FADC_D;
		end if;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
        regEncAddr            <= ClkDepth;
		EncClock              <= (others => '0');
	elsif CLK'event and CLK='1' then
		if regState=EncDt_1 then
			if valid='1' and regEncode=ClkData then
                regEncAddr    <= regEncAddr - 1;
				EncClock      <= EncClock + 1;
			end if;
		else
			regEncAddr        <= ClkDepth;
			EncClock          <= (others => '0');
		end if;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		EncHitData			<= (others => '0');
	elsif CLK'event and CLK='0' then
		case regEncode is
		when ClkData	=>		EncHitData	<= x"8000" & "00000" & EncClock;
		when Enc_0		=>		EncHitData	<= regHitData (127 downto 96);
		when Enc_1		=>		EncHitData	<= regHitData ( 95 downto 64);
		when Enc_2		=>		EncHitData	<= regHitData ( 63 downto 32);
		when Enc_3		=>		EncHitData	<= regHitData ( 31 downto  0);
		when Dwait		=>		EncHitData	<= x"8000" & "00000" & EncClock;
		end case;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		regHitData			<= (others => '0');
		hit_flag				<= '0';
	elsif CLK'event and CLK='1' then
		if regState=EncDt_1 then
			if regEncode=ClkData then
				regHitData	<= HitData;
				if HitData = x"00000000000000000000000000000000" then
					hit_flag	<= '0';
				else
					hit_flag	<= '1';
				end if;
			end if;
		else
			regHitData		<= (others => '0');
			hit_flag			<= '0';			
		end if;
	end if;
end process;

process (regState, regEncode, hit_flag, valid)
begin
	if regState=EncDt_1 then
		case regEncode is
		when	ClkData	=>
			if valid='0' then
				nextEncode		<= ClkData;
			elsif hit_flag='1' then
				nextEncode		<= Enc_0;
			else
				nextEncode		<= Dwait;
			end if;
		when	Enc_0		=>
			if valid='0' then
				nextEncode		<= Enc_0;
			else
				nextEncode		<= Enc_1;
			end if;
		when	Enc_1		=>
			if valid='0' then
				nextEncode		<= Enc_1;
			else
				nextEncode		<= Enc_2;
			end if;
		when	Enc_2		=>
			if valid='0' then
				nextEncode		<= Enc_2;
			else
				nextEncode		<= Enc_3;
			end if;
		when	Enc_3		=>
			if valid='0' then
				nextEncode		<= Enc_3;
			else
				nextEncode		<= Dwait;
			end if;
		when	Dwait		=>
			nextEncode			<= ClkData;
		end case;
	else
		nextEncode				<= ClkData;
	end if;
end process;

process (CLK, RST)
begin
	if RST='1' then
		TrgFlag				<= '0';
	elsif CLK'event and CLK='1' then
		if Trigger='0' then
			TrgFlag			<= '0';
		elsif regState=Header0 then
			TrgFlag			<= '1';
		end if;
	end if;
end process;

process (regState, Trigger, TrgFlag, EncClock, D_Exist, valid, regFadcAddr, regEncode)
begin
	case (regState) is
	when	AcqData	=>
		if Trigger='1' and TrgFlag='0' then
			nextState		<= Header0;
		else
			nextState		<= AcqData;
		end if;
	when	Header0	=>
		if valid='1' then
			nextState		<= Header1;
		else
			nextState		<= Header0;
		end if;
	when	Header1	=>
		if valid='1' then
			nextState		<= Header2;
		else
			nextState		<= Header1;
		end if;
	when	Header2	=>
		if valid='1' then
			nextState		<= Header3;
		else
			nextState		<= Header2;
		end if;
	when	Header3	=>
		if valid='1' then
			if D_Exist='1' then
				nextState	<= FADC_01;
			else
				nextState	<= Fotter;
			end if;
		else
			nextState		<= Header3;
		end if;
	when	FADC_01	=>
		if valid='1' then
			nextState		<= FADC_23;
		else
			nextState		<= FADC_01;
		end if;
	when	FADC_23	=>
		if valid='1' then
			if regFadcAddr="0000000000" or regFadcAddr > ClkDepth (10 downto 1) then
				nextState	<= EncDt_0;
			else
				nextState	<= FADC_01;
			end if;
		else
			nextState		<= FADC_23;
		end if;
	when	EncDt_0	=>
		if valid='1' then
			nextState		<= EncDt_1;
		else
			nextState		<= EncDt_0;
		end if;
	when	EncDt_1	=>
		if EncClock>=std_logic_vector(ClkDepth) and regEncode=Dwait and valid='1' then
			nextState		<= Fotter;
		else
			nextState		<= EncDt_1;
		end if;
	when	Fotter	=>
		if valid='1' then
			nextState		<= AcqData;
		else
			nextState		<= Fotter;
		end if;
	end case;
end process;

process (CLK)
begin
    if CLK'event and CLK='1' then
        regTrigger          <= Trigger;
        reg100us            <= clk100us;
    end if;
end process;

process (CLK, ECntRst)
begin
	if ECntRst='1' then
		EvtCount			<= (others => '0');
		LatchedCnt			<= (others => '0');
		regGSOcount			<= (others => '0');
    elsif CLK'event and CLK='1' then
        if Trigger='1' and regTrigger='0' then
    		EvtCount		<= EvtCount + 1;
    		LatchedCnt		<= ClkCount;
    		regGSOcount		<= GSOcounter;
        end if;
	end if;
end process;

process (CLK, ECntRst)
begin
	if ECntRst='1' then
		ClkCount				<= (others => '0');
    elsif CLK'event and CLK='1' then
        if clk100us='1' and reg100us='0' then
    		ClkCount			<= ClkCount + 1;
        end if;
	end if;
end process;

process (CLK, ECntRst)
begin
	if ECntRst='1' then
		clk100us				<= '0';
		cnt100us				<= (others => '0');
	elsif CLK'event and CLK='1' then
		if cnt100us < "10" & x"708" then
			clk100us			<= '0';
			cnt100us			<= cnt100us + 1;
		else
			clk100us			<= '1';
			cnt100us			<= (others => '0');
		end if;
	end if;
end process;

end Behavioral;

