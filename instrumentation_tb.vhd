library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helpers.all;

entity instrumentation_tb is
end instrumentation_tb;

architecture instrumentation_tb_arch of instrumentation_tb is
    signal tb_i_clk      : std_logic := '0';
    signal tb_adc_clk    : std_logic;
    signal tb_adc_ncs_il0: std_logic;
    signal tb_adc_dat_il0: std_logic := '0';
    signal tb_adc_out_il0: unsigned(11 downto 0); -- IL
    signal tb_adc_ncs_uo1: std_logic;
    signal tb_adc_dat_uo1: std_logic := '0';
    signal tb_adc_out_uo1: unsigned(11 downto 0); -- VO
    signal tb_adc_ncs_un0: std_logic;
    signal tb_adc_dat_un0: std_logic := '0';
    signal tb_adc_out_un0: unsigned(11 downto 0); -- VIN
    signal tb_o_clk      : std_logic;

    component instrumentation
    port (
        i_clk      : in  std_logic;
        adc_clk    : out std_logic;
        adc_ncs_il0: out std_logic;
        adc_dat_il0: in  std_logic;
        adc_out_il0: out unsigned(11 downto 0); -- IL
        adc_ncs_uo1: out std_logic;
        adc_dat_uo1: in  std_logic;
        adc_out_uo1: out unsigned(11 downto 0); -- VO
        adc_ncs_un0: out std_logic;
        adc_dat_un0: in  std_logic;
        adc_out_un0: out unsigned(11 downto 0); -- VIN
        o_clk      : out std_logic
    );
    end component;

    constant half_step: time := 31250 ps;

    -- debug
    signal dbg_count: integer range 0 to 15;
    signal dbg_data : unsigned(0 to 11);
begin

    instrumentation_inst : instrumentation
    port map (
        i_clk       => tb_i_clk,
        adc_clk     => tb_adc_clk,
        adc_ncs_il0 => tb_adc_ncs_il0,
        adc_dat_il0 => tb_adc_dat_il0,
        adc_out_il0 => tb_adc_out_il0,
        adc_ncs_uo1 => tb_adc_ncs_uo1,
        adc_dat_uo1 => tb_adc_dat_uo1,
        adc_out_uo1 => tb_adc_out_uo1,
        adc_ncs_un0 => tb_adc_ncs_un0,
        adc_dat_un0 => tb_adc_dat_un0,
        adc_out_un0 => tb_adc_out_un0,
        o_clk       => tb_o_clk
    );

    -- tb_i_clk
    process
    begin
        tb_i_clk <= '0';
        wait for half_step;
        tb_i_clk <= '1';
        wait for half_step;
    end process;

    -- testa todos os valores de 0 a 4095
    process(tb_adc_ncs_il0, tb_i_clk)
        variable tb_count: integer range 0 to 15 := 0;
        variable tb_data : unsigned(0 to 11) := (others => '1');
        variable stop    : boolean := false;
        variable tb_count4: integer range 0 to 3 := 3;
    begin
        if    falling_edge(tb_adc_ncs_il0) then
            tb_count := 0;
            tb_data  := tb_data + 1;
            if tb_data = "111111111111" then
                stop := true;
            end if;
        elsif rising_edge(tb_adc_ncs_il0) then
            if tb_adc_out_il0 /= tb_adc_out_uo1 or
               tb_adc_out_uo1 /= tb_adc_out_un0 then
                report "valores lidos pelos ADCs nao sao iguais!" severity failure;
            end if;
            tb_count4 := incrementa(tb_count4, 3);
            if (tb_data-tb_count4) /= tb_adc_out_il0 then
                report "valor lido pelo AD nao confere!" severity failure;
            end if;
        end if;
        if tb_adc_ncs_il0 = '0' and falling_edge(tb_i_clk) then
            if    tb_count < 12 then
                tb_adc_dat_il0 <= tb_data(tb_count);
                tb_adc_dat_uo1 <= tb_data(tb_count);
                tb_adc_dat_un0 <= tb_data(tb_count);
            elsif tb_count = 12 and stop then
                report "fim da simulacao. tudo OK!" severity failure;
            end if;
            tb_count := tb_count + 1;
        end if;
        -- debug
        dbg_count <= tb_count;
        dbg_data  <= tb_data;
    end process;
end instrumentation_tb_arch;
