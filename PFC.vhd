library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helpers.all;

entity PFC is
    generic (
        len      : integer :=  12;
        resolucao: integer := 800;
        n_saidas : integer :=   2
    );
    port (
        clk   : in  std_logic;

        -- interruptores
        S     : out std_logic_vector(3 downto 0);
        D     : out std_logic_vector(3 downto 0);

        -- instrumentacao
        adc_clk: out std_logic;
        adc_ncs_il0: out std_logic; -- IL
        adc_dat_il0: in  std_logic;
        adc_ncs_uo1: out std_logic; -- VO
        adc_dat_uo1: in  std_logic;
        adc_ncs_un0: out std_logic; -- VIN
        adc_dat_un0: in  std_logic;

        -- rele
        o_rele: out std_logic;

        -- DEBUG
        sw    : in  std_logic_vector(3 downto 0);
        keys  : in  std_logic_vector(1 downto 0);
        led   : out std_logic_vector(7 downto 0);
        fs    : out std_logic
    );
end PFC;

architecture PFC_arch of PFC is

    -- PLL
    signal clk_pll: std_logic;

    component pll
        port (
            inclk0: in  std_logic;
            c0    : out std_logic;
            c1    : out std_logic
        );
    end component;

    -- instrumentacao
    signal adc_clk_sig    : std_logic;
    signal adc_clk_out    : std_logic; -- os dados lidos dos ADCs estao atualizados
                                       -- e validos na borda de subida deste sinal
    signal ILk : unsigned(11 downto 0);
    signal VOk : unsigned(11 downto 0);
    signal VINk: unsigned(11 downto 0);

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

    -- PWM
    signal pwm_enable : std_logic := '0';
    signal pwm_input  : unsigned(int_length(resolucao)-1 downto 0);

    component pwm
        generic (
            resolucao: integer;
            n_saidas : integer
        );
        port (
            clk   : in  std_logic;
            enable: in  std_logic;
            input : in  unsigned(int_length(resolucao)-1 downto 0);
            S     : out std_logic_vector(n_saidas-1 downto 0);
            D     : out std_logic_vector(n_saidas-1 downto 0);
            fs    : out std_logic
        );
    end component;

    -- rele
    signal o_rele_sig: std_logic := '0';

    -- controle

    component controle
        generic (
            res  : integer;
            len  : integer
        );
        port (
            clk  : in  std_logic;
            ILk  : in  unsigned(len-1 downto 0);
            VOk  : in  unsigned(len-1 downto 0);
            VINk : in  unsigned(len-1 downto 0);
            M_out: out unsigned(int_length(res)-1 downto 0)
        );
    end component;

    -- DEBUG
    signal led_sig: std_logic_vector(11 downto 0) := (others => '0');

    -- interruptores
    signal S_sig: std_logic_vector(n_saidas-1 downto 0);
    signal D_sig: std_logic_vector(n_saidas-1 downto 0);

    signal S250_sig: std_logic_vector(n_saidas-1 downto 0);
    signal D250_sig: std_logic_vector(n_saidas-1 downto 0);
    signal fs250: std_logic;

--    signal S500_sig: std_logic_vector(n_saidas-1 downto 0);
--    signal D500_sig: std_logic_vector(n_saidas-1 downto 0);
--    signal fs500: std_logic;
--
--    signal S1000_sig: std_logic_vector(n_saidas-1 downto 0);
--    signal D1000_sig: std_logic_vector(n_saidas-1 downto 0);
--    signal fs1000: std_logic;

begin

    -- PLL
    pll_inst : pll
    port map (
        inclk0  => clk,
        c0      => clk_pll,
        c1      => adc_clk_sig
    );

    -- Instrumentacao
    instrumentation_inst : instrumentation
    port map (
        i_clk       => adc_clk_sig,
        adc_clk     => adc_clk    ,
        adc_ncs_il0 => adc_ncs_il0,
        adc_dat_il0 => adc_dat_il0,
        adc_out_il0 => ILk,
        adc_ncs_uo1 => adc_ncs_uo1,
        adc_dat_uo1 => adc_dat_uo1,
        adc_out_uo1 => VOk,
        adc_ncs_un0 => adc_ncs_un0,
        adc_dat_un0 => adc_dat_un0,
        adc_out_un0 => VINk,
        o_clk       => adc_clk_out
    );

    -- PWM
    pwm250_inst : pwm
    generic map (
        resolucao => resolucao,
        n_saidas  => n_saidas
    )
    port map (
        clk    => clk_pll,
        enable => pwm_enable,
        input  => pwm_input,
        S      => S250_sig,
        D      => D250_sig,
        fs     => fs250
    );

--    pwm500_inst : pwm
--    generic map (
--        resolucao => resolucao/2,
--        n_saidas  => n_saidas
--    )
--    port map (
--        clk    => clk_pll,
--        enable => pwm_enable,
--        input  => pwm_input(int_length(resolucao)-1 downto 1),
--        S      => S500_sig,
--        D      => D500_sig,
--        fs     => fs500
--    );
--
--    pwm1000_inst : pwm
--    generic map (
--        resolucao => resolucao/4,
--        n_saidas  => n_saidas
--    )
--    port map (
--        clk    => clk_pll,
--        enable => pwm_enable,
--        input  => pwm_input(int_length(resolucao)-1 downto 2),
--        S      => S1000_sig,
--        D      => D1000_sig,
--        fs     => fs1000
--    );
--
--    with sw(1 downto 0) select
--    D_sig <= D1000_sig when "11",
--             D500_sig  when "01",
--             D500_sig  when "10",
--             D250_sig  when others;
--
--    with sw(1 downto 0) select
--    S_sig <= S1000_sig when "11",
--             S500_sig  when "01",
--             S500_sig  when "10",
--             S250_sig  when others;
--
--    with sw(1 downto 0) select
--    fs <= fs1000 when "11",
--          fs500  when "01",
--          fs500  when "10",
--          fs250  when others;

    D_sig <= D250_sig;
    S_sig <= S250_sig;
    fs    <= fs250;

    -- interruptores
    S(0) <= S_sig(0);
    S(1) <= S_sig(1);
    S(2) <= '0';
    S(3) <= '0';

    D(0) <= D_sig(0);
    D(1) <= D_sig(1);
    D(2) <= '0';
    D(3) <= '0';

    -- rele
    o_rele     <= o_rele_sig;

    -- controle
    controle_inst : controle
    generic map (
        res   => resolucao,
        len   => len
    )
    port map (
        clk   => adc_clk_out,
        ILk   => ILk,
        VOk   => VOk,
        VINk  => VINk,
        M_out => pwm_input
    );

    -- Protecao
    led <= led_sig(11 downto 4);
    process(ILk, VOk, keys(0))
        variable enable: boolean := true;
    begin
        if keys(0) = '0' and enable = false then
            enable := true;
        elsif unsigned(ILk) > to_unsigned(2000, 12) or
              unsigned(VOk) > to_unsigned(2000, 12) then
            enable := false;
        else
            enable := enable;
        end if;
        if enable then
            pwm_enable <= '1';
            led_sig <= std_logic_vector(ILk);
        else
            pwm_enable <= '0';
            led_sig <= (others => '1');
        end if;
    end process;

end PFC_arch;
