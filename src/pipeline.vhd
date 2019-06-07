library ieee;
use ieee.std_logic_1164.all;

use work.core_pack.all;
use work.op_pack.all;

entity pipeline is
	port (
		clk, reset : in	 std_logic;
		mem_in     : in  mem_in_type;
		mem_out    : out mem_out_type;
		intr       : in  std_logic_vector(INTR_COUNT-1 downto 0));
end pipeline;

architecture rtl of pipeline is
	component fetch is
		port (
			clk, reset : in	 std_logic;
			stall      : in  std_logic;
			pcsrc	   : in	 std_logic;
			pc_in	   : in	 std_logic_vector(PC_WIDTH-1 downto 0);
			pc_out	   : out std_logic_vector(PC_WIDTH-1 downto 0);
			instr	   : out std_logic_vector(INSTR_WIDTH-1 downto 0));
	end component;

	component decode is
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
	end component;

	component exec is
		port (
			clk, reset       : in  std_logic;
			stall      		 : in  std_logic;
			flush            : in  std_logic;
			pc_in            : in  std_logic_vector(PC_WIDTH-1 downto 0);
			op	   	         : in  exec_op_type;
			pc_out           : out std_logic_vector(PC_WIDTH-1 downto 0);
			rd, rs, rt       : out std_logic_vector(REG_BITS-1 downto 0);
			aluresult	     : out std_logic_vector(DATA_WIDTH-1 downto 0);
			wrdata           : out std_logic_vector(DATA_WIDTH-1 downto 0);
			zero, neg         : out std_logic;
			new_pc           : out std_logic_vector(PC_WIDTH-1 downto 0);
			memop_in         : in  mem_op_type;
			memop_out        : out mem_op_type;
			jmpop_in         : in  jmp_op_type;
			jmpop_out        : out jmp_op_type;
			wbop_in          : in  wb_op_type;
			wbop_out         : out wb_op_type;
			forwardA         : in  fwd_type;
			forwardB         : in  fwd_type;
			cop0_rddata      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			mem_aluresult    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			wb_result        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			exc_ovf          : out std_logic);
	end component;

	component mem is
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
	end component;

	component wb is
		port (
			clk, reset : in  std_logic;
			stall      : in  std_logic;
			flush      : in  std_logic;
			op	   	   : in  wb_op_type;
			rd_in      : in  std_logic_vector(REG_BITS-1 downto 0);
			aluresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			memresult  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			rd_out     : out std_logic_vector(REG_BITS-1 downto 0);
			result     : out std_logic_vector(DATA_WIDTH-1 downto 0);
			regwrite   : out std_logic);
	end component;

	component cntrl is
		port (
			clk : in std_logic;
			reset : in std_logic;
			pcsrc : in std_logic;
			fl_fetch : out std_logic;
			fl_decode : out std_logic);
	end component;

	component fwd is
		port (
			reset : in std_logic;
			clk : in std_logic;
			next_op : in exec_op_type;
			forwardA : out fwd_type;
			forwardB : out fwd_type
		);
	end component;

	-- signals
	signal stall : std_logic;
	signal flush, fl_decode : std_logic

	signal fetch_pc_out	   : std_logic_vector(PC_WIDTH-1 downto 0);
	signal fetch_instr	   : std_logic_vector(INSTR_WIDTH-1 downto 0);

	signal decode_pc_out     : std_logic_vector(PC_WIDTH-1 downto 0);
	signal decode_exec_op    : exec_op_type;
	signal decode_cop0_op    : cop0_op_type;
	signal decode_jmp_op     : jmp_op_type;
	signal decode_mem_op     : mem_op_type;
	signal decode_wb_op      : wb_op_type;
	signal decode_exc_dec    : std_logic;

	signal exec_pc_out								: std_logic_vector(PC_WIDTH-1 downto 0);
	signal exec_rd, exec_rs, exec_rt	: std_logic_vector(REG_BITS-1 downto 0);
	signal exec_aluresult							: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal exec_wrdata           			: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal exec_zero, exec_neg        : std_logic;
	signal exec_new_pc           			: std_logic_vector(PC_WIDTH-1 downto 0);
	signal exec_memop_out        			: mem_op_type;
	signal exec_jmpop_out        			: jmp_op_type;
	signal exec_wbop_out         			: wb_op_type;
	signal exec_exc_ovf          			: std_logic;

	signal mem_pc_out        : std_logic_vector(PC_WIDTH-1 downto 0);
	signal mem_pcsrc         : std_logic;
	signal mem_rd_out        : std_logic_vector(REG_BITS-1 downto 0);
	signal mem_aluresult_out : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal mem_memresult     : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal mem_new_pc_out    : std_logic_vector(PC_WIDTH-1 downto 0);
	signal mem_wbop_out      : wb_op_type;
	signal mem_exc_load      : std_logic;
	signal mem_exc_store     : std_logic;

	signal wb_rd_out     : std_logic_vector(REG_BITS-1 downto 0);
	signal wb_result     : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal wb_regwrite   : std_logic;

	signal forwardA		: fwd_type;
	signal forwardB		: fwd_type;

