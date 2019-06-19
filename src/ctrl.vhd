library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity ctrl is
	port (
		clk : in std_logic;
		reset : in std_logic;
		stall : in std_logic;
		pcsrc_in : in std_logic;
		pcsrc_out : out std_logic;
		new_pc_in : in std_logic_vector(PC_WIDTH-1 downto 0);
		new_pc_out : out std_logic_vector(PC_WIDTH-1 downto 0);
		pc_decode_in : in std_logic_vector(PC_WIDTH-1 downto 0);
		pc_exec_in : in std_logic_vector(PC_WIDTH-1 downto 0);
		pc_mem_in : in std_logic_vector(PC_WIDTH-1 downto 0);
		exc_dec : in std_logic;
		exc_ovf : in std_logic;
		exc_load : in std_logic;
		exc_store : in std_logic;
		intr : in std_logic_vector(INTR_COUNT-1 downto 0);
		exec_op : in exec_op_type;
		cop0_op : in cop0_op_type;
		cop0_wrdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
		fl_decode : out std_logic;
		fl_mem : out std_logic;
		fl_exec : out std_logic;
		fl_wb : out std_logic
		);
end ctrl;

architecture rtl of ctrl is

	type state_type is (IDLE, FLUSH2);
	signal state, state_next : state_type;

	-- coprocessor 0 register addresses
	constant STATUS_ADDR : std_logic_vector(4 downto 0) := "01100";
	constant CAUSE_ADDR : std_logic_vector(4 downto 0) := "01101";
	constant EPC_ADDR : std_logic_vector(4 downto 0) := "01110";
	constant NPC_ADDR : std_logic_vector(4 downto 0) := "01111";

	-- coprocessor 0 registers
	signal status, status_nxt : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal cause, cause_nxt : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal epc, epc_nxt : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal npc, npc_nxt : std_logic_vector(DATA_WIDTH-1 downto 0);

	alias B : std_logic is cause_nxt(31);
	alias pen : std_logic_vector(2 downto 0) is cause_nxt(12 downto 10);
	alias exc : std_logic_vector(3 downto 0) is cause_nxt(5 downto 2);
	alias I : std_logic is status_nxt(0);

	-- exception codes
	constant exc_code_dec : std_logic_vector(3 downto 0) := "1010";
	constant exc_code_ovf : std_logic_vector(3 downto 0) := "1100";
	constant exc_code_load : std_logic_vector(3 downto 0) := "0100";
	constant exc_code_store : std_logic_vector(3 downto 0) := "0101";
	constant exc_code_intr : std_logic_vector(3 downto 0) := "0000";

	-- exceptions
	signal exc_dec_reg, exc_ovf_reg, exc_load_reg, exc_store_reg : std_logic;
	signal intr_reg :std_logic_vector(INTR_COUNT-1 downto 0);

	-- pc registers
	signal pc_decode_reg, pc_exec_reg, pc_mem_reg, pc_wb_reg : std_logic_vector(PC_WIDTH-1 downto 0);

	type bds_type is
	record
		decode : std_logic;
		exec : std_logic;
		mem : std_logic;
	end record;

	type new_pc_type is
	record
		decode : std_logic_vector(PC_WIDTH-1 downto 0);
		exec : std_logic_vector(PC_WIDTH-1 downto 0);
		mem : std_logic_vector(PC_WIDTH-1 downto 0);
	end record;

	signal bds : bds_type;
	signal new_pc : new_pc_type;

