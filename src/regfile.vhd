library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;

entity regfile is
	port (
		clk, reset       : in  std_logic;
		stall            : in  std_logic;
		rdaddr1, rdaddr2 : in  std_logic_vector(REG_BITS-1 downto 0);
		rddata1, rddata2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
		wraddr			 		 : in  std_logic_vector(REG_BITS-1 downto 0);
		wrdata			 		 : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		regwrite         : in  std_logic);
end regfile;

architecture rtl of regfile is
	type reg_t is array(2**REG_BITS-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
	signal reg : reg_t;
	constant reg_clear : reg_t := (others => (others => '0'));
begin  -- rtl
	-- one-process-method becouse of the hint in the assignment to use the implementation guidelines
	sync : process(clk, reset)
	begin
		if reset = '0' then
			reg <= reg_clear;
		elsif rising_edge(clk) then
			-- write to register
			if regwrite = '1' and stall = '0' then
				reg(to_integer(unsigned(wraddr))) <= wrdata;
			end if;
		end if;
	end process;

	rddata1 <= rddata1 when stall = '1' else
						(others => '0') when rdaddr1 = (0 to REG_BITS-1 => '0') else
						wrdata when (rdaddr1 = wraddr and regwrite = '1') else
						reg(to_integer(unsigned(rdaddr1)));

	rddata2 <= rddata2 when stall = '1' else
						(others => '0') when rdaddr2 = (0 to REG_BITS-1 => '0') else
						wrdata when (rdaddr2 = wraddr and regwrite = '1') else
						reg(to_integer(unsigned(rdaddr2)));
end rtl;
