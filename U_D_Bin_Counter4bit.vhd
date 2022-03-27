library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


ENTITY U_D_Bin_Counter4bit IS
PORT
(
	CLK				: IN std_logic := '0';
	RESET				: IN std_logic := '0';
	CLK_EN			: IN std_logic := '0';
	UP1_DOWN0		: IN std_logic := '0';
	COUNTER_BITS	: OUT std_logic_vector(3 downto 0)
);

END ENTITY;

ARCHITECTURE logic_4bit_counter OF U_D_Bin_Counter4bit IS

signal ud_bin_counter	: UNSIGNED (3 downto 0);

BEGIN

-- process (CLK, CLK_EN, RESET_n, UP1_DOWN0) IS
PROCESS (CLK, RESET) IS
BEGIN
	if (RESET = '1') THEN
		ud_bin_counter <= "0000";
	elsif (rising_edge(CLK)) THEN
	
		if ((UP1_DOWN0 = '1') AND (CLK_EN = '1')) THEN
			ud_bin_counter <= (ud_bin_counter + 1);
		
		elsif ((UP1_DOWN0 = '0') AND (CLK_EN = '1')) THEN
			ud_bin_counter <= (ud_bin_counter - 1);
		
		end if;
	
	end if;
	
	COUNTER_BITS <= std_logic_vector(ud_bin_counter);

END PROCESS;

END;