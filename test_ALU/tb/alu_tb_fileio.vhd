library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.core_pack.all;
use work.op_pack.all;

entity alu_tb_fileio is
end entity;

architecture arch of alu_tb_fileio is
  component alu is
    port (
      op   : in  alu_op_type;
      A, B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
      Z    : out std_logic;
      V    : out std_logic
      );
  end component;

  signal op : alu_op_type;
  signal A, B : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal R : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal Z, V : std_logic;

  file inputfile	: text;
  file outputfile	: text;
begin

  test : process
    variable line_input : line;
    variable line_output : line;
    variable v_op : string(1 to 8);
    variable v_A, v_B, v_R : std_logic_vector(DATA_WIDTH-1 downto 0);
    variable v_Z, v_V : std_logic;
    variable SPACE : character;
  begin

    file_open(inputfile, "./testdata/input.txt", read_mode);
    file_open(outputfile, "./testdata/output.txt", read_mode);

    while not endfile(inputfile) loop
      readline(inputfile, line_input);
      read(line_input, v_op);
      read(line_input, v_A);
      read(line_input, v_B);

      readline(outputfile, line_output);
      read(line_output, v_R);
      read(line_output, v_Z);
      read(line_output, v_V);

      op <= alu_op_type'value(v_op);
      A <= v_A;
      b <= v_B;

      wait for 10 ns;

      assert R = v_R report "R is wrong, expected " & to_bstring(v_R) & " result: " & to_bstring(R);
      assert Z = v_Z report "Z is wrong, expected " & std_logic'image(v_Z) & " result: " & std_logic'image(Z);
      assert V = v_V report "V is wrong, expected " & std_logic'image(v_V) & " result: " & std_logic'image(V);

    end loop;

    file_close(inputfile);
    file_close(outputfile);

  end process;

  alu_inst : alu
  port map (
    op => op,
    A => A,
    B => B,
    R => R,
    Z => Z,
    V => V
  );

end architecture;
