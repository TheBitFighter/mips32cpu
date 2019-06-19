library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity pipeline_tb is
end entity;

architecture arch of pipeline_tb is
  constant CLK_PERIOD : time := 20 ns;
  signal stop_clock : boolean := false;
  signal clk, reset : std_logic;

  component pipeline is
  	port (
  		clk, reset : in	 std_logic;
  		mem_in     : in  mem_in_type;
  		mem_out    : out mem_out_type;
  		intr       : in  std_logic_vector(INTR_COUNT-1 downto 0));
  end component;

  signal mem_in : mem_in_type;
  signal mem_out : mem_out_type;
  signal intr : std_logic_vector(INTR_COUNT-1 downto 0);
  signal counter : natural := 0;
begin

  pipeline_inst : pipeline
  port map (
    clk => clk,
    reset => reset,
    mem_in => mem_in,
    mem_out => mem_out,
    intr => intr
    );

  sim : process
  begin
    reset <= '0';
    mem_in <= ('0', (others => '0'));
    mem_in.rddata <= "10111010100110001000100110101011";
    intr <= (others => '0');
    wait for CLK_PERIOD/2 * 3;
    reset <= '1';
    wait for CLK_PERIOD * 71;

    wait for CLK_PERIOD * 0.5;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 1;

    --mem_in.rddata <= "10111010100110001000100110101011";
    mem_in.busy <= '0';
    wait for CLK_PERIOD/2;
    --mem_in.rddata <= (others => '0');
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 2;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 3;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 4;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 3;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 2;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 1;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 2;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 3;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 4;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 3;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 2;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 1;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 2;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 3;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 4;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 3;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 2;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 1;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 2;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 3;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 4;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 3;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 2;
    mem_in.busy <= '0';
    wait for CLK_PERIOD;
    mem_in.busy <= '1';
    wait for CLK_PERIOD * 1;
    mem_in.busy <= '0';

    wait;
  end process;

	counter_p : process(clk)
	begin
		if rising_edge(clk) and reset = '1' then
			counter <= counter + 1;
		end if;
	end process;

  clock : process
  begin
    while not stop_clock loop
      clk <= '0', '1' after CLK_PERIOD/2;
      wait for CLK_PERIOD;
    end loop;
    wait;
  end process;
end arch;
