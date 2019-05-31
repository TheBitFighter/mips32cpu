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
		instr	   	 : in  std_logic_vector(INSTR_WIDTH-1 downto 0);
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
			wraddr					 : in  std_logic_vector(REG_BITS-1 downto 0);
			wrdata					 : in  std_logic_vector(DATA_WIDTH-1 downto 0);
			regwrite         : in  std_logic);
	end component;

	alias opcode : std_logic_vector(5 downto 0) is instr(31 downto 26);
	alias rs : std_logic_vector(4 downto 0) is instr(25 downto 21);
	alias rt : std_logic_vector(4 downto 0) is instr(20 downto 16);
	alias rd_r : std_logic_vector(4 downto 0) is instr(15 downto 11);
	alias rd_i : std_logic_vector(4 downto 0) is instr(20 downto 16);
	alias shamt : std_logic_vector(4 downto 0) is instr(10 downto 6);
	alias func : std_logic_vector(5 downto 0) is instr(5 downto 0);
	alias address_immediate : std_logic_vector(15 downto 0) is instr(15 downto 0);
	alias target_address : std_logic_vector(25 downto 0) is instr(25 downto 0);

	signal rddata1 : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal rddata2 : std_logic_vector(DATA_WIDTH-1 downto 0);
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
				exec_op <= EXEC_NOP;
				cop0_op <= COP0_NOP;
				jmp_op <= JMP_NOP;
				mem_op <= MEM_NOP;
				wb_op <= WB_NOP;
				exc_dec <= '0';

				exec_op.readdata1 <= rddata1;
				exec_op.readdata2 <= rddata2;
				exec_op.rs <= rs;
				exec_op.rt <= rt;
				exec_op.imm <= (16 to DATA_WIDTH-1 => address_immediate(15)) & address_immediate;
				if opcode = "000000" or opcode = "010000" then
					exec_op.rd <= rd_r;
				else
					exec_op.rd <= rd_i;
				end if;

				case opcode is
					when "000000" => -- MiMi special instruction
						wb_op.regwrite <= '1';
						case func is
							when "000000" => -- SLL
								exec_op.aluop <= ALU_SLL;
								exec_op.readdata1 <= (0 to DATA_WIDTH-6 => '0') & shamt;
								exec_op.useamt <= '1';
							when "000010" => -- SRL
								exec_op.aluop <= ALU_SRL;
								exec_op.readdata1 <= (0 to DATA_WIDTH-6 => '0') & shamt;
								exec_op.useamt <= '1';
							when "000011" => -- SRA
								exec_op.aluop <= ALU_SRA;
								exec_op.readdata1 <= (0 to DATA_WIDTH-6 => '0') & shamt;
								exec_op.useamt <= '1';
							when "000100" => -- SLLV
								exec_op.aluop <= ALU_SLL;
							when "000110" => -- SRLV
								exec_op.aluop <= ALU_SRL;
							when "000111" => -- SRAV
								exec_op.aluop <= ALU_SRA;
							when "001000" => -- JR
								jmp_op <= JMP_JMP;
								exec_op.regdst <= '1';
								wb_op.regwrite <= '0';
							when "001001" => -- JALR
								jmp_op <= JMP_JMP;
								exec_op.regdst <= '1';
								exec_op.link <= '1';
							when "100000" => -- ADD
								exec_op.aluop <= ALU_ADD;
							when "100001" => -- ADDU
								exec_op.aluop <= ALU_ADD;
								exec_op.ovf <= '1';
							when "100010" => -- SUB
								exec_op.aluop <= ALU_SUB;
							when "100011" => -- SUBU
								exec_op.aluop <= ALU_SUB;
								exec_op.ovf <= '1';
							when "100100" => -- AND
								exec_op.aluop <= ALU_AND;
							when "100101" => -- OR
								exec_op.aluop <= ALU_OR;
							when "100110" => -- XOR
								exec_op.aluop <= ALU_XOR;
							when "100111" => -- NOR
								exec_op.aluop <= ALU_XOR;
							when "101010" => -- SLT
								exec_op.aluop <= ALU_SLT;
							when "101011" => -- SLTU
								exec_op.aluop <= ALU_SLTU;
							when others =>
								exc_dec <= '1';
						end case;
					when "000001" => -- MiMi regimm instructions
						case rd_i is
							when "00000" => -- BLTZ
								exec_op.aluop <= ALU_SLT;
								exec_op.branch <= '1';
								jmp_op <= JMP_BLTZ;
							when "00001" => -- BGEZ
								exec_op.aluop <= ALU_SLT;
								exec_op.branch <= '1';
								jmp_op <= JMP_BGEZ;
							when "10000" => -- BLTZAL
								exec_op.aluop <= ALU_SLT;
								exec_op.link <= '1';
								exec_op.rd <= (others => '0'); -- r31
								exec_op.branch <= '1';
								jmp_op <= JMP_BLTZ;
								wb_op.regwrite <= '1';
							when "10001" => -- BGEZAL
								exec_op.aluop <= ALU_SLT;
								exec_op.link <= '1';
								exec_op.rd <= (others => '0'); -- r31
								exec_op.branch <= '1';
								jmp_op <= JMP_BGEZ;
								wb_op.regwrite <= '1';
							when others =>
								exc_dec <= '1';
						end case;
					when "000010" => -- J
						exec_op.useimm <= '1';
						jmp_op <= JMP_JMP;
					when "000011" => -- JAL
						exec_op.useimm <= '1';
						exec_op.link <= '1';
						exec_op.rd <= (others => '0'); -- r31
						jmp_op <= JMP_JMP;
						wb_op.regwrite <= '1';
					when "000100" => -- BEQ
						exec_op.aluop <= ALU_SUB;
						exec_op.branch <= '1';
						jmp_op <= JMP_BEQ;
					when "000101" => -- BNE
						exec_op.aluop <= ALU_SUB;
						exec_op.branch <= '1';
						jmp_op <= JMP_BNE;
					when "000110" => -- BLEZ
						exec_op.aluop <= ALU_SLT;
						exec_op.branch <= '1';
						jmp_op <= JMP_BLEZ;
					when "000111" => -- BGTZ
						exec_op.aluop <= ALU_SLT;
						exec_op.branch <= '1';
						jmp_op <= JMP_BGTZ;
					when "001000" => -- ADDI
						exec_op.aluop <= ALU_ADD;
						exec_op.useimm <= '1';
						exec_op.ovf <= '1';
						wb_op.regwrite <= '1';
					when "001001" => -- ADDIU
						exec_op.aluop <= ALU_ADD;
						exec_op.useimm <= '1';
						wb_op.regwrite <= '1';
					when "001010" => -- SLTI
						exec_op.aluop <= ALU_SLT;
						exec_op.useimm <= '1';
						wb_op.regwrite <= '1';
					when "001011" => -- SLTIU
						exec_op.aluop <= ALU_SLTU;
						exec_op.useimm <= '1';
						wb_op.regwrite <= '1';
						exec_op.imm <= (16 to DATA_WIDTH-1 => '0') & address_immediate;
					when "001100" => -- ANDI
						exec_op.aluop <= ALU_AND;
						exec_op.useimm <= '1';
						wb_op.regwrite <= '1';
						exec_op.imm <= (16 to DATA_WIDTH-1 => '0') & address_immediate;
					when "001101" => -- ORI
						exec_op.aluop <= ALU_OR;
						exec_op.useimm <= '1';
						wb_op.regwrite <= '1';
						exec_op.imm <= (16 to DATA_WIDTH-1 => '0') & address_immediate;
					when "001110" => -- XORI
						exec_op.aluop <= ALU_XOR;
						exec_op.useimm <= '1';
						wb_op.regwrite <= '1';
						exec_op.imm <= (16 to DATA_WIDTH-1 => '0') & address_immediate;
					when "001111" => -- LUI;
						exec_op.aluop <= ALU_LUI;
						exec_op.useimm <= '1';
						wb_op.regwrite <= '1';
						exec_op.imm <= (16 to DATA_WIDTH-1 => '0') & address_immediate;
					when "010000" => -- MiMi cop0 instructions
						case rd_r is
							when "00000" => -- MFC0
								exec_op.cop0 <= '1';
								cop0_op.addr <= rd_r;
								wb_op.regwrite <= '1';
							when "00100" => -- MTC0
								exec_op.cop0 <= '1';
								cop0_op.wr <= '1';
								cop0_op.addr <= rd_r;
							when others =>
								exc_dec <= '1';
						end case;
					when "100000" => -- LB
						exec_op.aluop <= ALU_ADD;
						exec_op.useimm <= '1';
						mem_op.memread <= '1';
						mem_op.memtype <= MEM_B;
						wb_op.memtoreg <= '1';
						wb_op.regwrite <= '1';
					when "100001" => -- LH
						exec_op.aluop <= ALU_ADD;
						exec_op.useimm <= '1';
						mem_op.memread <= '1';
						mem_op.memtype <= MEM_H;
						wb_op.memtoreg <= '1';
						wb_op.regwrite <= '1';
					when "100011" => -- LW
						exec_op.aluop <= ALU_ADD;
						exec_op.useimm <= '1';
						mem_op.memread <= '1';
						mem_op.memtype <= MEM_W;
						wb_op.memtoreg <= '1';
						wb_op.regwrite <= '1';
					when "100100" => -- LBU
						exec_op.aluop <= ALU_ADD;
						exec_op.useimm <= '1';
						mem_op.memread <= '1';
						mem_op.memtype <= MEM_BU;
						wb_op.memtoreg <= '1';
						wb_op.regwrite <= '1';
					when "100101" => -- LHU
						exec_op.aluop <= ALU_ADD;
						exec_op.useimm <= '1';
						mem_op.memread <= '1';
						mem_op.memtype <= MEM_HU;
						wb_op.memtoreg <= '1';
						wb_op.regwrite <= '1';
					when "101000" => -- SB
						exec_op.aluop <= ALU_ADD;
						exec_op.useimm <= '1';
						mem_op.memwrite <= '1';
						mem_op.memtype <= MEM_B;
					when "101001" => -- SH
						exec_op.aluop <= ALU_ADD;
						exec_op.useimm <= '1';
						mem_op.memwrite <= '1';
						mem_op.memtype <= MEM_H;
					when "101011" => -- SW
						exec_op.aluop <= ALU_ADD;
						exec_op.useimm <= '1';
						mem_op.memwrite <= '1';
						mem_op.memtype <= MEM_W;
					when others =>
						exc_dec <= '1';
				end case;
			end if;
			if flush = '1' then
				pc_out <= (others => '0');
				exec_op <= EXEC_NOP;
				cop0_op <= COP0_NOP;
				jmp_op <= JMP_NOP;
				mem_op <= MEM_NOP;
				wb_op <= WB_NOP;
				exc_dec <= '0';
			end if;
		end if;
	end process;

	regfile_inst : regfile
	port map(
		clk => clk,
		reset => reset,
		stall => stall,
		rdaddr1 => rs,
		rdaddr2 => rt,
		rddata1 => rddata1,
		rddata2 => rddata2,
		wraddr => wraddr,
		wrdata => wrdata,
		regwrite => regwrite
	);

end rtl;
