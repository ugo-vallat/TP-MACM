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
begin

    Cond <= instr(31 downto 28);

    process(instr)
    begin
        if instr(27 downto 26) = "00" then  -- calcul
            -- équivalent de "with ... select"
            case instr(24 downto 21) is
                when "0100" => AluCtrl <= "00"; -- add
                when "0010" => AluCtrl <= "01"; -- sub
                when "0000" => AluCtrl <= "10"; -- and
                when "1100" => AluCtrl <= "11"; -- or
                when "1010" => AluCtrl <= "01"; -- comp
                when others => AluCtrl <= "00"; -- unexpected
            end case;

            Branch    <= '0';
            MemToReg  <= '0';
            MemWr     <= '0';
            AluSrc    <= instr(25);
            ImmSrc    <= "00";

            if instr(24 downto 21) = "1010" then
                RegWr <= '0';
            else
                RegWr <= '1';
            end if;

            RegSrc <= "00";

        elsif instr(27 downto 26) = "01" then -- mémoire
            if instr(23) = '0' then
                AluCtrl <= "00";
            else
                AluCtrl <= "01";
            end if;

            Branch     <= '0';
            MemToReg   <= '1';
            MemWr      <= not instr(20);
            AluSrc     <= '1';
            ImmSrc     <= "01";
            RegWr      <= instr(20);
            RegSrc     <= "10";

        else  -- branchement
            AluCtrl    <= "00";
            Branch     <= '1';
            MemToReg   <= '0';
            MemWr      <= '0';
            AluSrc     <= '1';
            ImmSrc     <= "10";
            RegWr      <= '0';
            RegSrc     <= "01";
        end if;
    end process;

    -- Process séparé pour PCSrc et CCwr
    process(instr)
    begin
        if instr(27 downto 26) = "00" then
            if instr(15 downto 12) = "1111" then
                PCSrc <= '1';
            else
                PCSrc <= '0';
            end if;
        elsif instr(27 downto 26) = "01" then
            if instr(20) = '1' and instr(15 downto 12) = "1111" then
                PCSrc <= '1';
            else
                PCSrc <= '0';
            end if;
        else
            PCSrc <= '0';
        end if;

        if instr(20) = '1' and instr(27 downto 26) = "00" then
            CCWr <= '1';
        else
            CCWr <= '0';
        end if;
    end process;

end architecture;


-------------------------------------------------------

-- Gestion des conditions

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity gestionCond is
    port(
    -- entrées
        Cond, CC_EX, CC : in std_logic_vector(3 downto 0) := (others => '0');
        CCWr_EX : in STD_LOGIC := '0';
    -- sorties
        CC_out : out std_logic_vector(3 downto 0) := (others => '0');
        CondEx : out STD_LOGIC := '0'
  );
end entity;
  
  
architecture gestionCond_arch of gestionCond is
    signal N,Z,C,V,condex_t : STD_LOGIC := '0';
begin

    N <= CC_EX(3);
    Z <= CC_EX(2);
    C <= CC_EX(1);
    V <= CC_EX(0);
    CondEx <= condex_t;

    CC_out <= CC when CCWr_EX = '1' and condex_t = '1' else CC_EX;
    with Cond select
        condex_t <= Z when "0000",
                    not Z when "0001",
                    C when "0010",
                    not C when "0011",
                    N when "0100",
                    not N when "0101",
                    V when "0110",
                    not V when "0111",
                    C and (not Z) when "1000",
                    (not C) or Z when "1001",
                    N xnor V when "1010",
                    N xor V when "1011",
                    (not Z) and (N xnor V) when "1100",
                    Z or (N xor V) when "1101",
                    '1' when others;

        

end architecture;








-------------------------------------------------------

-- Chemin de données

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


entity dataPath is
  port(
    clk,  init, ALUSrc_EX, MemWr_Mem, MemWr_RE, PCSrc_ER, Bpris_EX, Gel_LI, Gel_DI, RAZ_DI, RegWR, Clr_EX, MemToReg_RE : in std_logic := '0';
    RegSrc, EA_EX, EB_EX, immSrc, ALUCtrl_EX : in std_logic_vector(1 downto 0) := (others => '0');
    instr_DE: out std_logic_vector(31 downto 0) := (others => '0');
    a1, a2, rs1, rs2, CC, op3_EX_out, op3_ME_out, op3_RE_out: out std_logic_vector(3 downto 0)  := (others => '0')
);      
end entity;

