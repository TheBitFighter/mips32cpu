library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity jmpu is
	port (
		op   : in  jmp_op_type;
		N, Z : in  std_logic;
		J    : out std_logic);
end jmpu;

architecture rtl of jmpu is

begin  -- rtl
	jmp : process(all)
	begin
		case op is
			when JMP_NOP =>
				J <= '0';
			when JMP_JMP =>
				J <= '1';
			when JMP_BEQ =>
				J <= Z;
			when JMP_BNE =>
				J <= not Z;
			when JMP_BLEZ =>
				J <= N or Z;
			when JMP_BGTZ =>
				J <= not (N or Z);
			when JMP_BLTZ =>
				J <= N;
			when JMP_BGEZ =>
				J <= not N;
		end case;
	end process;
end rtl;
