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
	signal op : mem_op_type;
	signal mem_data_reg : std_logic_vector(DATA_WIDTH-1 downto 0);
begin  -- rtl
	mem : process(clk, reset)
	begin
		if reset = '0' then
			pc_out <= (others => '0');
			rd_out <= (others => '0');
			aluresult_out <= (others => '0');
			wbop_out <= WB_NOP;

			mem_op_reg <= MEM_NOP;
			mem_data_reg <= (others => '0');
		elsif rising_edge(clk) then
			if stall = '0' then
				pc_out <= pc_in;
				rd_out <= rd_in;
				aluresult_out <= aluresult_in;
				wbop_out <=  wbop_in;

				mem_op_reg <= mem_op;
				mem_data_reg <= mem_data;
			end if;
			if flush = '1' then
				pc_out <= (others => '0');
				rd_out <= (others => '0');
				aluresult_out <= (others => '0');
				wbop_out <= WB_NOP;

				mem_op_reg <= MEM_NOP;
				mem_data_reg <= (others => '0');
			end if;
		end if;
	end process;

	jmpu_inst : jmpu
	port map(
		op => jmp_op,
		N => neg,
		Z => zero,
		J => pcsrc
	);

	new_pc_out <= new_pc_in;

	op.memtype <= mem_op_reg.memtype;
	op.memwrite <= '0' when stall = '1' else mem_op_reg.memwrite;
	op.memread <= '0' when stall = '1' else mem_op_reg.memread;

	memu_inst : memu
	port map(
		op => op,
		A => aluresult_out(ADDR_WIDTH-1 downto 0), --?????
		W => wrdata,
		D => mem_data_reg,
		M => mem_out,
		R => memresult,
		XL => exc_load,
		XS => exc_store
	);


end rtl;

