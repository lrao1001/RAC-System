-- Group Members : Lakshya Rao, Avi Bhadore
-- Group Number  : 11

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY XY_Motion_SM IS
PORT
	(
		clk_in : IN std_logic;
		reset	 : IN std_logic := '0';
		X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out	: IN std_logic;
		clk_en_X, clk_en_Y, up_down_X, up_down_Y, err, CaptureXY, extender_en	: OUT std_logic
	);

END ENTITY XY_Motion_SM;

ARCHITECTURE logic OF XY_Motion_SM IS

-- BUTT_PRESS : motion is pressed
-- BUTT_REL   : motion is released
-- MOVING	  : counters are being incremented
TYPE STATE_NAMES IS (BUTT_PRESS, BUTT_REL, MOVING, ERROR_STATE, ERROR_FLASH);

signal current_state, next_state : STATE_NAMES;


BEGIN

-- Register Process
Register_Section : PROCESS (clk_in, reset, next_state)

BEGIN
	
	-- if reset is high, we move to BUTT_REL (the arbitrary start state)
	if (reset = '1') then
		current_state <= BUTT_REL;
		
	elsif (rising_edge(clk_in)) then
		current_state <= next_state;
		
	end if;

END PROCESS;


-- Transition Process
Transition_Section : PROCESS (current_state, X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out) IS

BEGIN

	CASE current_state IS
	
		when BUTT_PRESS =>
			
			-- if extender_out is 1 and motion is pressed, machine moves to error state
			if (motion = '0' AND extender_out = '1') then
				next_state <= ERROR_STATE;
			
			-- if extender_out is 0 and motion is pressed, machine starts moving
			elsif (motion = '0' AND extender_out = '0') then
				next_state <= MOVING;
			
			else
				next_state <= BUTT_PRESS;
			
			end if;
		
		when MOVING =>
			
			-- if machine is at TargetXY, we move to BUTT_REL
			if (X_EQ = '1' AND Y_EQ = '1') then
				next_state <= BUTT_REL;
			
			else
				next_state <= MOVING;
			
			end if;
		
		when BUTT_REL =>
			
			if (motion = '0') then
				next_state <= BUTT_PRESS;
			
			else
				next_state <= BUTT_REL;
			
			end if;
		
		-- if extender_out is low, machine should not be in ERROR_STATE anymore
		-- else, machine moves to the flashing state
		when ERROR_STATE =>
			
			if (extender_out = '0') then
				next_state <= BUTT_REL;
			
			else
				next_state <= ERROR_FLASH;
			
			end if;
		
		-- if extender_out goes low here, we move to start (BUTT_REL)
		-- else we go to ERROR_STATE and from that machine starts flashing again
		when ERROR_FLASH =>
			
			if (extender_out = '0') then
				next_state <= BUTT_REL;
			
			else
				next_state <= ERROR_STATE;
			
			end if;
	
	END CASE;

END PROCESS;


-- Decoder Process
PROCESS (X_GT, X_EQ, X_LT, motion, Y_GT, Y_EQ, Y_LT, extender_out) IS

BEGIN
		
	if (current_state = BUTT_PRESS) then
		
		-- clocks are not enabled since machine cannot move
		clk_en_X <= '0';
		clk_en_Y <= '0';
		err <= '0';
		-- extender cannot be enabled since we are pressing the button
		extender_en <= '0';
		-- machine can capture XY coords if extender_out is low
		
		CaptureXY <= NOT(extender_out);
	
	end if;
	
	if (current_state = BUTT_REL) then
		clk_en_X <= '0';
		clk_en_Y <= '0';
		err <= '0';
		-- machine can now extend the extender
		extender_en <= '1';
		CaptureXY <= NOT(extender_out);
		
	end if;
	
	if (current_state = MOVING) then
		-- individual clocks are high or low depending on their respect X/Y_EQ
		clk_en_X <= NOT(X_EQ);
		clk_en_Y <= NOT(Y_EQ);
		-- if XY_LT then up_down_XY should be high to increment the counter
		up_down_X <= X_LT;
		up_down_Y <= Y_LT;
		err <= '0';
		-- in the moving state, we cannot enable the extender
		extender_en <= '0';
		-- in the moving state, we cannot capture the TargetXY
		CaptureXY <= '0';
	
	end if;
	
	-- for ERROR_STATE and ERROR_FLASH state, err = 1 and err = 0 respectively, so when the machine switches
	-- between these two states, the err OUT std_logic goes low and high, and it alternates, allowing the LED
	-- to flash.
	if (current_state = ERROR_STATE) then
		clk_en_X <= '0';
		clk_en_Y <= '0';
		-- error goes high
		err <= '1';
		extender_en <= '1';
		CaptureXY <= '0';
	 
	 end if;
	 
	 if (current_state = ERROR_FLASH) then
		clk_en_X <= '0';
		clk_en_Y <= '0';
		-- error goes low
		err <= '0';
		extender_en <= '1';
		CaptureXY <= '0';
	 
	 end if;


END PROCESS;

END;
			
			
			
			
