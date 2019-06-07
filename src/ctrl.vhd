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
		fl_out : out std_logic
		);

end ctrl;

architecture rtl of ctrl is

	signal current_op : exec_op_type;
	type state_type is (IDLE, FLUSH2);
	signal state : state_type := IDLE;
	constant nop_instr : exec_op_type := (
		aluop => ALU_NOP,
		readdata1 => (others=>'0'),
		readdata2 => (others=>'0'),
		imm => (others=>'0'),
		rs => (others=>'0'),
		rt => (others=>'0'),
		rd => (others=>'0'),
		useimm => '0',
		useamt => '0',
		link => '0',
		branch => '0',
		regdst => '0',
		cop0 => '0',
		ovf => '0'
	);

begin

	latch : process(clk, reset)
	begin
		if (reset = '1') then
			current_op <= nop_instr;
		elsif (rising_edge(clk)) then
			current_op <= op;
		end if;
	end process;

	flush : process(current_op, clk)
	begin
		case state is
			when IDLE =>
				if (current_op.branch = '1') then
					fl_out <= '1';
					state <= FLUSH2;
				else
					fl_out <= '0';
				end if;
			when FLUSH2 =>
				if (rising_edge(clk)) then
					fl_out <= '1';
					state <= IDLE;
				end if;
		end case;
	end process;

end rtl;
