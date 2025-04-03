-- Definition des librairies
library IEEE;

-- Definition des portee d'utilisation
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Definition de l'entite
entity test_etage_fe is
end test_etage_fe;

-- Definition de l'architecture
architecture behavior of test_etage_fe is

-- definition de constantes de test
	constant R_SIZE	    : positive := 32;
	constant TIMEOUT 	: time := 200 ns; -- timeout de la simulation

-- definition de constantes
constant clkpulse : Time := 5 ns; -- 1/2 periode horloge

-- definition de types

-- definition de ressources internes

-- definition de ressources externes
signal npc				: STD_LOGIC_VECTOR(R_SIZE-1 downto 0);
signal npc_fw_br    	: STD_LOGIC_VECTOR(R_SIZE-1 downto 0);
signal PCSrc_ER			: STD_LOGIC;
signal Bpris_EX			: STD_LOGIC;
signal Gel_LI			: STD_LOGIC;

-- clock
signal E_CLK            : STD_LOGIC;

begin

------------------------------------------------------------------
-- definition de l'horloge
P_E_CLK: process
begin
	E_CLK <= '1';
	wait for clkpulse;
	E_CLK <= '0';
	wait for clkpulse;
end process P_E_CLK;

------------------------------------------------------------------
-- definition du timeout de la simulation
P_TIMEOUT: process
begin
	wait for TIMEOUT;
	assert FALSE report "SIMULATION TIMEOUT!!!" severity FAILURE;
end process P_TIMEOUT;

------------------------------------------------------------------
-- instanciation et mapping de composants
L1 : entity work.etageFE(etageFE_arch)   -- behavioral simulation
		port map (npc => npc,
            npc_fw_br => npc_fw_br,
            PCSrc_ER => PCSrc_ER,
            Bpris_EX => Bpris_EX,
            GEL_LI => Gel_LI,
            clk => E_CLK,
            pc_plus_4 => open,
            i_FE => open);

------------------------------------------------------------------
-- debut sequence de test
P_TEST: process
begin

	-- initialisations
	npc <= (others => '0');		
    npc_fw_br <= (others => '0');
    PCSrc_ER <= '1';
    Bpris_EX <= '0';
    Gel_LI <= '0';
	wait for clkpulse*2;


	-- incrémentation normale
	wait until E_CLK='1'; wait for clkpulse/2;
	Gel_LI <= '1';
    PCSrc_ER <= '0';
    wait for clkpulse*8;

    -- use npc
    wait until E_CLK='1'; wait for clkpulse/2;
    npc <= to_stdlogicvector(BIT_VECTOR'(X"000000FF"));
    PCSrc_ER <= '1';

    -- back to normal
    wait until E_CLK='1'; wait for clkpulse/2;
    PCSrc_ER <= '0';
    wait for clkpulse*4;

    -- use branch
    wait until E_CLK='1'; wait for clkpulse/2;
    npc_fw_br <= to_stdlogicvector(BIT_VECTOR'(X"000000FF"));
    Bpris_EX <= '1';

    -- back to normal
    wait until E_CLK='1'; wait for clkpulse/2;
    Bpris_EX <= '0';
    wait for clkpulse*4;

    -- gel
    wait until E_CLK='1'; wait for clkpulse/2;
	Gel_LI <= '0';
    wait for clkpulse*8;



	-- assert E_DO = to_stdlogicvector(BIT_VECTOR'(X"FFFF0000"))
	-- 	report "Memory 0 BAD VALUE"
	-- 	severity ERROR;

	-- ADD NEW SEQUENCE HERE

	-- LATEST COMMAND (NE PAS ENLEVER !!!)
	wait until E_CLK='1'; wait for clkpulse/2;
	assert FALSE report "FIN DE SIMULATION" severity FAILURE;
	-- assert (NOW < TIMEOUT) report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST;

end behavior;