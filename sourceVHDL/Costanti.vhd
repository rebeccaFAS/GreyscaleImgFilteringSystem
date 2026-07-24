library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use IEEE.NUMERIC_STD.ALL;


package Costanti is

    -- Image dimension NxM 64x64 dove N->colonna ed M->riga
    constant nCol: integer := 64;
    constant mRow: integer := 64;
    
    -- Dimensione image
    constant dimImg: integer := (nCol*mRow);
        
    -- Dati image dimension 8-bit unsigned
    constant dimDataImg: integer := 8;
    
    -- Kernel dimension KxK
    constant k_Kernel: integer := 3;
    
    -- Numero di FIFO register necessari 2
    -- FIFO dimension dimFIFO=N-K=61
    constant dimFIFO: integer := (nCol-k_Kernel);
    
    -- Numero di registri del circuito di bufferizzazione
    constant dimKernel: integer := (k_Kernel*k_Kernel); --(dimensione = 9)
    
    -- type matrix is array(2 downto 0, 2 downto 0) of std_logic_vector(7 downto 0);
    constant dimBuffer:integer:=(dimKernel+(nCol*2)); 
    
end package Costanti;