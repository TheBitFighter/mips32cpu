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
	component imem_altera is
		port
		(
			address		: in std_logic_vector (11 downto 0);
			clock		: in std_logic  := '1';
			q		: out std_logic_vector (31 downto 0)
		);
	end component;

	signal instr_reg : std_logic_vector(INSTR_WIDTH-1 downto 0);
	signal pc, pc_next : std_logic_vector(PC_WIDTH-1 downto 0);
begin

	fetcher : process(clk, reset)
	begin
		-- Reset
		if (reset = '0') then
			pc <= std_logic_vector(to_signed(-4, PC_WIDTH));
		-- Synchronous part
		elsif rising_edge(clk) then
			pc <= pc_next;
		end if;
	end process;

	output : process(all)
	begin
		if reset = '1' and stall = '0' then
			if pcsrc = '1' then
				pc_next <= pc_in;
				pc_out <= pc_in;
			else
				pc_next <= std_logic_vector(signed(pc) + 4);
				pc_out <= std_logic_vector(signed(pc) + 4);
			end if;
		else
			pc_next <= pc;
			pc_out <= pc;
		end if;
	end process;

	-- flush
	instr <= (others => '0') when pcsrc = '1' else instr_reg;

	-- Instruction memory
	imem : imem_altera
	port map (
		clock => clk,
		q => instr_reg,
		address => pc_next(PC_WIDTH-1 downto 2)
	);

end rtl;
