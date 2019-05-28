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
	signal alu_inter, adder_inter : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal current_op : exec_op_type;
	signal second_operator : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal exc_ovf_int, zero_int : std_logic;

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
	latch : process(clk)
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

	-- Control the aluresult output
	output : process(current_op)
	begin
		-- Set the alu flags to 0 by default
		neg <= '0';
		zero <= '0';
		exc_ovf <= '0';
		-- Check for a cop0 instruction
		if (current_op.cop0 = '1') then
			aluresult <= cop0_rddata;
			new_pc <= (others=>'0');
		-- Check for a branch instruction
		elsif (branch = '1') then
			aluresult <= adder_inter;
			new_pc <= adder_inter(PC_WIDTH-1 downto 0);
		-- Check if the pc should be used for output
		elsif (link = 1) then
			aluresult <= '0' & pc_in;
			new_pc <= pc_in;
		-- Check if a jump jump instruction was issued
		elsif (jmp_op = JMP_JMP and current_op.regdst = '0') then
			aluresult <= std_logic_vector(shift_left(unsigned(current_op.imm), 2));
			new_pc <= std_logic_vector(shift_left(unsigned(current_op.imm), 2))(PC_WIDTH-1 downto 0);
		elsif (jmp_op = JMP_JMP and current_op.regdst = '1') then
			aluresult <= current_op.readdata1;
			new_pc <= current_op.readdata1(PC_WIDTH-1 downto 0);
		-- Otherwise the alu output will be used
		else
			aluresult <= alu_inter;
			new_pc <= (others=>'0');
			-- Check if the alu flags should be adjusted
			if (alu_inter(DATA_WIDTH-1) = '1') then
				neg <= '1';
			end if;
			zero <= zero_int;
			exc_ovf <= exc_ovf_int;
		end if;
	end process;

	-- Set the alu inputs as needed
	alu_in : process(current_op)
		if (useimm = '0') then
			second_operator <= current_op.readdata2;
		else
			second_operator <= std_logic_vector(shift_left(signed(current_op.imm), 2));
		end if;
	end process;

	-- Adder for the new pc
	adder : process(current_op)
		adder_inter <= std_logic_vector(unsigned(pc_in) + shift_left(signed(current_op.imm), 2) - 4);
	begin

	end process;

	alu_inst : alu
	port map (
		op => current_op.aluop,
		A => current_op.readdata1,
		B => second_operator,
		R => alu_inter,
		Z => zero_int,
		V => exc_ovf_int
	);

end rtl;
