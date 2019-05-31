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

	-- Alu component definition
	component alu is
		port (
			op   : in  alu_op_type;
			A, B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
			Z    : out std_logic;
			V    : out std_logic
		);
	end component;

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

	-- Synchronous Process
	latch : process(clk, reset)
	begin
		-- Asynchronous reset
		if (reset = '0') then

			current_op <= nop_instr;

			-- Reset forward signals
			pc_out <= (others=>'0');
			memop_out <= MEM_NOP;
			jmpop_out <= JMP_NOP;
			wbop_out <= WB_NOP;

		elsif (rising_edge(clk)) then
			-- Stall the pipeline
			if (stall = '0') then
				current_op <= op;
				-- Forward signals
				pc_out <= pc_in;
				memop_out <= memop_in;
				jmpop_out <= jmpop_in;
				wbop_out <= wbop_in;
			end if;
			if (flush = '1') then
				-- Flush the operation registers
				current_op <= nop_instr;

				-- Reset forward signals
				pc_out <= (others=>'0');
				memop_out <= MEM_NOP;
				jmpop_out <= JMP_NOP;
				wbop_out <= WB_NOP;
			end if;
		end if;
	end process;

	-- Control the aluresult output
	output : process(all)
	begin
		neg <= '0';
		if (alu_inter(DATA_WIDTH-1) = '1') then
			neg <= '1';
		end if;
		zero <= zero_int;
		exc_ovf <= exc_ovf_int;
		-- Check for a cop0 instruction
		if (current_op.cop0 = '1') then
			aluresult <= cop0_rddata;
		-- Check if the pc should be used for output
		elsif (current_op.link = '1') then
			aluresult <= (pc_out'length to DATA_WIDTH-1 => '0') & pc_out;
		-- Otherwise the alu output will be used
		else
			aluresult <= alu_inter;
			-- Check if the alu flags should be adjusted
		end if;

		-- Route the new_pc output
		-- Check for a branch instruction
		if (current_op.branch = '1') then
			new_pc <= adder_inter(PC_WIDTH-1 downto 0);
		-- Check if a jump jump instruction was issued
	elsif (jmpop_out = JMP_JMP and current_op.regdst = '0') then
			new_pc <= current_op.imm(PC_WIDTH-3 downto 0) & "00";
		elsif (jmpop_out = JMP_JMP and current_op.regdst = '1') then
			new_pc <= current_op.readdata1(PC_WIDTH-1 downto 0);
		else
			new_pc <= (others=>'0');
		end if;

		wrdata <= current_op.readdata2;
	end process;

	-- Set the alu inputs as needed
	alu_in : process(all)
	begin
		if (current_op.useimm = '0') then
			second_operator <= current_op.readdata2;
		else
			second_operator <= current_op.imm;
		end if;
	end process;

	-- Adder for the new pc
	adder : process(all)
	begin
		adder_inter <= std_logic_vector(signed(pc_out) - 4 + shift_left(signed(current_op.imm), 2));
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
