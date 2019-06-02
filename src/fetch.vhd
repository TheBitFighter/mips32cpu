library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;

entity fetch is

	port (
		clk, reset : in	 std_logic;
		stall      : in  std_logic;
		pcsrc	   : in	 std_logic;
		pc_in	   : in	 std_logic_vector(PC_WIDTH-1 downto 0);
		pc_out	   : out std_logic_vector(PC_WIDTH-1 downto 0);
		instr	   : out std_logic_vector(INSTR_WIDTH-1 downto 0));

end fetch;

architecture rtl of fetch is

	signal next_counter : std_logic_vector(PC_WIDTH-1 downto 0);

begin

	fetcher : process(clk)
	begin
		-- Reset
		if (reset = '0') then
			pc_out <= std_logic_vector(to_unsigned(0, PC_WIDTH));
			next_counter <= std_logic_vector(to_unsigned(0, PC_WIDTH));
		-- Synchronous part
		elsif (rising_edge(clk)) then
			-- Stall the pipeline
			if (stall = '0') then
				-- If pcsrc is asserted, use pc_in as the new counter
				if (pcsrc = '1') then
					next_counter <= pc_in;
					pc_out <= pc_in;
				-- If it is not asserted, add 4 to the program counter
				else
					next_counter <= std_logic_vector(unsigned(next_counter) + 4);
					pc_out <= next_counter;
				end if;
			end if;
		end if;
	end process;

	-- Instruction memory
	imem : imem_altera
	port map (
		clock => clk,
		q => instr,
		address => next_counter
	);

end rtl;
