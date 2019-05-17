library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity regfile_tb is
end entity;

architecture arch of regfile_tb is
  constant CLK_PERIOD : time := 20 ns;
  signal stop_clock : boolean := false;

  signal clk, reset, stall, regwrite : std_logic;
  signal rdaddr1, rdaddr2, wraddr : std_logic_vector(REG_BITS-1 downto 0);
  signal rddata1, rddata2, wrdata : std_logic_vector(DATA_WIDTH-1 downto 0);

  component regfile is
  	port (
  		clk, reset       : in  std_logic;
  		stall            : in  std_logic;
  		rdaddr1, rdaddr2 : in  std_logic_vector(REG_BITS-1 downto 0);
  		rddata1, rddata2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
  		wraddr			 		 : in  std_logic_vector(REG_BITS-1 downto 0);
  		wrdata			 		 : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  		regwrite         : in  std_logic);
  end component;

begin
  regfile_inst : regfile
  port map(
    clk => clk,
    reset => reset,
    stall => stall,
    rdaddr1 => rdaddr1,
    rdaddr2 => rdaddr2,
    rddata1 => rddata1,
    rddata2 => rddata2,
    wraddr => wraddr,
    wrdata => wrdata,
    regwrite => regwrite
  );

  sim : process
  begin
    reset <= '0';
    stall <= '0';
    rdaddr1 <= (others => '0');
    rdaddr2 <= (others => '0');
    wraddr <= (others => '0');
    wrdata <= (others => '0');
    regwrite <= '0';
    wait for CLK_PERIOD*4;

    reset <= '1';
    wraddr <= std_logic_vector(to_unsigned(2, REG_BITS));
    wrdata <= (others => '1');
    regwrite <= '1';
    wait for CLK_PERIOD*4;

    wraddr <= std_logic_vector(to_unsigned(5, REG_BITS));
    wrdata <= (others => '1');
    regwrite <= '1';
    wait for CLK_PERIOD*4;

    wraddr <= (others => '0');
    wrdata <= (others => '1');
    regwrite <= '1';
    wait for CLK_PERIOD*4;

    regwrite <= '0';
    rdaddr1 <= std_logic_vector(to_unsigned(2, REG_BITS));
    rdaddr2 <= (others => '0');
    wait for CLK_PERIOD*4;

    wraddr <= std_logic_vector(to_unsigned(20, REG_BITS));
    wrdata <= (others => '1');
    regwrite <= '1';
    rdaddr1 <= std_logic_vector(to_unsigned(20, REG_BITS));
    wait for CLK_PERIOD*4;

    stall <= '1';
    wait for CLK_PERIOD*4;
    stall <= '0';

    wait;
  end process;

  clock : process
  begin
    while not stop_clock loop
      clk <= '1', '0' after CLK_PERIOD/2;
      wait for CLK_PERIOD;
    end loop;
    wait;
  end process;
end arch;
