LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY XY_motion_final IS
PORT MAP
(
	clk_in : IN std_logic;
	reset	 : IN std_logic;
	X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out	: IN std_logic;
	clk_en_X, clk_en_Y, up_down_X, up_down_Y, err, Capture_XY, extender_en	: OUT std_logic
);
END ENTITY XY_motion_final;

ARCHITECTURE xymotion_logic OF XY_motion_final IS

BEGIN

clk_en_X, clk_en_Y : OUT std_logic := '0';


-- Capturing Target XY
Capture_XY <= NOT(motion) AND NOT(extender_out);

-- Extender Enable
extender_en <= X_EQ AND Y_EQ;

-- X Counter
clk_en_X <= (X_GT OR X_LT) AND NOT(extender_out);
up_down_X <= clk_en_X AND X_LT;

-- Y Counter
clk_en_Y <= (Y_GT OR Y_LT) AND NOT(extender_out);
up_down_Y <= clk_en_Y AND Y_LT;

-- Error
err <= NOT(motion) AND extender_out;

END xymotion_logic;




