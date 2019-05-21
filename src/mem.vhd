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
	signal jmp_op_reg : jmp_op_type;
	signal zero_reg : std_logic;
	signal neg_reg : std_logic;
	signal pcsrc_reg : std_logic;
	signal mem_op_reg : mem_op_type;
	signal aluresult_in_reg : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal wrdata_reg : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal mem_data_reg : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal memresult_reg : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal mem_out_reg : mem_out_type;
	signal exc_load_reg : std_logic;
	signal exc_store_reg : std_logic;
begin  -- rtl
	mem : process(clk, reset)
	begin
		if reset = '0' then
			-- reset outputs
			pc_out <= (others => '0');
			pcsrc <= '0';
			rd_out <= (others => '0');
			aluresult_out <= (others => '0');
			memresult <= (others => '0');
			new_pc_out <= (others => '0');
			wbop_out <= WB_NOP;
			mem_out.address <= (others => '0');
			mem_out.rd <= '0';
			mem_out.wr <= '0';
			mem_out.byteena <= (others => '0');
			mem_out.wrdata <= (others => '0');
			exc_load <= '0';
			exc_store <= '0';
			-- reset internal registers
			jmp_op_reg <= JMP_NOP;
			zero_reg <= '0';
			neg_reg <= '0';
			pcsrc_reg <= '0';
			mem_op_reg <= MEM_NOP;
			aluresult_in_reg <= (others => '0');
			wrdata_reg <= (others => '0');
			mem_data_reg <= (others => '0');
		elsif rising_edge(clk) then
			if stall = '0' then
				new_pc_out <= new_pc_in;
				pc_out <= pc_in;
				rd_out <= rd_in;
				wbop_out <= wbop_in;
				aluresult_out <= aluresult_in;

				jmp_op_reg <= jmp_op;
				zero_reg <= zero;
				neg_reg <= neg;
				mem_op_reg <= mem_op;
				aluresult_in_reg <= aluresult_in;
				wrdata_reg <= wrdata;

				pcsrc <= pcsrc_reg;
				memresult <= memresult_reg;
				mem_out <= mem_out_reg;
				exc_load <= exc_load_reg;
				exc_store <= exc_store_reg;

				if flush = '1' then
					-- reset outputs
					pc_out <= (others => '0');
					pcsrc <= '0';
					rd_out <= (others => '0');
					aluresult_out <= (others => '0');
					memresult <= (others => '0');
					new_pc_out <= (others => '0');
					wbop_out <= WB_NOP;
					mem_out.address <= (others => '0');
					mem_out.rd <= '0';
					mem_out.wr <= '0';
					mem_out.byteena <= (others => '0');
					mem_out.wrdata <= (others => '0');
					exc_load <= '0';
					exc_store <= '0';
				end if;
			else
				mem_op_reg.memread <= '0';
				mem_op_reg.memwrite <= '0';
			end if;
		end if;
	end process;

	jmpu_inst : jmpu
	port map(
		op => jmp_op_reg,
		N => neg,
		Z => zero,
		J => pcsrc_reg
	);

	memu_inst : memu
	port map(
		op => mem_op_reg,
		A => aluresult_in_reg(ADDR_WIDTH-1 downto 0), --?????
		W => wrdata_reg,
		D => mem_data_reg,
		M => mem_out_reg,
		R => memresult_reg,
		XL => exc_load_reg,
		XS => exc_store_reg
	);
end rtl;
