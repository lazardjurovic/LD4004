----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2023 08:46:42 PM
-- Design Name: 
-- Module Name: system_tb - Behavioral
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

entity system_tb is
--  Port ( );
end system_tb;

architecture Behavioral of system_tb is

signal clk_f2_s,clk_f1_s,reset_s : std_logic;
signal data: std_logic_vector(3 downto 0);

begin

clk_gen2 : process
begin

  clk_f2_s <= '0';
  wait for 10ns;
  clk_f2_s<= '1';
  wait for 10ns;

end process;

duv: entity work.system_top
port map(
clk_f1 => clk_f1_s,
clk_f2 => clk_f2_s,
reset => reset_s,
CM_RAM => data
);


reset_s <= '0' , '1' after 10ns;
clk_f1_s <= '1';


end Behavioral;
