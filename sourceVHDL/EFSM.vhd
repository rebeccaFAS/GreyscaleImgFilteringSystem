library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Costanti.all;

entity SystemFSM is
    Port(
        clk, rst       : in  std_logic;
        enable         : in  std_logic; -- Start esterno
        window_valid   : in  std_logic; -- Finestra 3x3 pronta dal Buffer
        endImgfromBM   : in  std_logic; -- Fine immagine dal Buffer
        
        abilitaBM      : out std_logic; -- Abilita il Buffer Module
        abilitaCM      : out std_logic; -- Abilita il Convolution Module
        valid_data_out : out std_logic; -- Segnale per scrivere su file (ritardato)
        system_done    : out std_logic  -- Segnale di fine elaborazione totale
    );
end SystemFSM;

architecture Behavioral of SystemFSM is

    -- Definizione Stati FSM
    type state_type is (IDLE, FILL, RUN, DONE);
    signal current_state, next_state : state_type;

    -- Costanti di Latenza
    -- PIPE_LATENCY: Cicli extra per svuotare la pipeline dopo endImg (flush)
    constant PIPE_LATENCY : integer := 3; 
    
    -- COMPUTATION_DELAY: Ritardo specifico per valid_data_out (3 cicli richiesti)
    constant COMPUTATION_DELAY : integer := 4;

    -- Segnali interni
    signal latency_cnt : integer range 0 to PIPE_LATENCY;
    
    -- Shift Register per ritardare il segnale valid_data_out di 3 cicli
    signal valid_pipeline : std_logic_vector(COMPUTATION_DELAY-1 downto 0);
    signal valid_trigger  : std_logic; -- Ingresso dello shift register

begin

    -- =========================================================================
    -- 1. PROCESSO SEQUENZIALE (Registro di Stato + Gestione Ritardi)
    -- =========================================================================
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state  <= IDLE;
                latency_cnt    <= 0;
                valid_pipeline <= (others => '0'); -- Reset pipeline
            else
                -- Aggiornamento Stato
                current_state <= next_state;
                
                -- Gestione Shift Register per il ritardo di 3 cicli
                -- Shift verso sinistra: inseriamo valid_trigger in posizione 0
                valid_pipeline <= valid_pipeline(COMPUTATION_DELAY-2 downto 0) & valid_trigger;

                -- Gestione Contatore Flush (Per rimanere in RUN qualche ciclo alla fine)
                if ((current_state = RUN) and (endImgfromBM = '1')) then
                    if (latency_cnt < PIPE_LATENCY) then
                        latency_cnt <= latency_cnt + 1;
                    end if;
                else
--                    if current_state /= RUN then -- NON è RUN
                        latency_cnt <= 0;
--                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Assegnazione Uscita Ritardata
    -- L'uscita   l'ultimo bit dello shift register (dopo 3 cicli)
    valid_data_out <= valid_pipeline(COMPUTATION_DELAY-1);


    -- =========================================================================
    -- 2. LOGICA STATO PROSSIMO (Combinatorio)
    -- =========================================================================
    process(current_state, next_state, enable, window_valid, endImgfromBM, latency_cnt)
    begin  
        -- Valore di default per evitare latch
        next_state <= current_state;

        case current_state is
            
            -- IDLE: Attesa segnale di start
            when IDLE =>
                if enable = '1' then
                    next_state <= FILL;
                end if;

            -- FILL: Riempimento buffer iniziale (Latenza nCol+1)
            when FILL =>
                if window_valid = '1' then
                    next_state <= RUN;
                end if;

            -- RUN: Elaborazione attiva
            when RUN =>
                -- Rimaniamo in RUN finch  non finisce l'immagine e si svuota la pipeline
                if (endImgfromBM = '1' and latency_cnt = PIPE_LATENCY) then
                    next_state <= DONE;
                end if;        

            -- DONE: Fine elaborazione, handshake per tornare a IDLE
            when DONE =>
                if enable = '0' then -- Aspettiamo che l'enable esterno vada basso
                    next_state <= IDLE;
                end if;

            when others =>
                next_state <= IDLE;
        end case;
    end process;


    -- =========================================================================
    -- 3. LOGICA USCITE DI CONTROLLO (Combinatorio - Tipo Mealy)
    -- =========================================================================
    process(current_state, window_valid, endImgfromBM, enable)
    begin
        -- (importante per evitare latch involontari)
        abilitaBM     <= '0';
        abilitaCM     <= '0';
        valid_trigger <= '0'; -- Questo entra nello shift register
        system_done   <= '0';

        case current_state is
            
            when IDLE =>
                -- Se enable   alto, iniziamo subito ad abilitare il Buffer Module
                if enable = '1' then
                    abilitaBM <= '1';
                end if;
            
            when FILL =>
                abilitaBM <= '1';
                
                if window_valid = '1' then
                    abilitaCM     <= '1';
                    valid_trigger <= '1';
                end if;

            when RUN =>
                -- Logica principale di esecuzione:
                -- 1. Se window_valid   alto, o stiamo svuotando (endImg=1), elaboriamo.
                if (window_valid = '1' or endImgfromBM = '1') then
                    
                    abilitaCM     <= '1'; -- Abilita il calcolo della convoluzione
                    valid_trigger <= '1'; -- Carica '1' nella pipeline di ritardo (uscir  tra 3 cicli)
                    
                    -- Continuiamo a leggere dal buffer finch  non finisce l'immagine
                    if (endImgfromBM = '0') then
                        abilitaBM <= '1';
                    end if;
                end if;

            when DONE =>
                system_done <= '1';
                valid_trigger <= '0';
                -- In DONE valid_trigger   '0', quindi valid_data_out andr  a 0 dopo che la pipeline si svuota
                
        end case;
    end process;

end Behavioral;