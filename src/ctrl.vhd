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

	signal pcsrc_reg : std_logic;
	type state_type is (IDLE, FLUSH2);
	signal state : state_type := IDLE;
	);

begin

	latch : process(clk, reset)
	begin
		if (reset = '1') then
			pcsrc_reg <= '0';
		elsif (rising_edge(clk)) then
			pcsrc_reg <= pcsrc
		end if;
	end process;

	flush : process(pcsrc_reg, clk)
	begin
		case state is
			when IDLE =>
				if (pcsrc_reg = '1') then
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
