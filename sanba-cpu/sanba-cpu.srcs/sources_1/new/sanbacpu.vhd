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
    signal r_waddr  : std_logic_vector(9 downto 0) := "0000000000";
    signal r_raddr  : std_logic_vector(9 downto 0) := "0000000000";
    signal r_i_data : std_logic_vector(7 downto 0) := x"00";
    signal r_o_data : std_logic_vector(7 downto 0) := x"00";
    
    signal once : natural := 0;
begin
    vu : entity work.VideoUnit port map (
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
    
    process (clk) is
    begin
		if rising_edge(clk) then
			if once = 0 then
				r_i_data <= "11111111";
                r_waddr <= "0000010000";
				r_we <= '1';
				once <= 1;
			elsif once = 1 then
				r_i_data <= "10101010";
				r_waddr <= "0000110000";
				r_we <= '1';
				once <= 2;
			else
				r_we <= '0';
			end if;
		end if;
    end process;
end rtl;
