----------------------------------------------------------------------------------
--
-- Equivale al BLOCCO 3: struttura ad albero di CSA
--
-- sommando 2 ingressi ad 10 bit (SP)&(VR)
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;    
use IEEE.NUMERIC_STD.ALL;

entity RCAnoOut is
    generic(dimRCA: integer := 10);
    Port(in1, in2: in std_logic_vector(dimRCA-1 downto 0);    -- Bit in ingresso da somma (dim 10 unsigned)
         outRCA: out std_logic_vector(dimRCA downto 0));      -- risultato (dim 11 unsigned)
end RCAnoOut;

architecture Behavioral of RCAnoOut is

component FA is
    Port(in1, in2: in std_logic;   --Bit in ingresso da somma
         Cin: in std_logic;        --Carry in Ingresso
         sumFA: out std_logic;     --Risultato della somam tra i due ingressi
         Cout: out std_logic);     --Carry in Uscita
end component;

-- Internal signal declaration
signal Cins: std_logic_vector(dimRCA downto 0);      -- (dimensione 10 bit)

begin

Cins(0) <= '0'; 

generateRCA:
for ii in 0 to dimRCA-1 generate
FA_ii: FA port map(in1 => in1(ii), in2 => in2(ii), Cin => Cins(ii), sumFA => outRCA(ii), Cout => Cins(ii+1));
end generate;

outRCA(dimRCA) <= Cins(dimRCA);

end Behavioral;