library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity alu is
  port (
    i_a : in std_logic_vector(7 downto 0);
    i_b : in std_logic_vector(7 downto 0);
    o_q : out std_logic_vector(7 downto 0);
    o_c : out std_logic;
    o_z : out std_logic;
    i_op : in natural range 0 to 7
  );
end alu;

architecture rtl of alu is
    signal res : std_logic_vector(7 downto 0);
    signal x, y, add, sub : signed(8 downto 0);
begin
    process(i_a, i_b, i_op, x, y)
    begin
        o_c <= '-';
        case i_op is
            when 0 =>
                res <= std_logic_vector(add(7 downto 0));
                o_c <= add(8); 
            when 1 =>
                res <= std_logic_vector(sub(7 downto 0));
                o_c <= not sub(8);
            when 2 =>
                res <= i_a or i_b;
            when 3 =>
                res <= i_a and i_b;
            when 4 =>
                res <= i_a xor i_b;
            when others =>
                res <= x"00";
        end case;
    end process;
    
    x <= resize(signed(i_a), 9);
    y <= resize(signed(i_b), 9);
    add <= x + y;
    sub <= x - y;
    o_q <= res;
    o_z <= '1' when res = x"00" else '0';
    
end rtl;
