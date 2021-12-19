LIBRARY library IEEE;
USE IEEE.std_logic_1164.ALL;

PACKAGE buffer_types IS
    TYPE line IS ARRAY(0 TO 239) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE three_lines IS ARRAY(0 TO 2) OF line;
END PACKAGE buffer_types;

LIBRARY library IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

use work.buffer_types.all;

ENTITY Linebuffer IS
    PORT (
        --line_select : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        input_line : IN line;
        output_lines : OUT three_lines;
        filter_clock : IN std_logic
        uart_line_needed : OUT std_logic; -- 1: i need a new line, 0: done or i dont need a new line
    );
END ENTITY Linebuffer;

ARCHITECTURE RTL OF Linebuffer
    SIGNAL next_line_num : STD_LOGIC_VECTOR(1 DOWNTO 0) = "11";
    SIGNAL lines : lines_t;

    load_line : PROCESS (next_line)
    END load_line;

END RTL;