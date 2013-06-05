library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helpers.all;

entity instrumentation is
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
end instrumentation;

architecture instrumentation_arch of instrumentation is

    -- ADCs
    signal adc_clk_out    : std_logic; -- os dados lidos dos ADCs estao atualizados
                                       -- e validos na borda de subida deste sinal
    signal ILk : unsigned(11 downto 0);
    signal VOk : unsigned(11 downto 0);
    signal VINk: unsigned(11 downto 0);

    component ad7276
        port (
            i_clk: in  std_logic;
            c_ncs: out std_logic;
            c_dat: in  std_logic;
            o_dat: out unsigned(11 downto 0) := (others => '0')
        );
    end component;

begin

    -- ADCs
    adc_ncs_il0 <= adc_clk_out;
    adc_il0_inst : ad7276
    port map (
        i_clk => i_clk,
        c_ncs => adc_clk_out,
        c_dat => adc_dat_il0,
        o_dat => ILk
    );
    adc_uo1_inst : ad7276
    port map (
        i_clk => i_clk,
        c_ncs => adc_ncs_uo1,
        c_dat => adc_dat_uo1,
        o_dat => VOk
    );
    adc_un0_inst : ad7276
    port map (
        i_clk => i_clk,
        c_ncs => adc_ncs_un0,
        c_dat => adc_dat_un0,
        o_dat => VINk
    );

    adc_clk     <= i_clk;
    process(adc_clk_out)
        constant max  : integer := 4;
        variable count: integer range 0 to max-1 := max-1;
    begin
        if rising_edge(adc_clk_out) then
            count := incrementa(count, max-1);
            if count = 0 then
                adc_out_il0 <= ILk;
                adc_out_uo1 <= VOk;
                adc_out_un0 <= VINk;
            end if;
            if count = 0 then
                o_clk <= '1';
            else
                o_clk <= '0';
            end if;
        end if;
    end process;

end instrumentation_arch;
