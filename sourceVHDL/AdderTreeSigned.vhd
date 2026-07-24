----------------------------------------------------------------------------------
--
-- ADDER TREE
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AdderTreeSigned is
    generic(dimAT: integer := 20);
    Port(in1, in2, in3, in4: in std_logic_vector(dimAT-1 downto 0);      -- Bit in ingresso da somma (dim 8 unsigned)
         outAT: out std_logic_vector(dimAT+2 downto 0));                 -- risultato (dim 11 unsigned)
end AdderTreeSigned;

architecture Behavioral of AdderTreeSigned is

component CSAsigned is
    generic(dimCSA: integer := dimAT);
    Port(in1, in2, in3: in std_logic_vector(dimCSA-1 downto 0);    --Bit in ingresso da somma (dim 8 unsigned)
         SP: out std_logic_vector(dimCSA downto 0);                --Somma Parziale (SP) (dim 10 complemento a 2)
         PV: out std_logic_vector(dimCSA downto 0));               --Prodotto Vettoriale (PV) (dim 10 complemento a 2)
end component;

component RCAnoOut is
    generic(dimRCA: integer := dimAT+2);
    Port(in1, in2: in std_logic_vector(dimRCA-1 downto 0);    -- Bit in ingresso da somma (dim 10 unsigned)
         outRCA: out std_logic_vector(dimRCA downto 0));      -- risultato (dim 11 unsigned)
end component;

component FA is
    Port(in1, in2: in std_logic;   --Bit in ingresso da somma
         Cin: in std_logic;        --Carry in Ingresso
         sumFA: out std_logic;     --Risultato della somam tra i due ingressi
         Cout: out std_logic);     --Carry in Uscita
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
CSAsigned generic map(dimCSA => dimAT) port map(in1 => in1, in2 => in2, in3 => in3, SP => SP1, PV => PV1);
----------------------------
-- BLOCCO 2(Liv2): CSA 
-- 3 input: SP1+PV1+in4
-- uscita: SP2 e PV2
----------------------------
in4_extended <= in4(dimAT-1) & in4;

BLOCCO2:
CSAsigned generic map(dimCSA => dimAT+1) port map(in1 => SP1, in2 => PV1, in3 => in4_extended, SP => SP2, PV => PV2);
----------------------------
-- BLOCCO 3(Liv3): RCA 
-- 2 input: SP2+PV2
-- uscita: outAT
----------------------------
BLOCCO3:
RCAnoOut generic map(dimRCA => dimAT+2) port map(in1 => SP2, in2 => PV2, outRCA => SumS);

outAT <= SumS;

end Behavioral;