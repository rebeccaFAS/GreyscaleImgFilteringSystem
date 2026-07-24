library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Costanti.all;

entity BufferModule is
   port(clk, rst: in std_logic;
        wr_enableBM: in std_logic;
        dataIn: in std_logic_vector(dimDataImg-1 downto 0);
        
        -- Uscite verso l'esterno
        p00, p01, p02: out std_logic_vector(dimDataImg-1 downto 0);
        p10, p11, p12: out std_logic_vector(dimDataImg-1 downto 0);
        p20, p21, p22: out std_logic_vector(dimDataImg-1 downto 0);
        
        windowValid: out std_logic;
        endImgBM: out std_logic);
end BufferModule;

architecture Behavioral of BufferModule is

-- Componenti

component BufferLine is
   port(clk, rst: in std_logic;
        wr_en: in std_logic;
        dataIn: in std_logic_vector(7 downto 0);
        row: in integer range 0 to mRow-1;
        col: in integer range 0 to nCol-1;
        validIn: in std_logic;
        
        p00, p01, p02: out std_logic_vector(dimDataImg-1 downto 0);
        p10, p11, p12: out std_logic_vector(dimDataImg-1 downto 0);
        p20, p21, p22: out std_logic_vector(dimDataImg-1 downto 0));
end component;

-- Segnali di interconnessione
signal countS: std_logic_vector(12 downto 0);
signal valid_fsm: std_logic;
signal rowS: integer range 0 to mRow-1;
signal colS: integer range 0 to nCol-1;

signal reg_0: std_logic_vector(dimDataImg-1 downto 0);

begin

REGelem0:  entity work.Registro generic map(dimDataImg) port map(dataIn, clk, rst, '1', reg_0);

-- 1. Istanza Contatore
-- Conta sempre quando wr_en è attivo
Bcontatore: entity work.Contatore 
port map(clk => clk, rst => rst, enable  => wr_enableBM, qOut => countS);

-- 2. Istanza FSM
-- Decide quando i dati nel buffer sono pronti e calcola le coordinate
Bcontroller: entity work.Controller 
port map(clk => clk, rst => rst, qIn => countS, row => rowS, col => colS, rdyWindow => valid_fsm, endImg => endImgBM);

-- 2. Istanza Buffer
-- Gestisce lo storage e il padding
Blinebuffer: 
BufferLine port map(clk => clk, rst => rst, wr_en => wr_enableBM, 
                    dataIn => reg_0, row => rowS, col => colS, 
                    validIn => valid_fsm,
                    p00 => p00, p01 => p01, p02 => p02,
                    p10 => p10, p11 => p11, p12 => p12,
                    p20 => p20, p21 => p21, p22 => p22);
                    
windowValid <= valid_fsm;

end Behavioral;