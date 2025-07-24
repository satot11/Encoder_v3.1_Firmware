-- vhdl-linter-disable not-declared type-resolved component
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/09/26 11:17:07
-- Design Name: 
-- Module Name: main - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity main is
    Port (
        -- Oscillator 50MHz
        OSC_IN              : in    std_logic;

        -- ASIC Discri. out
        XDP                 : in    std_logic_vector (127 downto 0);
        
        -- ADC
		ADC_A				: in	std_logic_vector (9 downto 0);	--	ADC input
		ADC_B				: in	std_logic_vector (9 downto 0);	--	ADC input
		ADC_C				: in	std_logic_vector (9 downto 0);	--	ADC input
		ADC_D				: in	std_logic_vector (9 downto 0);	--	ADC input
		ADC_SET				: out	std_logic_vector (3 downto 0);	-- ADC control S11,S12,S21,S22
		ADC_CLK				: out	std_logic_vector (3 downto 0);	-- ADC clock

        -- ASIC Power control
        ASIC_POWER_OUT      : out   std_logic;

		-- chip DAC control
		CHIP_WR				: out	std_logic;
		CHIP_CK				: out	std_logic;
		CHIP_RB				: out	std_logic;
		CHIP_SD				: out	std_logic;

		--  Vth DAC control
		SYNC				: out	std_logic;
		SCLK				: out	std_logic;
		SDIN				: out	std_logic;

        --  ADC_BIAS DAC control
        ADC_SYNC            : out   std_logic;
        ADC_SCLK            : out   std_logic;
        ADC_SDIN            : out   std_logic;
		
		--      SiTCP
        EEPROM_SK_OUT       : out   std_logic;
        EEPROM_CS_OUT       : out   std_logic;
        EEPROM_DI_OUT       : out   std_logic;
        EEPROM_DO_IN        : inout std_logic;
        ETH_nRST_OUT        : out   std_logic;
        ETH_GTXCLK_OUT      : out   std_logic;
        ETH_TX_CLK_IN       : in    std_logic;
        ETH_TX_EN_OUT       : out   std_logic;
        ETH_TX_ER_OUT       : out   std_logic;
        ETH_TXD_OUT         : out   std_logic_vector ( 7 downto 0);
        ETH_RX_CLK_IN       : in    std_logic;
        ETH_RX_DV_IN        : in    std_logic;
        ETH_RX_ER_IN        : in    std_logic;
        ETH_RXD_IN          : in    std_logic_vector ( 7 downto 0);
        ETH_RX_COL_IN       : in    std_logic;
        ETH_RX_CRS_IN       : in    std_logic;
        ETH_MDC_OUT         : out   std_logic;
        ETH_MDIO_IO         : inout std_logic;
        ETH_HPD_OUT         : out   std_logic;
        ETH_IRQ_IN          : in    std_logic;

        -- DIP Switch
        DIP_SW_IN           : inout std_logic_vector ( 7 downto 0);

        -- Trigger In/Out
        -- TRG_IN              : in    std_logic_vector ( 7 downto 0);
        TRG_IN              : in    std_logic_vector ( 4 downto 0);
        TRG_OUT             : out   std_logic_vector ( 7 downto 0);

        -- LED
        LED_OUT             : out   std_logic_vector ( 3 downto 0)
    );
end main;

