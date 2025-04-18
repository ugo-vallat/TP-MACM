-- Definition des librairies
library IEEE;

-- Definition des portee d'utilisation
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Definition de l'entite
entity test_controle is
end test_controle;

-- Definition de l'architecture
architecture behavior of test_controle is

-- definition de constantes de test
	constant TIMEOUT 	: time := 500 ns; -- timeout de la simulation

-- definition de constantes
constant clkpulse : Time := 5 ns; -- 1/2 periode horloge

-- definition de types

-- definition de ressources internes

-- Signaux Controle
signal Branch_DE, PCSrc_DE, RegWr_DE, MemWr_DE, MemToReg_DE, CCWr_DE, AluSrc_DE : STD_LOGIC := '0';
signal AluCtrl_DE : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
signal cond_DE : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');


signal Branch_EX, PCSrc_EX, RegWr_EX, MemWr_EX, MemToReg_EX, CCWr_EX : STD_LOGIC := '0';
signal cond_EX : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

signal PCSrc_ME, RegWr_ME, MemWr_ME, MemToReg_ME: STD_LOGIC := '0';
signal PCSrc_RE, RegWr_RE, MemToReg_RE: STD_LOGIC := '0';


-- -- Signaux Cond
signal CC_EX, CC : std_logic_vector(3 downto 0) := (others => '0');
signal CC_out : std_logic_vector(3 downto 0) := (others => '0');
signal CondEx : STD_LOGIC := '0';

-- Signaux proc
signal init, ALUSrc_EX, MemWr_Mem, MemWr_RE_tmp, PCSrc_ER, Bpris_EX, Gel_LI, Gel_DI, RAZ_DI, RegWR, Clr_EX_tmp : std_logic := '0';
signal RegSrc, EA_EX_tmp, EB_EX_tmp, immSrc, ALUCtrl_EX : std_logic_vector(1 downto 0):= (others => '0'); 
signal instr_DE: std_logic_vector(31 downto 0) := (others => '0');
signal a1_tmp, a2_tmp, rs1_tmp, rs2_tmp, op3_EX_out_tmp, op3_ME_out_tmp, op3_RE_out_tmp: std_logic_vector(3 downto 0) := (others => '0');

-- clock
signal clk : STD_LOGIC;

begin


------------------------------------------------------------------
-- definition de l'horloge
P_E_CLK: process
begin
	CLK <= '1';
	wait for clkpulse;
	CLK <= '0';
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

-- Instanciation de controleUnit
test_controleunit : entity work.controleUnit(controleUnit_arch)
    port map (
        instr       => instr_DE,
        Branch      => Branch_DE,
        PCSrc       => PCSrc_DE,
        RegWr       => RegWr_DE,
        MemWr       => MemWr_DE,
        MemToReg    => MemToReg_DE,
        CCWr        => CCWr_DE,
        AluCtrl     => AluCtrl_DE,
        AluSrc      => AluSrc_DE,
        ImmSrc      => immSrc,
        RegSrc      => RegSrc,
        Cond        => cond_DE
    );

-- Instanciation de gestionCond
test_gestioncond : entity work.gestionCond(gestionCond_arch)
    port map (
        Cond        => cond_EX,
        CC_EX       => CC_EX,
        CC          => CC,
        CCWr_EX     => CCWr_EX,
        CC_out      => CC_out,
        CondEx      => CondEx
    );

    -- Instanciation de dataPath
