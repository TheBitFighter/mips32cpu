library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity ctrl is

	port (
		clk : in std_logic;
		reset : in std_logic;
		op : in exec_op_type;
		fl_fetch : out std_logic;
		fl_decode : out std_logic
);

end ctrl;

architecture rtl of ctrl is

	signal current_op : exec_op_type;

begin

	latch : process(clk, reset)
	begin
		if (reset = '1') then
		elsif (rising_edge(clk)) then
			current_op <= op;
		end if;
	end process;

	flush : process(current_op)
	begin
		if (current_op.branch = '1') then
			fl_fetch <= '1';
			fl_decode <= '1';
		else
			fl_fetch <= '0';
			fl_decode <= '0';
		end if;

	end process;

end rtl;
