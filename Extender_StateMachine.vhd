-- Group Members : Lakshya Rao, Avi Bhadore
-- Group Number  : 11

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


ENTITY Extender_StateMachine IS
PORT
(	
		clk_in, reset, extender_in, extender_en			: IN std_logic;
		extender_out, grappler_en, clk_en, left_right	: OUT std_logic
); 
		
END ENTITY Extender_StateMachine;


ARCHITECTURE logic OF Extender_StateMachine IS

-- Since the functionality depends upon the pressing AND releasing of the button, we must
-- include two states for the start and the end for the button presses. Since we if just have
-- one state, just pressing the button will make the Extender move, which is against its 
-- outlined functionality.

-- For the start, we have two states: extender_in_press, extender_in_rel
                                 --     ^ this is for when extender  ^ this is for when extender is out
											--       is not out, and button is    and button is pressed
											--       pressed									 
-- For the end, we also have two states: extender_out_press, extender_out_rel

TYPE STATE_NAMES IS (EXTENDER_IN_REL, EXTENDER_IN_PRESS, S0, S1, S2, S3,
                     EXTENDER_OUT_REL, EXTEDER_OUT_PRESS);
							
SIGNAL current_state, next_state : STATE_NAMES;
SIGNAL forward : std_logic;


BEGIN

-- Register Section
Register_Section : PROCESS (clk_in, reset, next_state) IS

BEGIN

	if (reset = '1') then
		current_state <= EXTENDER_IN_REL;
	
	elsif (rising_edge(clk_in)) then
		current_state <= next_state;
	
	end if;

END PROCESS;


-- Transition Section
Transition_Section : PROCESS (current_state, extender_in, forward, extender_en) IS

BEGIN

CASE current_state IS
	
	-- STARTING STATES
	
	when EXTENDER_IN_REL =>
	
		-- if extender button is not pressed and extender_en = '1', meaning movement is allowed
		if (extender_en = '1' AND extender_in = '1') then
			next_state <= EXTENDER_IN_PRESS;
			
		else
			next_state <= EXTENDER_IN_REL;
		
		end if;
	
	when EXTENDER_IN_PRESS =>
	
		-- if extender button is pressed and extender_en = '1', meaning movement is still allowed
		if (extender_en = '1' AND extender_in = '0') then
			next_state <= S0;
		 
		else
			next_state <= EXTENDER_IN_REL;
		
		end if;
	
	-- INTERMEDIATE (MOVING) STATES
	
	when S0 =>
		
		-- checking if forward motion is allowed, if so, then we move to S1
		if (forward = '1') then
			next_state <= S1;
		
		-- else, it means we should be moving backwards and so we go to start (EXTENDER_IN_REL)
		else
			next_state <= EXTENDER_IN_REL;
		
		end if;
		
	-- The same logic as S0 applied to the next 3 intermediate (moving) states, except that if 
	-- forward = '0', we move back to the previous state
	when S1 =>
		
		if (forward = '1') then
			next_state <= S2;
		
		else
			next_state <= S0;
		
		end if;
		
	when S2 =>
	
		if (forward = '1') then
			next_state <= S3;
		
		else
			next_state <= S1;
		
		end if;
	
	-- If forward = 1, we move to the FINAL STATES
	when S3 =>
	
		if (forward = '1') then
			next_state <= EXTENDER_OUT_REL;
		
		else
			next_state <= S2;
		
		end if;
	
	-- FINAL STATES (extender is fully extended)

	when EXTENDER_OUT_REL =>
	
		if (extender_en = '1' AND extender_in = '1') then
			next_state <= EXTENDER_OUT_PRESS;
		
		else
			next_state <= EXTENDER_OUT_REL;
		
		end if;
	
	when EXTENDER_OUT_PRESS =>
		
		-- checking if the extender_in goes low, if yes, then we move backwards
		if (extender_en = '1' AND extender_in = '0') then
			next_state <= S4;
		
		-- if extender_en goes low, just move back to EXTENDER_OUT_REL, because we are not allowed to
		-- extend
		elsif (extender_en = '0' AND extender_in = '0') then
			next_state <= EXTENDER_OUT_REL;
			
		else
			next_state <= EXTENDER_OUT_PRESS;
		
		end if;

	END CASE;

END PROCESS;


-- Decoder Section
Decoder_section : PROCESS (current_state, extender_en, extender_in, forward) IS

BEGIN

CASE current_state IS

	when EXTENDER_IN_REL =>
		
		-- we can move forward
		forward <= '1';
		-- we cannot shift yet
		clk_en  <= '0';
		left_right <= forward;
		-- extender is not out yet
		extender_out <= '0';
		-- we cannot use the grappler @ the start
		grappler_en <= '0';
	
	-- same logic as EXTENDER_IN_REL
	when EXTENDER_IN_PRESS =>
	
		-- we can move forward
		forward <= '1';
		-- we cannot shift yet
		clk_en  <= '0';
		left_right <= forward;
		-- extender is not out yet
		extender_out <= '0';
		-- we cannot use the grappler @ the start
		grappler_en <= '0';
	
	when S0 =>
	
		-- we can finally start moving, so clk_en goes high
		clk_en <= '1';
		-- in the Intermediate States, if we extend or retract depends on the value of the forward
		-- latch as set previously in the START or FINAL states.
		left_right <= forward;
		extender_out <= '1'; -- as per functionality
		grappler_en  <= '0'; -- since we are !@ FINAL states
	
	-- S1, S2, S3 have the same logic as S0
	when S1 =>
		
		clk_en <= '1';
		left_right <= forward;
		extender_out <= '1';
		grappler_en  <= '0';
	
	when S2 =>
		
		clk_en <= '1';
		left_right <= forward;
		extender_out <= '1';
		grappler_en  <= '0';
	
	when S3 =>
		
		clk_en <= '1';
		left_right <= forward;
		extender_out <= '1';
		grappler_en  <= '0';
	
	when EXTENDER_OUT_REL =>
	
		-- at this point, we cannot move forward, so forward goes low
		forward <= '0';
		-- since we cannot move
		clk_en <= '0';
		left_right <= forward;
		extender_out <= '1';
		-- since we are @ FINAL states, grappler can now be used
		grappler_en <= '1';
	
	-- Same logic as EXTENDER_OUT_REL
	when EXTENDER_OUT_PRESS =>
	
		forward <= '0';
		clk_en <= '0';
		left_right <= forward;
		extender_out <= '1';
		grappler_en <= '1';
	
	END CASE;

END PROCESS;


END logic;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	