----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2023 05:26:50 PM
-- Design Name: 
-- Module Name: ROM_memory - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.types.all;

entity ROM_memory is
  Port ( 
    active : in std_logic;
    reset : in std_logic;
    clk : in std_logic;
    data : inout std_logic_vector(3 downto 0)
  );
end ROM_memory;

architecture Behavioral of ROM_memory is

signal ROM : rom_mem := ("01100001", "01100010", "11010011", "10000001", others=>(others=>'0'));
signal current_state, next_state : rom_state := ADDR1;
signal addr_full : std_logic_vector(11 downto 0);
signal bus_in : std_logic_vector(3 downto 0);
signal bus_out : std_logic_vector(3 downto 0);

begin

state_change_proc: process(reset, clk)
begin
    
    if(reset = '0') then
        current_state <= ADDR1;
    else
        if(active = '1' and rising_edge(clk)) then
            current_state <= next_state;
        end if;
    end if;
   
end process;

bus_out <= ROM(to_integer(unsigned(addr_full)))(7 downto 4) when current_state = O1 else "ZZZZ";
bus_out <= ROM(to_integer(unsigned(addr_full)))(3 downto 0) when current_state = O2 else "ZZZZ";
bus_in <= data when (current_state= ADDR1 or current_state= ADDR2 or current_state= ADDR3) else "ZZZZ";
data <= bus_out when (current_state = O1 or current_state =  O2) else "ZZZZ";

addr_full(3 downto 0) <= bus_in when current_state = ADDR1 and falling_edge(clk);
addr_full(7 downto 4) <= bus_in when current_state = ADDR2  and falling_edge(clk);
addr_full(11 downto 8) <= bus_in when current_state = ADDR3  and falling_edge(clk);

state_gen_proc: process(current_state)
begin
    case current_state is 
        when ADDR1 => 
            next_state <= ADDR2;
        when ADDR2 => 
            next_state <= ADDR3;
        when ADDR3 => 
            next_state <= O1;
        when O1 => 
            next_state <= O2;  
        when O2 => 
            next_state <= ADDR1; 
        when others => next_state <= ADDR1;
    end case;
end process;


end Behavioral;