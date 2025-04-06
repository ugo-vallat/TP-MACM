-- Definition des librairies
library IEEE;

-- Definition des portee d'utilisation
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Definition de l'entite
entity test_etage_ex is
end test_etage_ex;

-- Definition de l'architecture
architecture behavior of test_etage_ex is

-- definition de constantes de test
	constant TIMEOUT 	: time := 200 ns; -- timeout de la simulation

-- definition de constantes
constant clkpulse : Time := 5 ns; -- 1/2 periode horloge

-- definition de types

-- definition de ressources internes

-- definition de ressources externes
signal E_Op1_EX, E_Op2_EX, E_ExtImm_EX, E_Res_fwd_ME, E_Res_fwd_ER, S_Res_EX : std_logic_vector(31 downto 0) := (others => '0');
signal E_Op3_EX : std_logic_vector(3 downto 0) := (others => '0');
signal E_EA_EX, E_EB_EX, E_ALUCtrl_EX : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal E_ALUSrc_EX : STD_LOGIC := '0';

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
L1 : entity work.etageEX(etageEX_arch)   -- behavioral simulation
		port map (
            Op1_EX => E_Op1_EX,
            Op2_EX => E_Op2_EX,
            Op3_EX => E_Op3_EX,
            ExtImm_EX => E_ExtImm_EX,
            Res_fwd_ME => E_Res_fwd_ME,
            Res_fwd_ER => E_Res_fwd_ER,
            EA_EX => E_EA_EX,
            EB_EX => E_EB_EX,
            ALUSrc_EX => E_ALUSrc_EX,
            ALUCtrl_EX => E_ALUCtrl_EX,
            Res_EX => S_Res_EX
        );

------------------------------------------------------------------
-- debut sequence de test
P_TEST: process
begin

    wait for 5 ns;

	-- initialisations
    E_Op1_EX <= (others => '0');
    E_Op2_EX <= (others => '0');
    E_Op3_EX <= (others => '0');
    E_ExtImm_EX <= (others => '0');
    E_Res_fwd_ME <= (others => '0');
    E_Res_fwd_ER <= (others => '0');
    E_EA_EX <= (others => '0');
    E_EB_EX <= (others => '0');
    E_ALUCtrl_EX <= (others => '0');
    E_ALUSrc_EX <= '0';
    wait for clkpulse*2;

    -- init operands
	E_Op1_EX <= X"0000000F";
    E_Op2_EX <= X"00000001";
    E_ExtImm_EX <= X"000000F0";
    E_Res_fwd_ME <= X"00000011";

	-- op1 + op2
	wait until E_CLK='1'; wait for clkpulse/2;
    E_ALUCtrl_EX <= "00";
    wait for clkpulse/2;
    assert S_Res_EX = X"00000010" report "failled op1 + op2" severity ERROR;

    -- op1 and Res_fwd_ME
	wait until E_CLK='1'; wait for clkpulse/2;
    E_ALUCtrl_EX <= "10";
    E_EB_EX <= "10";
    wait for clkpulse/2;
    assert S_Res_EX = X"00000001" report "failled op1 and Res_fwd_ME" severity ERROR;

    -- Res_fwd_ME or ExtImm_EX
    wait until E_CLK='1'; wait for clkpulse/2;
    E_ALUCtrl_EX <= "11";
    E_EA_EX <= "10";
    E_ALUSrc_EX <= '1';
    wait for clkpulse/2;
    assert S_Res_EX = X"000000F1" report "failled Res_fwd_ME or ExtImm_EX" severity ERROR;

    wait for 2*clkpulse;


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