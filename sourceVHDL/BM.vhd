library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Costanti.all; 

entity BM is
generic(dimMD: integer := 10;                                 -- (dim 11 bit)
        dimMR: integer := 7);                                 -- (dim 8 bit)
Port(MD: in std_logic_vector(dimMD downto 0);                 -- moltiplicando  (MD) 11 bits 
     MR: in std_logic_vector(dimMR downto 0);                 -- moltiplicatore (MR) 8 bits 
     outBM: out std_logic_vector(dimMD+dimMR+2 downto 0));    -- risultato della moltiplicazione 19 bit 
end BM;

architecture Behavioral of BM is

-- Si utilizza per effettuare l'estenzione con '0' al LSB
-- affinchè la dimensione sia un multiplo di 3
signal MRs: std_logic_vector(dimMR+1 downto 0);   -- (dim 9)

----------------------------------------------------------------------------------------------------------------------
-- BLOCCO Partial Product

-- Si dichiara un signal per estendere MD
signal MDs: std_logic_vector(dimMD downto 0);       -- (dim 11)
-- Si dichiara per invertire i bit da 0 ad 1 (e viceversa)
signal notMD: std_logic_vector(dimMD downto 0);     -- (dim 11)
signal comp2: std_logic_vector(dimMD+1 downto 0);     -- (dim 12)
-- Si dichiara il vettore "000...001" utile a +1
signal tempOne: std_logic_vector(dimMD downto 0) := (0 => '1', others => '0');     -- (dim 12)

-- Estensione per RCA signed
signal ExtnotMD: std_logic_vector(dimMD+1 downto 0);     -- (dim 12)
signal ExttempOne: std_logic_vector(dimMD+1 downto 0);
signal Extcomp2: std_logic_vector(dimMD+2 downto 0);     -- (dim 13)

-- Valori partial products: "ExA: 1; DA: 2; MA: -1; MDA: -2"
signal ExAs, DAs, MAs, MDAs: std_logic_vector(dimMD+2 downto 0);        -- (dim 13)
signal zeros: std_logic_vector(dimMD+2 downto 0) := (others => '0');    -- (dim 13)
----------------------------------------------------------------------------------------------------------------------
-- Booth Encoder

-- matrix 4x4 di elementi 3 bit
type codeArray is array (0 to k_Kernel) of std_logic_vector(k_Kernel-1 downto 0);
signal Cs: codeArray;

-- Multiplexer determina in base a code quale dei 5 segnali far passare
type mux_out_array is array (0 to k_Kernel) of std_logic_vector(dimMD+2 downto 0); -- 13 bit
signal PPs : mux_out_array;

signal inPP1, inPP2, inPP3, inPP4: std_logic_vector(dimMD+8 downto 0);   -- 19 dim

signal SumInternal: std_logic_vector(dimMD+11 downto 0);

begin

---------------------------------------------------------------------------------------------------------
-- BLOCCO Partial Product
MDs <= MD; -- (dim 11)
-- 1. Calcolo del complemento a 2
-- 1.1 Invertire 0 con 1 (e viceversa)
notMD <= not(MDs);  -- (dim 11)

-- Estensione
ExtnotMD <= notMD(dimMD) & notMD;
ExttempOne <= tempOne(dimMD) & tempOne;
-- 1.2 Si somma "000...1"
RCA: entity work.RCAnoOut generic map(dimRCA => dimMD+2) port map(in1 => ExtnotMD, in2 => ExttempOne, outRCA => Extcomp2);
comp2 <= Extcomp2(dimMD+1 downto 0);

-- 2. Calcolo i prodotti parziali con estensione di segno corretta (13 bit)
-- ExA (+1 * MD): Estendo replicando il bit di segno MD(12)
ExAs <= MDs(dimMD ) & MDs(dimMD ) & MDs;
    
-- DA (+2 * MD): Shift a sinistra di 1. Il bit basso è 0.
DAs <=  MDs(dimMD ) & MDs & '0';
    
-- MA (-1 * MD): Uso il valore comp2 e replico il suo bit di segno
MAs <= comp2(dimMD +1) & comp2;
    
-- MDA (-2 * MD): Shift a sinistra del complemento a 2
MDAs <= comp2 & '0'; -- (dim 13) ossia 12 -> 0
---------------------------------------------------------------------------------------------------------
-- BLOCCO BOTH ENCODER + MUX 5to1
MRs <= MR & '0';
-- Istanziamento BE
generateBE:
for ii in 0 to k_Kernel generate
BE_ii: entity work.BE generic map(k_Kernel) port map(MR => MRs((ii*2+2) downto ii*2), code => Cs(ii));
MUX_ii: entity work.MUX5to1 generic map(dimMD+2) port map(ExA => ExAs, DA => DAs, MA => MAs, MDA => MDAs, zero => zeros, Sel => Cs(ii), Outmux => PPs(ii));
end generate;

-- 4. Estensione Segno e Shift per l'Adder Tree (dim 20)
-- PP0: shift 0
inPP1 <= PPs(0)(dimMD+2) & PPs(0)(dimMD+2) & PPs(0)(dimMD+2) & PPs(0)(dimMD+2) & PPs(0)(dimMD+2) & PPs(0)(dimMD+2) & PPs(0);
-- PP1: shift 2
inPP2 <= PPs(1)(dimMD+2) & PPs(1)(dimMD+2) & PPs(1)(dimMD+2) & PPs(1)(dimMD+2) & PPs(1) & "00";
-- PP2: shift 4
inPP3 <= PPs(2)(dimMD+2) & PPs(2)(dimMD+2) & PPs(2) & "0000";
-- PP3: shift 6
inPP4 <= PPs(3) & "000000"; -- dim 13+6 = 19

-- entrano in AdderTree 20-1=19 escono 22
BM_Sum: entity work.AdderTreeSigned generic map(dimMD+9) port map(in1 => inPP1, in2 => inPP2, in3 => inPP3, in4 => inPP4, outAT => SumInternal);

outBM <= SumInternal(dimMD+9 downto 0);

end Behavioral;