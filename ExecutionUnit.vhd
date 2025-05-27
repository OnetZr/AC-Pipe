library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ExecutionUnit is
Port(
	PCOut:in std_logic_vector(15 downto 0);
	RD1: in std_logic_vector(15 downto 0);
	RD2: in std_logic_vector(15 downto 0);
	Ext_Imm: in std_logic_vector(15 downto 0);
	Func: in std_logic_vector(2 downto 0);
	SA: in std_logic;
	ALUSrc: in std_logic;
	ALUOp: in std_logic_vector(2 downto 0);
	BranchAddress: out std_logic_vector(15 downto 0);
	ALURes: out std_logic_vector(15 downto 0);
	ZeroSignal: out std_logic);
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is

signal YMUX:std_logic_vector(15 downto 0);
signal ALUControl: std_logic_vector(3 downto 0);
signal ALUResAux:std_logic_vector(15 downto 0);
signal ZeroAux: std_logic;

begin
--branch adddres
BranchAddress<=PCOut+Ext_Imm;

--mux
with ALUSrc select
	YMUX<=RD2 when '0',
			  Ext_Imm when others;
			  

process(ALUOp,Func)
begin
	case (ALUOp) is
		when "000"=>
				case (Func) is
					when "000"=> ALUControl<="0000"; 	--add
					when "001"=> ALUControl<="0001";	--sub
					when "010"=> ALUControl<="0010";	--sll
					when "011"=> ALUControl<="0011";	--srl
					when "100"=> ALUControl<="0100";	--and
					when "101"=> ALUControl<="0101";	--or
					when "110"=> ALUControl<="0110";	--xor
					when "111"=> ALUControl<="0111";	--sra
					when others=> ALUControl<="0000";	--others
				end case;
		when "001"=> ALUControl<="0000";	--addi
		when "010"=> ALUControl<="0001";	--beq
		when "101"=> ALUControl<="0100";	--andi
		when "110"=> ALUControl<="0101";	--ori
		when "111"=> ALUControl<="1000";	--jump
		when others=> ALUControl<="0000";	
	end case;
end process;

process(ALUControl,RD1,YMUX,SA)
begin
	case(ALUControl) is
		when "0000" => ALUResAux<=RD1+YMUX;   --add
					
		when "0001" => ALUResAux<=RD1-YMUX;   --sub
								
		when "0010" =>    --sll
					case (SA) is
						when '1' => ALUResAux<=RD1(14 downto 0) & "0";
						when others => ALUResAux<=RD1;	
					end case;
								
		when "0011" => 	--srl
					case (SA) is
						when '1' => ALUResAux<="0" & RD1(15 downto 1);
						when others => ALUResAux<=RD1;
					end case;
								
		when "0100" => ALUResAux<=RD1 and YMUX;--and
								
		when "0101" => ALUResAux<=RD1 or YMUX;--or
										
		when "0110" => ALUResAux<=RD1 xor YMUX;--xor
							
		when "0111" =>   --sra
					case (SA) is
                                when '1' => ALUResAux<=RD1(0) & RD1(15 downto 1);
                                when others => ALUResAux<=RD1;
                            end case;
					
		when "1000" => ALUResAux<=X"0000";--jmp
					
		when others => ALUResAUx<=X"0000";--others
	end case;

	case (ALUResAux) is	--zero
		when X"0000" => ZeroAux<='1';
		when others => ZeroAux<='0';
	end case;

end process;

ZeroSignal<=ZeroAux;

ALURes<=ALUResAux;


end Behavioral;

