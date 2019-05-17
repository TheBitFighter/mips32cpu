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

	signal ovf : std_logic := '0';

begin

	-- Process to determine the result output depending on the desired operation
	result : process(op)
	begin
		case op is
			when ALU_NOP =>
				R <= A;

			when ALU_LUI =>
				R <= B sll 16;

			when ALU_SLT =>
				R <= signed(A) < signed(B) ? '1' : '0';

			when ALU_SLTU =>
				R <= unsigned(A) < unsigned(B) ? '1' : '0';

			when ALU_SLL =>
				R <= B sll A(DATA_WIDTH-1 downto 0);

			when ALU_SRL =>
				R <= B srl A(DATA_WIDTH-1 downto 0);

			when ALU_SRA =>
				R <= B sra A(DATA_WIDTH-1 downto 0);

			when ALU_ADD =>
				R <= std_logic_vector(signed(A) + signed(B));
				if (signed(A) >= 0 and signed(B) >= 0 and signed(R) < 0) then
					ovf <= '1';
				elsif (signed(A) < 0 and signed(B) < 0 and signed(R) >= 0) then
					ovf <= '1';
				else
					ovf <= '0';
				end if;

			when ALU_SUB =>
				R <= std_logic_vector(signed(A) - signed(B));
				if (signed(A) >= 0 and signed(B) < 0 and signed(R) < 0) then
					ovf <= '1';
				elsif (signed(A) < 0 and signed(B) >= 0 and signed(R) >= 0) then
					ovf <= '1';
				else
					ovf <= '0';
				end if;

			when ALU_AND =>
				R <= A and B;

			when ALU_OR =>
				R <= A or B;

			when ALU_XOR =>
				R <= A xor B;

			when ALU_NOR =>
				R <= not (A or B);

			others =>
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
				if (A = std_logic_vector(signed(0), DATA_WIDTH)) then
					Z <= '1';
				else
					Z <= '0';
				end if;

		end case;

	end process;

  -- Process to determine the state of the overflow bit
	overflow : process(op)
		case op is

			when ALU_ADD =>
				V <= ovf;

			when ALU_SUB =>
				V <= ovf;

			when others =>
				V <= '0';

		end case;
	begin

	end process;

end rtl;