begin  -- rtl
	stall <= '1' when mem_in.busy = '1' else '0';
	flush <= '0';

	fetch_inst : fetch
	port map (
		clk => clk,
		reset => reset,
		stall => stall,
		pcsrc => mem_pcsrc,
		pc_in => mem_new_pc_out,
		pc_out => fetch_pc_out,
		instr => fetch_instr
	);

	decode_inst : decode
	port map (
		clk => clk,
		reset => reset,
		stall => stall,
		flush => fl_decode,
		pc_in => fetch_pc_out,
		instr => fetch_instr,
		wraddr => wb_rd_out,
		wrdata => wb_result,
		regwrite => wb_regwrite,
		pc_out => decode_pc_out,
		exec_op => decode_exec_op,
		cop0_op => decode_cop0_op,
		jmp_op => decode_jmp_op,
		mem_op => decode_mem_op,
		wb_op => decode_wb_op,
		exc_dec => decode_exc_dec
	);

	exec_inst : exec
	port map (
		clk => clk,
		reset => reset,
		stall => stall,
		flush => flush,
		op => decode_exec_op,
		rd => exec_rd,
		rs => exec_rs,
		rt => exec_rt,
		aluresult => exec_aluresult,
		wrdata => exec_wrdata,
		zero => exec_zero,
		neg => exec_neg,
		new_pc => exec_new_pc,
		pc_in => decode_pc_out,
		pc_out => exec_pc_out,
		memop_in => decode_mem_op,
		memop_out => exec_memop_out,
		jmpop_in => decode_jmp_op,
		jmpop_out => exec_jmpop_out,
		wbop_in => decode_wb_op,
		wbop_out => exec_wbop_out,
		forwardA => forwardA,
		forwardB => forwardB,
		cop0_rddata => (others => '0'), -- ???
		mem_aluresult => mem_aluresult_out,
		wb_result => wb_result,
		exc_ovf => exec_exc_ovf
	);

		mem_inst : mem
		port map (
			clk => clk,
			reset => reset,
			stall => stall,
			flush => flush,
			mem_op => exec_memop_out,
			jmp_op => exec_jmpop_out,
			wrdata => exec_wrdata,
			memresult => mem_memresult,
			zero => exec_zero,
			neg => exec_neg,
			pcsrc => mem_pcsrc,
			new_pc_in => exec_new_pc,
			new_pc_out => mem_new_pc_out,
			pc_in => exec_pc_out,
			pc_out => mem_pc_out,
			rd_in => exec_rd,
			rd_out => mem_rd_out,
			aluresult_in => exec_aluresult,
			aluresult_out => mem_aluresult_out,
			wbop_in => exec_wbop_out,
			wbop_out => mem_wbop_out,
			mem_out => mem_out,
			mem_data => mem_in.rddata,
			exc_load => mem_exc_load,
			exc_store => mem_exc_store
		);

		wb_inst : wb
		port map (
			clk => clk,
			reset => reset,
			stall => stall,
			flush => flush,
			op => mem_wbop_out,
			aluresult => mem_aluresult_out,
			memresult => mem_memresult,
			result => wb_result,
			regwrite => wb_regwrite,
			rd_in => mem_rd_out,
			rd_out => wb_rd_out
		);

		cntrl_inst : cntrl
		port map (
			clk => clk,
			reset => reset,
			op => mem_pcsrc,
			fl_out => fl_decode
		);

		fwd_inst : fwd
		port map (
			clk => clk,
			reset => reset,
			next_op => decode_exc_op,
			forwardA => forwardA,
			forwardB => forwardB
		);

end rtl;
