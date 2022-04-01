LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY XY_Motion_SM IS
PORT
	(
		clk_in : IN std_logic;
		reset	 : IN std_logic := '0';
		X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out	: IN std_logic;
		clk_en_X, clk_en_Y, up_down_X, up_down_Y, err, Capture_XY, extender_en	: OUT std_logic
	);

	END ENTITY XY_Motion_SM;

ARCHITECTURE logic OF XY_Motion_SM IS

TYPE STATE_NAMES IS (START, MOVING, END_POS, ERROR_STATE);

signal current_state, next_state : STATE_NAMES;


BEGIN

-- Register Process
Register_Section : PROCESS (clk_in, reset, next_state)

BEGIN

	if (reset = '0') then
		current_state <= START;
		
	elsif (rising_edge(clk_in)) then
		current_state <= next_state;
		
	end if;

END PROCESS;


-- Transition Process
Transition_Section : PROCESS (X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out) IS

BEGIN

	CASE current_state IS
	
		when START =>
		
			if (motion = '0' AND (X_EQ = '0' OR Y_EQ= '0')  ) then
				next_state <= MOVING;
			
			elsif (motion = '0' AND X_EQ = '1' AND Y_EQ = '1') then
				next_state <= END_POS;
			
			else
				next_state <= START;
			
			end if;
		
		when MOVING =>
		
			if (extender_out = '1') then
				next_state <= ERROR_STATE;
				
			elsif (X_EQ = '0' AND Y_EQ = '0') then
				next_state <= MOVING;
				
			elsif (X_EQ = '1' AND Y_EQ = '1') then
				next_state <= END_POS;
			
			end if;
		
		when END_POS =>
			
			if (X_EQ = '1' AND Y_EQ = '1') then
				next_state <= END_POS;
			
			else
				next_state <= MOVING;
			
			end if;
		
		when ERROR_STATE =>
			
			if (extender_out = '1') then
				next_state <= ERROR_STATE;
			
			else
				next_state <= START;
			
			end if;
	
	END CASE;

END PROCESS;


-- Decoder Process
PROCESS (X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out) IS

BEGIN

	CASE current_state IS
		
		when START =>
			-- extender cannot be used until @ END_POS
			extender_en <= '0';
			
			-- if motion is
			if (motion = '0') then
				Capture_XY <= '1';
			end if;
		
		when MOVING =>
			
			-- extender cannot be used until @ END_POS
			--extender_en <= '0';
			-- can't capture TargetXY if in moving state
			--Capture_XY <= '0';
			
			-- X motion
			--clk_en_X <= '1';
			
			if (X_EQ = '1') then
				clk_en_X <= '0';
				extender_en <= '0';
				Capture_XY <= '0';
				up_down_X <= '0';
			elsif (X_GT = '1') then
				up_down_X <= '1';
				extender_en <= '0';
				Capture_XY <= '0';
				clk_en_X <= '1';
			elsif (X_LT = '1') then
				up_down_X <= '0';
				extender_en <= '0';
				Capture_XY <= '0';
				clk_en_X <= '1';
			end if;
			
			
			-- Y motion
			--clk_en_Y <= '1';
			
			if (Y_EQ = '1') then
				clk_en_Y <= '0';
				clk_en_Y <= '1';
			
			elsif (Y_GT = '1') then
				up_down_Y <= '1';
				clk_en_Y <= '1';
			
			elsif (Y_LT = '1') then
				up_down_Y <= '0';
				clk_en_Y <= '1';
			
			end if;
		
		when END_POS =>
			--extender_en = '1';
			
			-- capture XY values even if @ END_POS
			if (motion = '0') then
				Capture_XY <= '1';
				extender_en <= '1';
				end if;
		
		when ERROR_STATE =>
			err <= '1';
		
	END CASE;

END PROCESS;

END;
			
			
			
			
