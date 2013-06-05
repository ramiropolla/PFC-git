library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helpers.all;

entity pwm_tb is
    generic (
        resolucao: integer := 800;
        n_saidas : integer :=   2
    );
end pwm_tb;

architecture pwm_tb_arch of pwm_tb is
    signal tb_clk      : std_logic := '0';
    signal tb_enable   : std_logic := '1';
    signal tb_low_power: std_logic := '0';
    signal tb_input    : unsigned(int_length(resolucao)-1 downto 0) := (others => '0');
    signal tb_S        : std_logic_vector(n_saidas-1 downto 0);
    signal tb_D        : std_logic_vector(n_saidas-1 downto 0);

    component pwm
    generic (
        resolucao: integer;
        n_saidas : integer
    );
    port (
        clk      : in  std_logic;
        enable   : in  std_logic;
        low_power: in  std_logic;
        input    : in  unsigned(int_length(resolucao)-1 downto 0);
        S        : out std_logic_vector(n_saidas-1 downto 0);
        D        : out std_logic_vector(n_saidas-1 downto 0);
        fs       : out std_logic
    );
    end component;

    constant half_step: time := 2500 ps;

    -- debug
    signal dbg_count: integer range 0 to resolucao;
    signal dbg_data : unsigned(int_length(resolucao)-1 downto 0);
begin

    pwm_inst : pwm
    generic map (
        resolucao => resolucao,
        n_saidas  => n_saidas
    )
    port map (
        clk       => tb_clk,
        enable    => tb_enable,
        low_power => tb_low_power,
        input     => tb_input,
        S         => tb_S,
        D         => tb_D
    );

    -- tb_clk
    process
    begin
        tb_clk <= '0';
        wait for half_step;
        tb_clk <= '1';
        wait for half_step;
    end process;

    -- testa todos os valores de 0 a resolucao
    process(tb_clk)
        variable int_input: integer range 0 to resolucao := 0;
        variable tb_count: integer range 0 to resolucao-1 := resolucao-1;
        variable tb_data : unsigned(int_length(resolucao)-1 downto 0) := (others => '1');
        variable stop    : boolean := false;
    begin
        if    falling_edge(tb_clk) then
            tb_count := incrementa(tb_count, resolucao-1);
            if tb_count = resolucao-1 then
                int_input := incrementa(int_input, resolucao);
                if int_input = resolucao then
                    report "fim da simulacao. tudo OK!" severity failure;
                end if;
            end if;
        elsif rising_edge (tb_clk) then
            if tb_count < int_input then
                if tb_S(1) /= '1' then
                    report "erro 1!" severity failure;
                end if;
            else
                if tb_S(1) /= '0' then
                    report "erro 0!" severity failure;
                end if;
            end if;
        end if;
        tb_data  := to_unsigned(int_input, int_length(resolucao));
        tb_input <= tb_data;
        -- debug
        dbg_count <= tb_count;
        dbg_data  <= tb_data;
    end process;
end pwm_tb_arch;
