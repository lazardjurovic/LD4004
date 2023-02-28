----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2023 08:30:52 PM
-- Design Name: 
-- Module Name: system_top - Behavioral
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

entity system_top is
  Port ( 
    clk_f1 : in std_logic;
    clk_f2 : in std_logic;
    reset: in std_logic;
    CM_RAM : out std_logic_vector(3 downto 0)
  );
end system_top;

architecture Behavioral of system_top is

signal data_s : std_logic_vector(3 downto 0);
signal sync_s : std_logic;

begin

memory : entity work.ROM_memory
port map(
    active => sync_s,
    reset => reset,
    clk => clk_f2,
    data => data_s
);

cpu: entity work.top_4004
port map(
D => data_s,
CM_RAM => CM_RAM,
SYNC => sync_s,
CM_ROM => open,
TEST => '1',
RESET => reset,
clk_f1 => clk_f1,
clk_f2 => clk_f2
);


end Behavioral;
