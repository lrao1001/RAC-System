LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY XY_motion_final IS
PORT
(
	clk_in : IN std_logic;
	reset	 : IN std_logic;
	X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out	: IN std_logic;
	up_down_X, up_down_Y, err, Capture_XY, extender_en	: OUT std_logic;
	clk_en_X, clk_en_Y	: OUT std_logic := '0'
);
END ENTITY XY_motion_final;

ARCHITECTURE xymotion_logic OF XY_motion_final IS

SIGNAL clk_X_temp, clk_Y_temp : std_logic := '0';

BEGIN

-- Capturing Target XY
Capture_XY <= NOT(motion) AND NOT(extender_out);

-- Extender Enable
extender_en <= X_EQ AND Y_EQ;

-- X Counter
clk_X_temp <= (X_GT OR X_LT) AND NOT(extender_out);
up_down_X <= clk_X_temp AND X_LT;
clk_en_X <= clk_X_temp;

-- Y Counter
clk_Y_temp <= (Y_GT OR Y_LT) AND NOT(extender_out);
up_down_Y <= clk_Y_temp AND Y_LT;
clk_en_Y <= clk_Y_temp;

-- Error
err <= NOT(motion) AND extender_out;

END xymotion_logic;
