----------------------------------------------------------------------------------
--
-- Equivale al BLOCCO 1: struttura ad albero di CSA
--
-- sommando 3 ingressi ad 8 bit in uscita come risultato della somma 10 bit
-- ricapitolando: n bit unsigned diventa n+2 bit unsigned
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Costanti.all; 

entity CSA is
    generic(dimCSA: integer := dimDataImg);
    Port(in1, in2, in3: in std_logic_vector(dimCSA-1 downto 0);    --Bit in ingresso da somma (dim 8 unsigned)
         SP: out std_logic_vector(dimCSA downto 0);                --Somma Parziale (SP) (dim 10 complemento a 2)
         PV: out std_logic_vector(dimCSA downto 0));               --Prodotto Vettoriale (PV) (dim 10 complemento a 2)
end CSA;

architecture Behavioral of CSA is

component FA is
    Port(in1, in2: in std_logic;   --Bit in ingresso da somma
         Cin: in std_logic;        --Carry in Ingresso
         sumFA: out std_logic;     --Risultato della somam tra i due ingressi
         Cout: out std_logic);     --Carry in Uscita
end component;

-- Internal signal declaration
-- si tratta di segnali d'appoggio necc. per poi effettuare lo shift
signal SPs: std_logic_vector(dimCSA-1 downto 0); -- (dimensione 8 bit)
signal PVs: std_logic_vector(dimCSA-1 downto 0); -- (dimensione 8 bit)

begin

generateCSA:
for ii in 0 to dimCSA-1 generate
FA_ii: FA port map(in1 => in1(ii), in2 => in2(ii), Cin => in3(ii), sumFA => SPs(ii), Cout => PVs(ii));
end generate;

-- SP shift dx
-- si aggiunge la cifra uguale all'ultima
SP <= '0' & SPs;    -- si aggiunge 0 siccome i numeri dataImg sono positivi

-- PV shift sx
-- si aggiunge '0'
PV <= PVs & '0';

end Behavioral;