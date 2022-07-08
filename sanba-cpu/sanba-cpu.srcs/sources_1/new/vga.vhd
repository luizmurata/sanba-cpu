library ieee;
use ieee.std_logic_1164.all;

entity VGA is
	generic (
		SCR_WIDTH     : natural := 640;
		SCR_HEIGHT    : natural := 480;
		H_FRONT_PORCH : natural := 16;
		H_SYNC_PULSE  : natural := 96;
		H_BACK_PORCH  : natural := 48;
		V_FRONT_PORCH : natural := 10;
		V_SYNC_PULSE  : natural := 2;
		V_BACK_PORCH  : natural := 33
	);
	port (
		-- clock (expected 100MHz)
		i_clk       : in std_logic;
		
		-- control signals
		o_draw_en   : out std_logic;                       -- enabled if in visible area
		o_x         : out natural range 0 to SCR_WIDTH-1;  -- current x coordinate
		o_y         : out natural range 0 to SCR_HEIGHT-1; -- current y coordinate
		i_r         : in std_logic_vector(3 downto 0);     -- red enable
		i_g         : in std_logic_vector(3 downto 0);     -- green enable
		i_b         : in std_logic_vector(3 downto 0);     -- blue enable
		
		-- VGA connector
		o_vga_r     : out std_logic_vector(3 downto 0);
		o_vga_g     : out std_logic_vector(3 downto 0);
		o_vga_b     : out std_logic_vector(3 downto 0);
		o_vga_hsync : out std_logic;
		o_vga_vsync : out std_logic
	);
end entity;

architecture rtl of VGA is
	constant H_SIZE       : natural := H_FRONT_PORCH+SCR_WIDTH+H_BACK_PORCH+H_SYNC_PULSE;
	constant H_SYNC_START : natural := H_FRONT_PORCH+SCR_WIDTH+H_BACK_PORCH;
	constant H_SYNC_END   : natural := H_FRONT_PORCH+SCR_WIDTH+H_BACK_PORCH+H_SYNC_PULSE-1;
	constant H_DRAW_START : natural := H_FRONT_PORCH;
	constant H_DRAW_END   : natural := H_FRONT_PORCH+SCR_WIDTH-1;
	constant V_SIZE       : natural := V_FRONT_PORCH+SCR_HEIGHT+V_BACK_PORCH+V_SYNC_PULSE;
	constant V_SYNC_START : natural := V_FRONT_PORCH+SCR_HEIGHT+V_BACK_PORCH-1;
	constant V_SYNC_END   : natural := V_FRONT_PORCH+SCR_HEIGHT+V_BACK_PORCH+V_SYNC_PULSE-1;
	constant V_DRAW_START : natural := V_FRONT_PORCH;
	constant V_DRAW_END   : natural := V_FRONT_PORCH+SCR_HEIGHT-1;
	signal r_half_clk     : std_logic := '0';
	signal r_vga_clk      : std_logic := '0';
	signal r_hcount       : natural range 0 to (H_SIZE-1) := 0;
	signal r_vcount       : natural range 0 to (V_SIZE-1) := 0;
begin
	-- generates a 50MHz clock
	clock_div50 : process (i_clk) is
	begin
		if rising_edge(i_clk) then
			r_half_clk <= not r_half_clk;
		end if;
	end process;
	
	-- generates a 25MHz clock
	clock_div25 : process (r_half_clk) is
	begin
	   if rising_edge(r_half_clk) then
	       r_vga_clk <= not r_vga_clk;
	   end if;
	end process;
	
	-- moves the cursor from top-left to down-right
	move_cursor : process (r_vga_clk) is
	begin
		if rising_edge(r_vga_clk) then
			-- reset to 0 if necessary
			if r_hcount = (H_SIZE-1) then
				if r_vcount = (V_SIZE-1) then
					r_vcount <= 0;
				else
					r_vcount <= r_vcount + 1;
				end if;
				r_hcount <= 0;
			else
				r_hcount <= r_hcount + 1;
			end if;
		end if;
	end process;
	
	-- sends hsync/vsync
	sync : process (r_vga_clk) is
	begin
		if rising_edge(r_vga_clk) then
			if (r_hcount >= H_SYNC_START) and (r_hcount <= H_SYNC_END) then
				o_vga_hsync <= '0';
			else
				o_vga_hsync <= '1';
			end if;
			if (r_vcount >= V_SYNC_START) and (r_vcount <= V_SYNC_END) then
				o_vga_vsync <= '0';
			else
				o_vga_vsync <= '1';
			end if;
		end if;
	end process;
	
	-- draws pixels
	draw : process (r_vga_clk) is
	begin
		if rising_edge(r_vga_clk) then
			if (r_hcount >= H_DRAW_START) and (r_hcount <= H_DRAW_END) 
				and (r_vcount >= V_DRAW_START) and (r_vcount <= V_DRAW_END) then
				o_draw_en <= '1';
				o_x <= r_hcount-H_DRAW_START;
				o_y <= r_vcount-V_DRAW_START;
				o_vga_r <= i_r;
				o_vga_g <= i_g;
				o_vga_b <= i_b;
			else
				o_draw_en <= '0';
				o_x <= 0;
				o_y <= 0;
				o_vga_r <= x"0";
				o_vga_g <= x"0";
				o_vga_b <= x"0";
			end if;
		end if;
	end process;
	
end;