architecture Behavioral of main is
    component   LAN8810_INIT
    generic (
        freqency	    : in    std_logic_vector ( 7 downto 0)
    );
    port (
        I_nRESET        : in    std_logic;
        CLOCK           : in    std_logic;
        PHY_ADDR        : in    std_logic_vector ( 4 downto 0);
        SiTCP_PHY_nRST  : in    std_logic;
        SiTCP_MDC       : in    std_logic;
        SiTCP_MDIO_OUT  : in    std_logic;
        SiTCP_MDIO_OE   : in    std_logic;
        MDC             : out   std_logic;
        O_MDIO          : out   std_logic;
        T_MDIO          : out   std_logic;
        PHY_nRESET      : out   std_logic;
        O_RESET         : out   std_logic
    );
    end component;
    component   WRAP_SiTCP_GMII_XC7S_32K
    generic (
        TIM_PERIOD      : in    std_logic_vector ( 7 downto 0)
    );
    port (
        CLK             : in    std_logic;
        RST             : in    std_logic;
        FORCE_DEFAULTn  : in    std_logic;
        EXT_IP_ADDR     : in    std_logic_vector (31 downto 0);
        EXT_TCP_PORT    : in    std_logic_vector (15 downto 0);
        EXT_RBCP_PORT   : in    std_logic_vector (15 downto 0);
        PHY_ADDR        : in    std_logic_vector ( 4 downto 0);
        EEPROM_CS       : out   std_logic;
        EEPROM_SK       : out   std_logic;
        EEPROM_DI       : out   std_logic;
        EEPROM_DO       : in    std_logic;
        GMII_RSTn       : out   std_logic;
        GMII_1000M      : in    std_logic;
        GMII_TX_CLK     : in    std_logic;
        GMII_TX_EN      : out   std_logic;
        GMII_TXD        : out   std_logic_vector ( 7 downto 0);
        GMII_TX_ER      : out   std_logic;
        GMII_RX_CLK     : in    std_logic;
        GMII_RX_DV      : in    std_logic;
        GMII_RXD        : in    std_logic_vector ( 7 downto 0);
        GMII_RX_ER      : in    std_logic;
        GMII_CRS        : in    std_logic;
        GMII_COL        : in    std_logic;
        GMII_MDC        : out   std_logic;
        GMII_MDIO_IN    : in    std_logic;
        GMII_MDIO_OUT   : out   std_logic;
        GMII_MDIO_OE    : out   std_logic;
        SiTCP_RST       : out   std_logic;
        TCP_OPEN_REQ    : in    std_logic;
        TCP_OPEN_ACK    : out   std_logic;
        TCP_ERROR       : out   std_logic;
        TCP_CLOSE_REQ   : out   std_logic;
        TCP_CLOSE_ACK   : in    std_logic;
        TCP_RX_WC       : in    std_logic_vector (15 downto 0);
        TCP_RX_WR       : out   std_logic;
        TCP_RX_DATA     : out   std_logic_vector ( 7 downto 0);
        TCP_TX_FULL	    : out   std_logic;
        TCP_TX_WR       : in    std_logic;
        TCP_TX_DATA     : in    std_logic_vector ( 7 downto 0);
        RBCP_ACT        : out   std_logic;
        RBCP_ADDR       : out   std_logic_vector (31 downto 0);
        RBCP_WD         : out   std_logic_vector ( 7 downto 0);
        RBCP_WE         : out   std_logic;
        RBCP_RE         : out   std_logic;
        RBCP_ACK        : in    std_logic;
        RBCP_RD         : in    std_logic_vector ( 7 downto 0)
    );
    end component;
    component   RBCP_REG
	port (
        clock               : in    std_logic;
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
    end component;
	component ASIC_DAC_set
	port	(
		CLK					: in	std_logic;
		RST					: in	std_logic;
		ACT					: in	std_logic;
		Run					: out	std_logic;
		Ch					: out	std_logic_vector ( 7 downto 0);
		Data				: in	std_logic_vector ( 7 downto 0);
		
		-- DAC I/O
		DAC_WE				: out	std_logic;
		DAC_CLK				: out	std_logic;
		DAC_RST				: out	std_logic;
		DAC_SD				: out	std_logic
	);
	end component;
	
	component   DACset
    generic (
        Addr                : in    std_logic_vector (7 downto 0)
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
	end component;

    component   Encoder
    port (
		clk					: in	std_logic;
		rst					: in	std_logic;
		CathodeSig			: in	std_logic;
		XDP_IN				: in	std_logic_vector (15 downto 0);
		run					: in	std_logic;
		hit_flag				: out	std_logic;
		hit_2					: out	std_logic;
		hit_3					: out	std_logic;
		addr					: in	unsigned (10 downto 0);
		dout					: out	std_logic_vector (15 downto 0)
    );
    end component;
    component   FADC_reg
    port (
		CLK					: in	std_logic;
		rst					: in	std_logic;
		run					: in	std_logic;
		Addr					: in	unsigned ( 9 downto 0);
		Dout_A				: out	std_logic_vector ( 9 downto 0);
		Dout_B				: out	std_logic_vector ( 9 downto 0);
		Dout_C				: out	std_logic_vector ( 9 downto 0);
		Dout_D				: out	std_logic_vector ( 9 downto 0);
		FADC_CLK				: out	std_logic;
		FADC_Set				: out	std_logic_vector ( 1 downto 0);
		FADC_Data_A			: in	std_logic_vector ( 9 downto 0);
		FADC_Data_B			: in	std_logic_vector ( 9 downto 0);
		FADC_Data_C			: in	std_logic_vector ( 9 downto 0);
		FADC_Data_D			: in	std_logic_vector ( 9 downto 0)
    );
    end component;
	component Formatter
	generic (
		ClkDepth				: unsigned ( 10 downto 0)
	);
	port (
		CLK					: in	std_logic;
		RST					: in	std_logic;
		Trigger				: in	std_logic;
		CntReset				: in	std_logic;
		Run					: out	std_logic;
		D_Exist				: in	std_logic;
		EncAddr				: out	unsigned ( 10 downto 0);
		FadcAddr				: out	unsigned (  9 downto 0);
		HitData				: in	std_logic_vector (127 downto 0);
		FADC_A				: in	std_logic_vector (  9 downto 0);
		FADC_B				: in	std_logic_vector (  9 downto 0);
		FADC_C				: in	std_logic_vector (  9 downto 0);
		FADC_D				: in	std_logic_vector (  9 downto 0);
		valid					: in	std_logic;
		GSOcounter			: in	std_logic_vector ( 31 downto 0);
		WriteEna				: out	std_logic;
		Dout					: out	std_logic_vector ( 31 downto 0)
	);
	end component;
    component   fifo_buffer
    port (
        rst             : IN    STD_LOGIC;
        wr_clk          : IN    STD_LOGIC;
        rd_clk          : IN    STD_LOGIC;
        din             : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
        wr_en           : IN    STD_LOGIC;
        rd_en           : IN    STD_LOGIC;
        dout            : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
        full            : OUT   STD_LOGIC;
        empty           : OUT   STD_LOGIC;
        valid           : OUT   STD_LOGIC;
        prog_full       : OUT   STD_LOGIC
    );
    end component;
    component   fifo_32
    port (
        clk             : IN    STD_LOGIC;
        srst            : IN    STD_LOGIC;
        din             : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
        wr_en           : IN    STD_LOGIC;
        rd_en           : IN    STD_LOGIC;
        dout            : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
        full            : OUT   STD_LOGIC;
        empty           : OUT   STD_LOGIC;
        valid           : OUT   STD_LOGIC;
        prog_full       : OUT   STD_LOGIC
    );
    end component;
    component   LURecover
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
    end component;
    

    constant    DriftWait       : unsigned (10 downto 0)    := "100" & x"00";   -- 1024clk * 100MHz

    signal  Osc50MHz            : std_logic;
    signal  locked              : std_logic;
    signal  pll_clkfb           : std_logic;
    signal  clk_100M            : std_logic;
    signal  clk_125M            : std_logic;
    signal  clk_200M            : std_logic;
    signal  clk_125M_buf        : std_logic;
    signal  clk_200M_buf        : std_logic;
    signal  SystemRst           : std_logic;
    
    signal  GMII_RSTn          : std_logic;
    signal  st_mdc              : std_logic;
    signal  st_mdio_out         : std_logic;
    signal  st_mdio_oe          : std_logic;
    signal  st_mdio_in          : std_logic;
    signal  st_sys_rst          : std_logic;
    signal  gmii_rx_clk         : std_logic;
    signal  eth_rx_clk_buf      : std_logic;
    signal  rxd_buf             : std_logic_vector ( 7 downto 0);
    signal  gmii_rxd            : std_logic_vector ( 7 downto 0);
    signal  rx_er_buf           : std_logic;
    signal  gmii_rx_er          : std_logic;
    signal  rx_dv_buf           : std_logic;
    signal  gmii_rx_dv          : std_logic;
    signal  gmii_col            : std_logic;
    signal  gmii_crs            : std_logic;
    signal  tx_clk_buf          : std_logic;
    signal  gmii_tx_en          : std_logic;
    signal  gmii_tx_er          : std_logic;
    signal  gmii_tx_clk         : std_logic;
    signal  eth_gtxclk_int      : std_logic;
    signal  gmii_txd            : std_logic_vector ( 7 downto 0);
    signal  st_cnt_clk          : std_logic_vector ( 8 downto 0);
--    signal  st_cnt_lod          : std_logic;
    signal  st_cnt_rst          : std_logic;
    signal  gmii_1000M          : std_logic;
    signal  rx_cnt              : std_logic_vector ( 6 downto 0);
    signal  cnt_clk             : std_logic_vector ( 8 downto 0);
    signal  cnt_lod             : std_logic;
    signal  cnt_rst             : std_logic;
    signal  phy_rst             : std_logic;
    signal  phy_mdc             : std_logic;
    signal  phy_t_mdio          : std_logic;
    signal  phy_O_mdio          : std_logic;
    signal  phy_irq             : std_logic;
    signal  Eep_CsBuf           : std_logic;
    signal  Eep_SkBuf           : std_logic;
    signal  Eep_DiBuf           : std_logic;
    signal  Eep_DoBuf           : std_logic;

    signal  rbcp_act            : std_logic;
    signal  rbcp_we             : std_logic;
    signal  rbcp_re             : std_logic;
    signal  rbcp_ack            : std_logic;
    signal  rbcp_wd             : std_logic_vector ( 7 downto 0);
    signal  rbcp_rd             : std_logic_vector ( 7 downto 0);
    signal  rbcp_addr           : std_logic_vector (31 downto 0);

    signal  TCP_OpenACK         : std_logic;
    signal  tcp_rx_wr           : std_logic;
    signal  tcp_rx_data         : std_logic_vector ( 7 downto 0);
    signal  tcp_rx_wc           : std_logic_vector (15 downto 0);
    signal  n_tcp_tx_full       : std_logic;
    
    signal  TrgOutBuf           : std_logic_vector ( 7 downto 0);
    signal  DipSwBuf            : std_logic_vector ( 7 downto 0);
    signal  dip_sw_data         : std_logic_vector ( 7 downto 0);

    signal  IP_SetBit           : std_logic_vector (31 downto 0);

    constant    phy_hpd         : std_logic := '0';
    constant    phy_addr        : std_logic_vector ( 4 downto 0)    := "00000";
    
    attribute dont_touch : string; 
    attribute dont_touch of phy_irq : signal is "true";  

	signal	DAC_Set		: std_logic;
	signal	DAC_Run		: std_logic;
	signal	DAC_WE		: std_logic;
	signal	DAC_Clk		: std_logic;
	signal	DAC_Rst		: std_logic;
	signal	DAC_SD		: std_logic;
	signal	DAC_WE_buf  : std_logic;
	signal	DAC_Clk_buf	: std_logic;
	signal	DAC_Rst_buf	: std_logic;
	signal	DAC_SD_buf	: std_logic;
	signal	DAC_Ch		: std_logic_vector ( 7 downto 0);
	signal	DAC_Data	: std_logic_vector ( 7 downto 0);
	
	signal	Vth_Set		    : std_logic;
	signal	Vth_Run		    : std_logic;
	signal	Vth_Sync	    : std_logic;
	signal	Vth_Clk		    : std_logic;
	signal	Vth_SD		    : std_logic;
	signal	Vth_Ch		    : std_logic_vector ( 7 downto 0);
	signal	Vth_Data	    : std_logic_vector ( 7 downto 0);
	signal	Vth_SyncBuf	    : std_logic;
	signal	Vth_ClkBuf	    : std_logic;
	signal	Vth_SDBuf	    : std_logic;

    signal  ADC_BIAS_Set    : std_logic;
    signal  ADC_BIAS_Run    : std_logic;
    signal  ADC_BIAS_Ch     : std_logic_vector (7 downto 0);
    signal  ADC_BIAS_Data   : std_logic_vector (7 downto 0);
    signal  ADC_BIAS_Sync   : std_logic;
    signal  ADC_BIAS_Clk    : std_logic;
    signal  ADC_BIAS_SD     : std_logic;
    signal  ADC_Sync_Buf    : std_logic;
    signal  ADC_Clk_Buf     : std_logic;
    signal  ADC_SD_Buf      : std_logic;

    signal  AP_ON           : std_logic;

    signal  hit_flag        : std_logic;
    signal  D_Exist         : std_logic;
    signal  Hit_Exist       : std_logic;
    signal  SysRunning      : std_logic;
    signal  AC_flag         : std_logic;

    signal  hit_xor         : std_logic_vector (7 downto 0);
    signal  hit_two         : std_logic_vector (7 downto 0);
    signal  hit_16          : std_logic_vector (7 downto 0);
    signal  hit_area        : std_logic_vector (3 downto 0);
    signal  hit_tri         : std_logic_vector (7 downto 0);
    signal  hit_3_area      : std_logic;

    signal  DExstCnt        : unsigned (10 downto 0);
    signal  HExstCnt        : unsigned (10 downto 0);

    signal  DAQ_Run         : std_logic;
    signal  DAQ_Run_not     : std_logic;
    signal  regTrg          : std_logic_vector (4 downto 0);
    signal  regCntRst       : std_logic_vector (4 downto 0);
    signal  ExDinReg        : std_logic_vector (7 downto 0);
    signal  ExDoutReg       : std_logic_vector (7 downto 0);
    signal  Trigger         : std_logic;
    signal  CntReset        : std_logic;
    signal  TrgCounter      : std_logic_vector (31 downto 0);
    signal  RegGSOtrg       : std_logic;
    signal  DlyGSOtrg       : std_logic;

    signal  AcqRunFlag      : std_logic;
    signal  ReadEncAddr     : unsigned (10 downto 0);
    signal  EncData         : std_logic_vector (127 downto 0);

    signal  ReadFADCad      : unsigned (9 downto 0);
    signal  Rec_FADC_A      : std_logic_vector (9 downto 0);
    signal  Rec_FADC_B      : std_logic_vector (9 downto 0);
    signal  Rec_FADC_C      : std_logic_vector (9 downto 0);
    signal  Rec_FADC_D      : std_logic_vector (9 downto 0);
    signal  FADC_CLK        : std_logic;
    signal  FADC_Set        : std_logic_vector (1 downto 0);
    signal  FADC_A_Data     : std_logic_vector (9 downto 0);
    signal  FADC_B_Data     : std_logic_vector (9 downto 0);
    signal  FADC_C_Data     : std_logic_vector (9 downto 0);
    signal  FADC_D_Data     : std_logic_vector (9 downto 0);

    signal  enc_valid       : std_logic;
    signal  tmp_we          : std_logic;
    signal  tmp_cnt         : std_logic_vector (31 downto 0);
    signal  tmp_full        : std_logic;

    signal  buf_rst         : std_logic;
    signal  buf_re          : std_logic;
    signal  buf_dout        : std_logic_vector (31 downto 0);
    signal  buf_ae          : std_logic;
    signal  buf_valid       : std_logic;
    signal  buf_full        : std_logic;
    signal  buf_we          : std_logic;
    signal  buf_din         : std_logic_vector (31 downto 0);

    signal  TCP_FIFO_Re     : std_logic;
    signal  TCP_TxData      : std_logic_vector (7 downto 0);
    signal  TCP_FIFO_Em     : std_logic;
    signal  TCP_TxWrEna     : std_logic;
    signal  TCP_TxFull      : std_logic;
    signal  TCP_CloseA      : std_logic;
    signal  TCP_CloseR      : std_logic;

    signal  rx_rst200ns     : std_logic;
    signal  rx_rst_2nd      : std_logic;
    signal  rst_cnt         : unsigned (8 downto 0);
    signal  rst_cnt2        : unsigned (6 downto 0);

    signal  SiTCP_Reset     : std_logic;
    signal  sys_reset       : std_logic;
    signal  st_phy_rst      : std_logic;
    signal  tcp_open_req    : std_logic;
    signal  tcp_close_req   : std_logic;

    signal  Internal_50MHz  : std_logic;
    signal  External_50MHz  : std_logic;

    signal  LatchUp_Recover     : std_logic := '0';
    signal  LatchUp_Detect      : std_logic;
    signal  LatchUp_Trg         : std_logic_vector (7 downto 0);
    signal  LatchUp_TrgAll      : std_logic;

    signal  AP_ON_LatchUp       : std_logic;
    signal  AP_ON_RBCP          : std_logic;
    signal  LatchUp_AP_RstCnt   : std_logic_vector (27 downto 0) := (others => '0');
    signal  LatchUp_AP_RstEnd   : std_logic;

    signal  LatchUp_AP_WaitCnt  : std_logic_vector (27 downto 0) := (others => '0');
    signal  LatchUp_ASICOn      : std_logic;

    signal  DAC_Set_LatchUp     : std_logic;
    signal  DAC_Set_RBCP        : std_logic;
    signal  LatchUp_DACRunWait      : std_logic;

begin

SystemRst       <= not locked;
SysRunning		<= not (SystemRst or SiTCP_Reset);
AC_flag			<= not dip_sw_data(5);

hit_xor(0)		<= hit_two(0) xor hit_16(0);
hit_xor(1)		<= hit_two(1) xor hit_16(1);
hit_xor(2)		<= hit_two(2) xor hit_16(2);
hit_xor(3)		<= hit_two(3) xor hit_16(3);
hit_xor(4)		<= hit_two(4) xor hit_16(4);
hit_xor(5)		<= hit_two(5) xor hit_16(5);
hit_xor(6)		<= hit_two(6) xor hit_16(6);
hit_xor(7)		<= hit_two(7) xor hit_16(7);

hit_area(0)		<= hit_16(0) or hit_16(1);
hit_area(1)		<= hit_16(2) or hit_16(3);
hit_area(2)		<= hit_16(4) or hit_16(5);
hit_area(3)		<= hit_16(6) or hit_16(7);
hit_3_area		<= '1'	when	(hit_area=x"7" or hit_area=x"b" or hit_area=x"d" or hit_area=x"e" or hit_area=x"f")	else '0';

ExDoutReg(0)	<= hit_flag;
ExDoutReg(1)	<= D_Exist;
ExDoutReg(2)	<= not AcqRunFlag;
ExDoutReg(3)	<= Trigger;
ExDoutReg(4)	<= tmp_we;
ExDoutReg(5)	<= buf_valid;
--ExDoutReg(7)    <= '0';
ExDoutReg(7)    <= ExDinReg(3);

process(clk_100M)
begin
    if clk_100M'event and clk_100M='1' then
        ExDoutReg(6)	<= TCP_FIFO_Re;
    end if;
end process;

process (clk_100M)
begin
    if clk_100M'event and clk_100M='1' then
        if DExstCnt > 0 then
            D_Exist     <= '1';
        else
            D_Exist     <= '0';
        end if;
    end if;
end process;

process (clk_100M)
begin
    if clk_100M'event and clk_100M='1' then
        if hit_16 = x"00" then
            hit_flag    <= '0';
        else
            hit_flag    <= '1';
        end if;
    end if;
end process;

process (clk_100M)
begin
    if clk_100M'event and clk_100M='1' then
        if HExstCnt > 0 then
            Hit_Exist   <= '1';
        else
            Hit_Exist   <= '0';
        end if;
    end if;
end process;

process (clk_100M, SystemRst)
begin
	if SystemRst='1' then
		DExstCnt		<= (others => '0');
	elsif clk_100M'event and clk_100M='1' then
		if hit_tri /= x"00" or (hit_two /= x"00" and hit_xor /= x"00") or hit_3_area='1' then
			DExstCnt	<= DriftWait;
		elsif DExstCnt > 0 then
			DExstCnt	<= DExstCnt - 1;
		else
			DExstCnt	<= (others => '0');
		end if;
	end if;
end process;

process (clk_100M, SystemRst)
begin
	if SystemRst='1' then
		HExstCnt		<= (others => '0');
	elsif clk_100M'event and clk_100M='1' then
		if hit_16 /= x"00" then
			HExstCnt	<= DriftWait;
		elsif HExstCnt > 0 then
			HExstCnt	<= HExstCnt - 1;
		else
			HExstCnt	<= (others => '0');
		end if;
	end if;
end process;


-----  External I/O  -----
process (clk_100M, SystemRst)
begin
	if SystemRst='1' then
		DAQ_Run		<= '0';
		regTrg		<= (others => '0');
		regCntRst	<= (others => '0');
	elsif clk_100M'event and clk_100M='1' then
		DAQ_Run		<= ExDinReg(1);
		regTrg		<= regTrg ( 3 downto 0) & ExDinReg(2);
		regCntRst	<= regCntRst ( 3 downto 0) & ExDinReg(4);
	end if;
end process;

process (clk_100M, SystemRst)
begin
	if SystemRst='1' then
		Trigger		<= '0';
	elsif clk_100M'event and clk_100M='1' then
		if regTrg="11111" then
			Trigger	<= '1';
		elsif regTrg="00000" then
			Trigger	<= '0';
		end if;
	end if;
end process;

process (clk_100M, SystemRst)
begin
	if SystemRst='1' then
		CntReset		<= '0';
	elsif clk_100M'event and clk_100M='1' then
		if regCntRst="11111" then
			CntReset	<= '1';
		else
			CntReset	<= '0';
		end if;
	end if;
end process;

process (clk_100M)
begin
    if clk_100M'event and clk_100M='1' then
        RegGSOtrg       <= ExDinReg(3);
        DlyGSOtrg       <= RegGSOtrg;
    end if;
end process;

process (SystemRst, CntReset, clk_100M)
begin
	if SystemRst='1' or CntReset='1' then
		TrgCounter	<= (others => '0');
	elsif clk_100M'event and clk_100M='1' then
        if RegGSOtrg='1' and DlyGSOtrg='0' then
    		TrgCounter	<= TrgCounter + 1;
        end if;
	end if;
end process;

dip_sw_data(0)  <= not DipSwBuf(0); 
dip_sw_data(1)  <= not DipSwBuf(1); 
dip_sw_data(2)  <= not DipSwBuf(2); 
dip_sw_data(3)  <= not DipSwBuf(3); 
dip_sw_data(4)  <= not DipSwBuf(4); 
dip_sw_data(5)  <= not DipSwBuf(5); 
dip_sw_data(6)  <= not DipSwBuf(6); 
dip_sw_data(7)  <= not DipSwBuf(7); 
DAQ_Run_not     <= not DAQ_Run;

LED_0_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 8,   SLEW    => "SLOW")  port map (  O   => LED_OUT(0),    I   => DAQ_Run_not    );
LED_1_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 8,   SLEW    => "SLOW")  port map (  O   => LED_OUT(1),    I   => SysRunning    );
LED_2_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 8,   SLEW    => "SLOW")  port map (  O   => LED_OUT(2),    I   => tmp_we    );
LED_3_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 8,   SLEW    => "SLOW")  port map (  O   => LED_OUT(3),    I   => hit_flag    );

