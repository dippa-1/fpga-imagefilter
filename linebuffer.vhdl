LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

PACKAGE buffer_types IS
    TYPE line_t IS ARRAY(0 TO 239) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE image_part_t IS ARRAY(0 TO 5) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
END PACKAGE buffer_types;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.buffer_types.ALL;

ENTITY Linebuffer IS
    PORT (
        ext_clk : IN STD_LOGIC; -- FPGA Clock
        input_line : IN line_t;
        line_ready : IN STD_LOGIC;
        image_part : OUT image_part_t;
        filter_clock : OUT STD_LOGIC;
        need_line : OUT STD_LOGIC -- 1: i need a new line, 0: done or i dont need a new line
    );
END ENTITY Linebuffer;

ARCHITECTURE RTL OF Linebuffer IS

    TYPE four_lines_t IS ARRAY(0 TO 3, 0 TO 239) OF STD_LOGIC_VECTOR(7 downto 0);

    SIGNAL s_filter_clock : STD_LOGIC := '0';
    SIGNAL s_need_line : STD_LOGIC := '0';
    SIGNAL next_line_num : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL lines : four_lines_t;
    SIGNAL initialized : STD_LOGIC := '0';
    -- SIGNAL image_part_index : STD_LOGIC_VECTOR RANGE 1 TO 239 := 1;
    SIGNAL image_part_index : STD_LOGIC_VECTOR(7 downto 0) := "00000001";

BEGIN

    filter_clock <= s_filter_clock;
    need_line <= s_need_line;

    initial_request : PROCESS
    BEGIN
        IF NOT initialized THEN
            /* s_need_line <= '1', '0' AFTER 100 ns; */
            s_need_line <= '1';
            WAIT;
        END IF;
    END PROCESS;

    reset_need_line : PROCESS (ext_clk)
    BEGIN
        if rising_edge(ext_clk) and not rising_edge(s_need_line) and s_need_line = '1' THEN
            s_need_line <= '0';
        end if;
    END PROCESS;

    receive_line : PROCESS (line_ready)
    BEGIN
        IF rising_edge(line_ready) THEN
            for i in 0 to 239 loop
                lines(next_line_num, i) <= input_line(i);
            end loop;
            next_line_num <= next_line_num + 1;
            image_part_index <= "00000001"; -- this indicates that the image parts can be transferred
            if NOT initialized then -- request as many lines as needed
                if next_line_num = 3 then
                    initialized <= '1';
                else
                    s_need_line <= not s_need_line;
                end if;
            end if;
        END IF;
    END PROCESS;

    -- this part is the reason for the error ...
    send_image_part : PROCESS (ext_clk)
    BEGIN
        IF rising_edge(ext_clk) AND initialized AND unsigned(image_part_index) < 239 THEN
            CASE next_line_num IS
                WHEN 0 =>
                    image_part(0) <= lines(1, to_integer(unsigned(image_part_index)));
                    image_part(1) <= lines(1, to_integer(unsigned(image_part_index)) + 1);
                    image_part(2) <= lines(2, to_integer(unsigned(image_part_index)) - 1);
                    image_part(3) <= lines(2, to_integer(unsigned(image_part_index)) + 1);
                    image_part(4) <= lines(3, to_integer(unsigned(image_part_index)) - 1);
                    image_part(5) <= lines(3, to_integer(unsigned(image_part_index)));
                WHEN 1 =>
                    image_part(0) <= lines(2, to_integer(unsigned(image_part_index)));
                    image_part(1) <= lines(2, to_integer(unsigned(image_part_index)) + 1);
                    image_part(2) <= lines(3, to_integer(unsigned(image_part_index)) - 1);
                    image_part(3) <= lines(3, to_integer(unsigned(image_part_index)) + 1);
                    image_part(4) <= lines(0, to_integer(unsigned(image_part_index)) - 1);
                    image_part(5) <= lines(0, to_integer(unsigned(image_part_index)));
                WHEN 2 =>
                    image_part(0) <= lines(3, to_integer(unsigned(image_part_index)));
                    image_part(1) <= lines(3, to_integer(unsigned(image_part_index)) + 1);
                    image_part(2) <= lines(0, to_integer(unsigned(image_part_index)) - 1);
                    image_part(3) <= lines(0, to_integer(unsigned(image_part_index)) + 1);
                    image_part(4) <= lines(1, to_integer(unsigned(image_part_index)) - 1);
                    image_part(5) <= lines(1, to_integer(unsigned(image_part_index)));
                WHEN 3 =>
                    image_part(0) <= lines(0, to_integer(unsigned(image_part_index)));
                    image_part(1) <= lines(0, to_integer(unsigned(image_part_index)) + 1);
                    image_part(2) <= lines(1, to_integer(unsigned(image_part_index)) - 1);
                    image_part(3) <= lines(1, to_integer(unsigned(image_part_index)) + 1);
                    image_part(4) <= lines(2, to_integer(unsigned(image_part_index)) - 1);
                    image_part(5) <= lines(2, to_integer(unsigned(image_part_index)));
            END CASE;
            image_part_index <= std_logic_vector(unsigned(image_part_index) + "00000001");
            s_filter_clock <= '1';
        ELSIF falling_edge(ext_clk) then
            s_filter_clock <= '0';
        END IF;
    END PROCESS;

END RTL;
