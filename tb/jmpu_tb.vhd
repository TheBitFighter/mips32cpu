library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity jmpu_tb is
end entity;

architecture arch of jmpu_tb is
  signal op : jmp_op_type;
  signal N, Z, J : std_logic;

  component jmpu is
  	port (
  		op   : in  jmp_op_type;
  		N, Z : in  std_logic;
  		J    : out std_logic);
  end component;

begin
  jmpu_inst : jmpu
  port map(
    op => op,
    N => N,
    Z => Z,
    J => J
  );

  sim : process
  begin
    op <= JMP_NOP;
    N <= '0';
    Z <= '0';
    wait for 10 ns;

    op <= JMP_JMP;
    wait for 10 ns;

    op <= JMP_BEQ;
    wait for 10 ns;

    op <= JMP_BNE;
    wait for 10 ns;

    op <= JMP_BLEZ;
    wait for 10 ns;

    N <= '1';
    wait for 10 ns;

    op <= JMP_BGTZ;
    wait for 10 ns;

    op <= JMP_BLTZ;
    wait for 10 ns;

    op <= JMP_BGEZ;
    wait;
  end process;
end arch;
