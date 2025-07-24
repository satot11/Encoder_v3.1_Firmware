-- vhdl-linter-disable not-declared type-resolved component
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/09/27 21:30:18
-- Design Name: 
-- Module Name: RBCP_REG - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity RBCP_REG is
    Port (  clock               : in    std_logic;
            reset               : in    std_logic;
            rbcp_act            : in    std_logic;
            rbcp_addr           : in    std_logic_vector (31 downto 0);
            rbcp_wd             : in    std_logic_vector ( 7 downto 0);
            rbcp_we             : in    std_logic;
            rbcp_re             : in    std_logic;
            rbcp_ack            : out   std_logic;
            rbcp_rd             : out   std_logic_vector ( 7 downto 0);

			DAC_ack				: out	std_logic;
			DAC_ctrl			: in	std_logic;
			DAC_Ch				: in	std_logic_vector ( 7 downto 0);
			DAC_Data			: out	std_logic_vector ( 7 downto 0);

            Vth_ack             : out   std_logic;
            Vth_ctrl            : in    std_logic;
            Vth_Ch              : in    std_logic_vector ( 7 downto 0);
            Vth_Data            : out   std_logic_vector ( 7 downto 0);

            ADC_BIAS_ack        : out   std_logic;
            ADC_BIAS_ctrl       : in    std_logic;
            ADC_BIAS_Ch         : in    std_logic_vector (7 downto 0);
            ADC_BIAS_Data       : out   std_logic_vector (7 downto 0);

            AP_ON               : out   std_logic;
            LatchUp_Detect      : out   std_logic
     );
end RBCP_REG;

architecture Behavioral of RBCP_REG is

    component   blk_mem_gen_0
	PORT (
		clka : IN STD_LOGIC;
		rsta : IN STD_LOGIC;
		wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		rsta_busy : OUT STD_LOGIC 
	);
    end component;
    
    signal  irAddr          : std_logic_vector (31 downto 0);
    signal  irWe            : std_logic;
    signal  irWd            : std_logic_vector ( 7 downto 0);
    signal  irRe            : std_logic;
    signal  valid_flag      : std_logic;
    signal  regState        : std_logic_vector ( 2 downto 0);
    signal  nextState       : std_logic_vector ( 2 downto 0);
    signal  regWe           : std_logic_vector ( 0 downto 0);
    signal  bufWe           : std_logic_vector ( 0 downto 0);
    signal  regAddr         : std_logic_vector ( 7 downto 0);
    signal  bufAddr         : std_logic_vector ( 7 downto 0);
    signal  chkAddr         : std_logic_vector (31 downto 0);
    signal  regDin          : std_logic_vector ( 7 downto 0);
    signal  bufDin          : std_logic_vector ( 7 downto 0);
    signal  regDout         : std_logic_vector ( 7 downto 0);
    signal  bufDout         : std_logic_vector ( 7 downto 0);
    signal  bufAck          : std_logic;
    signal  vth_flag        : std_logic;
    signal  ctrl_flag       : std_logic;

    signal  ADC_BIAS_flag   : std_logic;
    signal  ADC_ctrl_Buf    : std_logic;
    signal  Vth_ctrl_Buf    : std_logic;
    signal  DAC_ctrl_Buf    : std_logic;
    signal  ADC_BIAS_Ch_Buf : std_logic_vector ( 7 downto 0);
    signal  DAC_Ch_Buf      : std_logic_vector ( 7 downto 0);
    signal  Vth_Ch_Buf      : std_logic_vector ( 7 downto 0);

	signal	DAC_flag		: std_logic;

    signal  AP_ON_flag      : std_logic;
    signal  AP_OFF_flag     : std_logic;

    signal  LatchUp_DetectOn    : std_logic;
    signal  LatchUp_DetectOff   : std_logic;
    signal  ctrl_flag2          : std_logic;

begin

process (clock, reset)
begin
    if reset='1' then
        irAddr              <= (others => '0');
        irWe                <= '0';
        irWd                <= (others => '0');
        irRe                <= '0';
        rbcp_ack            <= '0';
        rbcp_rd             <= (others => '0');
        regState            <= "000";
        regWe               <= (others => '0');
        regAddr             <= (others => '0');
        regDin              <= (others => '0');
        AP_ON               <= '0';
        LatchUp_Detect      <= '0';
        ADC_ctrl_Buf        <= '0';
        Vth_ctrl_Buf        <= '0';
        DAC_ctrl_Buf        <= '0';
    elsif clock'event and clock='1' then
        irAddr              <= rbcp_addr;
        irWe                <= rbcp_we;
        irWd                <= rbcp_wd;
        irRe                <= rbcp_re;
        rbcp_ack            <= bufAck;
        rbcp_rd             <= bufDout;
        regState            <= nextState;
        regWe               <= bufWe;
        regAddr             <= bufAddr;
        regDin              <= bufDin;
        AP_ON               <= AP_ON_flag;
        LatchUp_Detect      <= LatchUp_DetectOn;
        ADC_ctrl_Buf        <= ADC_BIAS_ctrl;
        Vth_ctrl_Buf        <= Vth_ctrl;
        DAC_ctrl_Buf        <= DAC_ctrl;
    end if;
