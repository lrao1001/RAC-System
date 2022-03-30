LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY register_normal IS
PORT
	(
		clk 			: IN std_logic := '0';
		capture 		: IN std_logic := '0';
		RESET			: IN std_logic := '0';
		input_data 	: IN std_logic_vector(3 downto 0);
		reg_bits 	: OUT std_logic_vector(3 downto 0);
		sim_output 	: OUT std_logic_vector(3 downto 0)
	);
END ENTITY register_normal;

ARCHITECTURE register_architecture OF register_normal IS

signal reg_container : std_logic_vector(3 downto 0);

BEGIN

process (clk, reset, capture) is
begin
	
	if (reset = '1') then
		reg_container <= "0000";
		
	elsif (rising_edge(clk) AND capture = '1') then
		reg_container <= input_data;

	end if;

	reg_bits <= reg_container;
	sim_output <= reg_container;

END PROCESS;

END register_architecture;
