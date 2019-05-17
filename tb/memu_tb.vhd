library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity memu_tb is
end entity;

architecture arch of memu_tb is
  signal op : mem_op_type;
  signal A : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal W, D,R : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal M : mem_out_type;
  signal XL, XS : std_logic;

  component memu is
  	port (
  		op   : in  mem_op_type;
  		A    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
  		W    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  		D    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  		M    : out mem_out_type;
  		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
  		XL   : out std_logic;
  		XS   : out std_logic);
  end component;

begin
  memu_inst : memu
  port map(
    op => op,
    A => A,
    W => W,
    D => D,
    M => M,
    R => R,
    XL => XL,
    XS => xs
  );

  sim : process
  begin
    op.memread <= '0';
    op.memwrite <= '0';
    op.memtype <= MEM_B;
    A <= (others => '1');
    W <= "11111111" & "10101010" & "10011001" & "10001000";
    D <= "11111111" & "10101010" & "10011001" & "10001000";
    wait for 20 ns;

    op.memtype <= MEM_B;
    A(1 downto 0) <= "00";
    wait for 20 ns;

    A(1 downto 0) <= "01";
    wait for 20 ns;

    A(1 downto 0) <= "10";
    wait for 20 ns;

    A(1 downto 0) <= "11";
    wait for 20 ns;

    op.memtype <= MEM_BU;
    A(1 downto 0) <= "00";
    wait for 20 ns;

    A(1 downto 0) <= "01";
    wait for 20 ns;

    A(1 downto 0) <= "10";
    wait for 20 ns;

    A(1 downto 0) <= "11";
    wait for 20 ns;

    op.memtype <= MEM_H;
    A(1 downto 0) <= "00";
    wait for 20 ns;

    A(1 downto 0) <= "01";
    wait for 20 ns;

    A(1 downto 0) <= "10";
    wait for 20 ns;

    A(1 downto 0) <= "11";
    wait for 20 ns;

    op.memtype <= MEM_HU;
    A(1 downto 0) <= "00";
    wait for 20 ns;

    A(1 downto 0) <= "01";
    wait for 20 ns;

    A(1 downto 0) <= "10";
    wait for 20 ns;

    A(1 downto 0) <= "11";
    wait for 20 ns;

    op.memtype <= MEM_W;
    A(1 downto 0) <= "00";
    wait for 20 ns;

    A(1 downto 0) <= "01";
    wait for 20 ns;

    A(1 downto 0) <= "10";
    wait for 20 ns;

    A(1 downto 0) <= "11";
    wait for 20 ns;

    op.memread <= '1';
    op.memwrite <= '1';
    op.memtype <= MEM_H;
    A <= (1 downto 0 => '0', others => '1');
    wait for 20 ns;

    A <= (others => '0');
    wait for 20 ns;

    A(1 downto 0) <= "10";
    wait for 20 ns;

    op.memtype <= MEM_HU;
    A(1 downto 0) <= "01";

    wait;
  end process;
end arch;