TRG_0_IB:   IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => ExDinReg(0),   I   => TRG_IN(0)   );
ExClkBuf:   BUFG    port map    (   O   => External_50MHz,      I   => ExDinReg(0) );
TRG_1_IB:   IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => ExDinReg(1),   I   => TRG_IN(1)   );
TRG_2_IB:   IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => ExDinReg(2),   I   => TRG_IN(2)   );
TRG_3_IB:   IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => ExDinReg(3),   I   => TRG_IN(3)   );
TRG_4_IB:   IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => ExDinReg(4),   I   => TRG_IN(4)   );
-- TRG_5_IB:   IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => ExDinReg(5),   I   => TRG_IN(5)   );
-- TRG_6_IB:   IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => ExDinReg(6),   I   => TRG_IN(6)   );
-- TRG_7_IB:   IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => ExDinReg(7),   I   => TRG_IN(7)   );

TRG_0_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST")  port map (  O   => TRG_OUT(0),    I   => ExDoutReg(0)    );
TRG_1_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST")  port map (  O   => TRG_OUT(1),    I   => ExDoutReg(1)    );
TRG_2_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST")  port map (  O   => TRG_OUT(2),    I   => ExDoutReg(2)    );
TRG_3_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST")  port map (  O   => TRG_OUT(3),    I   => ExDoutReg(3)    );
TRG_4_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST")  port map (  O   => TRG_OUT(4),    I   => ExDoutReg(4)    );
TRG_5_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST")  port map (  O   => TRG_OUT(5),    I   => ExDoutReg(5)    );
TRG_6_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST")  port map (  O   => TRG_OUT(6),    I   => ExDoutReg(6)    );
TRG_7_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST")  port map (  O   => TRG_OUT(7),    I   => ExDoutReg(7)    );


