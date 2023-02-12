----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2023 05:50:05 PM
-- Design Name: 
-- Module Name: ROM_tb - Behavioral
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

entity ROM_tb is
--  Port ( );
end ROM_tb;

architecture Behavioral of ROM_tb is

signal active_s, clk_s, reset_s : std_logic;
signal address_s, data_s : std_logic_vector(3 downto 0);

begin

duv: entity work.ROM_memory
port map(
    active => active_s,
    clk=> clk_s,
    reset=> reset_s,
    address=> address_s,
    data=>data_s
);


clk_gen2 : process
begin

  clk_s <= '0';
  wait for 10ns;
  clk_s<= '1';
  wait for 10ns;

end process;

stim_gen: process
begin

    reset_s <= '0', '1' after 20ns;
    active_s <= '1';
    address_s <= "0000" after 10ns, "0000" after 30ns, "0000" after 50ns, -- LOCATION 0
    "0001" after 110ns, "0000" after 130ns, "0000" after 150ns; -- LOCATION 1
wait;
end process;


end Behavioral;
