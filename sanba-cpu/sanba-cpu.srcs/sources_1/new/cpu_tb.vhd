library ieee;
use ieee.std_logic_1164.all;
use std.textio.all; -- Imports the standard textio package.

entity cpu_tb is
end cpu_tb;

architecture tb of cpu_tb is
    constant period: time := 20 ns;
    signal clk : std_logic := '0';
    signal r_we : std_logic := '0';
    signal r_i_data : std_logic_vector(7 downto 0) := (others => '0');
    signal r_o_data : std_logic_vector(7 downto 0) := (others => '0');
    signal r_waddr : std_logic_vector(15 downto 0) := (others => '0');
    signal r_raddr : std_logic_vector(15 downto 0) := (others => '0');
    signal vga_r : std_logic_vector(3 downto 0) := (others => '0');
    signal vga_g : std_logic_vector(3 downto 0) := (others => '0');
    signal vga_b : std_logic_vector(3 downto 0) := (others => '0');
    signal vga_hs : std_logic := '0';
    signal vga_vs : std_logic := '0';
begin
    cpu : entity work.CPU port map (
        i_clk => clk,
        o_we => r_we,
        o_data => r_i_data,
        i_data => r_o_data,
        o_waddr => r_waddr,
        o_raddr => r_raddr
    );

    memory : entity work.Memory port map (
        i_clk => clk,
        i_we => r_we,
        i_data => r_i_data,
        o_data => r_o_data,
        i_waddr => r_waddr,
        i_raddr => r_raddr,
        o_vga_r => vga_r,
        o_vga_g => vga_g,
        o_vga_b => vga_b,
        o_vga_hsync => vga_hs,
        o_vga_vsync => vga_vs
    );

    process
    variable l : line;
    begin
        write (l, String'("-- BEGIN --"));
        writeline (output, l);
        for k in 0 to 8192 loop
            clk <= '1';
            wait for 10 ns;
            clk <= '0';
            wait for 10 ns;
        end loop;
        write (l, String'("-- END --"));
        writeline (output, l);
        wait; -- indefinitely suspend process
    end process;
end tb;