-----  Clock  -----
ClkMaker:   PLLE2_BASE
generic map (   CLKFBOUT_MULT       => 20,
                CLKIN1_PERIOD       => 20.000,
                CLKOUT0_DIVIDE      => 5,
                CLKOUT0_DUTY_CYCLE  => 0.500,
                CLKOUT1_DIVIDE      => 8,
                CLKOUT1_DUTY_CYCLE  => 0.500,
                CLKOUT2_DIVIDE      => 10,
                CLKOUT2_DUTY_CYCLE  => 0.500,
                DIVCLK_DIVIDE       => 1        )
port map    (   CLKFBOUT            => pll_clkfb,
                CLKOUT0             => clk_200M,
                CLKOUT1             => clk_125M,
                CLKOUT2             => clk_100M,
                CLKOUT3             => open,
                CLKOUT4             => open,
                CLKOUT5             => open,
                LOCKED              => locked,
                CLKFBIN             => pll_clkfb,
                CLKIN1              => Osc50MHz,
                PWRDWN              => '0',
                RST                 => '0'      );
sys_reset       <= (not locked);

OSC_BUF:    IBUF    
    generic map (   IOSTANDARD  => "LVCMOS33")
    port map    (   O   => Internal_50MHz,    I   => OSC_IN );

--Osc50MHz        <=  ExDinReg(0)     when    dip_sw_data(6)='1'     else    Internal_50MHz;
Osc_MUX:    BUFGMUX port map    (   O   => Osc50MHz,        I0  => Internal_50MHz,      I1  => External_50MHz,      S   => dip_sw_data(6)   );


------------- Latch Up Recover
--LatchUp_TrgAll  <= '0' when LatchUp_Trg=x"00" else '1';
AP_ON           <= AP_ON_RBCP and AP_ON_LatchUp;
DAC_Set         <= DAC_Set_RBCP or DAC_Set_LatchUp;

LU_Recover  : LURecover
generic map (   lu_time     => x"2710",        -- 100 us
                off_time    => x"10000000",    -- 2.68 s
                on_time     => x"10000000"  )  -- 2.68 s   
Port map    (   clk         => clk_100M,
                rst         => SystemRst,
                hit_flag    => hit_flag,
                enable      => LatchUp_Detect,
                dac_run     => DAC_Run,
                ap_on       => AP_ON_LatchUp,
                dac_ctrl    => DAC_Set_LatchUp  );

---- Analog Power Off
--process (clk_100M, SystemRst, LatchUp_Recover)
--begin
--    if SystemRst='1' or LatchUp_Recover='1' then
--        AP_ON_LatchUp           <= '1';
--        LatchUp_AP_RstCnt       <= (others => '0');
--        LatchUp_AP_RstEnd       <= '0';
--    elsif clk_100M'event and clk_100M='1' then
--        if LatchUp_TrgAll = '1' then
--            if LatchUp_AP_RstCnt/=x"fffffff" then
--                AP_ON_LatchUp       <= '0';
--                LatchUp_AP_RstCnt   <= LatchUp_AP_RstCnt + '1';
--                LatchUp_AP_RstEnd   <= '0';
--            else
--                AP_ON_LatchUp       <= '1';
--                LatchUp_AP_RstCnt   <= LatchUp_AP_RstCnt;
--                LatchUp_AP_RstEnd   <= '1';
--            end if;
--        else
--            AP_ON_LatchUp       <= '1';
--            LatchUp_AP_RstCnt      <= (others => '0');
--            LatchUp_AP_RstEnd      <= '0';
--        end if;
--    end if;
--end process;

---- Analog Power On & Waiting
--process (clk_100M, SystemRst, LatchUp_Recover)
--begin
--    if SystemRst='1' or LatchUp_Recover='1' then
--        LatchUp_AP_WaitCnt    <= (others => '0');
--        LatchUp_ASICOn        <= '0';
--    elsif clk_100M'event and clk_100M='1' then
--        if LatchUp_AP_RstEnd='1' then
--            if LatchUp_AP_WaitCnt/=x"fffffff" then
--                LatchUp_AP_WaitCnt  <= LatchUp_AP_WaitCnt + '1';
--                LatchUp_ASICOn      <= '0';
--            else
--                LatchUp_AP_WaitCnt  <= LatchUp_AP_WaitCnt;
--                LatchUp_ASICOn      <= '1';
--            end if;
--        else
--            LatchUp_AP_WaitCnt      <= (others => '0');
--            LatchUp_ASICOn          <= '0';
--        end if;
--    end if;
--end process;

---- ASIC DAC Set
--process (clk_100M, SystemRst, LatchUp_Recover)
--begin
--    if SystemRst='1' or LatchUp_Recover='1' then
--        DAC_Set_LatchUp             <= '0';
--        LatchUp_DACRunWait          <= '0';
--    elsif clk_100M'event and clk_100M='1' then
--        if LatchUp_ASICOn='1' then
--            if LatchUp_DACRunWait='0' and DAC_Run='0' then
--                DAC_Set_LatchUp     <= '1';
--                LatchUp_DACRunWait  <= '1';
--            elsif LatchUp_DACRunWait='1' and DAC_Run='1' then
--                DAC_Set_LatchUp     <= '0';
--                LatchUp_DACRunWait  <= '1';
--            end if;
--        else
--            DAC_Set_LatchUp         <= '0';
--            LatchUp_DACRunWait      <= '0';
--        end if;
--    end if;
--end process;

---- Latch-Up recover process finish
--process (clk_100M, SystemRst)
--begin
--    if SystemRst='1' then
--        LatchUp_Recover         <= '0';
--    elsif clk_100M'event and clk_100M='1' then
--        if LatchUp_DACRunWait='1' and DAC_Set_LatchUp='0' then
--            if DAC_Run='0' then
--                LatchUp_Recover     <= '1';
--            end if;
--        elsif LatchUp_Recover='1' then
--            if LatchUp_TrgAll='0' and LatchUp_AP_RstEnd='0' and LatchUp_ASICOn='0' then
--                LatchUp_Recover     <= '0';
--            end if;
--        end if;
--    end if;
--end process;


--------------------------


-----  Ring Buffers  -----
EncRBuf0	: Encoder
port map    (   clk					=> clk_100M,
            	rst					=> SystemRst,
                CathodeSig			=> AC_flag,
                XDP_IN				=> XDP (  15 downto   0),
                run					=> AcqRunFlag,
                hit_flag			=> hit_16 (0),
                hit_2				=> hit_two (0),
                hit_3				=> hit_tri (0),
                addr				=> ReadEncAddr,
                dout				=> EncData (  15 downto   0)    );
EncRBuf1	: Encoder
port map    (   clk					=> clk_100M,
                rst					=> SystemRst,
                CathodeSig			=> AC_flag,
                XDP_IN				=> XDP (  31 downto  16),
                run					=> AcqRunFlag,
                hit_flag			=> hit_16 (1),
                hit_2				=> hit_two (1),
                hit_3				=> hit_tri (1),
                addr				=> ReadEncAddr,
                dout				=> EncData (  31 downto  16)    );
EncRBuf2	: Encoder
port map    (   clk					=> clk_100M,
                rst					=> SystemRst,
                CathodeSig			=> AC_flag,
                XDP_IN				=> XDP (  47 downto  32),
                run					=> AcqRunFlag,
                hit_flag			=> hit_16 (2),
                hit_2				=> hit_two (2),
                hit_3				=> hit_tri (2),
                addr				=> ReadEncAddr,
                dout				=> EncData (  47 downto  32)    );
EncRBuf3	: Encoder
port map    (   clk					=> clk_100M,
                rst					=> SystemRst,
                CathodeSig			=> AC_flag,
                XDP_IN				=> XDP (  63 downto  48),
                run					=> AcqRunFlag,
                hit_flag			=> hit_16 (3),
                hit_2				=> hit_two (3),
                hit_3				=> hit_tri (3),
                addr				=> ReadEncAddr,
                dout				=> EncData (  63 downto  48)    );
EncRBuf4	: Encoder
port map    (   clk					=> clk_100M,
                rst					=> SystemRst,
                CathodeSig			=> AC_flag,
                XDP_IN				=> XDP (  79 downto  64),
                run					=> AcqRunFlag,
                hit_flag			=> hit_16 (4),
                hit_2				=> hit_two (4),
                hit_3				=> hit_tri (4),
                addr				=> ReadEncAddr,
                dout				=> EncData (  79 downto  64)    );
EncRBuf5	: Encoder
port map    (   clk					=> clk_100M,
                rst					=> SystemRst,
                CathodeSig			=> AC_flag,
                XDP_IN				=> XDP (  95 downto  80),
                run					=> AcqRunFlag,
                hit_flag			=> hit_16 (5),
                hit_2				=> hit_two (5),
                hit_3				=> hit_tri (5),
                addr				=> ReadEncAddr,
                dout				=> EncData (  95 downto  80)    );
