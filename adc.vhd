library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc is
    port (
        i_clk: in  std_logic;
        c_ncs: out std_logic := '1';
        c_dat: in  std_logic;
        o_dat: out unsigned(11 downto 0) := (others => '0')
    );
end adc;

architecture adc_arch of adc is
    signal data: unsigned(11 downto 0) := (others => '0');
begin
    process(i_clk)
        variable count: integer range 0 to 15 := 0;
    begin
        if falling_edge(i_clk) then
            if count > 12 then
                c_ncs <= '1';
            else
                c_ncs <= '0';
            end if;
            if count = 15 then
                count := 0;
            else
                count := count + 1;
            end if;
        end if;
        if rising_edge(i_clk) then
            data  <= data(10 downto 0) & c_dat;
            if count = 13 then
                o_dat <= data(10 downto 0) & c_dat;
            end if;
        end if;
    end process;
end adc_arch;
