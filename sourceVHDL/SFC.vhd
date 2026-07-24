----------------------------------------------------------------------------------
--
-- ADDER TREE
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Costanti.all; 

entity SFC is
    generic(dimAT: integer := 20);
    Port(in1, in2, in3: in std_logic_vector(dimAT-1 downto 0);      -- Bit in ingresso da somma (dim 8 unsigned)
         outAT: out std_logic_vector(dimAT+2 downto 0));                 -- risultato (dim 11 unsigned)
end SFC;

-- Nel modulo SFC
architecture Behavioral of SFC is

-- dimAT = 20
signal in1Ext, in2Ext, in3Ext: std_logic_vector(dimAT downto 0); -- 21 bit
signal SP1, PV1: std_logic_vector(dimAT+1 downto 0);             -- 22 bit
    
-- Segnali estesi per RCA (11 bit se dimAT=8)
signal SP1_ext, PV1_ext: std_logic_vector(dimAT+2 downto 0);

signal SumS: std_logic_vector(dimAT+3 downto 0);                -- 23 bit (per sicurezza)

begin
-- 1. Estensione segno ingressi (fondamentale per Signed)
in1Ext <= in1(dimAT-1) & in1;
in2Ext <= in2(dimAT-1) & in2;
in3Ext <= in3(dimAT-1) & in3;

-- 2. CSA (3 Operandi -> 2 Operandi)
SFCcsa: entity work.CSAsigned generic map(dimCSA => dimAT+1) port map(in1 => in1Ext, in2 => in2Ext, in3 => in3Ext, SP => SP1, PV => PV1);

--------------------------------------------------------------------------
-- LOGICA DI GESTIONE SEGNO (Fondamentale per RCA)
--------------------------------------------------------------------------
-- Estensione di segno classica (duplico l'MSB)
SP1_ext <= SP1(dimAT+1) & SP1; 
PV1_ext <= PV1(dimAT+1) & PV1; 

-- 3. RCA (Somma finale)
-- Se SP1 e PV1 sono 22 bit, impostiamo dimRCA a 22
SFCrca: entity work.RCAnoOut generic map(dimRCA => dimAT+3) port map(in1 => SP1_ext, in2 => PV1_ext, outRCA => SumS);

-- 4. Uscita (Tronchiamo i bit di overflow se non necessari)
outAT <= SumS(dimAT+2 downto 0); -- Ritorna 22 bit

end Behavioral;