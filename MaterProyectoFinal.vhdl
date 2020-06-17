# Proyecto-Final-Lab-de-Sistemas-Digitales
Proyecto final para la clase de Laboratorio de Sistemas Digitales
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_bit.all; 

entity integrado is
    Port ( CLK : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           Slave_address : in  STD_LOGIC_vector(6 downto 0);
           RW : in  std_logic; -- 1 escribir, 0 leer
           DataI : in  STD_LOGIC_vector(7 downto 0);
			  
           DataO : out  STD_LOGIC_vector(7 downto 0);
           Ack : out  STD_LOGIC;
           SDA : inout  STD_LOGIC;
           SCL2 : out  STD_LOGIC);
end integrado;

architecture Behavioral of integrado is
component slave
	port(
			 
			rw: in std_logic;  
			SCL:in std_logic;  
			enable: in std_logic;
			Slave_in: in std_logic_vector(7 downto 0)	;
			Slave_dataO: out std_logic_vector(7 downto 0); 
			Ack: out std_logic
	);
end component; 

type State_type is (Idle, Start, SlaveAddress, ACK1, RegisterAddress, ACK2,
                    txData, ACK3, Stop); 
signal State, NextState: State_type; 
signal counter: integer range 0 to 7:= 7; 
signal counter3: unsigned (2 downto 0):= "111"; 
signal counter2: integer range -1 to 7:= 7;
signal SCL: std_logic; 
signal CLK_AUX: std_logic := '0'; 
signal regAddress : std_logic_vector(6 downto 0):= "1111111"; 
signal Data_SLave: STD_LOGIC_vector(7 downto 0); 
signal ACK4: std_logic; 
signal DataMaster: std_logic_vector(7 downto 0); 
begin

	SL: slave port map (not Rw, SCL, enable, "10000100" , Data_slave, ACK4);  

	Process(State,CLK_AUX)
	begin 
		case state is 
		when Idle => 
			SCL<='1'; 
			SCL2<=SCL;
			SDA<='1'; 
			Nextstate<= Start;
			ACK<=ACK4;
	
		when Start => 
			SCL<='1';
			SCL2<=SCL;			
			SDA<='0'; 
			Nextstate<= SlaveAddress;
			ACK<=ACK4;
		
		when SlaveAddress => 
			SCL<= CLK_AUX; 
			ACK<=ACK4;
			SCL2<=SCL;
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
			ACK<=ACK4;
			SCL<= clk_AUX; 
			SCL2<=SCL;
			SDA<='Z'; 
			Nextstate<= RegisterAddress; 
		
		when RegisterAddress => 
			SCL<= clk_AUX; 
			SCL2<=SCL;
			ACK<=ACK4;
			if counter3 > "000" then 
				SDA<= regaddress(counter-1); 
				nextstate<= RegisterAddress; 
				counter3<= counter3-1; 
			elsif Counter3 = "000" then  
				nextstate<= ACK2; 
				counter3<= "111"; 
			end if; 
		
		when ACK2 =>
			ACK<=ACK4;
			SCL<= clk_AUX; 
			SCL2<=SCL;
			SDA<='Z';
			nextstate<= txData; 
		
		when txData => 
			SCL<= clk_AUX; 
			SCL2<=SCL;
			ACK<=ACK4;
			if RW = '1' then 
				if counter2 > 0 then 
					SDA<= Datai(counter2); 
					nextstate<= txData; 
					counter2<= counter2-1; 
				elsif Counter2 = 0 then 
					SDA<= datai(counter2); 
					nextstate<= ACK3; 
					DataMaster<= DataI; 
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
			ACK<=ACK4;
			SCL<= clk_AUX; 
			SCL2<=SCL;
			SDA<= 'Z'; 
			nextstate<=STOP; 
			
		when STOP => 
			SCL<='1';
			SCL2<=SCL;
			SDA<='1';
			ACK<=ACK4;
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
end behavioral;