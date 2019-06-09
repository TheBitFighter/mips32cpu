library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity ctrl is
	port (
		clk : in std_logic;
		reset : in std_logic;
		pcsrc : in std_logic;
		fl_out : out std_logic
		);
end ctrl;

architecture rtl of ctrl is

	type state_type is (IDLE, FLUSH2);
	signal state, state_next : state_type;

begin

	latch : process(clk, reset)
	begin
		if (reset = '0') then
			--pcsrc_reg <= '0';
			state <= IDLE;
		elsif (rising_edge(clk)) then
			--pcsrc_reg <= pcsrc;
			state <= state_next;
		end if;
	end process;

	flush : process(all)
	begin
		state_next <= state;

		case state is
			when IDLE =>
				if (pcsrc = '1') then
					fl_out <= '1';
					state_next <= FLUSH2;
				else
					fl_out <= '0';
				end if;
			when FLUSH2 =>
				fl_out <= '1';
				if pcsrc = '0' then
					state_next <= IDLE;
				end if;
		end case;
	end process;

end rtl;
