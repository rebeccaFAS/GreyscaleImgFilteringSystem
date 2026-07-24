library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity MUX5to1 is
generic(dimMUX: integer := 12); -- check dimensione
    Port(ExA, DA, MA, MDA, zero: in std_logic_vector(dimMUX downto 0);
         Sel: in std_logic_vector(2 downto 0);
         Outmux: out std_logic_vector(dimMUX downto 0));
end MUX5to1;

architecture Behavioral of MUX5to1 is

begin

with Sel select
Outmux <= ExA when "001",
          DA  when "010",
          MA  when "101",
          MDA when "110",
          zero when others;
          
end Behavioral;