EncRBuf6	: Encoder
port map    (   clk					=> clk_100M,
                rst					=> SystemRst,
                CathodeSig			=> AC_flag,
                XDP_IN				=> XDP ( 111 downto  96),
                run					=> AcqRunFlag,
                hit_flag			=> hit_16 (6),
                hit_2				=> hit_two (6),
                hit_3				=> hit_tri (6),
                addr				=> ReadEncAddr,
                dout				=> EncData ( 111 downto  96)    );
EncRBuf7	: Encoder
port map    (   clk					=> clk_100M,
                rst					=> SystemRst,
                CathodeSig			=> AC_flag,
                XDP_IN				=> XDP ( 127 downto 112),
                run					=> AcqRunFlag,
                hit_flag			=> hit_16 (7),
                hit_2				=> hit_two (7),
                hit_3				=> hit_tri (7),
                addr				=> ReadEncAddr,
                dout				=> EncData ( 127 downto 112)    );


-----  FADC Ring Buffer  -----
FADCenc	: FADC_reg
port map (  CLK					=> clk_100M,
            rst					=> SystemRst,
            run					=> AcqRunFlag,
            Addr				=> ReadFADCad,
            Dout_A				=> Rec_FADC_A,
            Dout_B				=> Rec_FADC_B,
            Dout_C				=> Rec_FADC_C,
            Dout_D				=> Rec_FADC_D,
            FADC_CLK			=> FADC_CLK,
            FADC_Set			=> FADC_Set,
            FADC_Data_A			=> FADC_A_Data,
            FADC_Data_B			=> FADC_B_Data,
            FADC_Data_C			=> FADC_C_Data,
            FADC_Data_D			=> FADC_D_Data    );

FADC_A0_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_A_Data(0),		I => ADC_A(0) );
FADC_A1_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_A_Data(1),		I => ADC_A(1) );
FADC_A2_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_A_Data(2),		I => ADC_A(2) );
FADC_A3_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_A_Data(3),		I => ADC_A(3) );
FADC_A4_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_A_Data(4),		I => ADC_A(4) );
FADC_A5_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_A_Data(5),		I => ADC_A(5) );
FADC_A6_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_A_Data(6),		I => ADC_A(6) );
FADC_A7_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_A_Data(7),		I => ADC_A(7) );
FADC_A8_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_A_Data(8),		I => ADC_A(8) );
FADC_A9_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_A_Data(9),		I => ADC_A(9) );
FADC_B0_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_B_Data(0),		I => ADC_B(0) );
FADC_B1_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_B_Data(1),		I => ADC_B(1) );
FADC_B2_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_B_Data(2),		I => ADC_B(2) );
FADC_B3_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_B_Data(3),		I => ADC_B(3) );
FADC_B4_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_B_Data(4),		I => ADC_B(4) );
FADC_B5_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_B_Data(5),		I => ADC_B(5) );
FADC_B6_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_B_Data(6),		I => ADC_B(6) );
FADC_B7_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_B_Data(7),		I => ADC_B(7) );
FADC_B8_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_B_Data(8),		I => ADC_B(8) );
FADC_B9_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_B_Data(9),		I => ADC_B(9) );
FADC_C0_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_C_Data(0),		I => ADC_C(0) );
FADC_C1_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_C_Data(1),		I => ADC_C(1) );
FADC_C2_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_C_Data(2),		I => ADC_C(2) );
FADC_C3_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_C_Data(3),		I => ADC_C(3) );
FADC_C4_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_C_Data(4),		I => ADC_C(4) );
FADC_C5_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_C_Data(5),		I => ADC_C(5) );
FADC_C6_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_C_Data(6),		I => ADC_C(6) );
FADC_C7_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_C_Data(7),		I => ADC_C(7) );
FADC_C8_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_C_Data(8),		I => ADC_C(8) );
FADC_C9_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_C_Data(9),		I => ADC_C(9) );
FADC_D0_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_D_Data(0),		I => ADC_D(0) );
FADC_D1_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_D_Data(1),		I => ADC_D(1) );
FADC_D2_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_D_Data(2),		I => ADC_D(2) );
FADC_D3_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_D_Data(3),		I => ADC_D(3) );
FADC_D4_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_D_Data(4),		I => ADC_D(4) );
FADC_D5_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_D_Data(5),		I => ADC_D(5) );
FADC_D6_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_D_Data(6),		I => ADC_D(6) );
FADC_D7_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_D_Data(7),		I => ADC_D(7) );
FADC_D8_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_D_Data(8),		I => ADC_D(8) );
FADC_D9_IB			: IBUF	generic map	( IOSTANDARD => "LVCMOS33" )
							port map	( O => FADC_D_Data(9),		I => ADC_D(9) );

FADC_ACLK_OB		: OBUF	generic map	( IOSTANDARD => "LVCMOS33", 	DRIVE => 4,		SLEW => "SLOW" )
							port map	( O => ADC_CLK(0),			I => FADC_CLK );
FADC_BCLK_OB		: OBUF	generic map	( IOSTANDARD => "LVCMOS33", 	DRIVE => 4,		SLEW => "SLOW" )
							port map	( O => ADC_CLK(1),			I => FADC_CLK );
FADC_CCLK_OB		: OBUF	generic map	( IOSTANDARD => "LVCMOS33", 	DRIVE => 4,		SLEW => "SLOW" )
							port map	( O => ADC_CLK(2),			I => FADC_CLK );
FADC_DCLK_OB		: OBUF	generic map	( IOSTANDARD => "LVCMOS33", 	DRIVE => 4,		SLEW => "SLOW" )
							port map	( O => ADC_CLK(3),			I => FADC_CLK );
FADC_Set00_OB		: OBUF	generic map	( IOSTANDARD => "LVCMOS33", 	DRIVE => 4,		SLEW => "SLOW" )
							port map	( O => ADC_Set(0),			I => FADC_Set(0) );
FADC_Set01_OB		: OBUF	generic map	( IOSTANDARD => "LVCMOS33", 	DRIVE => 4,		SLEW => "SLOW" )
							port map	( O => ADC_Set(1),			I => FADC_Set(1) );
FADC_Set10_OB		: OBUF	generic map	( IOSTANDARD => "LVCMOS33", 	DRIVE => 4,		SLEW => "SLOW" )
							port map	( O => ADC_Set(2),			I => FADC_Set(0) );
FADC_Set11_OB		: OBUF	generic map	( IOSTANDARD => "LVCMOS33", 	DRIVE => 4,		SLEW => "SLOW" )
							port map	( O => ADC_Set(3),			I => FADC_Set(1) );


-----  Formatting  -----
EncFrmtr	: Formatter
generic map (   ClkDepth				=> DriftWait    )
port map    (   CLK 					=> clk_100M,
                RST					    => SystemRst,
                Trigger				    => Trigger,
                CntReset				=> CntReset,
                Run					    => AcqRunFlag,
                D_Exist				    => Hit_Exist,
                EncAddr				    => ReadEncAddr,
                FadcAddr				=> ReadFADCad,
                HitData				    => EncData,
                FADC_A				    => Rec_FADC_A,
                FADC_B				    => Rec_FADC_B,
                FADC_C				    => Rec_FADC_C,
                FADC_D				    => Rec_FADC_D,
                valid					=> enc_valid,
                GSOcounter			    => TrgCounter,
                WriteEna				=> tmp_we,
                Dout					=> tmp_cnt     );

process (clk_100M, SystemRst)
begin
    if SystemRst='1' then
        enc_valid       <= '0';
    elsif clk_100M'event and clk_100M='1' then
        enc_valid       <= DAQ_Run and (not buf_full);
    end if;
end process;

DataBuf : fifo_32
port map    (   clk 				=> clk_100M,
                srst 				=> buf_rst,
                din 				=> tmp_cnt,
                wr_en 				=> tmp_we,
                rd_en 				=> buf_re,
                dout 				=> buf_dout,
                full 				=> open,
                empty 				=> buf_ae,
                valid				=> buf_valid,
                prog_full 			=> buf_full    );

process (clk_100M, SystemRst)
begin
	if SystemRst='1' then
		buf_re			<= '0';
	elsif clk_100M'event and clk_100M='1' then
		if buf_ae='0' and TCP_OpenACK='1' and tmp_full='0' then
			buf_re		<= '1';
		else
			buf_re		<= '0';
		end if;
	end if;
end process;

process (clk_100M, SystemRst)
begin
	if SystemRst='1' then
		buf_we			<= '0';
		buf_din			<= (others => '0');
	elsif clk_100M'event and clk_100M='1' then
		buf_we			<= buf_valid;
		buf_din			<= buf_dout;
	end if;
end process;

SiTCPBuf    : fifo_buffer
port map    (   rst 				=> buf_rst,
                wr_clk 				=> clk_100M,
                rd_clk 				=> clk_200M,
                din 				=> buf_din,
                wr_en 				=> buf_we,
                rd_en 				=> TCP_FIFO_Re,
                dout 				=> TCP_TxData,
                full 				=> open,
                empty 				=> TCP_FIFO_Em,
                valid 				=> TCP_TxWrEna,
                prog_full 			=> tmp_full    );
TCP_FIFO_Re		<= TCP_OpenACK and (not TCP_TxFull) and (not TCP_FIFO_Em);
buf_rst			<= (not DAQ_Run) or SystemRst;

process (clk_200M)
begin
	if clk_200M'event and clk_200M='1' then
		TCP_CloseA		<= TCP_CloseR and TCP_FIFO_Em;
	end if;
end process;


