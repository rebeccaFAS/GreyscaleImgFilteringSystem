library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity Moltiplicatore is
   generic (n: integer := 10);
   Port (a, b: in std_logic_vector(n-1 downto 0);
          risultato: out std_logic_vector(2*n-1 downto 0));
end Moltiplicatore;

architecture Behavioral of Moltiplicatore is

component Prodotti_parziali 
    generic (n:integer);
    Port (A : in std_logic_vector (n-1 downto 0);
          ExA,DA, MA, MDA : out std_logic_vector (n+1 downto 0));
end component;

component RCA
   generic(n : integer);
   port(a_rca, b_rca : in std_logic_vector(n-1 downto 0);
		 cin_rca : in std_logic;
		 s_rca : out std_logic_vector(n downto 0));
end component;

component CodificatoreBooth
     Port(B : in std_logic_vector (2 downto 0);
          C : out std_logic_vector (2 downto 0));
end component;

component Multiplexer
    generic(N:integer);
    Port (sel : in std_logic_vector(2 downto 0);
          A, B, C, D : in std_logic_vector(N-1 downto 0);
          uscita : out std_logic_vector(N-1 downto 0));
end component;

component Adder_4
    generic( n : integer);
    port(A, B, C, D : in std_logic_vector(n-1 downto 0);
         Cin_RCA : in std_logic;
         S : out std_logic_vector(n+1 downto 0));
end component;

signal D4, D3, D2, D1, D0: std_logic_vector(2 downto 0);
signal x_in: std_logic_vector(2 downto 0);
signal a_new: std_logic_vector(n downto 0);
signal EXA, DA, MA, MDA : std_logic_vector(n+2 downto 0) := (others => '0');
signal p0, p1, p2, p3, p4: std_logic_vector(n+2 downto 0);
signal p0_new, p1_new, p2_new, p3_new, p4_new: std_logic_vector(2*n downto 0);
signal Sum_4op: std_logic_vector(2*n+2 downto 0);
signal Sum_finale: std_logic_vector(2*n+1 downto 0);

begin
    x_in <= b(1 downto 0) & '0';
    
    C4: CodificatoreBooth port map(b(9 downto 7), D4);
    C3: CodificatoreBooth port map(b(7 downto 5), D3);
    C2: CodificatoreBooth port map(b(5 downto 3), D2);
    C1: CodificatoreBooth port map(b(3 downto 1), D1);
    C0: CodificatoreBooth port map(x_in, D0);

   -- a_new <= a(n-1) & a;
   a_new <= '0' & a;  -- Per unsigned
    
    PP: Prodotti_parziali generic map (n+1) port map (a_new, EXA, DA, MA, MDA);
    
    PP0: Multiplexer generic map (N => n+3) port map (D0, EXA, DA, MA, MDA, p0);
    PP1: Multiplexer generic map (N => n+3) port map (D1, EXA, DA, MA, MDA, p1);
    PP2: Multiplexer generic map (N => n+3) port map (D2, EXA, DA, MA, MDA, p2);
    PP3: Multiplexer generic map (N => n+3) port map (D3, EXA, DA, MA, MDA, p3);
    PP4: Multiplexer generic map (N => n+3) port map (D4, EXA, DA, MA, MDA, p4);
    
    -- Allineamento dei prodotti parziali per 10 bit
    p0_new <= p0(n+2) & p0(n+2) & p0(n+2) & p0(n+2) & p0(n+2) & p0(n+2) & p0(n+2) & p0(n+2) & p0;
    p1_new <= p1(n+2) & p1(n+2) & p1(n+2) & p1(n+2) & p1(n+2) & p1(n+2) & p1 & "00";
    p2_new <= p2(n+2) & p2(n+2) & p2(n+2) & p2(n+2) & p2 & "0000";
    p3_new <= p3(n+2) & p3(n+2) & p3 & "000000";
    p4_new <= p4 & "00000000";
    
    -- Somma dei primi 4 prodotti parziali con Adder_4
    Add4: Adder_4 generic map (n => 2*n+1) 
          port map (p0_new, p1_new, p2_new, p3_new, '0', Sum_4op);
    
    -- Somma finale con il quinto prodotto parziale
    AddFin: RCA generic map (n => 2*n+1) 
            port map (Sum_4op(2*n downto 0), p4_new, '0', Sum_finale);
    
    risultato <= Sum_finale(2*n-1 downto 0);
    
end Behavioral;
