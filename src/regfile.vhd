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
	subtype word_t is std_logic_vector(DATA_WIDTH-1 downto 0);
	type reg_t is array(2**REG_BITS-1 downto 0) of word_t;
	signal reg : reg_t;
begin  -- rtl
	-- one-process-method becouse of the hint in the assignment to use the implementation guidelines
	sync : process(clk, reset)
	begin
		if reset = '0' then
			reg <= (others => (others => '0'));
			rddata1 <= (others => '0');
			rddata2 <= (others => '0');
		elsif rising_edge(clk) and stall = '0' then
			-- write to register
			if regwrite = '1' then
				reg(to_integer(unsigned(wraddr))) <= wrdata;
			end if;
			-- read 1
			if rdaddr1 = (REG_BITS-1 downto 0 => '0') then
				rddata1 <= (others => '0');
			elsif rdaddr1 = wraddr and regwrite = '1' then
				rddata1 <= wrdata;
			else
				rddata1 <= reg(to_integer(unsigned(rdaddr1)));
			end if;
			-- read 2
			if rdaddr2 = (REG_BITS-1 downto 0 => '0') then
				rddata2 <= (others => '0');
			elsif rdaddr2 = wraddr and regwrite = '1' then
				rddata2 <= wrdata;
			else
				rddata2 <= reg(to_integer(unsigned(rdaddr2)));
			end if;
		end if;
	end process;
end rtl;
