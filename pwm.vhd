library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helpers.all;

entity pwm is
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
--        para ajudar a conferir no osciloscopio
        fs    : out std_logic
    );
end pwm;

architecture pwm_arch of pwm is
    constant t_morto: unsigned(3 downto 0) := to_unsigned(8, 4);
begin
    process(clk, enable)
        type cont_array is array(n_saidas-1 downto 0) of natural range 0 to resolucao-1;
        variable contador: cont_array := ((2*resolucao/2)-1, (1*resolucao/2)-1);
        type bool_array is array(n_saidas-1 downto 0) of boolean;
        variable switches: bool_array := (others => false);
        variable diodes  : bool_array := (others => true);
    begin
        if not enable = '1' then
            switches := (others => false);
            diodes   := (others => false);
        elsif rising_edge(clk) then
            for i in 0 to n_saidas-1 loop
                if contador(i) = resolucao-1 then
                    contador(i) := 0;
                else
                    contador(i) := contador(i) + 1;
                end if;

                if contador(i) < unsigned(input) then
                    switches(i) := true;
                else
                    switches(i) := false;
                end if;
                if (unsigned(input) = 0) or
                   ((contador(i) >= unsigned(input)+unsigned(t_morto)) and
                    (contador(i) < to_unsigned(resolucao,int_length(resolucao)) - unsigned(t_morto))) then
                    diodes(i) := true;
                else
                    diodes(i) := false;
                end if;
            end loop;
            if contador(0) < resolucao/2 then
                fs <= '1';
            else
                fs <= '0';
            end if;
        end if;

        for i in 0 to n_saidas-1 loop
            S(i) <= boolean_to_std_logic(switches(i));
            D(i) <= boolean_to_std_logic(diodes  (i));
        end loop;
    end process;
end pwm_arch;
