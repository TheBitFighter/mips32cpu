library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity decode is
	port (
		clk, reset : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;
		pc_in      : in  std_logic_vector(PC_WIDTH-1 downto 0);
		instr	   : in  std_logic_vector(INSTR_WIDTH-1 downto 0);
		wraddr     : in  std_logic_vector(REG_BITS-1 downto 0);
		wrdata     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite   : in  std_logic;
		pc_out     : out std_logic_vector(PC_WIDTH-1 downto 0);
		exec_op    : out exec_op_type;
		cop0_op    : out cop0_op_type;
		jmp_op     : out jmp_op_type;
		mem_op     : out mem_op_type;
		wb_op      : out wb_op_type;
		exc_dec    : out std_logic);
end decode;

architecture rtl of decode is
	component regfile is
		port (
			clk, reset       : in  std_logic;
			stall            : in  std_logic;
			rdaddr1, rdaddr2 : in  std_logic_vector(REG_BITS-1 downto 0);
			rddata1, rddata2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
			wraddr			 : in  std_logic_vector(REG_BITS-1 downto 0);
			wrdata			 : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			regwrite         : in  std_logic);
	end component;

	signal opcode_reg : std_logic_vector(5 downto 0);
	signal rs_reg : std_logic_vector(4 downto 0);
	signal rt_reg : std_logic_vector(4 downto 0);
	signal rd_r_reg : std_logic_vector(4 downto 0);
	signal rd_i_reg : std_logic_vector(4 downto 0);
	signal shamt_reg : std_logic_vector(4 downto 0);
	signal func_reg : std_logic_vector(5 downto 0);
	signal address_immediante_reg : std_logic_vector(15 downto 0);
	signal target_address_reg : std_logic_vector(25 downto 0);
begin  -- rtl
	decode : process(clk, reset)
	begin
		if reset = '0' then
			pc_out <= (others => '0');
			exec_op <= EXEC_NOP;
			cop0_op <= COP0_NOP;
			jmp_op <= JMP_NOP;
			mem_op <= MEM_NOP;
			wb_op <= WB_NOP;
			exc_dec <= '0';
		elsif rising_edge(clk) then
			if stall = '0' then
				pc_out <= pc_in;

				opcode_reg <= instr(31 downto 26);
				rs_reg <= instr(25 downto 21);
				rt_reg <= instr(20 downto 16);
				rd_r_reg <= instr(15 downto 11);
				rd_i_reg <= instr(20 downto 16);
				shamt_reg <= instr(10 downto 6);
				func_reg <= instr(5 downto 0);
				address_immediante_reg <= instr(15 downto 0);
				target_address_reg <= instr(25 downto 0);

			end if;
			if flush = '1' then

			end if;
		end if;
	end process;

	regfile_inst : regfile
	port map(
		clk => clk,
		reset => reset,
		rdaddr1 => ,
		rdaddr2 => ,
		rddata1 => ,
		rddata2 => ,
		wraddr => ,
		wrdata => ,
		regwrite =>
	);

end rtl;