-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
--
-- use work.core_pack.all;
-- use work.op_pack.all;
--
-- entity mem is
-- 	port (
-- 		clk, reset    : in  std_logic;
-- 		stall         : in  std_logic;
-- 		flush         : in  std_logic;
-- 		mem_op        : in  mem_op_type;
-- 		jmp_op        : in  jmp_op_type;
-- 		pc_in         : in  std_logic_vector(PC_WIDTH-1 downto 0);
-- 		rd_in         : in  std_logic_vector(REG_BITS-1 downto 0);
-- 		aluresult_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
-- 		wrdata        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
-- 		zero, neg     : in  std_logic;
-- 		new_pc_in     : in  std_logic_vector(PC_WIDTH-1 downto 0);
-- 		pc_out        : out std_logic_vector(PC_WIDTH-1 downto 0);
-- 		pcsrc         : out std_logic;
-- 		rd_out        : out std_logic_vector(REG_BITS-1 downto 0);
-- 		aluresult_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
-- 		memresult     : out std_logic_vector(DATA_WIDTH-1 downto 0);
-- 		new_pc_out    : out std_logic_vector(PC_WIDTH-1 downto 0);
-- 		wbop_in       : in  wb_op_type;
-- 		wbop_out      : out wb_op_type;
-- 		mem_out       : out mem_out_type;
-- 		mem_data      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
-- 		exc_load      : out std_logic;
-- 		exc_store     : out std_logic);
-- end mem;
--
-- architecture rtl of mem is
-- 	component jmpu is
-- 		port (
-- 			op   : in  jmp_op_type;
-- 			N, Z : in  std_logic;
-- 			J    : out std_logic);
-- 	end component;
--
-- 	component memu is
-- 		port (
-- 			op   : in  mem_op_type;
-- 			A    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
-- 			W    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
-- 			D    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
-- 			M    : out mem_out_type;
-- 			R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
-- 			XL   : out std_logic;
-- 			XS   : out std_logic);
-- 	end component;
--
-- 	-- internal registers
-- 	-- in
-- 	signal flush_reg          : std_logic;
-- 	signal mem_op_reg         : mem_op_type;
-- 	signal jmp_op_reg         : jmp_op_type;
-- 	signal pc_in_reg          : std_logic_vector(PC_WIDTH-1 downto 0);
-- 	signal rd_in_reg          : std_logic_vector(REG_BITS-1 downto 0);
-- 	signal aluresult_in_reg   : std_logic_vector(DATA_WIDTH-1 downto 0);
-- 	signal wrdata_reg         : std_logic_vector(DATA_WIDTH-1 downto 0);
-- 	signal zero_reg , neg_reg : std_logic;
-- 	signal new_pc_in_reg      : std_logic_vector(PC_WIDTH-1 downto 0);
-- 	signal wbop_in_reg        : wb_op_type;
-- 	signal mem_data_reg       : std_logic_vector(DATA_WIDTH-1 downto 0);
-- 	-- out
-- 	signal pcsrc_reg					: std_logic;
-- 	signal mem_out_reg				: mem_out_type;
-- 	signal memresult_reg			: std_logic_vector(DATA_WIDTH-1 downto 0);
-- 	signal exc_load_reg				: std_logic;
-- 	signal exc_store_reg			: std_logic;
-- begin  -- rtl
-- 	mem : process(clk, reset)
-- 	begin
-- 		if reset = '0' then
-- 			flush_reg <= '0';
-- 			mem_op_reg <= MEM_NOP;
-- 			jmp_op_reg <= JMP_NOP;
-- 			pc_in_reg <= (others => '0');
-- 			rd_in_reg <= (others => '0');
-- 			aluresult_in_reg <= (others => '0');
-- 			wrdata_reg <= (others => '0');
-- 			zero_reg <= '0';
-- 			neg_reg <= '0';
-- 			new_pc_in_reg <= (others => '0');
-- 			wbop_in_reg <= WB_NOP;
-- 			mem_data_reg <= (others => '0');
-- 		elsif rising_edge(clk) then
-- 			if stall = '0' then
-- 				flush_reg <= flush;
-- 				mem_op_reg <= mem_op;
-- 				jmp_op_reg <= jmp_op;
-- 				pc_in_reg <= pc_in;
-- 				rd_in_reg <= rd_in;
-- 				aluresult_in_reg <= aluresult_in;
-- 				wrdata_reg <= wrdata;
-- 				zero_reg <= zero;
-- 				neg_reg <= neg;
-- 				new_pc_in_reg <= new_pc_in;
-- 				wbop_in_reg <= wbop_in;
-- 				mem_data_reg <= mem_data;
-- 			else
-- 				mem_op_reg.memread <= '0';
-- 				mem_op_reg.memwrite <= '0';
-- 			end if;
-- 		end if;
-- 	end process;
--
-- 	outputs : process(all)
-- 	begin
-- 		if flush_reg = '1' then
-- 			pc_out <= (others => '0');
-- 			pcsrc <= '0';
-- 			rd_out <= (others => '0');
-- 			aluresult_out <= (others => '0');
-- 			memresult <= (others => '0');
-- 			new_pc_out <= (others => '0');
-- 			wbop_out <= WB_NOP;
-- 			mem_out.address <= (others => '0');
-- 			mem_out.rd <= '0';
-- 			mem_out.wr <= '0';
-- 			exc_load <= '0';
-- 			exc_store <= '0';
-- 		else
-- 			pc_out <= pc_in_reg;
-- 			pcsrc <= pcsrc_reg;
-- 			rd_out <= rd_in_reg;
-- 			aluresult_out <= aluresult_in_reg;
-- 			memresult <= memresult_reg;
-- 			new_pc_out <= new_pc_in_reg;
-- 			wbop_out <= wbop_in_reg;
-- 			mem_out <= mem_out_reg;
-- 			exc_load <= exc_load_reg;
-- 			exc_store <= exc_store_reg;
-- 		end if;
-- 	end process;
--
-- 	jmpu_inst : jmpu
-- 	port map(
-- 		op => jmp_op_reg,
-- 		N => neg_reg,
-- 		Z => zero_reg,
-- 		J => pcsrc_reg
-- 	);
--
-- 	memu_inst : memu
-- 	port map(
-- 		op => mem_op_reg,
-- 		A => aluresult_in_reg(ADDR_WIDTH-1 downto 0), --?????
-- 		W => wrdata_reg,
-- 		D => mem_data_reg,
-- 		M => mem_out_reg,
-- 		R => memresult_reg,
-- 		XL => exc_load_reg,
-- 		XS => exc_store_reg
-- 	);
-- end rtl;
