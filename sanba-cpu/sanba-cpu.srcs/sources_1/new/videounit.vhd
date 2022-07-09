library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity VideoUnit is
	port (
		-- clock (expected 100MHz)
		i_clk       : in std_logic;
		
		-- control signals
		i_we        : in std_logic;                     -- write enable
		i_data      : in std_logic_vector(7 downto 0);  -- input data to video memory (1x8 1bpp)
		o_data      : out std_logic_vector(7 downto 0); -- output data from video memory (1x8 1bpp)
		i_waddr     : in std_logic_vector(9 downto 0);  -- write address (64x128 1bpp matrix in row major order)
		i_raddr     : in std_logic_vector(9 downto 0);  -- read address (64x128 1bpp matrix in row major order)
		
		-- VGA connector
		o_vga_r     : out std_logic_vector(3 downto 0);
		o_vga_g     : out std_logic_vector(3 downto 0);
		o_vga_b     : out std_logic_vector(3 downto 0);
		o_vga_hsync : out std_logic;
		o_vga_vsync : out std_logic
	);
end;

architecture rtl of VideoUnit is
	constant V_START : natural range 0 to 639 := 80;
	
	-- video memory
	type t_mem is array (0 to 1023) of std_logic_vector(7 downto 0);
	signal video_mem : t_mem;
	
	-- counters for scaling
	signal r_hcount  : natural range 0 to 4 := 0;
	signal r_vcount  : natural range 0 to 4 := 0;
	signal r_row     : natural range 0 to 63 := 0;
	signal r_col     : natural range 0 to 127 := 0;
	signal old_x     : natural range 0 to 639 := 0;
	signal old_y     : natural range 0 to 319 := 0;

	-- signals for communication with the vga controller
	signal r_draw_en : std_logic;
	signal r_x       : natural range 0 to 639;
	signal r_y       : natural range 0 to 479;
	signal r_r       : std_logic_vector(3 downto 0);
	signal r_g       : std_logic_vector(3 downto 0);
	signal r_b       : std_logic_vector(3 downto 0);
begin
	vga_ctrl : entity work.VGA port map (
		i_clk => i_clk,
		o_draw_en => r_draw_en,
		o_x => r_x,
		o_y => r_y,
		i_r => r_r,
		i_g => r_g,
		i_b => r_b,
		o_vga_r => o_vga_r,
		o_vga_g => o_vga_g,
		o_vga_b => o_vga_b,
		o_vga_hsync => o_vga_hsync,
		o_vga_vsync => o_vga_vsync
	);
	
	mem_write : process (i_clk) is
	begin
		if rising_edge(i_clk) and (i_we = '1') then
		  video_mem(conv_integer(i_waddr)) <= i_data;
		end if;
	end process;
	
	draw : process (i_clk) is
		variable current_y  : natural range 0 to 319;
		variable current_x  : natural range 0 to 639;
		variable line_addr  : std_logic_vector(9 downto 0);
		variable off_c      : std_logic_vector(2 downto 0);
		variable cell       : std_logic;
		variable tmp        : std_logic_vector(7 downto 0);
	begin
		if rising_edge(i_clk) and (r_draw_en = '1') then
			if (r_y < V_START) or (r_y > (V_START+319)) then
				r_r <= x"0";
				r_g <= x"0";
				r_b <= x"1";
			else
				current_y := r_y - V_START;
				current_x := r_x;
				line_addr(9 downto 4) := std_logic_vector(to_unsigned(r_row, 6));
				tmp := std_logic_vector(to_unsigned(r_col, 8));
				line_addr(3 downto 0) := tmp(6 downto 3);
				off_c := tmp(2 downto 0);
				cell := video_mem(conv_integer(line_addr))(conv_integer(off_c));
				
				if cell = '1' then
					r_r <= x"1";
					r_g <= x"1";
					r_b <= x"1";
				else
					r_r <= x"0";
					r_g <= x"0";
					r_b <= x"0";
				end if;
				
				if current_x /= old_x then
					if r_hcount = 4 then
						r_hcount <= 0;
						r_col <= r_col + 1;
					else
						r_hcount <= r_hcount + 1;
					end if;
					old_x <= current_x;
				end if;
				
				if current_y /= old_y then
					if r_vcount = 4 then
						r_vcount <= 0;
						r_row <= r_row + 1;
					else
						r_vcount <= r_vcount + 1;
					end if;
					old_y <= current_y;
				end if;
			end if;
		end if;
	end process;
	
	o_data <= video_mem(conv_integer(i_raddr));
	
end;