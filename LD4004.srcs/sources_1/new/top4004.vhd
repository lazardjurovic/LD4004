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

use work.types.all;

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

signal current_state, next_state : state := A1;
signal address_register : addr_reg := (others=>(others=>'0'));
signal register_bank : regs :=(others=>(others=>'0'));

signal OPA, OPR : std_logic_vector(3 downto 0); 
-- INSTRUCTION WORD
-- OPR IS UPPER 4 BITS - OPERATION CODE
-- OPA IS LOWER 4 BITS - MODIFIER 

signal long_instr : std_logic := '0';  -- signal indicating that instruction takes 2 bytes
signal high_bits : std_logic_vector(3 downto 0) := (others => '0'); -- content of OPA register for 2 byte instrucitons

signal carry_flag: std_logic := '0';
signal accumulator : std_logic_vector(3 downto 0) := (others => '0');

begin
    
    sync_process : process(current_state)
    begin
       case current_state is
           when X3 => SYNC <= '0';
           when others => SYNC<= '1';
       end case;

    end process;

    clock_process : process(clk_f2,RESET)
    begin
        if(RESET = '0') then
            current_state <= A1;
        else
            if(rising_edge(clk_f2)) then
                current_state <= next_state;
            end if;
        end if;
    end process;
    
    prog_counter_proc : process(clk_f2, RESET,current_state)
    begin
        if(RESET = '0') then -- Reseting current state 
            address_register <= (others=>(others => '0'));
        else
            if(rising_edge(clk_f2) and current_state = X3) then -- Program counter is updated in fetch phase 
                address_register(0) <= std_logic_vector(unsigned(address_register(0)) + to_unsigned(1,12));       
        end if;
                
        if(OPR = "0011" and current_state = M2 and rising_edge(clk_f2)) then -- JIN and FIN depends on last bit of OPA = 0)   OPERATION ON address_register in M@ phase
                
                case OPA(0) is
                    when '0' => --FIN
                        
                    when '1' => -- JIN
                        address_register(0)(7 downto 4) <= register_bank(to_integer(unsigned(OPA(3 downto 1)&'0'))); -- PM changed
                        address_register(0)(3 downto 0) <= register_bank(to_integer(unsigned(OPA(3 downto 1)&'1'))); -- PL changed
                    when others => null;
                end case; 
         end if;       
         if(long_instr = '1' and current_state = M1 and rising_edge(clk_f2)) then -- JUN
                    address_register(0) <= high_bits & OPR & OPA;
            end if;
        end if;
    
    end process;       
    
    long_instr_process : process(long_instr, RESET)
    begin
        if(RESET = '0') then
            high_bits <= (others => '0');
        elsif(current_state = M2 and long_instr = '1') then
            high_bits <= OPA;
        else null;
        end if;
    end process;
    
--    bus_driver: process(current_state)
--    begin
--        case current_state is
--            when A1 => D <= address_register(0)(3 downto 0); -- SENDING LOW 4 BITS TO MEMORY
--            when A2 => D <= address_register(0)(7 downto 4); -- SENDING LOW 4 BITS TO MEMORY
--            when A3 => D <= address_register(0)(11 downto 8); -- SENDING LOW 4 BITS TO MEMORY
--            when others => D<= "ZZZZ";
--        end case;
--    end process;  

    D<= "ZZZZ";
    
    regs_process: process(current_state)
    begin
        case current_state is
            when M1 => OPR <= D;
            when M2 => OPA <= D;
            when others => null;
        end case;
    end process;  
        
    next_state_gen : process(current_state)
    begin
           case current_state is
                when A1 =>next_state <= A2;
                when A2 => next_state <= A3;
                when A3 => next_state <= M1;
                when M1 => next_state <= M2;
                when M2 => next_state <= X1;
                when X1 => next_state <= X2;
                when X2 => next_state <= X3;
                when X3 => next_state <= A1;
                when others => next_state <= A1;
           end case;
    end process;
    
    instruction_decode : process(OPA)
    begin
        if(current_state = M2)then
            case OPR is
                when "1101" => -- LDM
                    accumulator <= OPA;
                    long_instr <= '0';
                when "1010" => -- LD
                    accumulator <= register_bank(to_integer(unsigned(OPA)));
                    long_instr <= '0';
    --            when "1011" => -- XCH
                when "1000" => -- ADD
                    long_instr <= '0';
                    accumulator <= std_logic_vector((unsigned( register_bank(to_integer(unsigned(OPA))))) + (unsigned(accumulator))); -- add carry flag addition
                    if( ((unsigned( register_bank(to_integer(unsigned(OPA))))) + (unsigned(accumulator))) > 15 ) then
                        carry_flag <= '1';
                    else 
                        carry_flag <= '0';
                    end if;
                        
                when "1001" => -- SUB
                     long_instr <= '0';
                     accumulator <= std_logic_vector((unsigned( not register_bank(to_integer(unsigned(OPA))))) + (unsigned(accumulator)));  -- add carry flag addition
                     if( (unsigned( register_bank(to_integer(unsigned(OPA))))) > (unsigned(accumulator)) ) then
                        carry_flag <= '1';
                     else
                        carry_flag <= '0';
                     end if;
                when "0110" => -- INC
                    long_instr <= '0';
                    register_bank(to_integer(unsigned(OPA))) <= std_logic_vector(unsigned(register_bank(to_integer(unsigned(OPA)))) + 1);
    --            when "1100" => -- BBL            
    --            when "0010" => -- SRC
    --            when "0011" => --FIN depends on last bit of OPA = 1
    
    --ACCUMULATOR GROP INSTRUCTIONS
    
               when "1111" =>
                    long_instr <= '0';
                    case OPA is 
                        when "0000" => -- CLB
                            accumulator <= (others => '0');
                            carry_flag <= '0';
                        when "0001" => -- CLC
                            carry_flag <= '0';
                        when "0011" => -- CMC
                            carry_flag <= not carry_flag;
                        when "1010" => -- STC
                            carry_flag <= '1';
                        when "0100" => -- CMA
                            accumulator <= not accumulator;
                        when "0010" => -- IAC
                            accumulator <= std_logic_vector(unsigned(accumulator) + 1); -- add owerflow
                        when "1000" => -- DAC
                            accumulator <= std_logic_vector(unsigned(accumulator) - 1); -- add borrow
                        when "0101" => -- RAL
                        when "0110" => -- RAR
                        when "0111" => -- TCC
                            accumulator(3 downto 1) <= (others=>'0');
                            accumulator(0) <= carry_flag;
                            carry_flag <= '0';
                        when "1011" => -- DAA
                        when "1001" => -- TSC
                        when "1100" => -- KBP
                        when "1101" => -- DCL
                        when others => null;-- NOTHNG
                    end case;
 -- TWO WORD INSTRUCTIONS     
                when "0100" => 
                    long_instr <= '1';
--                when "0101" => -- JMS
--                when "0001" => -- JCN
--                when "0111" => -- ISZ
--                when "0010" => -- FIM                  
                when others => null;
                    
            end case;
        else null;
        end if;
    end process;
    
CM_RAM<= accumulator;
CM_ROM <= '0';

end Behavioral;