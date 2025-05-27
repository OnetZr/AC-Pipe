library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity IFetch is
	Port (WE : in std_logic;
			reset : in std_logic;
			clk: in std_logic;
			BranchAddress : in std_logic_vector(15 downto 0);
			JumpAddress : in std_logic_vector(15 downto 0);
			JCS : in std_logic;
			PCSrc : in std_logic;
			Instruction : out std_logic_vector(15 downto 0);
			PC : out std_logic_vector(15 downto 0):=X"0000");
end IFetch;

architecture Behavioral of IFetch is

--instructiuni
type rom_type is array(0 to 255) of std_logic_vector(15 downto 0);
signal ROM: rom_type := (
B"000_101_101_101_0_110", --xor $5 $5 $5
B"000_001_001_001_0_110", --xor $1 $1 $1
B"000_010_010_010_0_110", --xor $2 $2 $2
B"000_000_000_000_0_000", --no op
B"000_000_000_000_0_000", --no op
B"000_000_000_000_0_000", --no op
B"001_010_010_0001111",   --addi $2 $2 15
B"000_001_101_001_0_000", --add $1 $1 $5
B"000_101_101_0000001",   --addi $5 $5 1
B"000_000_000_000_0_000", --no op
B"000_000_000_000_0_000", --no op
B"000_000_000_000_0_000", --no op
B"100_101_010_0000001", --beq $2 $5 1
B"000_000_000_000_0_000", --no op
B"000_000_000_000_0_000", --no op
B"000_000_000_000_0_000", --no op
B"111_0000000000111", --jump 6
B"010_001_110_0000000", -- lw $6 0($1)

others =>x"1111");

signal qd, YALU, YMUX2, YMUX1: std_logic_vector(15 downto 0) :=X"0000";

begin


---MUX2
process(JCS,YMUX1,JumpAddress)
begin
	case(JCS) is
		when '0' => YMUX2 <= YMUX1;
		when '1' => YMUX2 <= JumpAddress;
		when others => YMUX2 <= X"0000";
	end case;
end process;	

--MUX1
process(PCSrc,YALU,BranchAddress)
begin
	case (PCSrc) is 
		when '0' => YMUX1 <= YALU;
		when '1' => YMUX1<=BranchAddress;
		when others => YMUX1<=X"0000";
	end case;
end process;	

--D FF
process(clk,reset)
begin
	if Reset='1' then
		qd<=X"0000";
	else if rising_edge(clk) and WE='1' then
		qd<=YMUX2;
		end if;
		end if;
end process;



Instruction<=ROM(conv_integer(qd(7 downto 0)));

--ALU
YALU<=qd + '1';
PC <= YALU;

end Behavioral;

