library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Costanti.all;

entity BufferLine is
   port(clk, rst: in std_logic;
        wr_en: in std_logic;
        dataIn: in std_logic_vector(dimDataImg-1 downto 0);

        row: in integer range 0 to mRow-1;
        col: in integer range 0 to nCol-1;
        
        validIn: in std_logic;
        
        p00, p01, p02: out std_logic_vector(dimDataImg-1 downto 0);
        p10, p11, p12: out std_logic_vector(dimDataImg-1 downto 0);
        p20, p21, p22: out std_logic_vector(dimDataImg-1 downto 0));
end BufferLine;

architecture Behavioral of BufferLine is

type shiftReg is array(dimBuffer-1 downto 0) of std_logic_vector(dimDataImg-1 downto 0);
signal lineBuffer: shiftReg := (others => (others => '0'));

-- Padding Zero
constant ZERO: std_logic_vector(dimDataImg-1 downto 0) := (others => '0');

begin

process(clk, rst)
begin
    if(rising_edge(clk))then
        if(rst = '1')then
            lineBuffer <= (others => (others => '0'));
        elsif(wr_en = '1')then
            lineBuffer(0) <= dataIn;
            for j in 1 to dimBuffer-1 loop
                lineBuffer(j) <= lineBuffer(j-1);   -- shift dei dati
            end loop;
        end if;
    end if;
end process;

process(validIn, row, col, lineBuffer)
begin
    if(validIn = '1')then
        p11 <= lineBuffer(nCol+1); -- Pixel centrale (Raw)

        -- Riga Nord
        if (row = 0 or col = 0) then p00 <= ZERO; else p00 <= lineBuffer(2*nCol + 2); end if;
        if (row = 0) then p01 <= ZERO; else p01 <= lineBuffer(2*nCol + 1); end if;
        if (row = 0 or col = 63) then p02 <= ZERO; else p02 <= lineBuffer(2*nCol); end if;

        -- Riga Centro
        if (col = 0)  then p10 <= ZERO; else p10 <= lineBuffer(nCol + 2); end if;
        -- qui pixel centrale
        if (col = 63) then p12 <= ZERO; else p12 <= lineBuffer(nCol); end if;

        -- Riga Sud
        if (row = 63 or col = 0) then p20 <= ZERO; else p20 <= lineBuffer(2); end if;
        if (row = 63) then p21 <= ZERO; else p21 <= lineBuffer(1); end if;
        if (row = 63 or col = 63) then p22 <= ZERO; else p22 <= lineBuffer(0); end if;
    else
        p00 <= ZERO; p01 <= ZERO; p02 <= ZERO;
        p10 <= ZERO; p11 <= ZERO; p12 <= ZERO;
        p20 <= ZERO; p21 <= ZERO; p22 <= ZERO;
    end if;
end process;

end Behavioral;