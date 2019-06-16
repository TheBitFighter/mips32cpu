library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity core_tb is
end entity;

architecture arch of core_tb is
  constant CLK_PERIOD : time := 20 ns;
  signal stop_clock : boolean := false;
  signal counter : natural := 0;
  signal reset, clk : std_logic;

  component core is
  	generic (
  		clk_freq : integer;
  		baud_rate : integer);
  	port (
  		clk, reset  : in  std_logic;
  		tx  		: out std_logic;
  		rx          : in  std_logic;
  		intr        : in  std_logic_vector(INTR_COUNT-1 downto 0));
  end component;


  signal rx : std_logic;
  signal intr : std_logic_vector(INTR_COUNT-1 downto 0);

begin

  core_inst : core
  generic map(
    clk_freq => 50_000_000,
    baud_rate => 115200
  )
  port map(
    clk => clk,
    reset => reset,
    tx => open,
    rx => rx,
    intr => intr
  );

  sim : process
  begin
    reset <= '0';
    rx <= '0';
    intr <= (others => '0');

    wait for CLK_PERIOD/2 * 3;
    reset <= '1';

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
