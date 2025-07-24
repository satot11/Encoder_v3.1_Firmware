-- vhdl-linter-disable not-declared type-resolved component
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/04/17 13:50:25
-- Design Name: 
-- Module Name: LURecover - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LURecover is
    generic (   lu_time     : in    std_logic_vector (15 downto 0);
                off_time    : in    std_logic_vector (31 downto 0);
                on_time     : in    std_logic_vector (31 downto 0)  );     
    Port    (   clk         : in    std_logic;
                rst         : in    std_logic;
                hit_flag    : in    std_logic;
                enable      : in    std_logic;
                dac_run     : in    std_logic;
                ap_on       : out   std_logic;
                dac_ctrl    : out   std_logic   );
end LURecover;

architecture Behavioral of LURecover is
    signal      hit_check       : std_logic;
    signal      lu_judge        : std_logic;
    signal      ap_ctrl         : std_logic;
    signal      dac_flag        : std_logic;
    signal      reg_dac         : std_logic;
    signal      lu_time_cnt     : std_logic_vector (15 downto 0);
    signal      ap_off_wait     : std_logic_vector (31 downto 0);
    signal      ap_on_wait      : std_logic_vector (31 downto 0);
begin

process(clk, rst)
begin
    if rst='1' then
        hit_check           <= '0';
        ap_on               <= '1';
        reg_dac             <= '0';
        dac_ctrl            <= '0';
    elsif clk'event and clk='1' then
        hit_check           <= hit_flag and enable;
        ap_on               <= ap_ctrl;
        reg_dac             <= dac_run;
        dac_ctrl            <= dac_flag;
    end if;
end process;

process(clk, rst)
begin
    if rst='1' then
        lu_judge            <= '0';
    elsif clk'event and clk='1' then
        if dac_run='0' and reg_dac='1' then
            lu_judge        <= '0';
        elsif lu_time_cnt=x"0000" then
            lu_judge        <= '1';
        end if;
    end if;
end process;

process(clk, rst)
begin
    if rst='1' then
        ap_ctrl             <= '1';
    elsif clk'event and clk='1' then
        if lu_judge='1' then
            if ap_off_wait=x"00000000" then
                ap_ctrl     <= '1';
            else
                ap_ctrl     <= '0';
            end if;
        else
            ap_ctrl         <= '1';
        end if;
    end if;
end process;

process(clk, rst)
begin
    if rst='1' then
        dac_flag            <= '0';
    elsif clk'event and clk='1' then
        if ap_on_wait=x"00000000" and dac_run='0' then
            dac_flag        <= '1';
        else
            dac_flag        <= '0';
        end if;
    end if;
end process;

process(clk, rst)
begin
    if rst='1' then
        lu_time_cnt         <= (others => '1');
    elsif clk'event and clk='1' then
        if hit_check='1' then
            if lu_time_cnt=x"0000" then
                lu_time_cnt <= x"0000";
            else
                lu_time_cnt <= lu_time_cnt - 1;
            end if;
        else
            lu_time_cnt     <= lu_time;
        end if;
    end if;
end process;

process (clk, rst)
begin
    if rst='1' then
        ap_off_wait         <= (others => '1');
    elsif clk'event and clk='1' then
        if lu_judge='1' then
            if ap_off_wait=x"00000000" then
                ap_off_wait <= x"00000000";
            else
                ap_off_wait <= ap_off_wait - 1;
            end if;
        else
            ap_off_wait     <= off_time;
        end if;
    end if;
end process;

process (clk, rst)
begin
    if rst='1' then
        ap_on_wait          <= (others => '1');
    elsif clk'event and clk='1' then
        if lu_judge='1' and ap_ctrl='1' then
            if ap_on_wait=x"00000000" then
                ap_on_wait  <= x"00000000";
            else
                ap_on_wait  <= ap_on_wait - 1;
            end if;
        else
            ap_on_wait      <= on_time;
        end if;
    end if;
end process;

end Behavioral;
