library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RCA is
	generic( n : integer);
	port(a_rca, b_rca : in std_logic_vector(n-1 downto 0);
		 cin_rca : in std_logic;
		 s_rca : out std_logic_vector(n downto 0));
end RCA;

architecture Behavioral of RCA is

component FullAdder is
	port(a, b, c : in std_logic;
		 s, cout : out std_logic);
end component;
signal C : std_logic_vector(n downto 0);
	
begin
C(0) <= Cin_rca;
for_gen : for i in 0 to n generate       
	if_gen : if( i < n )generate 
		FA : FullAdder port map ( a_rca(i), b_rca(i), C(i), s_rca(i), C(i+1));--somma per i bit meno significativi
   end generate if_gen;
	if_gen2 : if( i = n )generate 
		FA_MSB : FullAdder port map( a_rca(i-1), b_rca(i-1), C(i), s_rca(i), open); -- gestione del bit piu significativo
	end generate if_gen2;
end generate for_gen;
		
end Behavioral;
