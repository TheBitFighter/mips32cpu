library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity fwd is
	port (
		reset : in std_logic;
		clk : in std_logic;
		exec_rs : in std_logic_vector(REG_BITS-1 downto 0);
		exec_rt : in std_logic_vector(REG_BITS-1 downto 0);
		mem_rd : in std_logic_vector(REG_BITS-1 downto 0);
		mem_regwrite : in std_logic;
		wb_rd : in std_logic_vector(REG_BITS-1 downto 0);
		wb_regwrite : in std_logic;
		forwardA : out fwd_type;
		forwardB : out fwd_type
	);
end fwd;

architecture rtl of fwd is
begin

	checkA : process(all)
	begin
		if (exec_rs = (0 to REG_BITS-1 => '0')) then
			forwardA <= FWD_NONE;
		elsif (exec_rs = mem_rd and mem_regwrite = '1') then
			forwardA <= FWD_ALU;
		elsif (exec_rs = wb_rd and wb_regwrite = '1') then
			forwardA <= FWD_WB;
		else
			forwardA <= FWD_NONE;
		end if;
	end process;

	checkB : process(all)
	begin
		if (exec_rt = (0 to REG_BITS-1 => '0')) then
			forwardB <= FWD_NONE;
		elsif (exec_rt = mem_rd and mem_regwrite = '1') then
			forwardB <= FWD_ALU;
		elsif (exec_rt = wb_rd and wb_regwrite = '1') then
			forwardB <= FWD_WB;
		else
			forwardB <= FWD_NONE;
		end if;
	end process;

end rtl;
