LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE bus_mux_pkg IS
	TYPE bus_mux_array IS ARRAY(NATURAL RANGE<>) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
END PACKAGE bus_mux_pkg;

-------------------------------------------------

-- 32 bits Register (For PC storage and register files)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity Reg32 is
  PORT(
    source: in std_logic_vector(31 downto 0);
    output : out std_logic_vector(31 downto 0);
    wr, clk : in std_logic
    );
end entity;

architecture arch_reg of Reg32 is
  signal sig : std_logic_vector(31 downto 0):=(others => '0');
begin
  output <= sig;
  process(clk)
  begin
    if(rising_edge(clk)) then
      if(wr = '1') then
        sig <= source;    
      end if;
    end if;
  end process;
end architecture;
          
-------------------------------------------------

-- 4 bits Register (For PC storage and register files)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity Reg4 is
  PORT(
    source: in std_logic_vector(3 downto 0);
    output : out std_logic_vector(3 downto 0);
    wr, clk : in std_logic
    );
end entity;

architecture arch_reg of Reg4 is
  signal sig : std_logic_vector(3 downto 0):=(others => '0');
begin
  output <= sig;
  process(clk)
  begin
    if(rising_edge(clk)) then
      if(wr = '1') then
        sig <= source;    
      end if;
    end if;
  end process;
end architecture;


-------------------------------------------------

-- Register bank

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.bus_mux_pkg.ALL;

ENTITY RegisterBank IS
	PORT
	(
		s_reg_0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		data_o_0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		s_reg_1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		data_o_1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		dest_reg : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		data_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                pc_in : in STD_LOGIC_VECTOR(31 downto 0);
                pc_out : out STD_LOGIC_VECTOR(31 downto 0);
		wr_reg : IN STD_LOGIC;
		clk : IN STD_LOGIC
	);
END ENTITY RegisterBank;


architecture arch_reg_bank of RegisterBank IS
  signal regs : bus_mux_array(31 downto 0);

begin
  data_o_0 <= regs(to_integer(unsigned(s_reg_0)));
  data_o_1 <= regs(to_integer(unsigned(s_reg_1)));
  process(clk)
    variable dest: integer;  
  begin
    if(wr_reg='1' and rising_edge(clk)) then
      dest := to_integer(unsigned(dest_reg));
      regs(dest)<=data_i;
      if dest /= 15 then
        regs(15)<= pc_in;
    end if;
    end if;
  end process;
  
end architecture;
