LIBRARY work;
USE work.buffer_types.ALL;

ENTITY linebuffer_testbench IS
END ENTITY linebuffer_testbench;

ARCHITECTURE RTL OF linebuffer_testbench IS

	COMPONENT linebuffer IS
		PORT (
			input_line : IN line_t;
			line_ready : IN STD_LOGIC;
			image_part : OUT image_part_t;
			filter_clock : OUT STD_LOGIC;
			need_line : OUT STD_LOGIC
		);
	END COMPONENT linebuffer;

	-- inputs
	signal t_input_line : line_t;
	signal t_line_ready : std_logic;
	-- outputs
	signal t_image_part : image_part_t;
	signal t_filter_clock : std_logic := '0';
	signal t_need_line : std_logic;

	TYPE test_vector IS RECORD
		input_line : line_t;
		line_ready : std_logic;
		image_part : image_part_t;
		filter_clock : STD_LOGIC;
		need_line : std_logic;
	END RECORD;

	TYPE test_vector_array IS ARRAY (NATURAL RANGE 0 TO 0) OF test_vector;
	CONSTANT test_vectors : test_vector_array := (
		(
			-- request line high
			input_line => others <= (others <= '0'),
			line_ready => '0',
			image_part => others <= (others <= '0'),
			filter_clock => '0',
			need_line => '1'
		),
		(
			-- request line low
			input_line => others <= (others <= '0'),
			line_ready => '0',
			image_part => others <= (others <= '0'),
			filter_clock => '0',
			need_line => '0'
		),
		(
			-- after some time: line is ready
			input_line => (),
			line_ready => '1',
			image_part => others <= (others <= '0'),
			filter_clock => '0',
			need_line => '0'
		),
		(
			-- line ready low, need 2nd line
			input_line => (),
			line_ready => '0',
			image_part => others <= (others <= '0'),
			filter_clock => '0',
			need_line => '1'
		),
		(
			-- need line back to 0
			input_line => (),
			line_ready => '0',
			image_part => others <= (others <= '0'),
			filter_clock => '0',
			need_line => '0'
		),
		(
			-- after some time: 2nd line ready
			input_line => (),
			line_ready => '1',
			image_part => others <= (others <= '0'),
			filter_clock => '0',
			need_line => '0'
		),
		(
			-- line ready low, need 3rd line
			input_line => (),
			line_ready => '0',
			image_part => others <= (others <= '0'),
			filter_clock => '0',
			need_line => '1'
		),
		(
			-- need line low
			input_line => (),
			line_ready => '0',
			image_part => others <= (others <= '0'),
			filter_clock => '0',
			need_line => '0'
		),
		(
			-- after some time: 3rd line ready
			input_line => (),
			line_ready => '1',
			image_part => others <= (others <= '0'),
			filter_clock => '0',
			need_line => '0'
		),
		(
			-- need 4th line & send first image part
			input_line => (),
			line_ready => '0',
			image_part => (),
			filter_clock => '1',
			need_line => '1'
		),
		(
			-- 1st img part clk low
			input_line => (),
			line_ready => '0',
			image_part => (),
			filter_clock => '0',
			need_line => '0'
		),
		(
			-- 2 img part
			input_line => (),
			line_ready => '0',
			image_part => (),
			filter_clock => '1',
			need_line => '0'
		),
		(
			-- 2 img part clk low
			input_line => (),
			line_ready => '0',
			image_part => (),
			filter_clock => '0',
			need_line => '0'
		),
		(
			-- 3 img part
			input_line => (),
			line_ready => '0',
			image_part => (),
			filter_clock => '1',
			need_line => '0'
		),
		(
			-- 3 img part clk low
			input_line => (),
			line_ready => '0',
			image_part => (),
			filter_clock => '0',
			need_line => '0'
		),
	);

BEGIN
	DUT : linebuffer
	PORT MAP(
		input_line => t_input_line,
		line_ready => t_line_ready,
		image_part => t_image_part,
		filter_clock => t_filter_clock,
		need_line => t_need_line
	);

	test : PROCESS
	BEGIN
		FOR i IN test_vectors'RANGE LOOP
			t_input <= test_vectors(i).input;

			WAIT FOR 50 ns;
			t_clk <= '1';

			WAIT FOR 50 ns;
			t_clk <= '0';

			ASSERT(t_output = test_vectors(i).output)
			REPORT "Wrong result! " & to_string(t_output) & " should be " & to_string(test_vectors(i).output)
				& ", Diff: " & to_string(t_output - test_vectors(i).output) SEVERITY warning;

		END LOOP;
		WAIT;
	END PROCESS test;
END RTL;