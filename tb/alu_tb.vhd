use ieee.numeric_std;

use work.alu.all;
use work.op_pack.all;
use work.core_pack.all;

package alu is
  component alu is
    port (
  		op   : in  alu_op_type;
  		A, B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
  		Z    : out std_logic;
  		V    : out std_logic
      );
  end component;
end package;

architecture alu_tb of alu_tb is

  signal instr : alu_op_type;
  signal A, B : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal R : std_logic_vector (DATA_WIDTH-1, downto 0);
  signal Z, V : std_logic;

begin

  test : process
    instr <= ALU_NOP;
    A <= (others=>'0');
    B <= (others=>'0');
    wait for 10 ns;
    instr <= ALU_ADD;
    A <= std_logic_vector(to_integer(1, DATA_WIDTH));
    B <= std_logic_vector(to_integer(1, DATA_WIDTH));
    wait for 2 ns;
    assert R = std_logic_vector(to_integer(2, DATA_WIDTH));
    wait;
  begin

  end process;

  alu_inst : alu
  port map (
    op => instr,
    A => A,
    B => B,
    R => R,
    Z => Z,
    V => V
  );

end architecture;
