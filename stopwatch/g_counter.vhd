library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g_counter is
    generic (
        count_high : natural);

    Port ( g_clock :   in  std_logic;
           rst :       in  std_logic;
           count :     out natural range 0 to count_high;
           div_clock : out std_logic);
end entity g_counter;

architecture rtl of g_counter is

signal counter : natural range 0 to count_high := 0;
signal next_clk : std_logic := '0';

begin
    p_count : process (g_clock, rst) is
    begin
        if rst = '1' then
            counter <= 0;
        elsif rising_edge(g_clock) then
            if counter = count_high then
                counter <= 0;
                next_clk <= '1';
            else
                counter <= counter + 1;
                next_clk <= '0';
            end if;
        end if;
    end process p_count;
    
    count <= counter;
    div_clock <= next_clk;
  
end rtl;