-----  DAC control  -----
DACctrl		: ASIC_DAC_set
port map    (   CLK					=> clk_100M,
	            RST					=> SystemRst,
                ACT					=> DAC_Set,
                Run					=> DAC_Run,
                Ch					=> DAC_Ch,
                Data				=> DAC_Data,
                DAC_WE				=> DAC_WE,
                DAC_CLK				=> DAC_Clk,
                DAC_RST				=> DAC_Rst,
                DAC_SD				=> DAC_SD  );

VthCtrl		: DACset
generic map (   Addr                => x"80"    )
port map    (   CLK					=> clk_100M,
            	RST					=> SystemRst,
            	ACT					=> Vth_Set,
	            Run					=> Vth_Run,
            	Ch					=> Vth_Ch,
            	Data				=> Vth_Data,
            	DAC_SYNC			=> Vth_Sync,
            	DAC_CLK				=> Vth_Clk,
            	DAC_DIN				=> Vth_SD  );

ADC_BIAS_ctrl   : DACset
generic map (   Addr                => x"82"    )
port map    (   CLK                 => clk_100M,
                RST                 => SystemRst,
                ACT                 => ADC_BIAS_Set,
                Run                 => ADC_BIAS_Run,
                Ch                  => ADC_BIAS_Ch,
                Data                => ADC_BIAS_Data,
                DAC_SYNC            => ADC_BIAS_Sync,
                DAC_CLK             => ADC_BIAS_Clk,
                DAC_DIN             => ADC_BIAS_SD );


DAC_WE_FD           : FD    generic map ( INIT      => '1'  )
                            port map    ( Q =>  DAC_WE_Buf,     C => clk_100M,      D => DAC_WE   );
DAC_WE_OB			: OBUF	generic map	( IOSTANDARD => "LVCMOS33",	DRIVE => 4,		SLEW => "SLOW")
							port map	( O => CHIP_WR,				I => DAC_WE_Buf );
DAC_CK_FD           : FD    generic map ( INIT      => '1'  )
                            port map    ( Q =>  DAC_Clk_Buf,    C => clk_100M,      D => DAC_Clk  );
DAC_CK_OB			: OBUF	generic map	( IOSTANDARD => "LVCMOS33",	DRIVE => 4,		SLEW => "SLOW")
							port map	( O => CHIP_CK,				I => DAC_Clk_Buf );
DAC_RB_FD           : FD    generic map ( INIT      => '1'  )
                            port map    ( Q =>  DAC_Rst_Buf,    C => clk_100M,      D => DAC_Rst  );
DAC_RB_OB			: OBUF	generic map	( IOSTANDARD => "LVCMOS33",	DRIVE => 4,		SLEW => "SLOW")
							port map	( O => CHIP_RB,				I => DAC_Rst_Buf );
DAC_SD_FD           : FD    generic map ( INIT      => '1'  )
                            port map    ( Q =>  DAC_SD_Buf,     C => clk_100M,      D => DAC_SD   );
DAC_SD_OB			: OBUF	generic map	( IOSTANDARD => "LVCMOS33",	DRIVE => 4,		SLEW => "SLOW")
							port map	( O => CHIP_SD,				I => DAC_SD_Buf );
Vth_Sync_FD         : FD    generic map ( INIT      => '1'  )
                            port map    ( Q =>  Vth_SyncBuf,    C => clk_100M,  D => Vth_Sync   );
Vth_SYNC_OB			: OBUF	generic map	( IOSTANDARD => "LVCMOS33",	DRIVE => 4,		SLEW => "SLOW")
							port map	( O => SYNC,					I => Vth_SyncBuf );
Vth_CLK_FD          : FD    generic map ( INIT      => '1'  )
                            port map    ( Q =>  Vth_ClkBuf,     C => clk_100M,  D => Vth_Clk    );
Vth_CLK_OB			: OBUF	generic map	( IOSTANDARD => "LVCMOS33",	DRIVE => 4,		SLEW => "SLOW")
							port map	( O => SCLK,					I => Vth_ClkBuf  );
Vth_Data_FD         : FD    generic map ( INIT      => '1'  )
                            port map    ( Q =>  Vth_SDBuf,      C => clk_100M,  D => Vth_SD     );
Vth_DATA_OB			: OBUF	generic map	( IOSTANDARD => "LVCMOS33",	DRIVE => 4,		SLEW => "SLOW")
							port map	( O => SDIN,					I => Vth_SDBuf   );
ADC_BIAS_Sync_FD    : FD    generic map ( INIT      => '1'  )
                            port map    ( Q =>  ADC_Sync_Buf,   C => clk_100M,  D => ADC_BIAS_Sync  );
ADC_BIAS_SYNC_OB    : OBUF	generic map	( IOSTANDARD => "LVCMOS33",	DRIVE => 4,		SLEW => "SLOW")
                            port map    ( O => ADC_SYNC,   I => ADC_Sync_Buf );
ADC_BIAS_CLK_FD     : FD    generic map ( INIT      => '1'  )
                            port map    ( Q =>  ADC_Clk_Buf,    C => clk_100M,  D => ADC_BIAS_Clk   );
ADC_BIAS_CLK_OB     : OBUF	generic map	( IOSTANDARD => "LVCMOS33",	DRIVE => 4,		SLEW => "SLOW")
                            port map    ( O => ADC_SCLK,   I => ADC_Clk_Buf  );
ADC_BIAS_DATA_FD    : FD    generic map ( INIT      => '1'  )
                            port map    ( Q =>  ADC_SD_Buf,     C => clk_100M,  D => ADC_BIAS_SD    );
ADC_BIAS_DATA_OB    : OBUF	generic map	( IOSTANDARD => "LVCMOS33",	DRIVE => 4,		SLEW => "SLOW")
                            port map    ( O => ADC_SDIN,   I => ADC_SD_Buf );


-----  SiTCP  -----
-- st_cnt_rst は PHY (LAN8810) のリセット信号。
-- PLLがロックされてから198 count (0.99 us) 後にリセット解除。

-- st_sys_rst は SiTCP のリセット信号。
-- INIT_LAN8810 の O_RESET と接続されていて、PHYの初期化プロセスを完了するとSiTCPのリセットが解除される。

process(clk_200M, locked)
begin
    if locked='0' then
        st_cnt_clk              <= '0' & x"c6";
    elsif clk_200M'event and clk_200M='1' then
        if st_cnt_clk(8)='1' then
            st_cnt_clk          <= (others => '1');            
        else
            st_cnt_clk          <= st_cnt_clk - 1;
        end if;
    end if;
end process;

process (clk_200M, locked)
begin
    if locked='0' then
        st_cnt_rst              <= '0';
    elsif clk_200M'event and clk_200M='1' then
        st_cnt_rst              <= st_cnt_clk(8);
    end if;
end process;

-- PHYがMII (RX clock: 25MHz) か GMII (RX clock: 125MHz) かを判定して gmii_1000M を設定する。
-- 200MHz clock で 199 count 中に RX clock の立ち上がりが64 count 以上あれば GMII
process (clk_200M, st_sys_rst)
begin
    if st_sys_rst='1' then
        cnt_clk                 <= (others => '0');
    elsif clk_200M'event and clk_200M='1' then
        if cnt_clk(8)='1' then
            cnt_clk             <= '0' & x"c7";
        else
            cnt_clk             <= cnt_clk - 1;
        end if;
    end if;
end process;

process (clk_200M, st_sys_rst)
begin
    if st_sys_rst='1' then
        cnt_lod                 <= '0';
        cnt_rst                 <= '1';
    elsif clk_200M'event and clk_200M='1' then
        cnt_lod                 <= cnt_clk(8);
        cnt_rst                 <= cnt_lod;
    end if;
end process;

process (clk_200M, st_sys_rst)
begin
    if st_sys_rst='1' then
        gmii_1000M              <= '0';
    elsif clk_200M'event and clk_200M='1' then
        if cnt_lod='1' then
            gmii_1000M          <= rx_cnt(6);  -- (if rx_cnt >= 64)
        else
            gmii_1000M          <= gmii_1000M;
        end if;
    end if;
end process;

process (gmii_rx_clk, cnt_rst)
begin
    if cnt_rst='1' then
        rx_cnt                  <= (others => '0');
    elsif gmii_rx_clk'event and gmii_rx_clk='1' then
        if rx_cnt(6)='1' then
            rx_cnt              <= rx_cnt;
        else
            rx_cnt              <= rx_cnt + 1;
        end if;
    end if;
end process;

-------  SiTCP  -----
IP_SetBit       <= x"c0a864" & "01" & dip_sw_data ( 5 downto 0);

