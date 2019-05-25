library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity exec is

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

end exec;

architecture rtl of exec is

	constant nop_instr : exec_op_type := (
		aluop => ALU_NOP,
		readdata1 => (others=>'0'),
		readdata2 => (others=>'0'),
		imm => (others=>'0'),
		rs => (others=>'0'),
		rt => (others=>'0'),
		rd => (others=>'0'),
		useimm => '0',
		useamt => '0',
		link => '0',
		branch => '0',
		regdst => '0',
		cop0 => '0',
		ovf => '0'
	);
	signal alu_intermediate : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal current_op : exec_op_type;

begin

	-- Breakout signals from instruction
	rs <= current_op.rs;
	rd <= current_op.rd;
	rt <= current_op.rt;

	-- Forward signals
	pc_out <= pc_in;
	memop_out <= memop_in;
	jmpop_out <= jmpop_in;
	wbop_out <= wbop_in;

	-- Synchronous Process
	input : process(clk)
	begin
		-- Asynchronous reset
		if (reset = '0') then

			current_op <= nop_instr;

		elsif (rising_edge(clk)) then
			-- Stall the pipeline
			if (stall = '0') then
					if (flush = '1') then
						-- Flush the operation registers
						current_op.aluop <= nop_instr;
					else
						current_op <= op;
					end if;
			end if;
		end if;
	end process;

	exec : process(current_op)
	begin
		if (current_op.cop0 = '1') then
			aluresult <= cop0_rddata;
		elsif (current_op.useadd = '1'
				and alu_intermediate(DATA_WIDTH-1) = '1') then
			
		else
			aluresult <= alu_intermediate;
		end if;
	end process;

	adder : process(current_op.useadd)
	begin

	end process;

	alu_inst : alu
	port map (
		op => current_op.aluop,
		A => current_op.readdata1,
		B => current_op.readdata2,
		R => alu_intermediate,
		Z => zero,
		V => exc_ovf
	);

end rtl;
