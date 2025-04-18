-------------------------------------------------------

-- Gestion des aléas

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity gestionAleas is
    port (
      a1, a2, op3_ME_out, op3_RE_out : in std_logic_vector(3 downto 0);
      RegWr_Mem, RegWr_RE : in std_logic;
      Reg1, Reg2, op3_EX_out : in std_logic_vector(3 downto 0);
      MemToReg_EX : in std_logic;
      PCSrc_DE, PCSrc_EX, PCSrc_ME, PCSrc_ER, Bpris_EX : in std_logic;
  
      EA_EX, EB_EX : out std_logic_vector(1 downto 0);  
      Gel_LI, En_DI, Clr_EX, Clr_DI : out std_logic
    );
  end entity;
  
architecture arch_gestionAleas of gestionAleas is
begin

process(a1, a2, op3_ME_out, op3_RE_out, RegWr_Mem, RegWr_RE,
        Reg1, Reg2, op3_EX_out, MemToReg_EX,
        PCSrc_DE, PCSrc_EX, PCSrc_ME, PCSrc_ER, Bpris_EX)
    variable stall : std_logic;
begin

    -- === Forwarding EA_EX ===
    if (a1 = op3_ME_out and RegWr_Mem = '1') then
    EA_EX <= "10";
    elsif (a1 = op3_RE_out and RegWr_RE = '1' and a1 /= op3_ME_out) then
    EA_EX <= "01";
    else
    EA_EX <= "00";
    end if;

    -- === Forwarding EB_EX ===
    if (a2 = op3_ME_out and RegWr_Mem = '1') then
    EB_EX <= "10";
    elsif (a2 = op3_RE_out and RegWr_RE = '1' and a2 /= op3_ME_out) then
    EB_EX <= "01";
    else
    EB_EX <= "00";
    end if;

    -- === LDR Stall ===
    if ((Reg1 = op3_EX_out or Reg2 = op3_EX_out) and MemToReg_EX = '1') then
    stall := '1';
    else
    stall := '0';
    end if;

    -- === Contrôle pipeline ===
    Gel_LI <= not (stall or PCSrc_DE or PCSrc_EX or PCSrc_ME);
    En_DI  <= not stall;
    Clr_EX <= not (stall or Bpris_EX);
    Clr_DI <= not (PCSrc_DE or PCSrc_EX or PCSrc_ME or PCSrc_ER or Bpris_EX);

end process;

end architecture;
