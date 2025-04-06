-------------------------------------------------------

-- Unité de contôle

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity controleUnit is
    port (
        instr : in STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

        PCSrc, RegWr, MemToReg, MemWr, Branch, CCWr, AluSrc : out STD_LOGIC := '0';
        AluCtrl, ImmSrc, RegSrc : out STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
        Cond : out STD_LOGIC_VECTOR(3 downto 0) := (others => '0')
    );
end entity;

architecture controleUnit_arch of controleUnit is
    -- signal instr_type : STD_LOGIC_VECTOR(2 downto 0) := "000";
begin

    Cond <= instr(31 downto 28);

    process(instr)
    begin
        if instr(27 downto 26) = "00" then      -- calcul
            with instr(24 downto 21) select
                AluCtrl <= "00" when "0100",    -- add
                            "01" when "0010",   -- sub
                            "10" when "0000",   -- and
                            "11" when "1100",   -- or
                            "01" when "1010",   -- comp
                            "00" when others;   -- unexpected
            Branch <= '0';
            MemToReg <= '0';
            MemWr <= '0';
            AluSrc <= instr(25);
            ImmSrc <= "00";
            RegWr <= '0' when instr(24 downto 21) = "1010" else '1';
            RegSrc <= "00";
        elsif instr(27 downto 26) = "01" then   -- mémoire
            AluCtrl <= "00" when instr(23) = '0' else "01";
                Branch <= '0';
                MemToReg <= '1';
                MemWr <= not instr(20);
                AluSrc <= '1';
                ImmSrc <= "01";
                RegWr <= instr(20);
                RegSrc <= "10";
        else                                    -- branchement
            AluCtrl <= "00";
            Branch <= '1';
            MemToReg <=  '0';
            MemWr <= '0';
            AluSrc <= '1';
            ImmSrc <= "10";
            RegWr <= '0';
            RegSrc <= "01";
        end if;
    end process;

    process (instr) -- PCSrc and CCwr
    begin
        if instr(27 downto 26) = "00" then
            PCSrc <= '1' when instr(15 downto 12) = "1111" else '0';
        elsif instr(27 downto 26) = "01" then
            PCSrc <= '1' when instr(20) = '1' and instr(15 downto 12) = "1111" else '0';
        else
            PCSrc <= '0';
        end if;

        CCwr <= '1' when instr(20) = '1' and instr(27 downto 26) = "00" else '0';
    end process;

end architecture;













-------------------------------------------------------

-- Chemin de données

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity dataPath is
  port(
    clk,  init, ALUSrc_EX, MemWr_Mem, MemWr_RE, PCSrc_ER, Bpris_EX, Gel_LI, Gel_DI, RAZ_DI, RegWR, Clr_EX, MemToReg_RE : in std_logic;
    RegSrc, EA_EX, EB_EX, immSrc, ALUCtrl_EX : in std_logic_vector(1 downto 0);
    instr_DE: out std_logic_vector(31 downto 0);
    a1, a2, rs1, rs2, CC, op3_EX_out, op3_ME_out, op3_RE_out: out std_logic_vector(3 downto 0)
);      
end entity;

architecture dataPath_arch of dataPath is
  signal Res_RE, npc_fwd_br, pc_plus_4, i_FE, i_DE, Op1_DE, Op2_DE, Op1_EX, Op2_EX, extImm_DE, extImm_EX, Res_EX, Res_ME, WD_EX, WD_ME, Res_Mem_ME, Res_Mem_RE, Res_ALU_ME, Res_ALU_RE, Res_fwd_ME : std_logic_vector(31 downto 0);
  signal Op3_DE, Op3_EX, a1_DE, a1_EX, a2_DE, a2_EX, Op3_EX_out_t, Op3_ME, Op3_ME_out_t, Op3_RE, Op3_RE_out_t : std_logic_vector(3 downto 0);
begin

  -- FE
 
  -- DE

  -- EX
 
  -- ME
 
  -- RE
 
  
end architecture;
