----------------------------------------------------------------------------------
-- Il componente superiore
-- contiene BM - CM - componenti aggiuntivi
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Costanti.all; 

entity ConvolutionSystem is
Port(globalCLK, reset: in std_logic;

     dataRead: in std_logic_vector(dimDataImg-1 downto 0);  -- dato in ingresso
     
     enable: in std_logic;  -- dipende da FSM
     filterSel: in std_logic_vector(2 downto 0);    -- dipende dall'utente (TB)
     
     wr_dataNoSaturation: out std_logic_vector(dimDataImg+14 downto 0);    -- Output no saturazione
     wr_data: out std_logic_vector(dimDataImg-1 downto 0);      -- Output con saturazione
     rdy_toWr: out std_logic;
     done: out std_logic);  -- segnale che indica la fine del processo
end ConvolutionSystem;

architecture Behavioral of ConvolutionSystem is

-- Dichiarazione segnal interni (generalmente indicati con "S" o "s")
-- W0(SF) -> W0s -> W0(CM)
-- WL(SF) -> WLs -> WL(CM)
-- WC(SF) -> WCs -> WC(CM)
signal W0s, WLs, WCs: std_logic_vector(7 downto 0);
-- shift_val(SF) -> shift_valS -> shift_val(CdN)
signal shift_valS:integer range 0 to 4;

signal p00s, p01s, p02s: std_logic_vector(dimDataImg-1 downto 0);
signal p10s, p11s, p12s: std_logic_vector(dimDataImg-1 downto 0);
signal p20s, p21s, p22s: std_logic_vector(dimDataImg-1 downto 0);

signal window_validBMs: std_logic;
signal abilitaBMs, abilitaCMs: std_logic;
signal endImgBMs: std_logic;

signal resultConv:  std_logic_vector(dimDataImg+14 downto 0);

begin

EFSM: entity work.SystemFSM
Port map(clk => globalCLK, rst => reset,
         enable => enable,
         window_valid => window_validBMs,
         endImgfromBM => endImgBMs,
         abilitaBM => abilitaBMs,
         abilitaCM => abilitaCMs,
         valid_data_out => rdy_toWr,
         system_done => done);

SelettoreFiltro: entity work.FilterSelectorModule
                 port map(filter_sel => filterSel,  -- il segnale di controllo Sel proviene dall'esterno (TB)
                 W0 => W0s,
                 WL => WLs,
                 WC => WCs,
                 shift_val => shift_valS);

BM: entity work.BufferModule
port map(clk => globalCLK, rst => reset,
        wr_enableBM => abilitaBMs,
        dataIn => dataRead,
        
        -- Uscite verso l'esterno
        p00 => p00s, p01 => p01s, p02 => p02s,
        p10 => p10s, p11 => p11s, p12 => p12s,
        p20 => p20s, p21 => p21s, p22 => p22s,
        
        windowValid => window_validBMs,
        endImgBM => endImgBMs);

CM: entity work.ConvolutionModule
port map(clk => globalCLK, rst => reset,
         wr_enableCM => abilitaCMs,
 
         W0 => W0s,
         WL => WLs,
         WC => WCs,
         
         p00 => p00s, p01 => p01s, p02 => p02s,
         p10 => p10s, p11 => p11s, p12 => p12s,
         p20 => p20s, p21 => p21s, p22 => p22s,
         
         data_out => resultConv);

REGNoSat: entity work.Registro generic map(dimDataImg+15) port map(resultConv, globalCLK, reset, abilitaCMs, wr_dataNoSaturation);

SM: entity work.SaturationModule 
port map(clk => globalCLK, rst => reset,
         shift_val => shift_valS,
         data_in => resultConv,
         data_valid => abilitaCMs,
         data_out => wr_data);

end Behavioral;