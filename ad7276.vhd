library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helpers.all;

entity ad7276 is
    port (
        i_clk: in  std_logic;
        c_ncs: out std_logic := '1';
        c_dat: in  std_logic;
        o_dat: out unsigned(11 downto 0) := (others => '0')
    );
end ad7276;

architecture ad7276_arch of ad7276 is
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
            count := incrementa(count, 15);
        end if;
        if rising_edge(i_clk) then
            data  <= data(10 downto 0) & c_dat;
            if count = 13 then
                o_dat <= data(10 downto 0) & c_dat;
            end if;
        end if;
    end process;
end ad7276_arch;
