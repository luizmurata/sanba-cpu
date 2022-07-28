library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity SanbaCPU is
    port ( 
        clk : in std_logic;
        VGA_R : out std_logic_vector(3 downto 0);
        VGA_G : out std_logic_vector(3 downto 0);
        VGA_B : out std_logic_vector(3 downto 0);
        VGA_HS : out std_logic;
        VGA_VS : out std_logic
    );
end SanbaCPU;

architecture rtl of SanbaCPU is
    signal r_we : std_logic;
    signal r_waddr  : std_logic_vector(15 downto 0) := x"0000";
    signal r_raddr  : std_logic_vector(15 downto 0) := x"0000";
    signal r_i_data : std_logic_vector(7 downto 0) := x"00";
    signal r_o_data : std_logic_vector(7 downto 0) := x"00";
begin
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
    
    cpu : entity work.CPU port map (
        i_clk => clk,
        o_we => r_we,
        o_data => r_i_data,
        i_data => r_o_data,
        o_waddr => r_waddr,
        o_raddr => r_raddr
    );
    
    process (clk) is
    begin
		if rising_edge(clk) then
        end if;
    end process;
end rtl;