SiTCP:      WRAP_SiTCP_GMII_XC7S_32K
--generic map (   TIM_PERIOD      => x"c8"    )
generic map (   TIM_PERIOD      => x"96"    )
port map    (   CLK             => clk_200M,
                RST             => st_sys_rst,
                FORCE_DEFAULTn  => dip_sw_data(7),
                EXT_IP_ADDR     => IP_SetBit,
                EXT_TCP_PORT    => x"0018",
                EXT_RBCP_PORT   => x"1234",
                PHY_ADDR        => phy_addr,
                EEPROM_CS       => Eep_CSBuf,
                EEPROM_SK       => Eep_SkBuf,
                EEPROM_DI       => Eep_DiBuf,
                EEPROM_DO       => Eep_DoBuf,
                GMII_RSTn       => st_phy_rst,
                GMII_1000M      => gmii_1000M,
                GMII_TX_CLK     => gmii_tx_clk,
                GMII_TX_EN      => gmii_tx_en,
                GMII_TXD        => gmii_txd,
                GMII_TX_ER      => gmii_tx_er,
                GMII_RX_CLK     => gmii_rx_clk,
                GMII_RX_DV      => gmii_rx_dv,
                GMII_RXD        => gmii_rxd,
                GMII_RX_ER      => gmii_rx_er,
                GMII_CRS        => gmii_crs,
                GMII_COL        => gmii_col,
                GMII_MDC        => st_mdc,
                GMII_MDIO_IN    => st_mdio_in,
                GMII_MDIO_OUT   => st_mdio_out,
                GMII_MDIO_OE    => st_mdio_oe,
                SiTCP_RST       => SiTCP_Reset,
                TCP_OPEN_REQ    => '0',
                TCP_OPEN_ACK    => TCP_OpenACK,
                TCP_ERROR       => open,
                TCP_CLOSE_REQ   => TCP_CloseR,
                TCP_CLOSE_ACK   => TCP_CloseA,
                TCP_RX_WC       => (others => '1'),
                TCP_RX_WR       => open,
                TCP_RX_DATA     => open,
                TCP_TX_FULL	    => TCP_TxFull,
                TCP_TX_WR       => TCP_TxWrEna,
                TCP_TX_DATA     => TCP_TxData,
                RBCP_ACT        => rbcp_act,
                RBCP_ADDR       => rbcp_addr,
                RBCP_WD         => rbcp_wd,
                RBCP_WE         => rbcp_we,
                RBCP_RE         => rbcp_re,
                RBCP_ACK        => rbcp_ack,
                RBCP_RD         => rbcp_rd  );

SlwCtrl:    RBCP_REG
port map (  clock           => clk_200M,
            reset           => SiTCP_Reset,
            rbcp_act        => rbcp_act,
            rbcp_addr       => rbcp_addr,
            rbcp_wd         => rbcp_wd,
            rbcp_we         => rbcp_we,
            rbcp_re         => rbcp_re,
            rbcp_ack        => rbcp_ack,
            rbcp_rd         => rbcp_rd,
            DAC_ack			=> DAC_Set_RBCP,
            DAC_ctrl		=> DAC_Run,
            DAC_Ch			=> DAC_Ch,
            DAC_Data		=> DAC_Data,
            Vth_ack			=> Vth_Set,
            Vth_ctrl		=> Vth_Run,
            Vth_Ch			=> Vth_Ch,
            Vth_Data		=> Vth_Data,
            ADC_BIAS_ack    => ADC_BIAS_Set,
            ADC_BIAS_ctrl   => ADC_BIAS_Run,
            ADC_BIAS_Ch     => ADC_BIAS_Ch,
            ADC_BIAS_Data   => ADC_BIAS_Data,
            AP_ON           => AP_ON_RBCP,
            LatchUp_Detect  => LatchUp_Detect );

SW_0_IB:    IOBUF   generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  
                    port map    (   O   => DipSwBuf(0),     IO  => DIP_SW_IN(0),    I   => '0',     T   => '1'  );
SW_0_PU:    PULLUP  port map    (   O   => DIP_SW_IN(0)     );                    
SW_1_IB:    IOBUF   generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  
                    port map    (   O   => DipSwBuf(1),     IO  => DIP_SW_IN(1),    I   => '0',     T   => '1'  );
SW_1_PU:    PULLUP  port map    (   O   => DIP_SW_IN(1)     );                    
SW_2_IB:    IOBUF   generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  
                    port map    (   O   => DipSwBuf(2),     IO  => DIP_SW_IN(2),    I   => '0',     T   => '1'  );
SW_2_PU:    PULLUP  port map    (   O   => DIP_SW_IN(2)     );                    
SW_3_IB:    IOBUF   generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  
                    port map    (   O   => DipSwBuf(3),     IO  => DIP_SW_IN(3),    I   => '0',     T   => '1'  );
SW_3_PU:    PULLUP  port map    (   O   => DIP_SW_IN(3)     );                    
SW_4_IB:    IOBUF   generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  
                    port map    (   O   => DipSwBuf(4),     IO  => DIP_SW_IN(4),    I   => '0',     T   => '1'  );
SW_4_PU:    PULLUP  port map    (   O   => DIP_SW_IN(4)     );                    
SW_5_IB:    IOBUF   generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  
                    port map    (   O   => DipSwBuf(5),     IO  => DIP_SW_IN(5),    I   => '0',     T   => '1'  );
SW_5_PU:    PULLUP  port map    (   O   => DIP_SW_IN(5)     );                    
SW_6_IB:    IOBUF   generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  
                    port map    (   O   => DipSwBuf(6),     IO  => DIP_SW_IN(6),    I   => '0',     T   => '1'  );
SW_6_PU:    PULLUP  port map    (   O   => DIP_SW_IN(6)     );                    
SW_7_IB:    IOBUF   generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  
                    port map    (   O   => DipSwBuf(7),     IO  => DIP_SW_IN(7),    I   => '0',     T   => '1'  );
SW_7_PU:    PULLUP  port map    (   O   => DIP_SW_IN(7)     );                    

AP_ON_OB        : OBUF	generic map	( IOSTANDARD => "LVCMOS33",	DRIVE => 4,		SLEW => "SLOW")
                        port map ( O => ASIC_POWER_OUT,   I => AP_ON );


-------  EEPROM  -----
EEP_CS_OB:  OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  port map (  O   => EEPROM_CS_OUT,   I   => Eep_CsBuf    );
EEP_SK_OB:  OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  port map (  O   => EEPROM_SK_OUT,   I   => Eep_SkBuf    );
EEP_DI_OB:  OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  port map (  O   => EEPROM_DI_OUT,   I   => Eep_DiBuf    );
EEP_DO_IOB: IOBUF   generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  port map (  O   => Eep_DoBuf,       IO  => EEPROM_DO_IN,    I   => '0', T   => '1'  );
EEP_DO_PD:  PULLDOWN    port map(   O   => EEPROM_DO_IN );


-------  LAN8810  ----
LANinit:    LAN8810_INIT
generic map (   freqency	    => x"c8"   )
port map    (   I_nRESET        => st_cnt_rst,
                CLOCK           => clk_200M,
                PHY_ADDR        => phy_addr,
                SiTCP_PHY_nRST  => st_phy_rst, 
                SiTCP_MDC       => st_mdc,
                SiTCP_MDIO_OUT  => st_mdio_out,
                SiTCP_MDIO_OE   => st_mdio_oe,
                MDC             => phy_mdc,
                O_MDIO          => phy_o_mdio,
                T_MDIO          => phy_t_mdio,
                PHY_nRESET      => phy_rst,
                O_RESET         => st_sys_rst   );


