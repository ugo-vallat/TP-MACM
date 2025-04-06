-------------------------------------------------

-- Etage FE

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity etageFE is
  port(
    npc, npc_fw_br : in std_logic_vector(31 downto 0);
    PCSrc_ER, Bpris_EX, GEL_LI, clk : in std_logic;
    pc_plus_4, i_FE : out std_logic_vector(31 downto 0)
);
end entity;


architecture etageFE_arch of etageFE is
  signal pc_inter, pc_reg_in, pc_reg_out, sig_pc_plus_4, sig_4: std_logic_vector(31 downto 0);
begin

    sig_4 <= (2=>'1', others => '0');
    pc_plus_4 <= sig_pc_plus_4;
  
    -- Instanciation de la mémoire d’instruction
    inst_mem_1: entity work.inst_mem
        port map (
            addr => pc_reg_out,
            instr => i_FE
        );

    -- Instanciation de l'additionneur
    add_pc_4: entity work.addComplex
        port map (
            A => pc_reg_out,
            B => sig_4,
            cin => '0',
            s => sig_pc_plus_4,
            c30 => open,
            c31 => open
        );

    -- registre PC
    pd_reg: entity work.Reg32
        port map (
            source => pc_reg_in,
            output => pc_reg_out,
            clk => clk,
            wr => GEL_LI,
            raz => '1'
        );

    -- Sélection  pc si calculé
    with PCSrc_ER select
        pc_inter <= npc when '1',
                    sig_pc_plus_4 when others;

    -- Sélection pc si branchement
    with Bpris_EX select
        pc_reg_in <= npc_fw_br when '1',
                    pc_inter when others;



end architecture;

-- -------------------------------------------------

-- Etage DE

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity etageDE is
    port(
    -- depuis étage précédent
        i_DE, WD_ER, pc_plus_4 : in std_logic_vector(31 downto 0) := (others => '0');
        Op3_ER : in STD_LOGIC_VECTOR(3 downto 0);

    -- signaux de contôle
        RegSrc, immSrc : in STD_LOGIC_VECTOR(1 downto 0) := "00";
        RegWr, Init, clk : in STD_LOGIC;
    -- sorties
        Op1, Op2, extImm : out std_logic_vector(31 downto 0);
        Reg1, Reg2, Op3_DE : out STD_LOGIC_VECTOR(3 downto 0) := "0000"
  );
end entity;
  
  
architecture etageDE_arch of etageDE is
    signal sigOp1 : STD_LOGIC_VECTOR(3 downto 0):= "0000";
    signal sigOp2 : STD_LOGIC_VECTOR(3 downto 0):= "0000";
begin

    Reg1 <= sigOp1;
    Reg2 <= sigOp2;
    Op3_DE <= i_DE(15 downto 12);

    inst_RegisterBank: entity work.RegisterBank
        port map (
            clk => clk,
            s_reg_0 => sigOp1,
            s_reg_1 => sigOp2,
            dest_reg => Op3_ER,
            data_i => WD_ER,
            wr_reg => RegWr,
            data_o_0 => Op1,
            data_o_1 => Op2,
            init => Init,
            pc_in => pc_plus_4
        );

    inst_extension: entity work.extension
        port map (
            immSrc => immSrc,
            immIn => i_DE(23 downto 0),
            ExtOut => extImm
        );

    with RegSrc(0) select
        sigOp1 <= "1111" when '1',
                    i_DE(19 downto 16) when others;

    with RegSrc(1) select
        sigOp2 <= i_DE(15 downto 12) when '1',
                    i_DE(3 downto 0) when others;

end architecture;
  

-- -------------------------------------------------

-- -- Etage EX

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity etageEX is
    port(
    -- depuis étage précédent
        Op1_EX, Op2_EX, ExtImm_EX, Res_fwd_ME, Res_fwd_ER : in std_logic_vector(31 downto 0) := (others => '0');
        Op3_EX : in std_logic_vector(3 downto 0) := (others => '0');

    -- signaux de contôle
        EA_EX, EB_EX, ALUCtrl_EX : in STD_LOGIC_VECTOR(1 downto 0) := "00";
        ALUSrc_EX : in STD_LOGIC;

    -- sorties
        Res_EX, WD_EX, npc_fw_br : out std_logic_vector(31 downto 0) := (others => '0');
        CC, Op3_EX_out : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0')
  );
end entity;
  
  
architecture etageEX_arch of etageEX is
    signal ALUOp1, Oper2, ALUOp2, res : std_logic_vector(31 downto 0) := (others => '0');
begin

    Res_EX <= res;
    npc_fw_br <= res;
    Op3_EX_out <= Op3_EX;
    WD_EX <= Op2_EX;

    inst_ALU: entity work.ALU
        port map (
            A => ALUOp1,
            B => ALUOp2,
            sel => ALUCtrl_EX,
            Res => res,
            CC => CC
        );


    with EA_EX select
        ALUOp1 <= Op1_EX when "00",
                    Res_fwd_ER when "01",
                    Res_fwd_ME when "10",
                    (others => 'Z') when others;
    
    with EB_EX select
        Oper2 <= Op2_EX when "00",
                    Res_fwd_ER when "01",
                    Res_fwd_ME when "10",
                    (others => 'Z') when others;
    
    with ALUSrc_EX select
            ALUOp2 <= Oper2 when '0',
                        ExtImm_EX when others;


end architecture;
  
-- -------------------------------------------------

-- Etage ME

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity etageME is
    port(
    -- depuis étage précédent
        Res_ME, WD_ME : in std_logic_vector(31 downto 0) := (others => '0');
        Op3_ME : in std_logic_vector(3 downto 0) := (others => '0');

    -- signaux de contôle
        clk, MemWr_Mem : in STD_LOGIC := '0';

    -- sorties
        Res_Mem_ME, Res_ALU_ME, Res_fwd_ME : out std_logic_vector(31 downto 0) := (others => '0');
        Op3_ME_out : out std_logic_vector(3 downto 0) := (others => '0')
  );
end entity;
  
  
architecture etageME_arch of etageME is
begin

    Res_ALU_ME <= Res_ME;
    Res_fwd_ME <= Res_ME;
    Op3_ME_out <= Op3_ME;

    inst_data_mem: entity work.data_mem
        port map (
            addr => Res_ME,
            clk => clk,
            data => Res_Mem_ME,
            WD => WD_ME,
            WR => MemWr_Mem
        );

end architecture;
-- -------------------------------------------------

-- Etage ER

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity etageER is
    port (
        -- depuis étage précédent
        Res_Mem_RE, Res_ALU_RE : in std_logic_vector(31 downto 0) := (others => '0');
        Op3_RE : in std_logic_vector(3 downto 0) := (others => '0');

        -- signaux de contôle
        MemToReg_RE : in STD_LOGIC;

        -- sorties
        Res_RE : out std_logic_vector(31 downto 0) := (others => '0');
        Op3_RE_out : out std_logic_vector(3 downto 0) := (others => '0')
    );
end entity;

architecture etageER_arch of etageER is
begin

    Op3_RE_out <= Op3_RE;

    with MemToReg_RE select
        Res_RE <= Res_Mem_RE when '1',
                    Res_ALU_RE when others;

end architecture;
