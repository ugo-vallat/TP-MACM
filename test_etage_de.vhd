-- Definition des librairies
library IEEE;

-- Definition des portee d'utilisation
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Definition de l'entite
entity test_etage_de is
end test_etage_de;

-- Definition de l'architecture
architecture behavior of test_etage_de is

-- definition de constantes de test
	constant TIMEOUT 	: time := 200 ns; -- timeout de la simulation

-- definition de constantes
constant clkpulse : Time := 5 ns; -- 1/2 periode horloge

-- definition de types

-- definition de ressources internes

-- definition de ressources externes
signal E_i_DE			: STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
signal E_pc_plus_4    	: STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
signal E_WD_ER			: STD_LOGIC_VECTOR(31 downto 0):= (others => '0');
signal E_Op3_ER			: STD_LOGIC_VECTOR(3 downto 0):= (others => '0');
signal E_RegSrc			: STD_LOGIC_VECTOR(1 downto 0):= (others => '0');
signal E_immSrc			: STD_LOGIC_VECTOR(1 downto 0):= (others => '0');
signal E_RegWr			: STD_LOGIC:= '0';
signal E_Init           : STD_LOGIC:= '0';

-- clock
signal E_CLK            : STD_LOGIC:= '0';

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
L1 : entity work.etageDE(etageDE_arch)   -- behavioral simulation
		port map (
            clk => E_CLK,
            RegWr => E_RegWr,
            immSrc => E_immSrc,
            RegSrc => E_RegSrc,
            i_DE => E_i_DE,
            WD_ER => E_WD_ER,
            pc_plus_4 => E_pc_plus_4,
            Op3_ER => E_Op3_ER,
            Init => E_Init,
            Reg1 => open,
            Reg2 => open,
            Op1 => open,
            Op2 => open,
            extImm => open,
            Op3_DE => open
        );

------------------------------------------------------------------
-- debut sequence de test
P_TEST: process
begin

    wait for 5 ns;

	-- initialisations
    E_i_DE <= (others => '0');
    E_pc_plus_4 <= (others => '0');
    E_WD_ER <= (others => '0');
    E_Op3_ER <= (others => '0');
    E_RegSrc <= (others => '0');
    E_immSrc <= (others => '0');
    E_RegWr <= '0';
    E_Init <= '1';
    wait for clkpulse*2;
    E_Init <= '0';



	-- new PC
	wait until E_CLK='1'; wait for clkpulse/2;
	E_pc_plus_4 <= X"0000000F";
    wait for clkpulse*8;

    -- write value 
    wait until E_CLK='1'; wait for clkpulse/2;
    E_WD_ER <= X"12345678";
    E_Op3_ER <= X"8";
    E_RegWr <= '1';

    -- back to normal
    wait until E_CLK='1'; wait for clkpulse/2;
    E_WD_ER <= X"87654321";
    E_Op3_ER <= X"9";

    wait until E_CLK='1'; wait for clkpulse/2;
    E_RegWr <= '0';
    E_i_DE <= "00000000000010000000000000001001";
    E_RegSrc <= "00";

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