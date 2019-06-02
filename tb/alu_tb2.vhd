library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.core_pack.all;
use work.op_pack.all;

package alu_pkg is
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

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.core_pack.all;
use work.op_pack.all;
use work.alu_pkg.all;

entity alu_tb2 is

end entity;

architecture alu_tb2 of alu_tb2 is

  signal op : alu_op_type;
  signal A, B : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal R : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal Z, V : std_logic;

begin

  test : process
  
  constant NUM_COL	: integer := 3;		-- number of columns of file
  file inputfile	: text open read_mode is "alu_tb2_input.txt";
  variable row		: line;
  variable data_row_counter : integer := 0;
  variable file_op : string(9 downto 1);
  variable file_A	: std_logic_vector(DATA_WIDTH-1 downto 0);
  variable file_B 	: std_logic_vector(DATA_WIDTH-1 downto 0);
  
  
  begin
  
  
  
    if(not endfile(inputfile)) then
		data_row_counter := data_row_counter + 1;
		readline(inputfile, row);
		
		read(row,file_A);
		read(row,file_B);
	
		A <= file_A;
		B <= file_B;
		
		read(row,file_op);
		op <= alu_op_type'value(file_op);
		
	end if;
	
	
	
	
	
	
	wait for 10 ns;
  
  
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
