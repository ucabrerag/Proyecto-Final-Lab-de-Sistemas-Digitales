library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_bit.all; 

entity i2C is
    Port ( CLK : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           Slave_address : in  STD_LOGIC_vector(6 downto 0);
           RW : in  std_logic; -- 1 escribir, 0 leer
           DataI : in  STD_LOGIC_vector(7 downto 0);
			  Data_SLave: in STD_LOGIC_vector(7 downto 0); 
           DataO : out  STD_LOGIC_vector(7 downto 0);
           Ack : out  STD_LOGIC;
           SDA : inout  STD_LOGIC;
           SCL : out  STD_LOGIC);
end i2C;

architecture Behavioral of i2C is


	
type State_type is (Idle, Start, SlaveAddress, ACK1, RegisterAddress, ACK2,
                    txData, ACK3, Stop); 
signal State, NextState: State_type; 
signal counter: integer range 0 to 7:= 7; 
signal counter3: unsigned (2 downto 0):= "111"; 
signal counter2: integer range -1 to 7:= 7;

signal CLK_AUX: std_logic := '0'; 
signal regAddress : std_logic_vector(6 downto 0):= "1111111"; 
begin

	

	Process(State,CLK_AUX)
	begin 
		case state is 
		when Idle => 
			SCL<='1'; 
			SDA<='1'; 
			Nextstate<= Start;
			ACK<='0';
	
		when Start => 
			SCL<='1'; 
			SDA<='0'; 
			Nextstate<= SlaveAddress;
			ACK<='0';
		
		when SlaveAddress => 
			SCL<= CLK_AUX; 
			ACK<='0';
			if counter > 0 then  
				SDA<= slave_address(counter-1); 
				nextstate<= SlaveAddress; 
				counter<= counter -1; 
			elsif Counter = 0 then 
				SDA<= rw; 
				nextstate<= ACK1; 
				counter<= 7; 
			end if; 
		
		when ACK1 => 
			ACK<='1';
			SCL<= clk_AUX; 
			SDA<='Z'; 
			Nextstate<= RegisterAddress; 
		
		when RegisterAddress => 
			SCL<= clk_AUX; 
			ACK<='0';
			if counter3 > "000" then 
				SDA<= regaddress(counter-1); 
				nextstate<= RegisterAddress; 
				counter3<= counter3-1; 
			elsif Counter3 = "000" then  
				nextstate<= ACK2; 
				counter3<= "111"; 
			end if; 
		
		when ACK2 =>
			ACK<='1';
			SCL<= clk_AUX; 
			SDA<='Z';
			nextstate<= txData; 
		
		when txData => 
			SCL<= clk_AUX; 
			ACK<='0';
			if RW = '1' then 
				if counter2 > 0 then 
					SDA<= Datai(counter2); 
					nextstate<= txData; 
					counter2<= counter2-1; 
				elsif Counter2 = 0 then 
					SDA<= datai(counter2); 
					nextstate<= ACK3; 
					counter2<= 7; 
				end if;
			else 
				if counter2 >= 0 then 
					SDA<= Data_Slave(counter2); 
					nextstate<= txData;  
					counter2<= counter2-1;
					if Counter2 <= 0 then 
						SDA<= Data_Slave(counter2); 
						nextstate<= ACK3; 
						counter2<= 7; 
						DataO<= Data_Slave;
					end if; 
				
				end if;
		  end if; 
			
		when ACK3 => 
			ACK<='1';
			SCL<= clk_AUX; 
			SDA<= 'Z'; 
			nextstate<=STOP; 
			
		when STOP => 
			SCL<='1'; 
			SDA<='1';
			ACK<='0';
			if enable = '1' then 
				nextstate<= IDLE; 
			else 
				NextState<= STOP; 
			end if; 
		end case; 
	end process; 
	
	process (CLK)
	begin 
		if CLK'event and CLK='1' then 
			state<= nextstate; 
			CLK_AUX<= not CLK_AUX;
		end if; 
	end process; 
end Behavioral;