test_datapath : entity work.dataPath(dataPath_arch)
port map (
    clk             => clk,
    init            => init,
    ALUSrc_EX       => ALUSrc_EX,
    MemWr_Mem       => MemWr_Mem,
    PCSrc_ER        => PCSrc_RE,
    Bpris_EX        => Bpris_EX,
    Gel_LI          => Gel_LI,
    Gel_DI          => Gel_DI,
    RAZ_DI          => RAZ_DI,
    RegWR           => RegWr_RE,
    MemToReg_RE     => MemToReg_RE,
    RegSrc          => RegSrc,
    immSrc          => immSrc,
    ALUCtrl_EX      => ALUCtrl_EX,
    instr_DE        => instr_DE,
    CC              => CC,
    Clr_EX          => Clr_EX_tmp,
    EA_EX           => EA_EX_tmp,
    EB_EX           => EB_EX_tmp,
    a1              => a1_tmp,
    a2              => a2_tmp,
    rs1             => rs1_tmp,
    rs2             => rs2_tmp,
    MemWr_RE        => MemWr_RE_tmp,
    op3_EX_out      => op3_EX_out_tmp,
    op3_ME_out      => op3_ME_out_tmp,
    op3_RE_out      => op3_RE_out_tmp
    );

test_gestionAleas : entity work.gestionAleas
  port map (
    a1           => a1_tmp,
    a2           => a2_tmp,
    op3_ME_out   => op3_ME_out_tmp,
    op3_RE_out   => op3_RE_out_tmp,
    RegWr_Mem    => RegWr_ME,
    RegWr_RE     => RegWr_RE,
    Reg1         => rs1_tmp,
    Reg2         => rs2_tmp,
    op3_EX_out   => op3_EX_out_tmp,
    MemToReg_EX  => MemToReg_EX,
    PCSrc_DE     => PCSrc_DE,
    PCSrc_EX     => PCSrc_EX,
    PCSrc_ME     => PCSrc_ME,
    PCSrc_ER     => PCSrc_ER,
    Bpris_EX     => Bpris_EX,
    EA_EX        => EA_EX_tmp,
    EB_EX        => EB_EX_tmp,
    Gel_LI       => Gel_LI,
    En_DI        => En_DI,
    Clr_EX       => Clr_EX_tmp,
    Clr_DI       => Gel_DI 
    );

P_DE: process(clk)
begin

    if rising_edge(clk) then
        CCWr_EX <= CCWr_DE;
        CC_EX <= CC_out;
        cond_EX <= cond_DE;
        ALUCtrl_EX <= AluCtrl_DE;
        ALUSrc_EX <= AluSrc_DE;
        Branch_EX <= Branch_DE and CondEx;
        PCSrc_EX <= PCSrc_DE and CondEx;
        RegWr_EX <= RegWr_DE and CondEx;
        MemWr_EX <= MemWr_DE and CondEx;
        MemToReg_EX <= MemToReg_DE;

    end if;

end process;

P_EX: process(clk)
begin

    if rising_edge(clk) then
        PCSrc_ME <= PCSrc_EX;
        RegWr_ME <= RegWr_EX;
        MemWr_ME <= MemWr_EX;
        MemToReg_ME <= MemToReg_EX;
    end if;

end process;

P_ME: process(clk)
begin

    if rising_edge(clk) then
        PCSrc_RE <= PCSrc_ME;
        RegWr_RE <= RegWr_ME;
        MemToReg_RE <= MemToReg_ME;
    end if;

end process;

------------------------------------------------------------------
-- debut sequence de test
P_TEST: process
begin


    init <= '1';
    Gel_LI <= '1';
    Gel_DI <= '1';
    RAZ_DI <= '1';
	wait for clkpulse*2;

    
    init <= '0';
    Gel_LI <= '0';
    Gel_DI <= '0';
    RAZ_DI <= '0';
	wait for clkpulse*2;

    wait for clkpulse*30;




	-- assert E_DO = to_stdlogicvector(BIT_VECTOR'(X"FFFF0000"))
	-- 	report "Memory 0 BAD VALUE"
	-- 	severity ERROR;

	-- ADD NEW SEQUENCE HERE

	-- LATEST COMMAND (NE PAS ENLEVER !!!)
	wait until CLK='1'; wait for clkpulse/2;
	assert FALSE report "FIN DE SIMULATION" severity FAILURE;
	-- assert (NOW < TIMEOUT) report "FIN DE SIMULATION" severity FAILURE;

end process P_TEST;

end behavior;