ETH_RST_OB: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  port map (  O   => ETH_nRST_OUT,    I   => phy_rst      );
ETH_MDC_OB: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  port map (  O   => ETH_MDC_OUT,     I   => phy_mdc      );
ETH_MDIOB:  IOBUF   generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "SLOW")  port map (  O   => st_mdio_in,      IO  => ETH_MDIO_IO,     I   => phy_o_mdio,  T   => phy_t_mdio   );
ETH_RCLKIB: IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => eth_rx_clk_buf,  I   => ETH_RX_CLK_IN    );
ETH_RCLKRB: BUFR    port map    (   O   => gmii_rx_clk,     I   => eth_rx_clk_buf,      CE  => '1',     CLR => '0'  );
E_RXD_0_IB: IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => rxd_buf(0),      I   => ETH_RXD_IN(0)    );
E_RXD_0_DL: IDELAYE2
generic map (   IDELAY_TYPE => "FIXED", DELAY_SRC => "IDATAIN", IDELAY_VALUE => 6,  HIGH_PERFORMANCE_MODE => "FALSE",   SIGNAL_PATTERN => "DATA",   REFCLK_FREQUENCY => 200.0,  CINVCTRL_SEL => "FALSE",    PIPE_SEL => "FALSE" ) 
port map    (   C => '0',   REGRST => '0',  LD => '0',  CE => '0',  INC => '0', CINVCTRL => '0', CNTVALUEIN => "00000", IDATAIN => rxd_buf(0), DATAIN => '0', LDPIPEEN => '0', DATAOUT => gmii_rxd(0), CNTVALUEOUT => open  );
E_RXD_1_IB: IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => rxd_buf(1),      I   => ETH_RXD_IN(1)    );
E_RXD_1_DL: IDELAYE2
generic map (   IDELAY_TYPE => "FIXED", DELAY_SRC => "IDATAIN", IDELAY_VALUE => 6,  HIGH_PERFORMANCE_MODE => "FALSE",   SIGNAL_PATTERN => "DATA",   REFCLK_FREQUENCY => 200.0,  CINVCTRL_SEL => "FALSE",    PIPE_SEL => "FALSE" ) 
port map    (   C => '0',   REGRST => '0',  LD => '0',  CE => '0',  INC => '0', CINVCTRL => '0', CNTVALUEIN => "00000", IDATAIN => rxd_buf(1), DATAIN => '0', LDPIPEEN => '0', DATAOUT => gmii_rxd(1), CNTVALUEOUT => open  );
E_RXD_2_IB: IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => rxd_buf(2),      I   => ETH_RXD_IN(2)    );
E_RXD_2_DL: IDELAYE2
generic map (   IDELAY_TYPE => "FIXED", DELAY_SRC => "IDATAIN", IDELAY_VALUE => 6,  HIGH_PERFORMANCE_MODE => "FALSE",   SIGNAL_PATTERN => "DATA",   REFCLK_FREQUENCY => 200.0,  CINVCTRL_SEL => "FALSE",    PIPE_SEL => "FALSE" ) 
port map    (   C => '0',   REGRST => '0',  LD => '0',  CE => '0',  INC => '0', CINVCTRL => '0', CNTVALUEIN => "00000", IDATAIN => rxd_buf(2), DATAIN => '0', LDPIPEEN => '0', DATAOUT => gmii_rxd(2), CNTVALUEOUT => open  );
E_RXD_3_IB: IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => rxd_buf(3),      I   => ETH_RXD_IN(3)    );
E_RXD_3_DL: IDELAYE2
generic map (   IDELAY_TYPE => "FIXED", DELAY_SRC => "IDATAIN", IDELAY_VALUE => 6,  HIGH_PERFORMANCE_MODE => "FALSE",   SIGNAL_PATTERN => "DATA",   REFCLK_FREQUENCY => 200.0,  CINVCTRL_SEL => "FALSE",    PIPE_SEL => "FALSE" ) 
port map    (   C => '0',   REGRST => '0',  LD => '0',  CE => '0',  INC => '0', CINVCTRL => '0', CNTVALUEIN => "00000", IDATAIN => rxd_buf(3), DATAIN => '0', LDPIPEEN => '0', DATAOUT => gmii_rxd(3), CNTVALUEOUT => open  );
E_RXD_4_IB: IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => rxd_buf(4),      I   => ETH_RXD_IN(4)    );
E_RXD_4_DL: IDELAYE2
generic map (   IDELAY_TYPE => "FIXED", DELAY_SRC => "IDATAIN", IDELAY_VALUE => 6,  HIGH_PERFORMANCE_MODE => "FALSE",   SIGNAL_PATTERN => "DATA",   REFCLK_FREQUENCY => 200.0,  CINVCTRL_SEL => "FALSE",    PIPE_SEL => "FALSE" ) 
port map    (   C => '0',   REGRST => '0',  LD => '0',  CE => '0',  INC => '0', CINVCTRL => '0', CNTVALUEIN => "00000", IDATAIN => rxd_buf(4), DATAIN => '0', LDPIPEEN => '0', DATAOUT => gmii_rxd(4), CNTVALUEOUT => open  );
E_RXD_5_IB: IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => rxd_buf(5),      I   => ETH_RXD_IN(5)    );
E_RXD_5_DL: IDELAYE2
generic map (   IDELAY_TYPE => "FIXED", DELAY_SRC => "IDATAIN", IDELAY_VALUE => 6,  HIGH_PERFORMANCE_MODE => "FALSE",   SIGNAL_PATTERN => "DATA",   REFCLK_FREQUENCY => 200.0,  CINVCTRL_SEL => "FALSE",    PIPE_SEL => "FALSE" ) 
port map    (   C => '0',   REGRST => '0',  LD => '0',  CE => '0',  INC => '0', CINVCTRL => '0', CNTVALUEIN => "00000", IDATAIN => rxd_buf(5), DATAIN => '0', LDPIPEEN => '0', DATAOUT => gmii_rxd(5), CNTVALUEOUT => open  );
E_RXD_6_IB: IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => rxd_buf(6),      I   => ETH_RXD_IN(6)    );
E_RXD_6_DL: IDELAYE2
generic map (   IDELAY_TYPE => "FIXED", DELAY_SRC => "IDATAIN", IDELAY_VALUE => 6,  HIGH_PERFORMANCE_MODE => "FALSE",   SIGNAL_PATTERN => "DATA",   REFCLK_FREQUENCY => 200.0,  CINVCTRL_SEL => "FALSE",    PIPE_SEL => "FALSE" ) 
port map    (   C => '0',   REGRST => '0',  LD => '0',  CE => '0',  INC => '0', CINVCTRL => '0', CNTVALUEIN => "00000", IDATAIN => rxd_buf(6), DATAIN => '0', LDPIPEEN => '0', DATAOUT => gmii_rxd(6), CNTVALUEOUT => open  );
E_RXD_7_IB: IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => rxd_buf(7),      I   => ETH_RXD_IN(7)    );
E_RXD_7_DL: IDELAYE2
generic map (   IDELAY_TYPE => "FIXED", DELAY_SRC => "IDATAIN", IDELAY_VALUE => 6,  HIGH_PERFORMANCE_MODE => "FALSE",   SIGNAL_PATTERN => "DATA",   REFCLK_FREQUENCY => 200.0,  CINVCTRL_SEL => "FALSE",    PIPE_SEL => "FALSE" ) 
port map    (   C => '0',   REGRST => '0',  LD => '0',  CE => '0',  INC => '0', CINVCTRL => '0', CNTVALUEIN => "00000", IDATAIN => rxd_buf(7), DATAIN => '0', LDPIPEEN => '0', DATAOUT => gmii_rxd(7), CNTVALUEOUT => open  );
E_RX_ER_IB: IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => rx_er_buf,       I   => ETH_RX_ER_IN     );
E_RX_ER_DL: IDELAYE2
generic map (   IDELAY_TYPE => "FIXED", DELAY_SRC => "IDATAIN", IDELAY_VALUE => 0,  HIGH_PERFORMANCE_MODE => "FALSE",   SIGNAL_PATTERN => "DATA",   REFCLK_FREQUENCY => 200.0,  CINVCTRL_SEL => "FALSE",    PIPE_SEL => "FALSE" ) 
port map    (   C => '0',   REGRST => '0',  LD => '0',  CE => '0',  INC => '0', CINVCTRL => '0', CNTVALUEIN => "00000", IDATAIN => rx_er_buf,  DATAIN => '0', LDPIPEEN => '0', DATAOUT => gmii_rx_er,  CNTVALUEOUT => open  );
E_RX_DV_IB: IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => rx_dv_buf,       I   => ETH_RX_DV_IN     );
E_RX_DV_DL: IDELAYE2
generic map (   IDELAY_TYPE => "FIXED", DELAY_SRC => "IDATAIN", IDELAY_VALUE => 0,  HIGH_PERFORMANCE_MODE => "FALSE",   SIGNAL_PATTERN => "DATA",   REFCLK_FREQUENCY => 200.0,  CINVCTRL_SEL => "FALSE",    PIPE_SEL => "FALSE" ) 
port map    (   C => '0',   REGRST => '0',  LD => '0',  CE => '0',  INC => '0', CINVCTRL => '0', CNTVALUEIN => "00000", IDATAIN => rx_dv_buf,  DATAIN => '0', LDPIPEEN => '0', DATAOUT => gmii_rx_dv,  CNTVALUEOUT => open  );
SR_DL_CTRL: IDELAYCTRL  port map    (   RDY => open,    REFCLK  => clk_200M,    RST => st_sys_rst   );
E_COL_IB:   IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => gmii_col,    I   => ETH_RX_COL_IN        );
E_CRS_IB:   IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map (  O   => gmii_crs,    I   => ETH_RX_CRS_IN        );

E_TXCLK_IB: IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map    (   O   => tx_clk_buf,      I   => ETH_TX_CLK_IN        );
E_TX_EN_OB: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST"   )   port map    (   O   => ETH_TX_EN_OUT,       I   => gmii_tx_en       );
E_TX_ER_OB: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST"   )   port map    (   O   => ETH_TX_ER_OUT,       I   => gmii_tx_er       );
GMIIMUX:    BUFGMUX port map    (   O   => gmii_tx_clk,     I0  => tx_clk_buf,      I1  => clk_125M,    S   => gmii_1000M               );
IOB_GXT:    ODDR    port map    (   C   => gmii_tx_clk,     CE  => '1',     D1  => '0',     D2  => '1',     R   => '0',     S   => '0',     Q   => eth_gtxclk_int   );
E_GTXCLKob: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST"   )   port map    (   O   => ETH_GTXCLK_OUT,      I   => eth_gtxclk_int   );
E_TXD_0_OB: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST"   )   port map    (   O   => ETH_TXD_OUT(0),      I   => gmii_txd(0)      );
E_TXD_1_OB: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST"   )   port map    (   O   => ETH_TXD_OUT(1),      I   => gmii_txd(1)      );
E_TXD_2_OB: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST"   )   port map    (   O   => ETH_TXD_OUT(2),      I   => gmii_txd(2)      );
E_TXD_3_OB: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST"   )   port map    (   O   => ETH_TXD_OUT(3),      I   => gmii_txd(3)      );
E_TXD_4_OB: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST"   )   port map    (   O   => ETH_TXD_OUT(4),      I   => gmii_txd(4)      );
E_TXD_5_OB: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST"   )   port map    (   O   => ETH_TXD_OUT(5),      I   => gmii_txd(5)      );
E_TXD_6_OB: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST"   )   port map    (   O   => ETH_TXD_OUT(6),      I   => gmii_txd(6)      );
E_TXD_7_OB: OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 4,   SLEW    => "FAST"   )   port map    (   O   => ETH_TXD_OUT(7),      I   => gmii_txd(7)      );

E_HPD_OB:   OBUF    generic map (   IOSTANDARD  => "LVCMOS33",  DRIVE   => 8,   SLEW    => "SLOW"   )   port map    (   O   => ETH_HPD_OUT,         I   => phy_hpd          );
E_IRQ_IB:   IBUF    generic map (   IOSTANDARD  => "LVCMOS33"   )   port map    (   O   => phy_irq,         I   => ETH_IRQ_IN           );

                
end Behavioral;
