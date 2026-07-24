library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BE is
generic(dimBE: integer := 3);
Port(MR: in std_logic_vector(dimBE-1 downto 0);       -- il moltiplicatore (coefficiente del kernel)
     code: out std_logic_vector(dimBE-1 downto 0));   -- il segnale di controllo del mux
end BE;

architecture Behavioral of BE is

-- inizializzo a 0 così non effettuo shit per aggiunger 0 a LSB di MR
--signal MRs: std_logic_vector(dimBe downto 0) := (others=> '0'); -- (dimensione 9 bit)

signal Y0, Y1, Y2: std_logic;

begin
-- Essendo MR a 8 bit si aggiunge '0' al LSB così è 9
-- si generano 3 booth encoder siccome codifica radix-4
-- uscita code (0)
Y0 <= not(MR(1) and MR(0));
code(2) <= Y0 and MR(2);

-- uscita code(1)
Y1 <= MR(2) xor MR(1);
code(1) <= Y1 and (not(Y2));

-- uscita code(0)
Y2 <= MR(1) xor MR(0);
code(0) <= Y2;

end Behavioral;