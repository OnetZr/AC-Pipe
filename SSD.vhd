library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SSD is
    Port (
        clk     : in STD_LOGIC;
        digits  : in STD_LOGIC_VECTOR(15 downto 0);
        an      : out STD_LOGIC_VECTOR(3 downto 0);
        cat     : out STD_LOGIC_VECTOR(6 downto 0)
    );
end SSD;

architecture Behavioral of SSD is

    signal digit_sel : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal refresh_counter : STD_LOGIC_VECTOR(18 downto 0) := (others => '0');
    signal current_digit : STD_LOGIC_VECTOR(3 downto 0);

begin


    process(clk)
    begin
        if rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
            digit_sel <= refresh_counter(18 downto 17); 
        end if;
    end process;


    process(digit_sel, digits)
    begin
        case digit_sel is
            when "00" =>
                an <= "1110";
                current_digit <= digits(3 downto 0);
            when "01" =>
                an <= "1101";
                current_digit <= digits(7 downto 4);
            when "10" =>
                an <= "1011";
                current_digit <= digits(11 downto 8);
            when others =>
                an <= "0111";
                current_digit <= digits(15 downto 12);
        end case;
    end process;


    process(current_digit)
    begin
        case current_digit is
            when "0000" => cat <= "0000001"; -- 0
            when "0001" => cat <= "1001111"; -- 1
            when "0010" => cat <= "0010010"; -- 2
            when "0011" => cat <= "0000110"; -- 3
            when "0100" => cat <= "1001100"; -- 4
            when "0101" => cat <= "0100100"; -- 5
            when "0110" => cat <= "0100000"; -- 6
            when "0111" => cat <= "0001111"; -- 7
            when "1000" => cat <= "0000000"; -- 8
            when "1001" => cat <= "0000100"; -- 9
            when "1010" => cat <= "0001000"; -- A
            when "1011" => cat <= "1100000"; -- B
            when "1100" => cat <= "0110001"; -- C
            when "1101" => cat <= "1000010"; -- D
            when "1110" => cat <= "0110000"; -- E
            when "1111" => cat <= "0111000"; -- F
            when others => cat <= "1111111"; -- Blank
        end case;
    end process;

end Behavioral;
