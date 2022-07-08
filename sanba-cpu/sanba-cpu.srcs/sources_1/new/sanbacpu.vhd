library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SanbaCPU is
  port ( 
    clk : in std_logic;
    VGA_R : out std_logic_vector(3 downto 0);
    VGA_G : out std_logic_vector(3 downto 0);
    VGA_B : out std_logic_vector(3 downto 0);
    VGA_HS : out std_logic;
    VGA_VS : out std_logic
  );
end sanbacpu;

architecture rtl of sanbacpu is
    signal r_vga_r : std_logic_vector(3 downto 0) := x"0";
    signal r_vga_g : std_logic_vector(3 downto 0) := x"0";
    signal r_vga_b : std_logic_vector(3 downto 0) := x"0";
begin
    vga : entity work.VGA port map (
        i_clk => clk,
        i_r => r_vga_r,
        i_g => r_vga_g,
        i_b => r_vga_b,
        o_vga_r => vga_r,
        o_vga_g => vga_g,
        o_vga_b => vga_b,
        o_vga_hsync => vga_hs,
        o_vga_vsync => vga_vs
    );
    
    process (clk) is
    begin
        r_vga_r <= x"f";
        r_vga_g <= x"f";
    end process;
end rtl;
