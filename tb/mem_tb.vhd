library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity mem_tb is
end entity;

architecture arch of mem_tb is
  constant CLK_PERIOD : time := 20 ns;
  signal stop_clock : boolean := false;

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

  signal clk, reset    : std_logic;
  signal stall         : std_logic;
  signal flush         : std_logic;
  signal mem_op        : mem_op_type;
  signal jmp_op        : jmp_op_type;
  signal pc_in         : std_logic_vector(PC_WIDTH-1 downto 0);
  signal rd_in         : std_logic_vector(REG_BITS-1 downto 0);
  signal aluresult_in  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal wrdata        : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal zero, neg     : std_logic;
  signal new_pc_in     : std_logic_vector(PC_WIDTH-1 downto 0);
  signal pc_out        : std_logic_vector(PC_WIDTH-1 downto 0);
  signal pcsrc         : std_logic;
  signal rd_out        : std_logic_vector(REG_BITS-1 downto 0);
  signal aluresult_out : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal memresult     : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal new_pc_out    : std_logic_vector(PC_WIDTH-1 downto 0);
  signal wbop_in       : wb_op_type;
  signal wbop_out      : wb_op_type;
  signal mem_out       : mem_out_type;
  signal mem_data      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal exc_load      : std_logic;
  signal exc_store     : std_logic;

begin


  sim : process
  begin
    reset <= '0';
    stall <= '0';
    flush <= '0';
    mem_op <= MEM_NOP;
    jmp_op <= JMP_NOP;
    pc_in <= (others => '0');
    rd_in <= (others => '0');
    aluresult_in <= (others => '0');
    wrdata <= (others => '0');
    zero <= '0';
    neg <= '0';
    new_pc_in <= (others => '0');
    wbop_in <= WB_NOP;
    mem_data <= (others => '0');

    wait for CLK_PERIOD/2 * 5;
    reset <= '1';

    wait for CLK_PERIOD*2;
    pc_in <= (others => '1');
    wait for CLK_PERIOD;
    mem_op.memread <= '1';

    wait for CLK_PERIOD;
    --stall <= '1';
    --pc_in <= (0 => '0', others => '1');
    aluresult_in <= (others => '1');

    wait for CLK_PERIOD;
    stall <= '0';

    wait for CLK_PERIOD;
    flush <= '1';

    wait for CLK_PERIOD;
    flush <= '0';


    wait;
  end process;

  mem_inst : mem
  port map(
    clk => clk,
    reset => reset,
    stall => stall,
    flush => flush,
    mem_op => mem_op,
    jmp_op => jmp_op,
    pc_in => pc_in,
    rd_in => rd_in,
    aluresult_in => aluresult_in,
    wrdata => wrdata,
    zero => zero,
    neg => neg,
    new_pc_in => new_pc_in,
    pc_out => pc_out,
    pcsrc => pcsrc,
    rd_out => rd_out,
    aluresult_out => aluresult_out,
    memresult => memresult,
    new_pc_out => new_pc_out,
    wbop_in => wbop_in,
    wbop_out => wbop_out,
    mem_out => mem_out,
    mem_data => mem_data,
    exc_load => exc_load,
    exc_store => exc_store
  );

  clock : process
  begin
    while not stop_clock loop
      clk <= '0', '1' after CLK_PERIOD/2;
      wait for CLK_PERIOD;
    end loop;
    wait;
  end process;
end arch;
