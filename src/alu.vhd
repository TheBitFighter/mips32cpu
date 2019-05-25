library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity alu is
	port (
		op   : in  alu_op_type;
		A, B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		Z    : out std_logic;
		V    : out std_logic);

end alu;

architecture rtl of alu is

	signal calc : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

	-- Process to determine the result output depending on the desired operation
	result : process(op)
	begin
		case op is
			when ALU_NOP =>
				R <= A;

			when ALU_LUI =>
				R <= std_logic_vector(shift_left(unsigned(B), 16));

			when ALU_SLT =>
				if (signed(A) < signed(B)) then
				 R <= (others=>'0');
				 R(0) <= '1';
			 else
				 R <= (others=>'0');
			 end if;

			when ALU_SLTU =>
				if (unsigned(A) < unsigned(B)) then
					R <= (others=>'0');
 					R(0) <= '1';
				else
					R <= (others=>'0');
				end if;

			when ALU_SLL =>
				R <= std_logic_vector(shift_left(unsigned(B), to_integer(unsigned(A))));

			when ALU_SRL =>
				R <= std_logic_vector(shift_right(unsigned(B), to_integer(unsigned(A))));

			when ALU_SRA =>
				R <= std_logic_vector(shift_right(signed(B), to_integer(unsigned(A))));

			when ALU_ADD =>
				R <= std_logic_vector(signed(A) + signed(B));
				calc <= std_logic_vector(signed(A) + signed(B));

			when ALU_SUB =>
				R <= std_logic_vector(signed(A) - signed(B));
				calc <= std_logic_vector(signed(A) - signed(B));

			when ALU_AND =>
				R <= A and B;

			when ALU_OR =>
				R <= A or B;

			when ALU_XOR =>
				R <= A xor B;

			when ALU_NOR =>
				R <= not (A or B);

			when others =>
				R <= (others=>'0');

		end case;
	end process;

	-- Process to determine the state of the zero bit
	zero : process(op)
	begin
		case op is

			when ALU_SUB =>
				if (A = B) then
					Z <= '1';
				else
					Z <= '0';
				end if;

			when others =>
				if (A = (others=>'0')) then
					Z <= '1';
				else
					Z <= '0';
				end if;

		end case;

	end process;

  -- Process to determine the state of the overflow bit
	overflow : process(op, calc)
	begin
		case op is

			when ALU_ADD =>
				if (signed(A) >= 0 and signed(B) >= 0 and signed(calc) < 0) then
					V <= '1';
				elsif (signed(A) < 0 and signed(B) < 0 and signed(calc) >= 0) then
					V <= '1';
				else
					V <= '0';
				end if;

			when ALU_SUB =>
				if (signed(A) >= 0 and signed(B) < 0 and signed(calc) < 0) then
					V <= '1';
				elsif (signed(A) < 0 and signed(B) >= 0 and signed(calc) >= 0) then
					V <= '1';
				else
					V <= '0';
				end if;

			when others =>
				V <= '0';

			end case;

	end process;

end rtl;
