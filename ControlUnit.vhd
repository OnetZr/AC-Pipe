library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity ControlUnit is
Port	( Instr:in std_logic_vector(2 downto 0);
			 RegDst: out std_logic;
			 ExtOp: out std_logic;
			 ALUSrc: out std_logic;
			 Branch: out std_logic;
			 Jump: out std_logic;
			 ALUOp: out std_logic_vector(2 downto 0);
			 MemWrite: out std_logic;
			 MemtoReg: out std_logic;
			 RegWrite: out std_logic);
end ControlUnit;

architecture Behavioral of ControlUnit is



begin

process(Instr)
begin
	case (Instr) is 
		when "000"=> --Instructiuni R
			RegDst<='1';
			ExtOp<='0';
			ALUSrc<='0';
			Branch<='0';
			Jump<='0';
			ALUOp<="000";
			MemWrite<='0';
			MemtoReg<='0';
			RegWrite<='1';
			
		when "001"=> --addi
			RegDst<='0';
			ExtOp<='1';
			ALUSrc<='1';
			Branch<='0';
			Jump<='0';
			ALUOp<="001";
			MemWrite<='0';
			MemtoReg<='0';
			RegWrite<='1';
			
		when "010"=> --lw
			RegDst<='0';
			ExtOp<='1';
			ALUSrc<='1';
			Branch<='0';
			Jump<='0';
			ALUOp<="001";
			MemWrite<='0';
			MemtoReg<='1';
			RegWrite<='1';
			
		when "011"=> --sw
			RegDst<='X';
			ExtOp<='1';
			ALUSrc<='1';
			Branch<='0';
			Jump<='0';
			ALUOp<="001";
			MemWrite<='1';
			MemtoReg<='X';
			RegWrite<='0';
			
		when "100"=> --beq
			RegDst<='X';
			ExtOp<='1';
			ALUSrc<='0';
			Branch<='1';
			Jump<='0';
			ALUOp<="010";
			MemWrite<='0';
			MemtoReg<='X';
			RegWrite<='0';
			
		when "101"=> --andi
			RegDst<='0';
			ExtOp<='1';
			ALUSrc<='1';
			Branch<='0';
			Jump<='0';
			ALUOp<="101";
			MemWrite<='0';
			MemtoReg<='0';
			RegWrite<='1';
			
		when "110"=> --ori
			RegDst<='0';
			ExtOp<='1';
			ALUSrc<='1';
			Branch<='0';
			Jump<='0';
			ALUOp<="110";
			MemWrite<='0';
			MemtoReg<='0';
			RegWrite<='1';
			
		when "111"=> -----JUMP-----
			RegDst<='X';
			ExtOp<='1';
			ALUSrc<='X';
			Branch<='0';
			Jump<='1';
			ALUOp<="111";
			MemWrite<='0';
			MemtoReg<='X';
			RegWrite<='0';
		
		when others =>	--others
			RegDst<='X';
			ExtOp<='X';
			ALUSrc<='X';
			Branch<='0';
			Jump<='0';
			ALUOp<="000";
			MemWrite<='0';
			MemtoReg<='0';
			RegWrite<='0';
	end case;
end process;		


end Behavioral;

