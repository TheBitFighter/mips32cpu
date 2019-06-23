library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity mem is
	port (
		clk, reset    : in  std_logic;
		stall         : in  std_logic;
		flush         : in  std_logic;
		mem_op        : in  mem_op_type;
		jmp_op        : in  jmp_op_type;
		pc_in         : in  std_logic_vector(PC_WIDTH-1 downto 0);
		rd_in         : in  std_logic_vector(REG_BITS-1 downto 0);
		aluresult_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		wrdata        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		zero, neg     : in  std_logic;
		new_pc_in     : in  std_logic_vector(PC_WIDTH-1 downto 0);
		pc_out        : out std_logic_vector(PC_WIDTH-1 downto 0);
		pcsrc         : out std_logic;
		rd_out        : out std_logic_vector(REG_BITS-1 downto 0);
		aluresult_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
		memresult     : out std_logic_vector(DATA_WIDTH-1 downto 0);
		new_pc_out    : out std_logic_vector(PC_WIDTH-1 downto 0);
		wbop_in       : in  wb_op_type;
		wbop_out      : out wb_op_type;
		mem_out       : out mem_out_type;
		mem_data      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		exc_load      : out std_logic;
		exc_store     : out std_logic);
end mem;

architecture rtl of mem is
	component jmpu is
		port (
			op   : in  jmp_op_type;
			N, Z : in  std_logic;
			J    : out std_logic);
	end component;

	component memu is
		port (
			op   : in  mem_op_type;
			A    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
			W    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			D    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			M    : out mem_out_type;
			R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
			XL   : out std_logic;
			XS   : out std_logic);
	end component;

	-- internal registers
	signal mem_op_reg : mem_op_type := MEM_NOP;
	signal stall_reg : std_logic;
	signal op_reg : mem_op_type;
	signal wrdata_reg : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal aluresult_next : std_logic_vector(DATA_WIDTH-1 downto 0);

	signal jmp_op_reg : jmp_op_type;
	signal N, Z : std_logic;
	signal new_pc_in_reg : std_logic_vector(PC_WIDTH-1 downto 0);
begin  -- rtl
	mem : process(clk, reset, flush)
	begin
		if reset = '0' then
			pc_out <= (others => '0');
			rd_out <= (others => '0');
			aluresult_next <= (others => '0');
			wbop_out <= WB_NOP;

			mem_op_reg <= MEM_NOP;
			wrdata_reg <= (others => '0');
			jmp_op_reg <= JMP_NOP;
			N <= '0';
			Z <= '0';
			new_pc_in_reg <= (others => '0');
		elsif flush = '1' then
			jmp_op_reg <= JMP_NOP;
			mem_op_reg <= MEM_NOP;
			wbop_out <= WB_NOP;
		elsif rising_edge(clk) then
			stall_reg <= stall;
			if stall = '0' then
				pc_out <= pc_in;
				rd_out <= rd_in;
				aluresult_next <= aluresult_in;
				wbop_out <=  wbop_in;

				mem_op_reg <= mem_op;
				wrdata_reg <= wrdata;
				jmp_op_reg <= jmp_op;
				N <= neg;
				Z <= zero;
				new_pc_in_reg <= new_pc_in;
			end if;
		end if;
	end process;

	jmpu_inst : jmpu
	port map(
		op => jmp_op_reg,
		N => N,
		Z => Z,
		J => pcsrc
	);

	new_pc_out <= new_pc_in_reg;

	op_reg_p : process(all)
	begin
		op_reg.memtype <= mem_op_reg.memtype;

		if stall_reg = '1' then
			op_reg.memwrite <= '0';
			op_reg.memread <= '0';
		else
			op_reg.memwrite <= mem_op_reg.memwrite;
			op_reg.memread <= mem_op_reg.memread;
		end if;
	end process;

	memu_inst : memu
	port map(
		op => op_reg,
		A => aluresult_next(ADDR_WIDTH-1 downto 0),
		W => wrdata_reg,
		D => mem_data,
		M => mem_out,
		R => memresult,
		XL => exc_load,
		XS => exc_store
	);

	aluresult_out <= aluresult_next;

end rtl;
