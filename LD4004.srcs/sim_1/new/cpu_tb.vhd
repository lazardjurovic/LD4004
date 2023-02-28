----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/11/2023 08:01:14 PM
-- Design Name: 
-- Module Name: phase_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu_tb is
--  Port ( );
end cpu_tb;

architecture Behavioral of cpu_tb is

signal D_signal : std_logic_vector(3 downto 0);
signal CM_RAM_s : std_logic_vector(3 downto 0);
signal SYNC_s, CM_ROM_s, TEST_s, RESET_s, clk_f1_s, clk_f2_s : std_logic;

begin

procesor: entity work.top_4004
port map(
        D => D_signal,
        CM_RAM => CM_RAM_s,
        SYNC => SYNC_s,
        CM_ROM => CM_ROM_s,
        TEST => TEST_s,
        RESET => RESET_s,
        clk_f1 => clk_f1_s,
        clk_f2 => clk_f2_s
);

clk_gen2 : process
begin

  clk_f2_s <= '0';
  wait for 10ns;
  clk_f2_s<= '1';
  wait for 10ns;

end process;


stim_gen: process
begin
    D_signal<=
    "0110" after 50ns,"0001" after 70ns, "ZZZZ" after 90ns, --INC R1
    "0110" after 210ns, "0010" after 230ns,"ZZZZ" after 250ns, -- INC R2
    "1101" after 370ns,"0100" after 390ns,"ZZZZ" after 410ns, -- LDM 4 (ACC <- 4)
    "1000" after 530ns, "0001" after 550ns, "ZZZZ" after 570ns, -- ADD (ACC <- R1 + ACC) = 5
    "0100" after 690ns, "1111" after 710ns, "ZZZZ" after 730ns, -- JUN 0xFFF
    "0110" after 850ns,"0011" after 870ns, "ZZZZ" after 890ns; --INC R3 -- for testing long_isntr flag

    CM_ROM_s <= '0';
    clk_f1_s <= '1';
    TEST_s <= '0';
    RESET_s<= '1';

     
wait;
end process;

end Behavioral;