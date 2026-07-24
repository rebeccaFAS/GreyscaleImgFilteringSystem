library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CodificatoreBooth is
       Port(B : in std_logic_vector (2 downto 0);
            C : out std_logic_vector (2 downto 0));
end CodificatoreBooth;

architecture Behavioral of CodificatoreBooth is

begin

--C <=  "000" when B="000" or B="111" else
--      "001" when B="001" or B="010" else
--      "010" when B="011" else
--      "110" when B="100" else 
--      "111" when B="101" or B="110";

C(0) <= B(0) XOR B(1);
C(1) <= (NOT(B(0) XOR B(1))) AND (B(1) XOR B(2));
C(2) <= B(2) AND (NOT(B(0) AND B(1)));

end Behavioral;


