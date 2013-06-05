library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helpers.all;

entity ad7276_tb is
end ad7276_tb;

architecture ad7276_tb_arch of ad7276_tb is
    signal tb_clk: std_logic := '0';
    signal tb_ncs: std_logic;
    signal tb_c_dat: std_logic := '0';
    signal tb_o_dat: unsigned(11 downto 0);
    signal tb_o_mm : unsigned(11 downto 0);

    component ad7276
    port (
        i_clk: in  std_logic;
        c_ncs: out std_logic := '1';
        c_dat: in  std_logic;
        o_dat: out unsigned(11 downto 0) := (others => '0');
        -- media movel
        o_mm : out unsigned(11 downto 0) := (others => '0')
    );
    end component;

    constant half_step: time := 3125 ps;
    constant mm_exp   : integer := 5;

    -- debug
    signal dbg_count: integer range 0 to 15;
    signal dbg_data : unsigned(0 to 11);
begin

    ad7276_inst : ad7276
    port map (
        i_clk => tb_clk,
        c_ncs => tb_ncs,
        c_dat => tb_c_dat,
        o_dat => tb_o_dat,
        o_mm  => tb_o_mm
    );

    -- tb_clk
    process
    begin
        tb_clk <= '0';
        wait for half_step;
        tb_clk <= '1';
        wait for half_step;
    end process;

    -- testa todos os valores de 0 a 4095
    process(tb_ncs, tb_clk)
        variable tb_count: integer range 0 to 15 := 0;
        variable tb_data : unsigned(0 to 11) := (others => '1');
        variable stop    : boolean := false;
        -- media movel
        type buf_array is array (0 to 2**mm_exp-1) of unsigned(11 downto 0);
        variable buf  : buf_array := (others => (others => '0'));
        variable acc  : unsigned(11+mm_exp downto 0) := (others => '0');
        variable idx  : integer range 0 to 2**mm_exp-1 := 0;
        variable tb_mm: unsigned(11 downto 0);
    begin
        if    falling_edge(tb_ncs) then
            tb_count := 0;
            tb_data  := tb_data + 1;
            if tb_data = "111111111111" then
                stop := true;
            end if;
            -- media movel
            acc := acc - buf(idx);
            acc := acc + tb_data;
            buf(idx) := tb_data;
            tb_mm := acc(11+mm_exp downto mm_exp);
            idx := incrementa(idx, 2**mm_exp-1);
        elsif rising_edge(tb_ncs) then
            if    tb_data /= tb_o_dat then
                report "valor lido pelo AD nao confere!" severity failure;
            elsif tb_mm   /= tb_o_mm  then
                report "valor da media movel nao confere!" severity failure;
            end if;
        end if;
        if tb_ncs = '0' and falling_edge(tb_clk) then
            if    tb_count < 12 then
                tb_c_dat <= tb_data(tb_count);
            elsif tb_count = 12 and stop then
                report "fim da simulacao. tudo OK!" severity failure;
            end if;
            tb_count := tb_count + 1;
        end if;
        -- debug
        dbg_count <= tb_count;
        dbg_data  <= tb_data;
    end process;
end ad7276_tb_arch;
