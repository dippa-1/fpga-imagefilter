LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-- USE ieee.numeric_std_unsigned.ALL;

LIBRARY work;
USE work.buffer_types.ALL;

ENTITY linebuffer_testbench IS
END ENTITY linebuffer_testbench;

ARCHITECTURE RTL OF linebuffer_testbench IS

	COMPONENT Linebuffer IS
		PORT (
			ext_clk : IN STD_LOGIC;
			input_line : IN line_t;
			line_ready : IN STD_LOGIC;
			image_part : OUT image_part_t;
			filter_clock : OUT STD_LOGIC;
			need_line : OUT STD_LOGIC
		);
	END COMPONENT Linebuffer;

	-- inputs
	SIGNAL t_ext_clk : STD_LOGIC;
	SIGNAL t_input_line : line_t;
	SIGNAL t_line_ready : STD_LOGIC;
	-- outputs
	SIGNAL t_image_part : image_part_t;
	SIGNAL t_filter_clock : STD_LOGIC := '0';
	SIGNAL t_need_line : STD_LOGIC;
	-- test vector
	TYPE test_vector IS RECORD
		input_line : line_t;
		line_ready : STD_LOGIC;
		image_part : image_part_t;
		filter_clock : STD_LOGIC;
		need_line : STD_LOGIC;
	END RECORD;

	TYPE test_vector_array IS ARRAY (NATURAL RANGE 0 TO 14) OF test_vector;
	CONSTANT test_vectors : test_vector_array := (
	(
		-- request line high
		input_line => (OTHERS => (OTHERS => '0')),
		line_ready => '0',
		image_part => (OTHERS => (OTHERS => '0')),
		filter_clock => '0',
		need_line => '1'
		),
		(
		-- request line low
		input_line => (OTHERS => (OTHERS => '0')),
		line_ready => '0',
		image_part => (OTHERS => (OTHERS => '0')),
		filter_clock => '0',
		need_line => '0'
		),
		(
		-- after some time: line is ready
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '1',
		image_part => (OTHERS => (OTHERS => '0')),
		filter_clock => '0',
		need_line => '0'
		),
		(
		-- line ready low, need 2nd line
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '0',
		image_part => (OTHERS => (OTHERS => '0')),
		filter_clock => '0',
		need_line => '1'
		),
		(
		-- need line back to 0
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '0',
		image_part => (OTHERS => (OTHERS => '0')),
		filter_clock => '0',
		need_line => '0'
		),
		(
		-- after some time: 2nd line ready
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '1',
		image_part => (OTHERS => (OTHERS => '0')),
		filter_clock => '0',
		need_line => '0'
		),
		(
		-- line ready low, need 3rd line
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '0',
		image_part => (OTHERS => (OTHERS => '0')),
		filter_clock => '0',
		need_line => '1'
		),
		(
		-- need line low
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '0',
		image_part => (OTHERS => (OTHERS => '0')),
		filter_clock => '0',
		need_line => '0'
		),
		(
		-- after some time: 3rd line ready
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '1',
		image_part => (OTHERS => (OTHERS => '0')),
		filter_clock => '0',
		need_line => '0'
		),
		(
		-- need 4th line & send first image part
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '0',
		image_part => (OTHERS => (OTHERS => '0')), -- todo: real data
		filter_clock => '1',
		need_line => '1'
		),
		(
		-- 1st img part clk low
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '0',
		image_part => (OTHERS => (OTHERS => '0')), -- todo: real data
		filter_clock => '0',
		need_line => '0'
		),
		(
		-- 2 img part
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '0',
		image_part => (OTHERS => (OTHERS => '0')), -- todo: real data
		filter_clock => '1',
		need_line => '0'
		),
		(
		-- 2 img part clk low
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '0',
		image_part => (OTHERS => (OTHERS => '0')), -- todo: real data
		filter_clock => '0',
		need_line => '0'
		),
		(
		-- 3 img part
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '0',
		image_part => (OTHERS => (OTHERS => '0')), -- todo: real data
		filter_clock => '1',
		need_line => '0'
		),
		(
		-- 3 img part clk low
		input_line => (OTHERS => (OTHERS => '0')), -- todo: real data
		line_ready => '0',
		image_part => (OTHERS => (OTHERS => '0')), -- todo: real data
		filter_clock => '0',
		need_line => '0'
		)
	);

BEGIN
	DUT : linebuffer
	PORT MAP(
		ext_clk => t_ext_clk,
		input_line => t_input_line,
		line_ready => t_line_ready,
		image_part => t_image_part,
		filter_clock => t_filter_clock,
		need_line => t_need_line
	);

	test : PROCESS
	BEGIN
		FOR i IN test_vectors'RANGE LOOP
			t_input_line <= test_vectors(i).input_line;
			t_line_ready <= test_vectors(i).line_ready;

			WAIT FOR 50 ns;
			t_ext_clk <= '1';

			WAIT FOR 50 ns;
			t_ext_clk <= '0';

			-- for p in t_image_part'RANGE LOOP
			-- 	ASSERT(t_image_part(p) = test_vectors(i).image_part(p));
			-- 	REPORT "image_part pixel is not as expected! " & to_string(t_image_part(p)) & " should be " & to_string(test_vectors(i).image_part(p)) SEVERITY error;
			-- end loop;

		END LOOP;
		WAIT;
	END PROCESS test;
END RTL;