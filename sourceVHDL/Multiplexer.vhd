library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplexer is
    generic (N: integer);
    Port (sel : in std_logic_vector(2 downto 0);
          A, B, C, D : in std_logic_vector(N-1 downto 0);
          uscita : out std_logic_vector(N-1 downto 0));
end Multiplexer;

architecture Behavioral of Multiplexer is
begin
    with sel select
        uscita <= (others => '0') when "000",  -- 0
                  A when "001",                -- 1
                  B when "010",                -- 2
                  C when "101",                -- -1 
                  D when "110",                -- -2 
                  (others => 'X') when others; 
end Behavioral;