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

	signal insrt_reg, stall_instr_reg : std_logic_vector(INSTR_WIDTH-1 downto 0);
	signal stall_reg : std_logic;
	signal pc_next : std_logic_vector(PC_WIDTH-1 downto 0);
begin

	fetcher : process(clk, reset)
	begin
		-- Reset
		if (reset = '0') then
			pc_next <= std_logic_vector(to_signed(0, PC_WIDTH));
			stall_reg <= '0';
			stall_instr_reg <= (others => '0');
		-- Synchronous part
		elsif (rising_edge(clk)) then
			stall_reg <= stall;
			stall_instr_reg <= instr;
			-- Stall the pipeline
			if (stall = '0') then
				-- If pcsrc is asserted, use pc_in as the new counter
				if (pcsrc = '1') then
					pc_next <= pc_in;
				-- If it is not asserted, add 4 to the program counter
				else
					pc_next <= std_logic_vector(signed(pc_next) + 4);
				end if;
			end if;
		end if;
	end process;

	-- Instruction memory
	imem : imem_altera
	port map (
		clock => clk,
		q => insrt_reg,
		address => pc_next(PC_WIDTH-1 downto 2)
	);

	pc_out <= pc_next;
	instr <= stall_instr_reg when stall_reg = '1' else insrt_reg;

end rtl;
