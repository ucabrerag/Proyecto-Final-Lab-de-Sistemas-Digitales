library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_bit.all;

entity slave is
	port(
			 
			rw: in std_logic; 
			SCL:in std_logic;  
			enable: in std_logic;
			Slave_in: in std_logic_vector(7 downto 0)	;
			Slave_dataO: out std_logic_vector(7 downto 0); 
			Ack: out std_logic
	);
end slave;


architecture Behavioral of slave is
signal Address: std_logic_vector(6 downto 0); 
signal slave_address: std_logic_vector(6 downto 0); 
signal counter: integer range 0 to 7:= 7; 
signal counter3: unsigned (2 downto 0):= "111"; 
signal counter2: integer range -1 to 7:= 7;
signal CLK_AUX: std_logic; 
type State_type is (Idle, Start, SlaveAddress, ACK1, RegisterAddress, ACK2,
                    txData, ACK3, Stop); 
signal State, NextState: State_type; 
begin
	Process(State,SCL)
	begin 
		case state is 
		when Idle =>  
			Nextstate<= Start;
			ACK<='0';
	
		when Start =>  
			Nextstate<= SlaveAddress;
			ACK<='0';
		
		when SlaveAddress => 
			ACK<='0';
			if counter > 0 then  
				 
				nextstate<= SlaveAddress; 
				counter<= counter -1; 
			elsif Counter = 0 then  
				nextstate<= ACK1; 
				counter<= 7; 
			end if; 
		
		when ACK1 => 
		if address = slave_address then
			ACK<='1';
			Nextstate<= RegisterAddress; 
		else 
			ACK<='0'; 
			Nextstate<= slaveaddress; 
		end if; 
		
		when RegisterAddress =>  
			ACK<='0';
			if counter3 > "000" then  
				nextstate<= RegisterAddress; 
				counter3<= counter3-1; 
			elsif Counter3 = "000" then  
				nextstate<= ACK2; 
				counter3<= "111"; 
			end if; 
		
		when ACK2 =>
		
			ACK<='1';
			nextstate<= txData; 
		
		when txData => 
		
			ACK<='0';
			if RW = '0' then 
				if counter2 > 0 then  
					nextstate<= txData; 
				elsif Counter2 = 0 then  
					nextstate<= ACK3; 
					counter2<= 7; 
				end if;
			else 
				if counter2 >= 0 then 
	 
					nextstate<= txData;  
					counter2<= counter2-1;
					if Counter2 <= 0 then 
						Slave_dataO<= Slave_In; 
						nextstate<= ACK3; 
						counter2<= 7; 
					end if; 
				
				end if;
		  end if; 
			
		when ACK3 => 
			ACK<='1'; 
			nextstate<=STOP; 
			
		when STOP => 
			ACK<='0';
			if enable = '1' then 
				nextstate<= IDLE; 
			else 
				NextState<= STOP; 
			end if; 
		end case; 
	end process; 
	
	process (SCL)
	begin 
		if SCL'event and SCL='1' then 
			state<= nextstate; 
		end if; 
	end process; 
end Behavioral;
  
