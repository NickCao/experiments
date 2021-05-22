library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity led is
  port(clk:in std_logic;
       rst:in std_logic;
       odd:out std_logic_vector(3 downto 0);
       even:out std_logic_vector(3 downto 0);
       nat:out std_logic_vector(6 downto 0));
end led;

architecture led_bhv of led is
begin
  process(clk)
    variable cnt_even:integer := 0;
    variable cnt_nat:integer := 0;
  begin
    if (clk'event and clk = '1') then
      cnt_even := cnt_even + 2;
      cnt_nat := cnt_nat + 1;
      if (cnt_even > 8 or rst = '1') then
        cnt_even := 0;
      end if;
      if (cnt_nat > 15 or rst = '1') then
        cnt_nat := 0;
      end if;
    end if;
    odd <= std_logic_vector(to_unsigned(cnt_even + 1 , odd'length));
    even <= std_logic_vector(to_unsigned(cnt_even, even'length));
    case cnt_nat is
      when 0 => nat <= "0111111";
      when 1 => nat <= "0000110";
      when 2 => nat <= "1011011";
      when 3 => nat <= "1001111";
      when 4 => nat <= "1100110";
      when 5 => nat <= "1101101";
      when 6 => nat <= "1111101";
      when 7 => nat <= "0000111";
      when 8 => nat <= "1111111";
      when 9 => nat <= "1100111";
      when 10 => nat <= "1110111";
      when 11 => nat <= "1111100";
      when 12 => nat <= "0111001";
      when 13 => nat <= "1011110";
      when 14 => nat <= "1111001";
      when 15 => nat <= "1110001";
      when others => nat <= "0000000";
    end case;
  end process;
end;
