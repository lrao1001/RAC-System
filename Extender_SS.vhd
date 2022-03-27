LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


ENTITY Extender_SS IS
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
		grappler_en		: OUT std_logic := '0'
	);
END ENTITY Extender_SS;


Architecture SM of Extender_SS IS

TYPE STATE_NAMES IS (S0, S1, S2, S3, S4);
SIGNAL current_state, next_state : STATE_NAMES;
SIGNAL backwards : std_logic := '0';

BEGIN

Register_Section : PROCESS (clk, reset, next_state)
BEGIN

	if (reset = '1') then
		current_state <= S0;
		
	elsif (rising_edge(clk)) then
		current_state <= next_state;
		
	end if;
	
END PROCESS;


Transition_Section : PROCESS (extender_in, extender_en, state_input)
BEGIN
	
	CASE current_state IS
		
		when S0 =>
			
			backwards <= '0';
			if (extender_in = '0' AND extender_en = '1') then
				next_state <= S1;
			else
				next_state <= S0;
			end if;
			
		when S1 =>
			if (backwards = '1') then
				next_state <= S0;
			else
				next_state <= S1;
			end if;
		
		when S2 =>
			if (backwards = '1') then
				next_state <= S1;
			else
				next_state <= S3;
			end if;
		
		when S3 =>
			if (backwards = '1') then
				next_state <= S2;
			else
				next_state <= S4;
			end if;
		
		when S4 =>
			if (extender_in = '0' AND extender_en = '1') then
				backwards <= '1';
				next_state <= S3;
			else
				next_state <= S4;
			end if;
		
		when others =>
			next_state <= S0;
			
	END CASE;

END PROCESS;


Decoder_Section : PROCESS (current_state)

BEGIN
	if (current_state = S0) then
	
		grappler_en <= '0';
		extender_out <= '0';
		
		if (extender_in = '0' AND extender_en = '1') then
			clk_en <= '1';
			left_right <= '1';
		else
			clk_en <= '0';
		
		end if;
		
	end if;
	
	if (current_state = S1 OR current_state = S2 OR current_state = S3) then
		
		clk_en <= '1';
		extender_out <= '1';

		if (backwards = '1') then
			left_right <= '0';
		else
			left_right <= '1';
		end if;
	
	end if;
	
	if (current_state = S4) then
		
		extender_out <= '1';
		grappler_en  <= '1';
		
		if (extender_in = '0' AND extender_en = '1') then
			clk_en <= '1';
			left_right <= '0';
		else
			clk_en <= '0';
			left_right <= '0';
		end if;
	
	end if;
END PROCESS;

END SM;
			
			
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
