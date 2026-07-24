library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Costanti.all;

entity Controller is
    Port(clk, rst: in std_logic;
        qIn: in std_logic_vector(12 downto 0);

        row: out integer range 0 to mRow-1;
        col: out integer range 0 to nCol-1;

        rdyWindow: out std_logic;
        endImg: out std_logic);
end Controller;

architecture Behavioral of Controller is

signal contS : integer;


-- Latenza per finestra 3x3
constant Latenza : integer := nCol + 2;
-- Fine dati (come nel primo codice)
constant endDati : integer := (nCol * mRow) + Latenza;

begin

contS <= to_integer(unsigned(qIn));

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            row <= 0;
            col <= 0;
            
            rdyWindow <= '0';
            endImg <= '0';
        else
            -- Avanza SOLO quando la finestra è valida
            if((contS >= Latenza)and(contS < endDati))then
            -- INDICE = contS - Latenza
                -- divisione intera
                -- ossia 14/5 = 2
                row <= (contS - Latenza) / nCol;
                -- resro della divisione
                -- ossia 14/5 = 4 
                col <= (contS - Latenza) mod nCol;
                rdyWindow <= '1';
            else
                rdyWindow <= '0';
            end if;
            
            -- Gestione fine dati
            if(contS >= endDati)then
                endImg <= '1';
            else
                endImg <= '0';
            end if;
                   
        end if;
    end if;
end process;

end Behavioral;