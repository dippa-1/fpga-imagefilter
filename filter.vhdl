LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE filter_type IS
	-- array only has 6 elements because the main diagonal isn't needed
	TYPE input_array IS ARRAY(0 TO 5) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
END PACKAGE filter_type;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std_unsigned.ALL;

USE work.filter_type.ALL;

ENTITY filter IS
	-- type filter_type is array(0 to 7) of std_logic_vector(7 downto 0);
	PORT (
		clk : IN STD_LOGIC;
		input : IN input_array;
		output : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY filter;

ARCHITECTURE RTL OF filter IS

	-- signal s_output_horizontal : std_logic_vector(7 downto 0);
	-- signal s_output_vertical : std_logic_vector(7 downto 0);
	-- signal s_output : std_logic_vector(7 downto 0);

	SIGNAL s_in0_extended : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL s_in1_extended : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL s_in2_extended : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL s_in3_extended : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL s_in4_extended : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL s_in5_extended : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL s_sum_pos : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL s_sum_neg : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL s_output : STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN
	extend_input : PROCESS (clk)
	BEGIN
		IF rising_edge(clk) THEN
			s_in0_extended(9 DOWNTO 8) <= "00";
			s_in0_extended(7 DOWNTO 0) <= input(0);
			s_in1_extended(9 DOWNTO 8) <= "00";
			s_in1_extended(7 DOWNTO 0) <= input(1);
			s_in2_extended(9 DOWNTO 8) <= "00";
			s_in2_extended(7 DOWNTO 0) <= input(2);
			s_in3_extended(9 DOWNTO 8) <= "00";
			s_in3_extended(7 DOWNTO 0) <= input(3);
			s_in4_extended(9 DOWNTO 8) <= "00";
			s_in4_extended(7 DOWNTO 0) <= input(4);
			s_in5_extended(9 DOWNTO 8) <= "00";
			s_in5_extended(7 DOWNTO 0) <= input(5);

		END IF;
	END PROCESS extend_input;

	-- seperate_calculation: process(clk)
	-- begin
	-- 	if rising_edge(clk) then
	-- s_output_horizontal <= std_logic_vector(unsigned(input(5)) - unsigned(input(0)) - unsigned(input(1)) - unsigned(input(1)) - unsigned(input(2)) + unsigned(input(6)) + unsigned(input(6)) + unsigned(input(7)));
	-- s_output_vertical <= std_logic_vector(unsigned(input(2)) - unsigned(input(0)) - unsigned(input(3)) - unsigned(input(3)) - unsigned(input(5)) + unsigned(input(4)) + unsigned(input(4)) + unsigned(input(7)));
	-- s_output_horizontal <= std_logic_vector(input(5) - input(0) - input(1) - input(1) - input(2) + input(6) + input(6) + input(7));
	-- s_output_vertical <= std_logic_vector(input(2) - input(0) - input(3) - input(3) - input(5) + input(4) + input(4) + input(7));
	-- s_sum_pos <= std_logic_vector(("0000000000" & input(0)) + ("0000000000" & input(1)) + ("0000000000" & input(3))); 
	-- s_sum_neg <= std_logic_vector(("0000000000" & input(2)) + ("0000000000" & input(4)) + ("0000000000" & input(5)));
	-- end if;
	-- wait;
	-- end process seperate_calculation;

	PROCESS (s_in0_extended, s_in1_extended, s_in2_extended, s_in3_extended, s_in4_extended, s_in5_extended)
	BEGIN
		s_sum_pos <= STD_LOGIC_VECTOR(s_in0_extended + s_in1_extended + s_in3_extended) / 6;
		s_sum_neg <= STD_LOGIC_VECTOR(s_in2_extended + s_in4_extended + s_in5_extended) / 6;
	END PROCESS;

	PROCESS (s_sum_pos, s_sum_neg)
	BEGIN
		s_output <= STD_LOGIC_VECTOR((s_sum_pos + d"128") - s_sum_neg);
	END PROCESS;

	-- combine_calculation: process(s_output_horizontal, s_output_vertical)
	combine_calculation : PROCESS (s_output)
	BEGIN
		-- output <= std_logic_vector((s_output_horizontal srl 1) + (s_output_vertical srl 1));
		-- output <= std_logic_vector(shift_right(unsigned(s_output_horizontal)) + shift_right(unsigned(s_output_vertical)));
		output <= s_output(7 DOWNTO 0);
	END PROCESS combine_calculation;

END RTL;