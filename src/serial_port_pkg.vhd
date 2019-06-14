library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package serial_port_pkg is
  component serial_port is
    port(
      clk : in std_logic;
      res_n : in std_logic;
      rx : in std_logic;
      tx : in std_logic;
      tx_data : in std_logic_vector(7 downto 0);
      tx_wr : in std_logic;
      tx_free : out std_logic;
      tx_rd : in std_logic,
      rx_data : out std_logic_vector(7 downto 0);
      rx_empty : out std_logic;
      rx_full : out std_logic
    );
  end component;
end package;
