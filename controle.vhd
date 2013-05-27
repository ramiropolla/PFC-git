library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helpers.all;

entity controle is
    generic (
        res  : integer;
        len  : integer
    );
    port (
        clk  : in  std_logic;
        ILk  : in  unsigned(len-1 downto 0) := to_unsigned(0, len);
        VOk  : in  unsigned(len-1 downto 0) := to_unsigned(0, len);
        VINk : in  unsigned(len-1 downto 0) := to_unsigned(0, len);
        M_out: out unsigned(int_length(res)-1 downto 0) := to_unsigned(0, int_length(res));

        -- depuracao
        s_V_erro_cur  : out signed(len downto 0);
        s_V_erro_prev : out signed(len downto 0) := (others => '0');
        s_G_cur       : out signed(len downto 0);
        s_G_prev      : out signed(len downto 0) := (others => '0');
        s_I_ref       : out signed(len downto 0);
        s_I_erro      : out signed(len downto 0);
        s_D           : out signed(len downto 0);
        s_D_res       : out signed(int_length(res) downto 0);
        s_u_D_res     : out unsigned(int_length(res)-1 downto 0)
    );
end controle;

architecture controle_arch of controle is
    constant res_len: integer := int_length(res);

    constant u_res : unsigned(res_len-1 downto 0) := to_unsigned( res, res_len);
    constant V_ref : unsigned(len    -1 downto 0) := to_unsigned(1320, len);
    constant V_A0  : unsigned(len    -1 downto 0) := to_unsigned(3693, len);
    constant V_A1  : unsigned(len    -1 downto 0) := to_unsigned(3686, len);
    constant I_K   : unsigned(len    -1 downto 0) := to_unsigned(3880, len);

begin

    process(clk, ILk, VOk, VINk)
        constant VOk_range   : integer := 1000;
        variable VOk_count   : integer range 0 to VOk_range-1 := VOk_range-1;
        variable V_erro_cur  : signed(len downto 0) := (others => '0');
        variable V_erro_prev : signed(len downto 0) := (others => '0');
        variable G_cur       : signed(len downto 0);
        variable G_prev      : signed(len downto 0) := (others => '0');
        variable I_ref       : signed(len downto 0);
        variable s_ILk       : signed(len downto 0);
        variable I_erro      : signed(len downto 0);
        variable D           : signed(len downto 0);
        variable D_res       : signed(res_len downto 0);
        variable u_D_res     : unsigned(res_len-1 downto 0);
        variable M           : unsigned(res_len-1 downto 0);
    begin
        if falling_edge(clk) then
            -- VOk sub-amostrado em 1000 vezes
            VOk_count := incrementa(VOk_count, VOk_range-1);
            if  VOk_count = 0 then
                V_erro_cur := u_diff(V_ref, VOk);
            end if;
            G_cur       := tf_pi(V_erro_cur, V_A0, V_erro_prev, V_A1, G_prev);
            I_ref       := qmult(G_cur, VINk); -- s13, u12
            s_ILk       := signed('0'&ILk);
            I_erro      := limitsx(s_ILk - I_ref, len);
            D           := qmult(I_erro, I_K, 2); -- s13, u12 -- ganho de 2 bits = 4
            D_res       := qmult(D, u_res); -- s13, u10
            u_D_res     := limit0(D_res, res_len);
            M           := u_res - u_D_res;

            -- depuracao
            s_V_erro_cur  <= V_erro_cur;
            s_G_cur       <= G_cur;
            s_I_ref       <= I_ref;
            s_I_erro      <= I_erro;
            s_D           <= D;
            s_D_res       <= D_res;
            s_u_D_res     <= u_D_res;
            s_V_erro_prev <= V_erro_prev;
            s_G_prev      <= G_prev;

            -- atualizacao dos delays e flip-flops
            M_out       <= M;
            V_erro_prev := V_erro_cur;
            G_prev      := G_cur;
        end if;
    end process;

end controle_arch;
