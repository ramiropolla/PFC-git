library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package helpers is
    type cont_array is array(natural range <>) of integer;
    function int_length(x: integer) return integer;
    function boolean_to_std_logic(x: boolean) return std_logic;
    function limit(x: unsigned; n: integer; min: integer; max: integer) return unsigned;
    function limitsx(x: signed; len: integer) return signed;

    -- 1
    function tf_pi(erro_cur: signed; A0: unsigned; erro_prev: signed; A1: unsigned; saida_prev: signed) return signed;
    -- 2
    function qmult(a: signed; b: signed) return signed;
    function qmult(a: signed; b: signed; gain: integer) return signed;
    function qmult(a: signed; b: unsigned) return signed;
    function qmult(a: signed; b: unsigned; gain: integer) return signed;
    function umult(a: unsigned; b: unsigned) return unsigned;
    -- 3
    function u_diff(pos: unsigned; neg: unsigned) return signed;
    -- 4
    function limit0(x: signed; len: integer) return unsigned;
end;

package body helpers is
    function int_length(x: integer) return integer is
        variable ret: integer := 1;
        variable l_x: integer := x;
    begin
        while l_x > 1 loop
            ret := ret + 1;
            l_x := l_x / 2;
        end loop;
        return ret;
    end function int_length;

    function boolean_to_std_logic(x: boolean) return std_logic is
    begin
        if x then
            return '1';
        else
            return '0';
        end if;
    end function boolean_to_std_logic;

    function limit(x: unsigned; n: integer; min: integer; max: integer) return unsigned is
    begin
        if    x > max then
            return to_unsigned(max, n);
        elsif x < min then
            return to_unsigned(min, n);
        else
            return unsigned(x);
        end if;
    end function limit;

    function limitsx(x: signed; len: integer) return signed is
        variable maxval: signed(x'length-1 downto 0) := (others => '0');
        variable minval: signed(x'length-1 downto 0) := (others => '1');
        variable i: integer := 0;
    begin
        while i < len loop
            maxval(i) := '1';
            minval(i) := '0';
            i := i + 1;
        end loop;
        if    x > maxval then
            return maxval;
        elsif x < minval then
            return minval;
        else
            return x;
        end if;
    end function limitsx;

    -- 1
    function tf_pi(erro_cur: signed; A0: unsigned; erro_prev: signed; A1: unsigned; saida_prev: signed) return signed is
        variable saida         : signed(saida_prev'length-1   downto 0);
        variable saida_lim     : signed(saida_prev'length-1 downto 0);
        variable Aerro_cur     : signed(erro_cur'length-1 downto 0);
        variable Aerro_prev    : signed(erro_cur'length-1 downto 0);
        variable Aerro_diff    : signed(erro_cur'length-1 downto 0);
        variable Aerro_diff_lim: signed(erro_cur'length-1 downto 0);
    begin
        Aerro_cur      := qmult(erro_cur , A0);
        Aerro_prev     := qmult(erro_prev, A1);
        Aerro_diff     := Aerro_cur - Aerro_prev;
        Aerro_diff_lim := limitsx(Aerro_diff, erro_cur'length-1);
        saida          := Aerro_diff_lim + saida_prev;
        saida_lim      := limitsx(saida, saida_prev'length-1);
        return saida_lim;
    end function tf_pi;

    -- 2
    function qmult(a: signed; b: signed) return signed is
    begin
        return qmult(a, b, 0);
    end function qmult;
    function qmult(a: signed; b: signed; gain: integer) return signed is
        constant alen: integer := a'length;
        constant blen: integer := b'length;
        variable mult: signed(alen+blen-1 downto 0);
        variable res : signed(     blen-1 downto 0);
--        variable sign: boolean := false;
    begin
        mult := a * b;
--        if mult < 0 then
--            sign := true;
--            mult := -mult;
--        end if;
        res := mult(alen+blen-1-gain downto alen-gain);
--        if sign then
--            res := -res;
--        end if;
        res := limitsx(res, blen-1);
        return res;
    end function qmult;
    function qmult(a: signed; b: unsigned) return signed is
    begin
        return qmult(a, b, 0);
    end function qmult;
    function qmult(a: signed; b: unsigned; gain: integer) return signed is
        variable s_b: signed(b'length downto 0);
    begin
        s_b := signed('0'&b);
        return qmult(a, s_b, gain+1);
    end function qmult;

    function umult(a: unsigned; b: unsigned) return unsigned is
        constant len : integer := a'length;
        variable mult: unsigned(2*len-1 downto 0);
        variable res : unsigned(  len-1 downto 0);
    begin
        mult := a * b;
        res := mult(2*len-1 downto len);
        return res;
    end function umult;

    -- 3
    function u_diff(pos: unsigned; neg: unsigned) return signed is
        constant len : integer := pos'length;
        variable s_pos: signed(len downto 0);
        variable s_neg: signed(len downto 0);
        variable res  : signed(len downto 0);
    begin
        s_pos := signed('0'&pos);
        s_neg := signed('0'&neg);
        res   := s_pos - s_neg;
        return res;
    end function u_diff;

    -- 4
    function limit0(x: signed; len: integer) return unsigned is
        variable maxval: signed(x'length-1 downto 0) := (others => '0');
        constant minval: signed(x'length-1 downto 0) := (others => '0');
        variable i: integer := 0;
    begin
        while i < len loop
            maxval(i) := '1';
            i := i + 1;
        end loop;
        if    x > maxval then
            return unsigned(maxval(len-1 downto 0));
        elsif x < minval then
            return unsigned(minval(len-1 downto 0));
        else
            return unsigned(x(len-1 downto 0));
        end if;
    end function limit0;

end package body;
