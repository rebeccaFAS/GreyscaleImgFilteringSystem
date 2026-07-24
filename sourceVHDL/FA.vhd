----------------------------------------------------------------------------------
-- Design Name: Full Adder version full
-- Module Name: FullAdder - Behavioral
-- Code by Rebecca Speranza
-- Create Date: 13.10.2025
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FA is
    Port(in1, in2: in std_logic;   --Bit in ingresso da somma
         Cin: in std_logic;        --Carry in Ingresso
         sumFA: out std_logic;     --Risultato della somam tra i due ingressi
         Cout: out std_logic);     --Carry in Uscita
end FA;

architecture Behavioral of FA is

begin

sumFA <= in1 xor in2 xor Cin;
Cout <= (in1 and in2)or(Cin and (in1 xor in2));

end Behavioral;