end process;

process (clock)
begin
    if clock'event and clock='1' then
        ADC_BIAS_Ch_Buf     <= ADC_BIAS_Ch;
        DAC_Ch_Buf          <= DAC_Ch;
        Vth_Ch_Buf          <= Vth_Ch;
    end if;
end process;

process (clock, reset)
begin
   if reset='1' then
       DAC_ack             <= '0';
   elsif clock'event and clock='1' then
       if DAC_ctrl_Buf='1' then
           DAC_ack         <= '0';
       elsif DAC_flag='1' and bufAck='1' then
           DAC_ack         <= '1';
       end if;
   end if;
end process;

process (clock, reset)
begin
    if reset='1' then
        Vth_ack             <= '0';
    elsif clock'event and clock='1' then
        if Vth_ctrl_Buf='1' then
            Vth_ack         <= '0';
		elsif vth_flag='1' and bufAck='1' then
            Vth_ack         <= '1';
        end if;
    end if;
end process;

process (clock, reset)
begin
    if reset='1' then
        ADC_BIAS_ack        <= '0';
    elsif clock'event and clock='1' then
        if ADC_ctrl_Buf='1' then
            ADC_BIAS_ack    <= '0';
        elsif ADC_BIAS_flag='1' and bufAck='1' then
            ADC_BIAS_ack    <= '1';
        end if;
    end if;
end process;

process (clock, reset)
begin
    if reset='1' then
        bufAddr             <= (others => '0');
        bufWe(0)            <= '0';
        bufDin              <= (others => '0');
        bufDout             <= (others => '1');
		DAC_Data			<= (others => '0');
        Vth_Data            <= (others => '0');
        ADC_BIAS_Data       <= (others => '0');
    elsif clock'event and clock='1' then
        if rbcp_act='1' then
            bufAddr         <= irAddr ( 7 downto 0);
            bufWe(0)        <= irWe and valid_flag and (not ctrl_flag) and (not ctrl_flag2);
            bufDin          <= irWd;
            bufDout         <= regDout;
			DAC_Data		<= (others => '0');
            Vth_Data        <= (others => '0');
            ADC_BIAS_Data   <= (others => '0');
		elsif DAC_ctrl_Buf='1' then
			bufAddr			<= DAC_Ch_Buf;
			bufWe(0)		<= '0';
			bufDin			<= (others => '0');
			bufDout			<= (others => '1');
			DAC_Data		<= regDout;
			Vth_Data		<= (others => '0');
            ADC_BIAS_Data   <= (others => '0');
        elsif Vth_ctrl_Buf='1' then
            bufAddr         <= Vth_Ch_Buf;
            bufWe(0)        <= '0';
            bufDin          <= (others => '0');
            bufDout         <= (others => '1');     
			DAC_Data		<= (others => '0');       
            Vth_Data        <= regDout;
            ADC_BIAS_Data   <= (others => '0');
        elsif ADC_ctrl_Buf='1' then
            bufAddr         <= ADC_BIAS_Ch_Buf;
            bufWe(0)        <= '0';
            bufDin          <= (others => '0');
            bufDout         <= (others => '1');
            DAC_Data        <= (others => '0');
            Vth_Data        <= (others => '0');
            ADC_BIAS_Data   <= regDout;
        else
            bufAddr         <= (others => '0');
            bufWe(0)        <= '0';
            bufDin          <= (others => '0');
            bufDout         <= (others => '1');
			DAC_Data		<= (others => '0');
            Vth_Data        <= (others => '0');
            ADC_BIAS_Data   <= (others => '0');
        end if;
    end if;
end process;

process (clock, reset)
begin
    if reset='1' then
        bufAck              <= '0';
    elsif clock'event and clock='1' then
        if regState="010" then
            bufAck          <= '1';
        else
            bufAck          <= '0';
        end if;
    end if;
end process;

process (clock)
begin
    if clock'event and clock='1' then
        if irAddr(31 downto 8)=x"000000" then
            valid_flag      <= '1';
        else
            valid_flag      <= '0';
        end if;
    end if;
end process;

process (clock, reset)
begin
    if reset='1' then
            ctrl_flag           <= '0';
            vth_flag            <= '0';
            DAC_flag            <= '0';
            ADC_BIAS_flag       <= '0';
	elsif clock'event and clock='1' then
		if irAddr=x"000000f0" and bufWe="1" then
            ctrl_flag           <= '1';
			vth_flag			<= bufDin(0) and (not bufDin(1)) and (not bufDin(2));
            DAC_flag            <= bufDin(1) and (not bufDin(0)) and (not bufDin(2));
            ADC_BIAS_flag       <= bufDin(2) and (not bufDin(0)) and (not bufDin(1));
		else
            ctrl_flag           <= '0';
			vth_flag			<= '0';
            DAC_flag            <= '0';
			ADC_BIAS_flag       <= '0';
		end if;
	end if;
