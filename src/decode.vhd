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

	signal rdaddr1, rdaddr2 : std_logic_vector(REG_BITS-1 downto 0);
	signal rddata1, rddata2 : std_logic_vector(DATA_WIDTH-1 downto 0);

	signal opcode : std_logic_vector(5 downto 0);
	signal rs : std_logic_vector(4 downto 0);
	signal rt : std_logic_vector(4 downto 0);
	signal rd : std_logic_vector(4 downto 0);
	signal shamt : std_logic_vector(4 downto 0);
	signal func : std_logic_vector(5 downto 0);
	signal address, immediate : std_logic_vector(15 downto 0);
	signal target_adress : std_logic_vector(25 downto 0);
begin  -- rtl

	opcode <= instr(31 downto 26);
	rs <= instr(25 downto 21);
	rt <= instr(20 downto 16);
	rd <= instr(15 downto 11) when opcode = "000000" or opcode = "010000" else instr(20 downto 16); -- R or I format
	shamt <= instr(10 downto 6);
	func <= instr(5 downto 0);
	address <= instr(15 downto 0);
	immediate <= instr(15 downto 0);
	target_adress <= instr(25 downto 0);

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
			exec_op.rd <= rd;

			case opcode is
				when "000000" => --MiMi special instructions
					case func is
						when "000000" => -- SLL
							exec_op.aluop <= ALU_SLL;
							exec_op.useamt <= '1';


						when others =>

					end case;
				when others =>

			end case;
		end if;
	end process;

	regfile_inst : regfile
	port map(
		clk => clk,
		reset => reset,
		rdaddr1 => rdaddr1,
		rdaddr2 => rdaddr2,
		rddata1 => rddata1,
		rddata2 => rddata2,
		wraddr => wraddr,
		wrdata => wrdata,
		regwrite => regwrite
	);

end rtl;
