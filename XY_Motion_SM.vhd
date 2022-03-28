LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
	Clk			: in	std_logic;
	pb_n			: in	std_logic_vector(3 downto 0);
 	sw   			: in  std_logic_vector(7 downto 0); 
	leds			: out std_logic_vector(7 downto 0);

------------------------------------------------------------------	
	xreg, yreg	: out std_logic_vector(3 downto 0);-- (for SIMULATION only)
	xPOS, yPOS	: out std_logic_vector(3 downto 0);-- (for SIMULATION only)
------------------------------------------------------------------	
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment display (for LogicalStep only)
	seg7_char1  : out	std_logic;				    		-- seg7 digit1 selector (for LogicalStep only)
	seg7_char2  : out	std_logic				    		-- seg7 digit2 selector (for LogicalStep only)
	
	);
END LogicalStep_Lab4_top;

ARCHITECTURE Circuit OF LogicalStep_Lab4_top IS

-- Provided Project Components Used
------------------------------------------------------------------- 
COMPONENT Clock_Source 	port (SIM_FLAG: in boolean;clk_input: in std_logic;clock_out: out std_logic);
END COMPONENT;

component SevenSegment
  port 
   (
      hex	   :  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
      sevenseg :  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
   ); 
end component SevenSegment;
--
component segment7_mux 
  port 
   (
		  clk       	: in  std_logic := '0';
		  DIN2 			: in  std_logic_vector(6 downto 0);	
		  DIN1 			: in  std_logic_vector(6 downto 0);
		  DOUT			: out	std_logic_vector(6 downto 0);
		  DIG2			: out	std_logic;
		  DIG1			: out	std_logic
   );
end component segment7_mux;


-- __________________________________ ADDITIONAL COMPONENTS __________________________________

-- Component 1
-- Inverter Block
COMPONENT Inverter
PORT
	(
		in3, in2, in1, in0 : IN std_logic;
		out3, out2, out1, out0 : OUT std_logic
	);
END COMPONENT Inverter;


-- Component 2
-- Grappler
COMPONENT Grappler
PORT 
	(
		clk			 : IN std_logic;
		reset 		 : IN std_logic;
		grappler_in	 : IN std_logic;
		grappler_en	 : IN std_logic;
		grappler_on  : OUT std_logic
	);
END COMPONENT Grappler;


-- Component 3
-- Extender
COMPONENT Extender_SS
PORT
	(
		clk				: IN std_logic;
		reset				: IN std_logic;
		extender_in		: IN std_logic;
		extender_en		: IN std_logic;
		state_input		: IN std_logic_vector(3 downto 0);
		
		extender_out	: OUT std_logic := '0';
		clk_en 			: OUT std_logic;
		left_right		: OUT std_logic;
		grappler_en		: OUT std_logic
	);
END COMPONENT Extender_SS;


-- Component 4
-- Biderectional Shift Register
component Bidir_shift_reg 
port
	(
		CLK				: in std_logic := '0';
		RESET				: in std_logic := '0';
		CLK_EN 			: in std_logic := '0';
		LEFT0_RIGHT1 	: in std_logic := '0';
		REG_BITS 		: out std_logic_vector(3 downto 0)
	);
end component Bidir_shift_reg;


-- Component 5
-- XY Motion
COMPONENT XY_Motion_SM
PORT
	(
		clk_in, reset, X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out							: IN std_logic;
		clk_en_X, clk_en_Y, up_down_X, up_down_Y, err, Capture_XY, extender_en	: OUT std_logic := '0'
	);
END COMPONENT XY_Motion_SM;


-- Component 6
-- Up Down 4 Bit Binary Counter
COMPONENT U_D_Bin_Counter4bit
PORT
	(
		CLK				: IN std_logic := '0';
		RESET				: IN std_logic := '0';
		CLK_EN			: IN std_logic := '0';
		UP1_DOWN0		: IN std_logic := '0';
		COUNTER_BITS	: OUT std_logic_vector(3 downto 0)
	);
END COMPONENT U_D_Bin_Counter4bit;


-- Component 7
-- Normal register
COMPONENT register_normal
PORT
	(
		clk 			: IN std_logic := '0';
		capture 		: IN std_logic := '0';
		RESET			: IN std_logic := '0';
		input_data 	: IN std_logic_vector(3 downto 0);
		reg_bits 	: OUT std_logic_vector(3 downto 0)
	);
END COMPONENT register_normal;


-- Component 8
-- 1 Bit Comparator
COMPONENT compx1
PORT
	(
		in0, in1 	: IN std_logic;
		gt, eq, lt  : OUT std_logic
	);
END COMPONENT compx1;


-- Component 9
-- 4 Bit Comparator
COMPONENT compx4
PORT
	(
		input0, input1 		: IN std_logic_vector(3 downto 0);
		AGTB, AEQB, ALTB		: OUT std_logic
	);
END COMPONENT compx4;
-- ________________________________________________________________________________________


------------------------------------------------------------------
-- provided signals
-------------------------------------------------------------------
------------------------------------------------------------------	
constant SIM_FLAG : boolean := TRUE; -- set to FALSE when compiling for FPGA download to LogicalStep board
------------------------------------------------------------------	
------------------------------------------------------------------	

