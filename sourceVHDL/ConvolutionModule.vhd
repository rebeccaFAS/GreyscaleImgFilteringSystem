library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Costanti.all; 

entity ConvolutionModule is
   Port(clk, rst: in  std_logic;
           
        wr_enableCM: in  std_logic;
        
        W0, WL, WC: in std_logic_vector(dimDataImg-1 downto 0); -- dim 8
        
        p00, p01, p02: in std_logic_vector(dimDataImg-1 downto 0);
        p10, p11, p12: in std_logic_vector(dimDataImg-1 downto 0);
        p20, p21, p22: in std_logic_vector(dimDataImg-1 downto 0);
        
        data_out: out std_logic_vector(dimDataImg+14 downto 0));
end ConvolutionModule;

architecture Behavioral of ConvolutionModule is

component BM is
generic(dimMD: integer := 10;                                   -- (dim 11 bit)
        dimMR: integer := 7);                                   -- (dim 8 bit)
Port(MD: in std_logic_vector(dimMD downto 0);                 -- moltiplicando  (MD) 11 bits 
     MR: in std_logic_vector(dimMR downto 0);                 -- moltiplicatore (MR) 8 bits 
     outBM: out std_logic_vector(dimMD+dimMR+2 downto 0));        -- risultato della moltiplicazione 20 bit 
end component;

component AdderTree is
    generic(dimAT: integer := dimDataImg);
    Port(in1, in2, in3, in4: in std_logic_vector(dimAT-1 downto 0);      -- Bit in ingresso da somma (dim 8 unsigned)
         outAT: out std_logic_vector(dimAT+2 downto 0));                 -- risultato (dim 11 unsigned)
end component;

component SFC is
    generic(dimAT: integer := 20);
    Port(in1, in2, in3: in std_logic_vector(dimAT-1 downto 0);      -- Bit in ingresso da somma (dim 8 unsigned)
         outAT: out std_logic_vector(dimAT+2 downto 0));                 -- risultato (dim 11 unsigned)
end component;

-- Dichiarazione segnali interni
signal outBM0, outBML, outBMC: std_logic_vector(dimDataImg+11 downto 0);
signal outAT1, outAT2: std_logic_vector(dimDataImg+2 downto 0);
-- Registri relativi
signal regBM0, regBML, regBMC : std_logic_vector(dimDataImg+11 downto 0);
signal regAT1, regAT2 : std_logic_vector(dimDataImg+2 downto 0);

signal pC: std_logic_vector(dimDataImg+2 downto 0);

-- STADIO 1: Registri di ingresso e somme parziali
signal reg_pC : std_logic_vector(dimDataImg+2 downto 0);

-- STADIO 3: Registro di uscita finale
signal outSFC: std_logic_vector(dimDataImg+14 downto 0);

begin
-----------------------------------------------------------------------------------------------

-- ADDER SECTION

-- BLOCCO1: relativo a [p00+p02+p20+p22]*WC
AT1: AdderTree port map(in1 => p00, in2 => p02, in3 => p20, in4 => p22, outAT => outAT1);

-- BLOCCO2: relativo a [p01+p12+p21+p10]*WL
AT2: AdderTree port map(in1 => p01, in2 => p12, in3 => p21, in4 => p10, outAT => outAT2);

pC <= "000" & p11;  -- tre 000 siccome è a forza positivo

-- REGISTRI ADDER SECTION
REG_AT1: entity work.Registro generic map(dimDataImg+3) port map(outAT1, clk, rst, wr_enableCM, regAT1);
REG_AT2: entity work.Registro generic map(dimDataImg+3) port map(outAT2, clk, rst, wr_enableCM, regAT2);
REGpC:  entity work.Registro generic map(dimDataImg+3) port map(pC, clk, rst, wr_enableCM, reg_pC);

--  MULTIPLIER SECTION

-- BLOCCO 0: relativo a  p11*W0
-- Istanziamento BM
BM0: BM port map(MD => reg_pC, MR => W0, outBM => outBM0);

-- BLOCCO1: relativo a [p00+p02+p20+p22]*WC
BM1: BM port map(MD => regAT1, MR => WC, outBM => outBML); 

-- BLOCCO2: relativo a [p01+p12+p21+p10]*WL
BM2: BM port map(MD => regAT2, MR => WL, outBM => outBMC);

REG_BM0: entity work.Registro generic map(dimDataImg+12) port map(outBM0, clk, rst, wr_enableCM, regBM0);
REG_BML: entity work.Registro generic map(dimDataImg+12) port map(outBML, clk, rst, wr_enableCM, regBML);
REG_BMC: entity work.Registro generic map(dimDataImg+12) port map(outBMC, clk, rst, wr_enableCM, regBMC);
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------

-- BLOCCO3: sum for convolution 3 input [outBM0+outAT1+outAT2]
SFC0: SFC generic map(dimDataImg+12)  port map(in1 => regBM0, in2 => regBML, in3 => regBMC, outAT => outSFC);

REGSFC: entity work.Registro generic map(dimDataImg+15) port map(outSFC, clk, rst, wr_enableCM, data_out);

end Behavioral;