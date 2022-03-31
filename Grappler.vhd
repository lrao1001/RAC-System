LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY grappler IS
PORT
	(	clk			: IN std_logic := '0';
		RESET			: IN std_logic := '0';
		grappler_in	: IN std_logic;
		grappler_en	: IN std_logic;
		grappler_on : OUT std_logic

	);
END ENTITY grappler;
	
ARCHITECTURE grappler_SM OF grappler IS
	
TYPE STATE_NAMES IS (D,C,O);  -- Disabled state, Closed Grappler State, Open Grappler State respectively.
SIGNAL current_state, next_state : STATE_NAMES; 

BEGIN


--Register Logic
Register_Section: PROCESS (clk, RESET, next_state) 
	BEGIN
	IF (reset = '1') THEN 
		current_state <= D; --this sets Disabled as our reset state.
	ELSIF(rising_edge(clk)) THEN
		current_state <= next_state; --if not async reset, proceed to next state.
	END IF;
END PROCESS;


--STATE TRANSITION LOGIC PROCESS
Transition_Section: PROCESS (grappler_en, grappler_in,current_state)
	BEGIN
	CASE current_state IS
		WHEN D =>
		IF(grappler_en = '1') THEN --enabling grappler means it starts off as closed.
			next_state <= C;
		ELSE
			next_state <= D;
		END IF;
		
		WHEN C =>
		IF (grappler_en = '0') THEN --turning off grapple enabler means it should be disabled.
			next_state <= D;
		ELSIF (grappler_in = '1') THEN
			next_state <= O;  --otherwise, actually follow the button push and open the grappler.
		ELSE
			next_state <= C;  --if the button isn't pushed, just idle.
		END IF;
		
		WHEN O =>
		IF (grappler_en = '0') THEN --immediately jump to disabled state 
			next_state <= D; 
		ELSIF (grappler_in = '0') THEN  --once the press is completed, close the grappler again.
			next_state <= C;
		ELSE
			next_state <= O; --otherwise, keep the grappler open.
		END IF;

	END CASE;
END PROCESS;


--State Machine Actions 	
Mealy_SM: PROCESS (current_state)
BEGIN
	
	IF (current_state = D) THEN  --grappler is never open when disabled.
		grappler_on <= '0';
		
	ELSIF (current_state = C) THEN --this state exists specifically for the grappler to be closed, but enabled.
		grappler_on <= '0';
		
	ELSIF (current_state = O) THEN --this state exists specifically for the grappler to be open.
		grappler_on <= '1';
		
	END IF;
		
END PROCESS;
	
END;
	
	
	
	
	
	
	
	
