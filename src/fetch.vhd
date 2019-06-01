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

	signal insrt_reg : std_logic_vector(INSTR_WIDTH-1 downto 0);
	signal stall_reg : std_logic;
begin

	fetcher : process(clk, reset)
	begin
		-- Reset
		if (reset = '0') then
			pc_out <= std_logic_vector(to_signed(0, PC_WIDTH)); -- 0 or -4, tests needed
			stall_reg <= '0';
		-- Synchronous part
		elsif (rising_edge(clk)) then
			stall_reg <= stall;
			-- Stall the pipeline
			if (stall = '0') then
				-- If pcsrc is asserted, use pc_in as the new counter
				if (pcsrc = '1') then
					pc_out <= pc_in;
				-- If it is not asserted, add 4 to the program counter
				else
					pc_out <= std_logic_vector(signed(pc_out) + 4);
				end if;
			end if;
		end if;
	end process;

	-- Instruction memory
	imem : imem_altera
	port map (
		clock => clk,
		q => insrt_reg,
		address => pc_out(PC_WIDTH-1 downto 2)
	);

	instr <= instr when stall_reg = '1' else insrt_reg;

end rtl;

-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
--
-- use work.core_pack.all;
--
-- entity fetch is
--
-- 	port (
-- 		clk, reset : in	 std_logic;
-- 		stall      : in  std_logic;
-- 		pcsrc	   : in	 std_logic;
-- 		pc_in	   : in	 std_logic_vector(PC_WIDTH-1 downto 0);
-- 		pc_out	   : out std_logic_vector(PC_WIDTH-1 downto 0);
-- 		instr	   : out std_logic_vector(INSTR_WIDTH-1 downto 0));
--
-- end fetch;
--
-- architecture rtl of fetch is
--
-- 	signal next_counter : std_logic_vector(PC_WIDTH-1 downto 0);
-- 		component imem_altera is
-- 			port
-- 			(
-- 				address		: in std_logic_vector (11 downto 0);
-- 				clock		: in std_logic  := '1';
-- 				q		: out std_logic_vector (31 downto 0)
-- 			);
-- 		end component;
-- begin
--
-- 	fetcher : process(clk)
-- 	begin
-- 		-- Reset
-- 		if (reset = '0') then
-- 			pc_out <= std_logic_vector(to_unsigned(0, PC_WIDTH));
-- 			next_counter <= std_logic_vector(to_unsigned(0, PC_WIDTH));
-- 		-- Synchronous part
-- 		elsif (rising_edge(clk)) then
-- 			-- Stall the pipeline
-- 			if (stall = '0') then
-- 				-- If pcsrc is asserted, use pc_in as the new counter
-- 				if (pcsrc = '1') then
-- 					next_counter <= pc_in;
-- 					pc_out <= pc_in;
-- 				-- If it is not asserted, add 4 to the program counter
-- 				else
-- 					next_counter <= std_logic_vector(unsigned(next_counter) + 4);
-- 					pc_out <= next_counter;
-- 				end if;
-- 			end if;
-- 		end if;
-- 	end process;
--
-- 	-- Instruction memory
-- 	imem : imem_altera
-- 	port map (
-- 		clock => clk,
-- 		q => instr,
-- 		address => pc_out(PC_WIDTH-1 downto 2)
-- 	);
--
-- end rtl;
