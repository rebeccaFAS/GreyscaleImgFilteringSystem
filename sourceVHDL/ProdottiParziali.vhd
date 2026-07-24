library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.std_logic_signed.all;

entity Prodotti_parziali is
    generic (n:integer);
    Port (A : in std_logic_vector (n-1 downto 0);
          ExA,DA, MA, MDA : out std_logic_vector (n+1 downto 0));
end Prodotti_parziali;

architecture Behavioral of Prodotti_parziali is

component RCA_PP is
     generic(nb: integer);
     Port ( A, B : in std_logic_vector (n-1 downto 0);
            cin : in std_logic;
            cout : out std_logic;
            Ris : out std_logic_vector (n downto 0));
end component;

signal zeri: std_logic_vector (n-1 downto 0):=(others=>'0');
signal negato: std_logic_vector (n downto 0);
signal not_A: std_logic_vector (n-1 downto 0);

begin

    not_A <= not(A);
    Neg: RCA_PP generic map (n) port map (not_A,zeri ,'1',open,negato); -- come se fa not A+0000..1
    ExA <=A(n-1)& A(n-1)&A; -- A
    DA<= A(n-1)& A&'0';     -- 2A
    MA <= negato(n)&negato ;-- -A
    MDA <= negato&'0';      -- -2A
    
end Behavioral;