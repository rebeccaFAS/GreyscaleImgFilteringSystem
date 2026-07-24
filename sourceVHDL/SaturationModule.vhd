library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Costanti.all; 

entity SaturationModule is
Port(clk, rst: in  std_logic;
     shift_val: in  integer range 0 to 4; 
     data_in: in  std_logic_vector(dimDataImg+14 downto 0); 
     data_valid: in  std_logic;
     data_out: out std_logic_vector(dimDataImg-1 downto 0));
end SaturationModule;

architecture Behavioral of SaturationModule is
signal shifted_data : std_logic_vector(22 downto 0);
signal overflow_bits : std_logic;
begin

-- 1. SHIFT MANUALE (Normalizzazione)
-- Gestiamo shift_val in modo dinamico. 
-- Concateniamo il bit di segno per mantenere il valore Signed (Arithmetic Shift).
process(data_in, shift_val)
begin
    case shift_val is
        when 4 => -- Caso Gaussiano: divido per 16
            shifted_data <= (22 downto 19 => data_in(22)) & data_in(22 downto 4);
        when 3 => -- Eventuale divisione per 8
            shifted_data <= (22 downto 20 => data_in(22)) & data_in(22 downto 3);
        when 2 => -- Eventuale divisione per 4
            shifted_data <= (22 downto 21 => data_in(22)) & data_in(22 downto 2);
        when 1 => -- Eventuale divisione per 2
            shifted_data <= data_in(22) & data_in(22 downto 1);
        when others => -- Nessuno shift (shift_val = 0)
            shifted_data <= data_in;
    end case;
end process;

-- 2. CONTROLLO OVERFLOW (Sui dati già normalizzati)
-- Se dopo la divisione i bit dal 21 all'8 contengono degli '1' (e il numero è positivo),
-- allora il valore supera 255.
overflow_bits <= '1' when (shifted_data(21 downto 8) /= "00000000000000") else '0';
--- il DIVERSO DA /= SI PUò IMPLEMENTARE CON CHE PORTA ?
-- OR TRA TUTTI I BIT 

-- 3. LOGICA DI SATURAZIONE
process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            data_out <= (others => '0');
        elsif data_valid = '1' then
            
            if shifted_data(22) = '1' then 
                -- Valore Negativo -> Satura a 0
                data_out <= (others => '0');
            
            elsif overflow_bits = '1' then
                -- Valore > 255 -> Satura a 255
                data_out <= (others => '1');
            
            else
                -- Valore nel range [0, 255]
                data_out <= shifted_data(7 downto 0);
            end if;
            
        end if;
    end if;
end process;

end Behavioral;