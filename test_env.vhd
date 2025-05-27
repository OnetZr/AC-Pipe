library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity test_env is
    Port ( clk : in  STD_LOGIC;
           btn : in  STD_LOGIC_VECTOR (4 downto 0);
           sw : in  STD_LOGIC_VECTOR (15 downto 0);
           led : out  STD_LOGIC_VECTOR (15 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           cat : out  STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
	port ( btn: in std_logic;
		clock: in std_logic;
		enable: out std_logic);
end component;

component SSD is
port( clk: in STD_LOGIC;
		digits: in STD_LOGIC_VECTOR(15 DOWNTO 0);
		an: out STD_LOGIC_VECTOR(3 DOWNTO 0);
		cat: out STD_LOGIC_VECTOR(6 DOWNTO 0));
end component;

component IFetch is
	Port (WE : in std_logic;
			reset : in std_logic;
			clk: in std_logic;
			BranchAddress : in std_logic_vector(15 downto 0);
			JumpAddress : in std_logic_vector(15 downto 0);
			JCS : in std_logic;
			PCSrc : in std_logic;
			Instruction : out std_logic_vector(15 downto 0);
			PC : out std_logic_vector(15 downto 0));
end component;




signal RegDst: std_logic;
signal ExtOp: std_logic;
signal ALUSrc: std_logic;
signal Branch: std_logic;
signal Jump: std_logic;
signal ALUOp: std_logic_vector(2 downto 0);
signal MemWrite: std_logic;
signal MemtoReg: std_logic;
signal RegWrite: std_logic;

component IDecode is
	Port ( clk: in std_logic;
			Instruction: in std_logic_vector(15 downto 0);
			WriteData: in std_logic_vector(15 downto 0);
			RegWrite: in std_logic;
			RegWrite2: in std_logic;
			RegDst: in std_logic;
			ExtOp: in std_logic;
			ReadData1: out std_logic_vector(15 downto 0);
			ReadData2: out std_logic_vector(15 downto 0);
			Ext_Imm : out std_logic_vector(15 downto 0);
			Func : out std_logic_vector(2 downto 0);
			SA : out std_logic);

end component;

component ControlUnit is
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
end component;

component MEM is
	port(
			clk: in std_logic;
			ALURes : in std_logic_vector(15 downto 0);
			WriteData: in std_logic_vector(15 downto 0);
			MemWrite: in std_logic;		
			MemWriteCtrl: in std_logic;				
			MemData:out std_logic_vector(15 downto 0);
			ALURes2 :out std_logic_vector(15 downto 0)
	);
end component;

component ExecutionUnit is
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
end component;

signal enable: STD_LOGIC;    
signal enable2: STD_LOGIC;	  
signal BranchAddress:std_logic_vector(15 downto 0);  	  
signal JumpAddress:std_logic_vector(15 downto 0); 		  
signal y : std_logic_vector(15 downto 0):=X"0000";  
signal InstrOut: std_logic_vector(15 downto 0);			    
signal PCout: std_logic_vector(15 downto 0);				    
signal ALURes: std_logic_vector(15 downto 0);			   
signal ZeroSignal: std_logic;										
signal RD1: std_logic_vector(15 downto 0);					
signal RD2: std_logic_vector(15 downto 0);					
signal Ext_Imm : std_logic_vector(15 downto 0);				
signal Func :std_logic_vector(2 downto 0);					
signal SA : std_logic;												
signal MemData: std_logic_vector(15 downto 0);				
signal ALUResOut: std_logic_vector(15 downto 0);			
signal WriteDataReg: std_logic_vector(15 downto 0);		
signal PCSrc:std_logic;												

signal ifid: std_logic_vector(31 downto 0);
signal idex: std_logic_vector(88 downto 0);
signal exmem: std_logic_vector(55 downto 0);
signal memwb: std_logic_vector(36 downto 0);
signal ymux: std_logic_vector(2 downto 0);

begin
c1 :MPG port map(btn(0),clk,enable);
c2 :MPG port map(btn(1),clk,enable2);

IFmap: IFetch port map(enable,enable2,clk,BranchAddress,JumpAddress,Jump,PCSrc,InstrOut,PCout);


process(clk)
begin
    if(rising_edge(clk)) then
        ifid(31 downto 16)<=InstrOut;
        ifid(15 downto 0)<=PCOut;
    end if;
end process;
IDmap: IDecode port map (clk,InstrOut,WriteDataReg,RegWrite,enable,RegDst,ExtOp,RD1,RD2,Ext_Imm,Func,SA);
CUmap: ControlUnit port map (InstrOut(15 downto 13),RegDst,ExtOp,ALUSrc,Branch,Jump,ALUOp,MemWrite,MemtoReg,RegWrite);

process(clk)
begin
    if rising_edge(clk) then
        idex(88)<=MemtoReg;
        idex(87)<=RegWrite;
        idex(86)<=MemWrite;
        idex(55)<=Branch;
        idex(84 downto 82)<=ALUOp;
        idex(81)<=ALUSrc;
        idex(79 downto 64)<=ifid(15 downto 0);
        idex(63 downto 48)<=ifid(31 downto 16);
        idex(47 downto 32)<=RD1;
        idex(31 downto 16)<=RD2;
        idex(15 downto 0)<=Ext_imm;
    end if;
end process;

process(RegDst)
begin
    case RegDst is
    when '0' => ymux<=idex(57 downto 55);
    when '1' => ymux<=idex(54 downto 52);
    when others=>ymux<="000";
    end case;
end process;
EXEcomp: ExecutionUnit port map(idex(79 downto 64),idex(47 downto 32),idex(31 downto 16),idex(15 downto 0),idex(50 downto 48),idex(51), idex(81),idex(84 downto 82),BranchAddress,ALURes,ZeroSignal);


process(clk)
begin
    if rising_edge(clk) then
        exmem(55)<=ZeroSignal;
        exmem(54)<=idex(88);--MemtoReg;
        exmem(53)<=idex(87);--RegWrite;
        exmem(52)<=idex(86);--MemWrite;
        exmem(51)<=idex(55);--Branch;
        exmem(50 downto 35)<=BranchAddress;
        exmem(34 downto 19)<=ALURes;
        exmem(18 downto 3)<=idex(31 downto 16);--RD2;
        exmem(2 downto 0)<=YMUX;
    end if;
end process;

Memcomp: MEM port map(clk,exmem(34 downto 19),exmem(18 downto 3),exmem(52),enable,MemData,ALUResOut);
process(clk)
begin
    if rising_edge(clk) then
        memwb(36)<=exmem(54);
        memwb(35)<=exmem(53);
        memwb(34 downto 19)<=MemData;
        memwb(18 downto 3)<=ALUResOut;
        memwb(2 downto 0)<=exmem(2 downto 0);
    end if;
end process;


process(MemtoReg,ALUResOut,MemData)
begin
	case (MemtoReg) is
		when '1' => WriteDataReg<=memwb(34 downto 19);
		when '0' => WriteDataReg<=memwb(18 downto 3);
		when others => WriteDataReg<=WriteDataReg;
	end case;
end process;	

PCSrc<=ZeroSignal and Branch;

JumpAddress<=PCOut(15 downto 14) & InstrOut(13 downto 0);

SSDmap: SSD port map(clk, y, an, cat);


process(InstrOut,PCout,RD1,RD2,Ext_Imm,ALURes,MemData,WriteDataReg,sw)
begin
	case(sw(7 downto 5)) is
		when "000"=>
				y<=InstrOut;
		when "001"=>
				y<=PCout;
		when "010"=>
				y<=RD1;
		when "011"=>
				y<=RD2;
		when "100"=>
				y<=Ext_Imm;
		when "101" => 
				y<=ALURes;		
		when "110"=>
				y<=MemData;
		when "111"=>
				y<=WriteDataReg;
		when others=>
				y<=X"AAAA";
	end case;
end process;

process(RegDst,ExtOp,ALUSrc,Branch,Jump,MemWrite,MemtoReg,RegWrite,sw,ALUOp)
begin
	if sw(0)='0' then		
		led(7)<=RegDst;
		led(6)<=ExtOp;
		led(5)<=ALUSrc;
		led(4)<=Branch;
		led(3)<=Jump;
		led(2)<=MemWrite;
		led(1)<=MemtoReg;
		led(0)<=RegWrite;
		
	else
		led(2 downto 0)<=ALUOp(2 downto 0);
		led(7 downto 3)<="00000";
	end if;
end process;	


end Behavioral;

