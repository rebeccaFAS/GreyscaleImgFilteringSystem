library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Adder_4 is
    generic( n : integer);
    port(A, B, C, D : in std_logic_vector(n-1 downto 0);
         Cin_RCA : in std_logic;
         S : out std_logic_vector(n+1 downto 0));  -- Cambiato da n+2 a n+1
end Adder_4;

architecture Behavioral of Adder_4 is
component RCA is
     generic( n : integer);
     port(a_rca, b_rca : in std_logic_vector(n-1 downto 0);
		 cin_rca : in std_logic;
		 s_rca : out std_logic_vector(n downto 0));
end component;

signal SommaP1, SommaP2 : std_logic_vector(n downto 0);

begin
-- Prima somma: A + B
Adder1: RCA generic map(n => n) port map(A, B, '0', SommaP1);
-- Seconda somma: C + D  
Adder2: RCA generic map(n => n) port map(C, D, '0', SommaP2);
-- Somma finale: (A+B) + (C+D)
Adder3: RCA generic map(n => n+1) port map(SommaP1, SommaP2, '0', S);

end Behavioral;