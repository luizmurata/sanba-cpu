library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity CPU is
    port (
        i_clk   : in std_logic;
		o_we    : out std_logic;
		o_raddr : out std_logic_vector(15 downto 0);
		o_waddr : out std_logic_vector(15 downto 0);
		i_data  : in std_logic_vector(7 downto 0);
		o_data  : out std_logic_vector(7 downto 0)
    );
end entity CPU;

architecture rtl of CPU is

    type t_state is (
        start, fetch, send, stop
    );
    signal r_state : t_state := start;
    signal r_next_state : t_state;
    signal addr : std_logic_vector(9 downto 0) := "0000000000";
    signal data : std_logic_vector(7 downto 0) := x"00";

begin

    process (i_clk) is
    begin
        if rising_edge(i_clk) then
            r_state <= r_next_state;
        end if;
    end process;
    
    process (r_state,i_data,data,addr) is
    begin
        case r_state is
            when start =>
                o_we <= '0';
                o_raddr <= (others => '0');
                o_waddr <= (others => '0');
                o_data <= x"00";
                r_next_state <= fetch;
            when fetch =>
                o_raddr(15 downto 10) <= "000000";
                o_raddr(9 downto 0) <= addr;
                o_waddr <= (others => '0');
                o_we <= '0';
                o_data <= x"00";
                data <= i_data;
                r_next_state <= send;
            when send =>
                o_raddr <= (others => '0');
                o_waddr(15 downto 10) <= "111111";
                o_waddr(9 downto 0) <= addr;
                o_we <= '1';
                o_data <= data;
                addr <= addr + 1;
                r_next_state <= fetch;
            when stop =>
                o_we <= '0';
                o_raddr <= (others => '0');
                o_waddr <= (others => '0');
                o_data <= x"00";
                r_next_state <= stop;
        end case;
    end process;

end architecture rtl;