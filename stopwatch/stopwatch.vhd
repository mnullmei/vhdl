library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stopwatch is
    Port (  clk :  in  std_logic;
            btnL : in  std_logic;
            btnR : in  std_logic;
            seg :  out std_logic_vector(6 downto 0);
            an  :  out std_logic_vector(3 downto 0)
    );
end entity stopwatch;

architecture rtl of stopwatch is

component debounce is   
    port ( debounce_clk : in std_logic;
           debounce_input : in std_logic;
           debounce_output : out std_logic);
end component debounce;

component g_counter is
    generic (
        count_high : natural := 9);
    Port ( g_clock :   in  std_logic;
           rst :       in  std_logic;
           count :     out natural range 0 to count_high;
           div_clock : out std_logic);
end component g_counter;

signal clk_12_khz : std_logic;

signal start_stop : std_logic := '0';
signal clock_run : std_logic;

signal button_left  : std_logic;
signal button_right : std_logic;

signal do_reset : std_logic := '0';

-- separate counter for even illumination of all 4 7-segment digits
signal led_driver_counter : std_logic_vector (18 downto 0);
signal led_driver_mux     : std_logic_vector (1  downto 0);

signal led_digit : natural range 0 to 9;

signal clock_m100 : std_logic;
signal clock_m10 :  std_logic;
signal clock_1 :    std_logic;
signal clock_10 :   std_logic;
signal clock_min :  std_logic;

signal seg_m100 : natural range 0 to 9 := 0;
signal seg_m10 :  natural range 0 to 9 := 0;
signal seg_1 :    natural range 0 to 9 := 0;
signal seg_10 :   natural range 0 to 9 := 0;

constant div_100_hz : natural := 500000;
signal counter_100_hz : natural range 0 to div_100_hz;
signal clk_100_hz : std_logic := '0';

begin
    clk_12_khz <= led_driver_counter(12);

    debounce_reset : debounce
        port map (
            debounce_clk => clk_12_khz,
            debounce_input => btnL,
            debounce_output => button_left);

    debounce_start_stop : debounce
        port map (
            debounce_clk => clk_12_khz,
            debounce_input => btnR,
            debounce_output => button_right);

    start_stop_state : process(button_right)
    begin
        if (rising_edge(button_right)) then
            start_stop <= not start_stop;
        end if;       
    end process start_stop_state;

    do_reset <= '1' when (button_left = '1') and (start_stop = '0') else '0';

    p_100_hz : process (clk) is
    begin
        if rising_edge(clk) then
            led_driver_counter <= std_logic_vector(unsigned(led_driver_counter) + 1);
            if counter_100_hz = div_100_hz - 1 then
                counter_100_hz <= 0;
                clk_100_hz <= not clk_100_hz;
             else
                counter_100_hz <= counter_100_hz + 1;
            end if;
        end if;
    end process p_100_hz;

    clock_run <= start_stop and clk_100_hz;

    counter_m100 : g_counter
        port map (
            g_clock   => clock_run,
            rst       => do_reset,
            count     => seg_m100,
            div_clock => clock_m10);
                
   counter_m10 : g_counter
        port map (
            g_clock   => clock_m10,
            rst       => do_reset,
            count     => seg_m10,
            div_clock => clock_1);

   counter_1 : g_counter
        port map (
            g_clock   => clock_1,
            rst       => do_reset,
            count     => seg_1,
            div_clock => clock_10);

    counter_10 : g_counter
        generic map (
            count_high => 5)
        port map (
            g_clock   => clock_10,
            rst       => do_reset,
            count     => seg_10,
            div_clock => clock_min);

    led_decode : process(led_digit)
    begin
        case led_digit is
            when 0 => seg <= "1000000";
            when 1 => seg <= "1111001";
            when 2 => seg <= "0100100";
            when 3 => seg <= "0110000";
            when 4 => seg <= "0011001";
            when 5 => seg <= "0010010";
            when 6 => seg <= "0000010";
            when 7 => seg <= "1111000";
            when 8 => seg <= "0000000";
            when 9 => seg <= "0010000";
            when others => seg <= "1111111";
        end case;
    end process led_decode;

    led_driver_mux <= led_driver_counter(18 downto 17); -- 381 Hz refresh
    led_driver: process(led_driver_mux)
    begin
        case led_driver_mux is
            when "00" => an <= "0111"; 
                         led_digit <= seg_10;
            when "01" => an <= "1011"; 
                         led_digit <= seg_1;
            when "10" => an <= "1101"; 
                         led_digit <= seg_m10;
            when "11" => an <= "1110"; 
                         led_digit <= seg_m100;
        end case;
    end process led_driver;

end rtl;
