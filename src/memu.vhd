library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pack.all;
use work.op_pack.all;

entity memu is
	port (
		op   : in  mem_op_type;
		A    : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
		W    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		D    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
		M    : out mem_out_type;
		R    : out std_logic_vector(DATA_WIDTH-1 downto 0);
		XL   : out std_logic;
		XS   : out std_logic);
end memu;

architecture rtl of memu is

begin  -- rtl
	M_byteena_wrdata_OUT : process(all)
		variable BB, AA, XX : std_logic_vector(BYTE_WIDTH-1 downto 0);
	begin
		BB := W(2*BYTE_WIDTH-1 downto BYTE_WIDTH);
		AA := W(BYTE_WIDTH-1 downto 0);
		XX := (others => '-');

		case op.memtype is
			when MEM_B | MEM_BU =>
				case A(1 downto 0) is
					when "00" =>
						M.byteena <= "1000";
						M.wrdata <= AA & XX & XX & XX;
					when "01" =>
						M.byteena <= "0100";
						M.wrdata <= XX & AA & XX & XX;
					when "10" =>
						M.byteena <= "0010";
						M.wrdata <= XX & XX & AA & XX;
					when "11" =>
						M.byteena <= "0001";
						M.wrdata <= XX & XX & XX & AA;
					when others => null;
				end case;

			when MEM_H | MEM_HU =>
				case A(1 downto 0) is
					when "00" | "01" =>
						M.byteena <= "1100";
						M.wrdata <= BB & AA & XX & XX;
					when "10" | "11" =>
						M.byteena <= "0011";
						M.wrdata <= XX & XX & BB & AA;
					when others => null;
				end case;

			when MEM_W =>
				case A(1 downto 0) is
					when "00" | "01" | "10" | "11" =>
						M.byteena <= "1111";
						M.wrdata <= W; -- W == DCBA
					when others => null;
				end case;

		end case;
	end process;

	R_OUT : process(all)
		variable DD, CC, BB, AA, SS, zero : std_logic_vector(BYTE_WIDTH-1 downto 0);
	begin
		DD := D(4*BYTE_WIDTH-1 downto 3*BYTE_WIDTH);
		CC := D(3*BYTE_WIDTH-1 downto 2*BYTE_WIDTH);
		BB := D(2*BYTE_WIDTH-1 downto BYTE_WIDTH);
		AA := D(BYTE_WIDTH-1 downto 0);
		SS := (others => '0');
		zero := (others => '0');

		case op.memtype is
			when MEM_B =>
				case A(1 downto 0) is
					when "00" =>
						SS := (others => DD(BYTE_WIDTH-1));
						R <= SS & SS & SS & DD;
					when "01" =>
						SS := (others => CC(BYTE_WIDTH-1));
						R <= SS & SS & SS & CC;
					when "10" =>
						SS := (others => BB(BYTE_WIDTH-1));
						R <= SS & SS & SS & BB;
					when "11" =>
						SS := (others => AA(BYTE_WIDTH-1));
						R <= SS & SS & SS & AA;
					when others => null;
				end case;

			when MEM_BU =>
				case A(1 downto 0) is
					when "00" =>
						R <= zero & zero & zero & DD;
					when "01" =>
						R <= zero & zero & zero & CC;
					when "10" =>
						R <= zero & zero & zero & BB;
					when "11" =>
						R <= zero & zero & zero & AA;
					when others => null;
				end case;

			when MEM_H =>
				case A(1 downto 0) is
					when "00" | "01" =>
						SS := (others => DD(BYTE_WIDTH-1));
						R <= SS & SS & DD & CC;
					when "10" | "11" =>
						SS := (others => BB(BYTE_WIDTH-1));
						R <= SS & SS & BB & AA;
					when others => null;
				end case;

			when MEM_HU =>
				case A(1 downto 0) is
					when "00" | "01" =>
						R <= zero & zero & DD & CC;
					when "10" | "11" =>
						R <= zero & zero & BB & AA;
					when others => null;
				end case;

			when MEM_W =>
				case A(1 downto 0) is
					when "00" | "01" | "10" | "11" =>
						R <= D; -- D == DCBA
					when others => null;
				end case;

		end case;
	end process;

	XL_XS_adress_rd_wr_OUT : process(all)
	begin
		M.address <= A;
		M.rd <= op.memread;
		M.wr <= op.memwrite;
		XL <= '0';
		XS <= '0';

		if (op.memread = '1' and A(1 downto 0) = "00" 		and  A(ADDR_WIDTH-1 downto 2) = (ADDR_WIDTH-3 downto 0 => '0')) 		or
			 (op.memread = '1' and op.memtype 	 = MEM_H 		and (A(1 downto 0) = "01" or A(1 downto 0) = "11")) or
			 (op.memread = '1' and op.memtype 	 = MEM_HU		and (A(1 downto 0) = "01" or A(1 downto 0) = "11")) or
			 (op.memread = '1' and op.memtype 	 = MEM_W	 	and (A(1 downto 0) = "01" or A(1 downto 0) = "10" 	or A(1 downto 0) = "11")) then
				 XL <= '1';
				 M.rd <= '0';
				 M.wr <= '0';
		end if;

		if (op.memwrite = '1' and A(1 downto 0) = "00"		and  A(ADDR_WIDTH-1 downto 2) = (ADDR_WIDTH-3 downto 0 => '0'))		or
			 (op.memwrite = '1' and op.memtype 		= MEM_H		and (A(1 downto 0) = "01" or A(1 downto 0) = "11")) or
			 (op.memwrite = '1' and op.memtype 		= MEM_HU 	and (A(1 downto 0) = "01" or A(1 downto 0) = "11")) or
			 (op.memwrite = '1' and op.memtype 		= MEM_W 	and (A(1 downto 0) = "01" or A(1 downto 0) = "10" 	or A(1 downto 0) = "11")) then
				 XS <= '1';
				 M.rd <= '0';
				 M.wr <= '0';
		end if;
	end process;
end rtl;
