library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity fwd is
	port (
		reset : in std_logic;
		clk : in std_logic;
		next_op : in exec_op_type;
		forwardA : out fwd_type;
		forwardB : out fwd_type
);

end fwd;

architecture rtl of fwd is

	signal current_op : exec_op_type;
	signal rd1, rd2 : std_logic_vector(REG_BITS-1 downto 0);

begin

	latch : process(reset, clk)
	begin
		if (reset = '0') then
			rd1 <= (others=>'0');
			rd2 <= (others=>'0');
		elsif (rising_edge(clk)) then
			current_op <= next_op;
			rd1 <= current_op.rd;
			rd2 <= rd1;
		end if;
	end process;

	checkA : process(current_op)
	begin
		if (current_op.rs = rd1) then
			forwardA <= FWD_ALU;
		elsif (current_op.rs = rd2) then
			forwardA <= FWD_WB;
		else
			forwardA <= FWD_NONE;
		end if;
	end process;

	checkB : process(current_op)
	begin
		if (current_op.rs = rd1) then
			forwardB <= FWD_ALU;
		elsif (current_op.rs = rd2) then
			forwardB <= FWD_WB;
		else
			forwardB <= FWD_NONE;
		end if;
	end process;

end rtl;