architecture dataPath_arch of dataPath is
  signal Res_RE, npc_fw_br, pc_plus_4, i_FE, i_DE, Op1_DE, Op2_DE, Op1_EX, Op2_EX, extImm_DE, extImm_EX, Res_EX, Res_ME, WD_EX, WD_ME, Res_Mem_ME, Res_Mem_RE, Res_ALU_ME, Res_ALU_RE, Res_fwd_ME : std_logic_vector(31 downto 0) := (others => '0');
  signal Op3_DE, Op3_EX_t, a1_DE, a1_EX, a2_DE, a2_EX, Op3_EX_out_t, Op3_ME, Op3_ME_out_t, Op3_RE, Op3_RE_out_t : std_logic_vector(3 downto 0) := (others => '0');
begin





  -- FE
    inst_FE: entity WORK.etageFE
    port map(
        npc => Res_RE,
        npc_fw_br => npc_fw_br,
        pc_plus_4 => pc_plus_4,
        i_FE => i_FE,
        Gel_LI => GEL_LI,
        Bpris_EX => Bpris_EX,
        PCSrc_ER => PCSrc_ER,
        clk => clk
    );

    proc_FE : process (clk)
    begin
        if rising_edge(clk) then
            if Gel_DI = '0' then
                i_DE <= i_FE;
            end if;
        end if;        
    end process;

    instr_DE <= i_DE;
    
  -- DE
  inst_DE: entity WORK.etageDE
  port map(
      i_DE => i_DE,
      pc_plus_4 => pc_plus_4,
      WD_ER => Res_RE,
      Op3_ER => Op3_RE_out_t,
      clk => clk,
      extImm => extImm_DE,
      Op3_DE => Op3_DE,
      Op2 => Op2_DE,
      op1 => Op1_DE,
      Reg2 => a2_DE,
      Reg1 => a1_DE,
      RegWr => RegWR,
      immSrc => immSrc,
      RegSrc => RegSrc,
      Init => init
  );

  proc_DE : process (clk)
  begin
      if rising_edge(clk) then
        if Clr_EX = '0' then 
            a1_EX <= a1_DE;
            a2_EX <= a2_DE;
            Op1_EX <= Op1_DE;
            Op2_EX <= Op2_DE;
            Op3_EX_t <= Op3_DE;
            extImm_EX <= extImm_DE;
        end if;
      end if;        
  end process;

  -- EX
  inst_EX: entity WORK.etageEX
  port map(
    Op3_EX => Op3_EX_t,
    Op1_EX => Op1_EX,
    Op2_EX => Op2_EX,
    ExtImm_EX => extImm_EX,
    Res_fwd_ER => Res_RE,
    Res_fwd_ME => Res_fwd_ME,
    npc_fw_br => npc_fw_br,
    WD_EX => WD_EX,
    Op3_EX_out => op3_EX_out_t,
    Res_EX => Res_EX,
    CC => CC,
    ALUCtrl_EX => ALUCtrl_EX,
    ALUSrc_EX => ALUSrc_EX,
    EB_EX => EB_EX,
    EA_EX => EA_EX

  );

  proc_EX : process (clk)
  begin
      if rising_edge(clk) then
        Res_ME <= Res_EX;
        Op3_ME <= op3_EX_out_t;
        WD_ME <= WD_EX;
      end if;        
  end process;

  a1 <= a1_EX;
  a2 <= a2_EX;
  op3_EX_out <= op3_EX_out_t;
 
  -- ME
  inst_ME: entity WORK.etageME
  port map(
      Res_ME => Res_ME,
      Op3_ME => Op3_ME,
      WD_ME => WD_ME,
      clk => clk,
      Res_fwd_ME => Res_fwd_ME,
      Op3_ME_out => Op3_ME_out_t,
      Res_ALU_ME => Res_ALU_ME,
      Res_Mem_ME => Res_Mem_ME,
      MemWr_Mem => MemWr_Mem
  );

  proc_ME : process (clk)
  begin
      if rising_edge(clk) then
          Res_Mem_RE <= Res_Mem_ME;
          Res_ALU_RE <= Res_ALU_ME;
          Op3_RE <= Op3_ME_out_t;
      end if;        
  end process;

  Op3_ME_out <= Op3_ME_out_t;
 
  -- RE
  inst_RE: entity WORK.etageRE
  port map(
      Res_Mem_RE => Res_Mem_RE,
      Res_ALU_RE => Res_ALU_RE,
      Op3_RE => Op3_RE,
      op3_RE_out => Op3_RE_out_t,
      Res_RE => Res_RE,
      MemToReg_RE => MemToReg_RE
  );

  Op3_RE_out <= Op3_RE_out_t;
 
  
end architecture;
