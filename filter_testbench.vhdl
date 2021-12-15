LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.numeric_std_unsigned.ALL;

LIBRARY work;
USE work.filter_type.ALL;

ENTITY filter_testbench IS
END ENTITY filter_testbench;

ARCHITECTURE RTL OF filter_testbench IS

	COMPONENT filter IS
		PORT (
			clk : IN STD_LOGIC;
			input : IN input_array;
			output : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT filter;

	-- inputs
	SIGNAL t_clk : STD_LOGIC := '0';
	SIGNAL t_input : input_array := (d"255", d"255", x"00", x"00", x"00", x"00");
	-- output
	SIGNAL t_output : STD_LOGIC_VECTOR(7 DOWNTO 0);
	TYPE test_vector IS RECORD
		input : input_array;
		output : STD_LOGIC_VECTOR(7 DOWNTO 0);
	END RECORD;

	TYPE test_vector_array IS ARRAY (NATURAL RANGE 0 TO 16) OF test_vector;
	CONSTANT test_vectors : test_vector_array := (
		-- a, b, sum , carry   -- positional method is used below
		(
		input => (x"ff", x"ff", x"00", x"00", x"00", x"00"),
		output => d"213"
		),
		(
		input => (x"13", x"4d", x"b0", x"44", x"38", x"0f"),
		output => x"72"
		),
		(
		input => (x"f1", x"13", x"0e", x"7f", x"0c", x"c1"),
		output => x"9c"
		),
		(
		input => (x"b9", x"43", x"2c", x"45", x"56", x"21"),
		output => x"9a"
		),
		(
		input => (x"4c", x"95", x"bb", x"75", x"d7", x"24"),
		output => x"70"
		),
		(
		input => (x"30", x"3e", x"3c", x"4e", x"02", x"7f"),
		output => x"7f"
		),
		(
		input => (x"6a", x"4d", x"98", x"95", x"3e", x"db"),
		output => x"6f"
		),
		(
		input => (x"ed", x"ea", x"15", x"5f", x"db", x"49"),
		output => x"aa"
		),
		(
		input => (x"3e", x"0a", x"fd", x"18", x"cf", x"be"),
		output => x"23"
		),
		(
		input => (x"02", x"be", x"eb", x"fd", x"82", x"bf"),
		output => x"6d"
		),
		(
		input => (x"ea", x"3f", x"fe", x"4c", x"06", x"f4"),
		output => x"6a"
		),
		(
		input => (x"c0", x"8a", x"2b", x"0d", x"77", x"c1"),
		output => x"7e"
		),
		(
		input => (x"79", x"28", x"73", x"31", x"d2", x"ae"),
		output => x"4f"
		),
		(
		input => (x"06", x"30", x"41", x"d5", x"81", x"58"),
		output => x"7d"
		),
		(
		input => (x"bd", x"a6", x"1e", x"68", x"92", x"69"),
		output => x"9d"
		),
		(
		input => (x"24", x"5a", x"31", x"25", x"d5", x"9f"),
		output => x"55"
		),
		(
		input => (x"c4", x"c6", x"50", x"5b", x"1f", x"d8"),
		output => x"9a"
		)
	);

BEGIN
	DUT : filter
	PORT MAP(
		clk => t_clk,
		input => t_input,
		output => t_output
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