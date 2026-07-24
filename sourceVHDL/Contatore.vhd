library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Contatore is
    Port(clk, rst: in std_logic;
         enable: in std_logic;
         qOut: out std_logic_vector(12 downto 0));
end Contatore;

architecture Behavioral of Contatore is

signal CountS: unsigned(12 downto 0) := (others => '0');

begin

process(clk)
begin
if(rising_edge(clk))then
    if(rst = '1')then
        CountS <= (others => '0');
    elsif(enable = '1')then
        CountS <= CountS + 1;
     end if; -- rst & enable
end if; -- clk
end process; --clk

qOut <= std_logic_vector(CountS);

end Behavioral;