library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_textio.all;
library STD;
use STD.textio.all;

use work.Costanti.all;

entity TB_ConvolutionSystem is
end TB_ConvolutionSystem;

architecture Behavioral of TB_ConvolutionSystem is

------------------------------------------------------------------------
-- COMPONENT UNDER TEST
------------------------------------------------------------------------
component ConvolutionSystem is
Port(
    globalCLK : in std_logic;
    reset     : in std_logic;

    dataRead  : in std_logic_vector(dimDataImg-1 downto 0);
    enable    : in std_logic;
    filterSel : in std_logic_vector(2 downto 0);

    wr_dataNoSaturation : out std_logic_vector(dimDataImg+14 downto 0);
    wr_data             : out std_logic_vector(dimDataImg-1 downto 0);
    rdy_toWr            : out std_logic;
    done                : out std_logic
);
end component;

------------------------------------------------------------------------
-- SIGNALS
------------------------------------------------------------------------
signal clk   : std_logic := '0';
signal rst   : std_logic := '0';

signal enableS : std_logic := '0';
-- ==========================================================
-- INSERISCI IL FILTRO CHE PREFERISCI
-- Leggenda:
-- Codifica dei filtri (filter_sel):
--   "000" ? Filtro Gaussiano (Blur)       | Somma pesi = 16 ? shift 4
--   "001" ? Filtro Identità
--   "010" ? Edge Detection (tutti -1)
--   "011" ? Sharpening
--   "100" ? Laplaciano 8-neighbors
--   "101" ? Laplaciano 4-neighbors
--
-- In caso di valore non valido di filter_sel viene selezionato
-- automaticamente il filtro Identità.
-- ==========================================================
signal filterSelS : std_logic_vector(2 downto 0) := "001";

signal dataReadS : std_logic_vector(dimDataImg-1 downto 0);

signal wr_dataS     : std_logic_vector(dimDataImg-1 downto 0);
signal wr_dataNoSatS: std_logic_vector(dimDataImg+14 downto 0);

signal rdy_toWrS : std_logic;
signal doneS     : std_logic;

constant CLK_PERIOD : time := 10 ns;

------------------------------------------------------------------------
-- FILE PATHS
------------------------------------------------------------------------
constant FILE_IN  : string := "C:\Users\rebec\Documents\Progetto SD\lena64.txt";
constant FILE_OUT_SAT : string := "C:\Users\rebec\Documents\Progetto SD\outputLena64.txt";
constant FILE_OUT_NOSAT : string := "C:\Users\rebec\Documents\Progetto SD\outNoSatLena64.txt";

begin

------------------------------------------------------------------------
-- DUT INSTANTIATION
------------------------------------------------------------------------
UUT: ConvolutionSystem
port map(
    globalCLK => clk,
    reset     => rst,
    dataRead  => dataReadS,
    enable    => enableS,
    filterSel => filterSelS,

    wr_dataNoSaturation => wr_dataNoSatS,
    wr_data             => wr_dataS,
    rdy_toWr            => rdy_toWrS,
    done                => doneS
);

------------------------------------------------------------------------
-- CLOCK GENERATION
------------------------------------------------------------------------
clk_process: process
begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
end process;

------------------------------------------------------------------------
-- INPUT IMAGE READING
------------------------------------------------------------------------
ead_image: process
    file f_in : text;                    -- File di input
    variable l : line;                   -- Riga letta dal file
    variable px : integer;               -- Pixel temporaneo
begin
    file_open(f_in, FILE_IN, read_mode); -- Apri file in lettura

    rst <= '1';                          -- Attiva reset
    enableS <= '0';                       -- Disabilita DUT
    wait for 50 ns;                       -- Attendi 50 ns

    rst <= '0';                          -- Disattiva reset
    enableS <= '1';                       -- Abilita DUT

    while not endfile(f_in) loop         -- Loop fino a fine file
        readline(f_in, l);               -- Leggi una riga
        read(l, px);                     -- Leggi pixel intero
        dataReadS <= std_logic_vector(to_unsigned(px, dimDataImg)); -- Assegna al DUT
        wait until rising_edge(clk);      -- Sincronizza col clock
    end loop;

    enableS <= '0';                       -- Disabilita input al DUT
    file_close(f_in);                     -- Chiudi file
    wait;                                 -- Ferma processo
end process;

------------------------------------------------------------------------
-- OUTPUT WRITING (SYNC WITH rdy_toWr, STOP ON done)
------------------------------------------------------------------------
write_results: process
    file f_sat   : text open write_mode is FILE_OUT_SAT;
    file f_nosat : text open write_mode is FILE_OUT_NOSAT;

    variable l_sat   : line;
    variable l_nosat : line;
    variable written : integer := 0;    -- contatore scrittura
begin
    -- aspetta fine reset
    wait until rst = '0';

    -- ciclo fino a DONE
    while doneS = '0' loop
        wait until rising_edge(clk);

        if rdy_toWrS = '1' then
            -- OUTPUT SATURATO (unsigned 0..255)
            write(l_sat, to_integer(unsigned(wr_dataS)));
            writeline(f_sat, l_sat);

            -- OUTPUT NON SATURATO (signed, può essere negativo)
            write(l_nosat, to_integer(signed(wr_dataNoSatS)));
            writeline(f_nosat, l_nosat);

            written := written + 1;
        end if;
    end loop;

    -- Scrittura finale se rimasto qualche dato
    if rdy_toWrS = '1' then
        write(l_sat, to_integer(unsigned(wr_dataS)));
        writeline(f_sat, l_sat);
        write(l_nosat, to_integer(unsigned(wr_dataNoSatS)));
        writeline(f_nosat, l_nosat);
        written := written + 1;
    end if;

    -- Chiude i file
    file_close(f_sat);
    file_close(f_nosat);

end process;
end Behavioral;