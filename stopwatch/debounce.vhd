library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is   
    port ( debounce_clk : in std_logic;
           debounce_input : in std_logic;
           debounce_output : out std_logic);
end entity debounce;

architecture rtl of debounce is

    constant debounce_time : natural := 122;  -- 10 ms for 12.2 kHz debounce_clk
    signal debounce_counter : natural range 0 to debounce_time := 0;
    signal old_input : std_logic := '0';

begin

   p_debounce : process (debounce_clk) is
    begin
        if rising_edge(debounce_clk) then
            if debounce_input =  old_input then
                debounce_counter <= 0;
            else
                if debounce_counter /= debounce_time then -- ignore short transistions
                    debounce_counter <= debounce_counter + 1;
                else
                    old_input <= debounce_input;
                end if;
            end if;
        end if;
    end process p_debounce;

    debounce_output <= old_input;
    
end rtl;