begin

	bds.decode <= pcsrc_in;
	new_pc.decode <= new_pc_in;

	latch : process(clk, reset, stall)
	begin
		if (reset = '0') then
			state <= IDLE;
			exc_dec_reg <= '0';
			exc_ovf_reg <= '0';
			exc_load_reg <= '0';
			exc_store_reg <= '0';
			intr_reg <= (others => '0');
			pc_decode_reg <= (others => '0');
			pc_exec_reg <= (others => '0');
			pc_mem_reg <= (others => '0');
			pc_wb_reg <= (others => '0');

			bds.exec <= '0';
			bds.mem <= '0';
			new_pc.exec <= (others => '0');
			new_pc.mem <= (others => '0');
			-- cop0 reg
			status <= (others => '0');
			cause <= (others => '0');
			epc <= (others => '0');
			npc <= (others => '0');
		elsif rising_edge(clk) and stall = '0' then
			state <= state_next;
			exc_dec_reg <= exc_dec;
			exc_ovf_reg <= exc_ovf;
			exc_load_reg <= exc_load;
			exc_store_reg <= exc_store;
			intr_reg <= intr;
			pc_decode_reg <= pc_decode_in;
			pc_exec_reg <= pc_exec_in;
			pc_mem_reg <= pc_mem_in;
			pc_wb_reg <= pc_mem_reg;

			bds.exec <= bds.decode;
			bds.mem <= bds.exec;
			new_pc.exec <= new_pc.decode;
			new_pc.mem <= new_pc.exec;
			-- cop0 reg
			status <= status_nxt;
			cause <= cause_nxt;
			epc <= epc_nxt;
			npc <= npc_nxt;
		end if;
	end process;

	cop : process(all)
	begin

		status_nxt <= status;
		cause_nxt <= cause;
		epc_nxt <= epc;
		npc_nxt <= npc;
		cop0_wrdata <= (others => '0');
		fl_decode <= '0';
		fl_exec <= '0';
		fl_mem <= '0';
		fl_wb <= '0';

		-- ctrl
		state_next <= state;

		case state is
			when IDLE =>
			if (pcsrc_in = '1') then
				fl_decode <= '1';
				state_next <= FLUSH2;
			else
				fl_decode <= '0';
			end if;
			when FLUSH2 =>
			fl_decode <= '1';
			if pcsrc_in = '0' then
				state_next <= IDLE;
			end if;
		end case;

			pcsrc_out <= pcsrc_in;
			new_pc_out <= new_pc_in;


		-- cop0
		--
		-- if exc_dec_reg = '1' or exc_ovf_reg = '1' or exc_load_reg = '1' or exc_store_reg = '1' then --or intr_reg = '1' then
		-- 	pcsrc_out <= '1';
		-- 	new_pc_out <= EXCEPTION_PC;
		-- else
		-- 	pcsrc_out <= pcsrc_in;
		-- 	new_pc_out <= new_pc_in;
		-- end if;
		--
		-- case cop0_op.addr is
		-- 	when STATUS_ADDR =>
		-- 		if cop0_op.wr = '1' then
		-- 			status_nxt <= exec_op.readdata2;
		-- 		else
		-- 			cop0_wrdata <= status;
		-- 		end if;
		-- 	when CAUSE_ADDR =>
		-- 		if cop0_op.wr = '1' then
		-- 			cause_nxt <= exec_op.readdata2;
		-- 		else
		-- 			cop0_wrdata <= cause;
		-- 		end if;
		-- 	when EPC_ADDR =>
		-- 		if cop0_op.wr = '1' then
		-- 			epc_nxt <= exec_op.readdata2;
		-- 		else
		-- 			cop0_wrdata <= epc;
		-- 		end if;
		-- 	when NPC_ADDR =>
		-- 		if cop0_op.wr = '1' then
		-- 			npc_nxt <= exec_op.readdata2;
		-- 		else
		-- 			cop0_wrdata <= npc;
		-- 		end if;
		-- 	when others => null;
		-- end case;
		--
		-- if exc_dec_reg = '1' then
		-- 	exc <= exc_code_dec;
		-- 	epc_nxt <= (PC_WIDTH to DATA_WIDTH-1 => '0') & pc_exec_reg;
		-- 	if bds.decode = '1' then
		-- 		B <= '1';
		-- 		npc_nxt <= (PC_WIDTH to DATA_WIDTH-1 => '0') & new_pc.decode;
		-- 	else
		-- 		B <= '0';
		-- 		npc_nxt <= (PC_WIDTH to DATA_WIDTH-1 => '0') & pc_decode_reg;
		-- 	end if;
		-- 	state_next <= FLUSH2;
		-- 	fl_decode <= '1';
		-- 	fl_exec <= '1';
		--
		-- elsif exc_ovf_reg = '1' then
		-- 	exc <= exc_code_ovf;
		-- 	epc_nxt <= (PC_WIDTH to DATA_WIDTH-1 => '0') & pc_mem_reg;
		-- 	if bds.exec = '1' then
		-- 		B <= '1';
		-- 		npc_nxt <= (PC_WIDTH to DATA_WIDTH-1 => '0') & new_pc.exec;
		-- 	else
		-- 		B <= '0';
		-- 		npc_nxt <= (PC_WIDTH to DATA_WIDTH-1 => '0') & pc_exec_reg;
		-- 	end if;
		-- 	state_next <= FLUSH2;
		-- 	fl_decode <= '1';
		-- 	fl_exec <= '1';
		-- 	fl_mem <= '1';
		--
		-- elsif exc_load_reg = '1' then
		-- 	exc <= exc_code_load;
		-- 	epc_nxt <= (PC_WIDTH to DATA_WIDTH-1 => '0') & pc_wb_reg;
		-- 	if bds.mem = '1' then
		-- 		B <= '1';
		-- 		npc_nxt <= (PC_WIDTH to DATA_WIDTH-1 => '0') & new_pc.mem;
		-- 	else
		-- 		B <= '0';
		-- 		npc_nxt <= (PC_WIDTH to DATA_WIDTH-1 => '0') & pc_mem_reg;
		-- 	end if;
		-- 	state_next <= FLUSH2;
		-- 	fl_decode <= '1';
		-- 	fl_exec <= '1';
		-- 	fl_mem <= '1';
		-- 	fl_wb <= '1';
		--
		-- elsif exc_store_reg = '1' then
		-- 	exc <= exc_code_store;
		-- 	epc_nxt <= (PC_WIDTH to DATA_WIDTH-1 => '0') & pc_wb_reg;
		-- 	if bds.mem = '1' then
		-- 		B <= '1';
		-- 		npc_nxt <= (PC_WIDTH to DATA_WIDTH-1 => '0') & new_pc.mem;
		-- 	else
		-- 		B <= '0';
		-- 		npc_nxt <= (PC_WIDTH to DATA_WIDTH-1 => '0') & pc_mem_reg;
		-- 	end if;
		-- 	state_next <= FLUSH2;
		-- 	fl_decode <= '1';
		-- 	fl_exec <= '1';
		-- 	fl_mem <= '1';
		-- 	fl_wb <= '1';
		--
		-- -- elsif intr_reg = '1' then
		-- -- 	exc <= exc_code_intr;
		-- 	--epc_nxt <=
		-- 	--npc_nxt <=
		-- 	-- ?????
		--
		-- end if;



	end process;

end rtl;
