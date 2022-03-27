-- Group Members: Avi Bhadore, Lakshya Rao
-- Group Number : 11

library ieee;
use ieee.std_logic_1164.all;


ENTITY Inverter IS 
PORT (
			in3, in2, in1, in0 : IN std_logic;
			out3, out2, out1, out0 : OUT std_logic
	); 
END Inverter;

ARCHITECTURE Inverter_logic OF Inverter IS
BEGIN
	
	out3 <= NOT in3;
	out2 <= NOT in2;
	out1 <= NOT in1;
	out0 <= NOT in0;
END Inverter_logic;
