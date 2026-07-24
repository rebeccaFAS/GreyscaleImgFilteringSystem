----------------------------------------------------------------------------------
-- ADDER TREE
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Costanti.all; 

entity AdderTree is
    generic(dimAT: integer := dimDataImg);
    Port(in1, in2, in3, in4: in std_logic_vector(dimAT-1 downto 0);      -- Bit in ingresso da somma (dim 8 unsigned)
         outAT: out std_logic_vector(dimAT+2 downto 0));                 -- risultato (dim 11 unsigned)
end AdderTree;

architecture Behavioral of AdderTree is

component CSA is
    generic(dimCSA: integer := dimDataImg);
    Port(in1, in2, in3: in std_logic_vector(dimCSA-1 downto 0);    --Bit in ingresso da somma (dim 8 unsigned)
         SP: out std_logic_vector(dimCSA downto 0);                --Somma Parziale (SP) (dim 10 complemento a 2)
         PV: out std_logic_vector(dimCSA downto 0));               --Prodotto Vettoriale (PV) (dim 10 complemento a 2)
end component;

component RCAnoOut is
    generic(dimRCA: integer := 10);
    Port(in1, in2: in std_logic_vector(dimRCA-1 downto 0);    -- Bit in ingresso da somma (dim 10 unsigned)
         outRCA: out std_logic_vector(dimRCA downto 0));      -- risultato (dim 11 unsigned)
end component;

-- Internal signal declaration
-- si tratta di segnali d'appoggio necc. per interconnetere i CSA insieme
-- relativi a BLOCCO1 -->  BLOCCO2
signal SP1: std_logic_vector(dimAT downto 0); -- (dimensione 9 bit)
signal PV1: std_logic_vector(dimAT downto 0); -- (dimensione 9 bit)

-- relativi a BLOCCO2 -->  BLOCCO3
signal SP2: std_logic_vector(dimAT+1 downto 0); -- (dimensione 10 bit)
signal PV2: std_logic_vector(dimAT+1 downto 0); -- (dimensione 10 bit)
signal in4_extended: std_logic_vector(dimAT downto 0); -- (dimensione 9 bit)

-- relativi out di BLOCCO3
signal SumS: std_logic_vector(dimAT+2 downto 0);  -- signal interni di somma parziale e vettore riporti

begin

----------------------------
-- BLOCCO 1(Liv1): CSA 
-- 3 input: in1+in2+in3
-- uscita: SP1 e PV1
----------------------------
BLOCCO1:
CSA generic map(dimDataImg) port map(in1 => in1, in2 => in2, in3 => in3, SP => SP1, PV => PV1);
----------------------------
-- BLOCCO 2(Liv2): CSA 
-- 3 input: SP1+PV1+in4
-- uscita: SP2 e PV2
----------------------------
in4_extended <= '0' & in4;

BLOCCO2:
CSA generic map(dimDataImg+1) port map(in1 => SP1, in2 => PV1, in3 => in4_extended, SP => SP2, PV => PV2);
----------------------------
-- BLOCCO 3(Liv3): RCA 
-- 2 input: SP2+PV2
-- uscita: outAT
----------------------------
BLOCCO3:
RCAnoOut generic map(dimDataImg+2) port map(in1 => PV2, in2 => SP2, outRCA => SumS);

outAT <= SumS;

end Behavioral;