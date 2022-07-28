library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity Memory is
	port (
		i_clk   : in std_logic;
		i_we    : in std_logic;
		i_raddr : in std_logic_vector(15 downto 0);
		i_waddr : in std_logic_vector(15 downto 0);
		i_data  : in std_logic_vector(7 downto 0);
		o_data  : out std_logic_vector(7 downto 0);
		
		-- VGA connector
		o_vga_r     : out std_logic_vector(3 downto 0);
		o_vga_g     : out std_logic_vector(3 downto 0);
		o_vga_b     : out std_logic_vector(3 downto 0);
		o_vga_hsync : out std_logic;
		o_vga_vsync : out std_logic
	);
end Memory;

architecture rtl of Memory is
    
	type t_mem is array (0 to (65536-1024)) of std_logic_vector(7 downto 0);
	
     impure function ReadMemFile(FileName : STRING) return t_mem is
        --file FileHandle         : TEXT open READ_MODE is FileName;
        --variable CurrentLine    : LINE;
        --variable TempWord       : std_logic_vector(7 downto 0);
        variable Result         : t_mem;
    begin
        for i in 0 to (65536-1024) loop
            --exit when endfile(FileHandle);
            --readLine(FileHandle, CurrentLine);
            --hread(CurrentLine, TempWord);
            Result(i) := x"AA";
        end loop;
       
        return Result;
    end function; 
    
    signal r_mem : t_mem := ReadMemFile("rams_init_file.data");
	
    signal r_we : std_logic;
    signal r_waddr  : std_logic_vector(9 downto 0) := "0000000000";
    signal r_raddr  : std_logic_vector(9 downto 0) := "0000000000";
    signal r_i_data : std_logic_vector(7 downto 0) := x"00";
    signal r_o_data : std_logic_vector(7 downto 0) := x"00";
begin
    
    vu : entity work.VideoUnit port map (
        i_clk => i_clk,
        i_we => r_we,
        i_data => r_i_data,
        o_data => r_o_data,
        i_waddr => r_waddr,
        i_raddr => r_raddr,
        o_vga_r => o_vga_r,
        o_vga_g => o_vga_g,
        o_vga_b => o_vga_b,
        o_vga_hsync => o_vga_hsync,
        o_vga_vsync => o_vga_vsync
    );

	process (i_clk,i_we) is
	begin
		if rising_edge(i_clk) and i_we = '1' then
            if i_waddr >= x"fc00" then
                r_we <= '1';
                r_waddr <= i_waddr(9 downto 0);
                r_i_data <= i_data;
            else
                r_we <= '0';
                r_mem(conv_integer(i_waddr)) <= i_data;
            end if;
		end if;
	end process;
	
	r_raddr <= i_raddr(9 downto 0);
	o_data <= r_mem(conv_integer(i_raddr)) when i_raddr < x"fc00" else r_o_data;

end rtl;