end process;

process (clock, reset)
begin
    if reset='1' then
            ctrl_flag2          <= '0';
            AP_ON_flag          <= '0';
            LatchUp_DetectOn    <= '0';
--            AP_OFF_flag         <= '0';
	elsif clock'event and clock='1' then
		if irAddr=x"000000f1" and bufWe="1" then
			ctrl_flag2          <= '1';
            AP_ON_flag          <= bufDin(0);
            LatchUp_DetectOn    <= bufDin(1);
--            AP_OFF_flag         <= bufDin(4);
		else
			ctrl_flag2          <= '0';
            AP_ON_flag          <= AP_ON_flag;
            LatchUp_DetectOn    <= LatchUp_DetectOn;
--            AP_OFF_flag         <= '0';
		end if;
	end if;
end process;

--process (clock, reset)
--begin
--    if reset='1' then
--        chkAddr         <= (others => '0');
--    elsif clock'event and clock='1' then
--        if irWe='1' then
--            chkAddr     <= irAddr;
--        else
--            chkAddr     <= chkAddr;
--        end if;
--    end if;
--end process;

--process (clock, reset)
--begin
--    if reset='1' then
--            ctrl_flag2           <= '0';
--            LatchUp_DetectOn          <= '0';
--            LatchUp_DetectOff         <= '0';
--	elsif clock'event and clock='1' then
--		if irAddr=x"000000f1" and bufWe="1" then
--			ctrl_flag2			<= '1';
--            LatchUp_DetectOn          <= bufDin(0);
--            LatchUp_DetectOff         <= bufDin(1);
--		else
--			ctrl_flag2			<= '0';
--            LatchUp_DetectOn          <= '0';
--            LatchUp_DetectOff         <= '0';
--		end if;
--	end if;
--end process;

--process (clock, reset)
--begin
--    if reset='1' then
--    elsif clock'event and clock='1' then
--        if chkAddr=x"000000f0" and bufWe="1" then
--        elsif DAC_ctrl='1' then
--        end if;
--    end if;
--end process;

--process (clock, reset)
--begin
--    if reset='1' then
--	elsif clock'event and clock='1' then
--		if chkAddr=x"000000f0" and bufWe="1" then
--		elsif ADC_BIAS_ctrl='1' then
--		end if;
--	end if;
--end process;

--process (clock, reset)
--begin
--    if reset='1' then
--        AP_ON           <= '0';
--    elsif clock'event and clock='1' then
--        if AP_ON_flag='1' and AP_OFF_flag='0' then
--            AP_ON       <= '1';
--        elsif AP_ON_flag='0' and AP_OFF_flag='1' then
--            AP_ON       <= '0';
--        end if;
--    end if;
--end process;


--process (clock, reset)
--begin
--    if reset='1' then
--        LatchUp_Detect           <= '0';
--    elsif clock'event and clock='1' then
--        if LatchUp_DetectOn='1' and LatchUp_DetectOff='0' then
--            LatchUp_Detect       <= '1';
--        elsif LatchUp_DetectOn='0' and LatchUp_DetectOff='1' then
--            LatchUp_Detect       <= '0';
--        end if;
--    end if;
--end process;

process (regState, rbcp_act, DAC_flag, vth_flag, ADC_BIAS_flag, irWe, irRe, irAddr, DAC_ctrl_Buf, Vth_ctrl_Buf, ADC_ctrl_Buf)
begin
    case (regState) is
    when    "000"   =>
        if rbcp_act='1' then
            nextState       <= "001";
        else
            nextState       <= "000";
        end if;
    when    "001"   =>
        if irWe='1' or irRe='1' then
            nextState       <= "011";
        else
            nextState       <= "001";
        end if;
    when    "011"   =>
        if irWe='0' and irRe='0' then
            nextState       <= "010";
        else
            nextState       <= "011";
        end if;
    when    "010"   =>
        nextState           <= "110";
    when    "110"   =>
        if DAC_ctrl_Buf='1' or Vth_ctrl_Buf='1' or ADC_ctrl_Buf='1' then
            nextState       <= "100";
        elsif DAC_flag='0' and vth_flag='0' and ADC_BIAS_flag='0' then
            nextState       <= "000";
        else
            nextState       <= "110";
        end if;
    when    "100"   =>
        if DAC_ctrl_Buf='0' and Vth_ctrl_Buf='0' and ADC_ctrl_Buf='0' then
            nextState       <= "000";
        else
            nextState       <= "100";
        end if;
    when    others  =>
        nextState           <= "000";
    end case;
end process;

RBCPmem:   blk_mem_gen_0
port map (  clka            => clock,
			rsta			=> reset,
            wea             => regWe,
            addra           => regAddr,
            dina            => regDin,
            douta           => regDout,
			rsta_busy		=> open  );

end Behavioral;
