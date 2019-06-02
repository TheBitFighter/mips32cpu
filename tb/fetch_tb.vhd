library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity fetch_tb is
end entity;

architecture arch of fetch_tb is
  constant CLK_PERIOD : time := 20 ns;
  signal stop_clock : boolean := false;

  component fetch is
  	port (
  		clk, reset : in	 std_logic;
  		stall      : in  std_logic;
  		pcsrc	   : in	 std_logic;
  		pc_in	   : in	 std_logic_vector(PC_WIDTH-1 downto 0);
  		pc_out	   : out std_logic_vector(PC_WIDTH-1 downto 0);
  		instr	   : out std_logic_vector(INSTR_WIDTH-1 downto 0));
  end component;

  signal clk, reset, stall, pcsrc : std_logic;
  signal pc_in	   : std_logic_vector(PC_WIDTH-1 downto 0);
  signal pc_out	   : std_logic_vector(PC_WIDTH-1 downto 0);
  signal instr	   : std_logic_vector(INSTR_WIDTH-1 downto 0);
begin


  sim : process
  begin
    stall <= '0';
    pcsrc <= '0';
    reset <= '0';
    pc_in <= (others => '0');

    wait for CLK_PERIOD*3;
    reset <= '1';
    wait for CLK_PERIOD*2;
    stall <= '1';
    wait for CLK_PERIOD;
    stall <= '0';
    wait for CLK_PERIOD*2;
    pcsrc <= '1';
    pc_in <= std_logic_vector(to_unsigned(0, PC_WIDTH));
    wait for CLK_PERIOD;
    pcsrc <= '0';

    wait;
  end process;

  fetch_inst : fetch
  port map (
    clk => clk,
    reset => reset,
    stall => stall,
    pcsrc => pcsrc,
    pc_in => pc_in,
    pc_out => pc_out,
    instr => instr
  );

  clock : process
  begin
    while not stop_clock loop
      clk <= '1', '0' after CLK_PERIOD/2;
      wait for CLK_PERIOD;
    end loop;
    wait;
  end process;
end arch;
