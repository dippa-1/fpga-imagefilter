LIBRARY library IEEE;
USE IEEE.std_logic_1164.ALL;

PACKAGE buffer_types IS
    TYPE line_t IS ARRAY(0 TO 239) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    type image_part_t is array(0 to 5) of STD_LOGIC_VECTOR(7 downto 0);
END PACKAGE buffer_types;

LIBRARY library IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.buffer_types.ALL;

ENTITY Linebuffer IS
    PORT (
        input_line : IN line_t;
        line_ready : IN STD_LOGIC;
        image_part : OUT image_part_t;
        filter_clock : OUT STD_LOGIC;
        need_line : OUT STD_LOGIC -- 1: i need a new line, 0: done or i dont need a new line
    );
END ENTITY Linebuffer;

ARCHITECTURE RTL OF Linebuffer
    SIGNAL next_line_num : STD_LOGIC_VECTOR(1 DOWNTO 0) = "00";
    SIGNAL lines : ARRAY(0 TO 3) OF line_t;
    SIGNAL initialized : STD_LOGIC = '0';

    initialize: process
    begin
        if not initialized then
            need_line <= '1', '0' after 10 ns;
            initialized <= '1';
        end if;
    end process initialize;

    -- load_line : PROCESS (next_line)
    -- begin
    -- END process load_line;

END RTL;