-- ______________________________________ INTERNAL SIGNALS _______________________________________________
signal clk_in, clock	: std_logic;

-- Outputs: Inverter
signal RESET 				: std_logic;
signal motion 				: std_logic;
signal extender_INPUT	: std_logic;
signal grappler_INPUT	: std_logic;


-- Inputs: Grappler
signal grappler_en : std_logic;
-- Outputs: Grappler
signal grappler_on : std_logic;


-- Inputs: Extender
signal extender_en 	: std_logic;
signal ext_pos 		: std_logic_vector(3 downto 0);
-- Outputs: Extender
signal clk_en_reg4 	: std_logic;
signal left_right 	: std_logic;
signal extender_out 	: std_logic;


-- Inputs: Reg4
-- Taken care of above
-- Inputs: Reg4
-- Taken care of above


-- Inputs: XY Motion
signal X_GT : std_logic;
signal X_EQ : std_logic;
signal X_LT : std_logic;
signal Y_GT : std_logic;
signal Y_EQ : std_logic;
signal Y_LT : std_logic;
-- Outputs: XY Motion
signal Capture_XY : std_logic;
signal error 		: std_logic;


-- Inputs: X Register

signal X_target : std_logic_vector(3 downto 0);
-- Outputs: X Register
signal X_reg	 : std_logic_vector(3 downto 0);


-- Inputs: Y Register

signal Y_target : std_logic_vector(3 downto 0);
-- Outputs: Y Register
signal Y_reg	 : std_logic_vector(3 downto 0);


-- Inputs: X Counter
signal clk_en_X 	: std_logic;
signal up_down_X 	: std_logic;
-- Outputs: X Counter
signal X_pos		: std_logic_vector(3 downto 0);

-- Inputs: Y Counter
signal clk_en_Y 	: std_logic;
signal up_down_Y 	: std_logic;
signal Y_pos		: std_logic_vector(3 downto 0);


-- SevenSegDecoders
-- X
signal X_sevenseg_out : std_logic_vector(6 downto 0);
-- Y
signal Y_sevenseg_out : std_logic_vector(6 downto 0);
-- _______________________________________________________________________________________________________


BEGIN
clk_in <= clk;
X_target <= sw(7 downto 4);
Y_target <= sw(3 downto 0);


-- ___________________________________________INSTANTATIONS_______________________________________________

Clock_Selector		: Clock_source 		 PORT MAP (SIM_FLAG, clk_in, clock);

-- Inverter
Inverter1			: Inverter				 PORT MAP (pb_n(3), pb_n(2), pb_n(1), pb_n(0), RESET, motion, extender_INPUT, grappler_INPUT);

-- Extender
Extender1			: Extender_SS			 PORT MAP (clk_in, RESET, extender_INPUT, extender_en, ext_pos, extender_out, clk_en_reg4, left_right, grappler_en);

-- Reg4
Reg4					: Bidir_shift_reg		 PORT MAP (clk_in, RESET, clk_en_reg4, left_right, ext_pos);

-- XY Motion
XY_Motion1			: XY_Motion_SM			 PORT MAP (clk_in, RESET, X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out,
											 clk_en_X, clk_en_Y, up_down_X, up_down_Y, error, Capture_XY, extender_en);
											 
-- Grappler
Grappler1			: Grappler				 PORT MAP (clk_in, RESET, grappler_INPUT, grappler_en, grappler_on);

-- X Counter
X_counter			: U_D_Bin_Counter4bit PORT MAP (clk_in, RESET, clk_en_X, up_down_X, X_pos);
-- X Register (Target X)
X_register			: register_normal 	 PORT MAP (clk_in, Capture_XY, RESET, X_target, X_reg);

-- Y Counter
Y_Counter			: U_D_Bin_Counter4bit PORT MAP (clk_in, RESET, clk_en_Y, up_down_Y, Y_pos);
-- Y Register (Target Y)
Y_register			: register_normal 	 PORT MAP (clk_in, Capture_XY, RESET, Y_target, Y_reg);

-- X 4-Bit Comparator
X_4bitComparator	: compx4 				 PORT MAP (X_pos, X_reg, X_GT, X_EQ, X_LT);

-- Y 4-Bit Comparator
Y_4bitComparator	: compx4 				 PORT MAP (Y_pos, Y_reg, Y_GT, Y_EQ, Y_LT);

-- X SevenSegment
X_SevenSegment		: SevenSegment 		 PORT MAP (X_pos, X_sevenseg_out);

-- Y SevenSegment
Y_SevenSegment		: SevenSegment 		 PORT MAP (Y_pos, Y_sevenseg_out);

-- Seven Segment Multiplexer
SevenSegMux			: segment7_mux 		 PORT MAP (clk_in, X_sevenseg_out, Y_sevenseg_out, seg7_data, seg7_char1, seg7_char2);
-- _______________________________________________________________________________________________________


-- Permanent outputs
leds(5 downto 2) <= ext_pos;
leds(0) <= error;
leds(1) <= grappler_on;





END Circuit;






