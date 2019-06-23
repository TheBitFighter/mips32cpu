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

  signal intr : std_logic_vector(INTR_COUNT-1 downto 0);

  signal mem_out : mem_out_type;
	signal mem_in  : mem_in_type;

	--signal ocram_rd : std_logic;
	signal ocram_wr : std_logic;
	signal ocram_rddata : std_logic_vector(DATA_WIDTH-1 downto 0);

	signal uart_rd : std_logic;
	signal uart_wr : std_logic;
	signal uart_rddata : std_logic_vector(DATA_WIDTH-1 downto 0);

	type mux_type is (MUX_OCRAM, MUX_UART);
	signal mux : mux_type;

begin

  pipeline : entity work.pipeline port map (
		clk	    => clk,
		reset   => reset,
		mem_in  => mem_in,
		mem_out => mem_out,
		intr    => intr);

	ocram : entity work.ocram_altera port map (
		address => mem_out.address(11 downto 2),
		byteena => mem_out.byteena,
		clock	=> clk,
		data	=> mem_out.wrdata,
		wren	=> ocram_wr,
		q		=> ocram_rddata);

	iomux: process (mem_out, mux, ocram_rddata, uart_rddata)
	begin  -- process mux

		mux <= MUX_OCRAM;

		case mem_out.address(ADDR_WIDTH-1 downto ADDR_WIDTH-2) is
			when "00" => mux <= MUX_OCRAM;
			when "11" => mux <= MUX_UART;
			when others => null;
		end case;

		mem_in.busy <= mem_out.rd;

		mem_in.rddata <= (others => '0');
		case mux is
			when MUX_OCRAM => mem_in.rddata <= ocram_rddata;
			when MUX_UART  => --mem_in.rddata <= uart_rddata;
        mem_in.rddata <= (others => '0');
        if mem_out.address(2) = '0' then
          mem_in.rddata(24) <= '1';
        end if;
			when others => null;
		end case;

		--ocram_rd <= '0';
		ocram_wr <= '0';
		if mux = MUX_OCRAM then
			--ocram_rd <= mem_out.rd;
			ocram_wr <= mem_out.wr;
		end if;

		uart_rd <= '0';
		uart_wr <= '0';
		-- if mux = MUX_UART then
		-- 	uart_rd <= mem_out.rd;
		-- 	uart_wr <= mem_out.wr;
		-- end if;

	end process iomux;

  sim : process
  begin
    reset <= '0';
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
