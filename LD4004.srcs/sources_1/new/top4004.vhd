----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/11/2023 07:12:30 PM
-- Design Name: 
-- Module Name: top_4004 - Behavioral
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

entity top_4004 is
  Port (
        D : inout std_logic_vector(3 downto 0);
        CM_RAM : out std_logic_vector(3 downto 0);
        SYNC : out std_logic;
        CM_ROM : out std_logic;
        TEST : in std_logic;
        RESET : in std_logic;  -- RESET IS ACTIVE LOW
        clk_f1 : in std_logic;
        clk_f2 : in std_logic
   );
end top_4004;

architecture Behavioral of top_4004 is 

type state is (A1,A2,A3,M1,M2,X1,X2,X3);
signal current_state, next_state : state := A1;

type addr_reg is array (0 to 3) of std_logic_vector(11 downto 0);
signal address_register : addr_reg;

type regs is array (15 downto 0) of std_logic_vector(3 downto 0);
signal register_bank : regs;

signal data_bus : std_logic_vector(3 downto 0);

signal OPA, OPR : std_logic_vector(3 downto 0); 
-- INSTRUCTION WORD
-- OPR IS UPPER 4 BITS - OPERATION CODE
-- OPA IS LOWER 4 BITS - MODIFIER

signal accumulator : std_logic_vector(3 downto 0);

begin

    clock_process : process(clk_f2,clk_f1,RESET)
    begin
        if(RESET = '0') then
            current_state <= A1;
        else
            if(rising_edge(clk_f2)) then
                current_state <= next_state;
            end if;
        end if;
    end process;
        
    state_gen : process(current_state,address_register)
    begin
       case current_state is
       
            when A1 =>
                data_bus <= address_register(0)(3 downto 0); -- SENDING LOW 4 BITS TO MEMORY
                next_state <= A2;
            when A2 => 
                data_bus <= address_register(0)(7 downto 4); -- SENDING LOW 4 BITS TO MEMORY
                next_state <= A3;
            when A3 =>
                data_bus <= address_register(0)(11 downto 8); -- SENDING LOW 4 BITS TO MEMORY
                next_state <= M1;
            when M1 =>
                OPR <= D; --LOADING OPR INTO CPU
                next_state <= M2;
            when M2 =>
                OPA <= D; -- LOADING OPA INTO CPU
                next_state <= X1;
            when X1 =>
                next_state <= X2;
            when X2 =>
                next_state <= X3;
            when X3 =>
                next_state <= A1;
            when others =>
                next_state <= A1;
       
       end case;
        
    end process;
    
CM_RAM<= OPR;

end Behavioral;