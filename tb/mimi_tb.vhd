library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity mimi_tb is
end entity;

architecture arch of mimi_tb is
  constant CLK_PERIOD : time := 20 ns;
  signal stop_clock : boolean := false;

  component mimi is

  	port (
  		clk_pin   : in  std_logic;
  		reset_pin : in  std_logic;
  		tx  	  : out std_logic;
  		rx        : in  std_logic;
  		intr_pin  : in  std_logic_vector(INTR_COUNT-1 downto 0));
  end component;

  signal reset, clk : std_logic;

  signal tx, rx : std_logic;
  signal intr : std_logic_vector(INTR_COUNT-1 downto 0);

begin

  mimi_inst : mimi
  port map(
    clk_pin => clk,
    reset_pin => reset,
    tx => tx,
    rx => rx,
    intr_pin => intr
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

  clock : process
  begin
    while not stop_clock loop
      clk <= '0', '1' after CLK_PERIOD/2;
      wait for CLK_PERIOD;
    end loop;
    wait;
  end process;

end arch;
