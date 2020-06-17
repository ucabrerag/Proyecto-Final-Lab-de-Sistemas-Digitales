-- Equipo #1
-- TestBench

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 

 
ENTITY TestbenchIntegrado IS
END TestbenchIntegrado;
 
ARCHITECTURE behavior OF TestbenchIntegrado IS 
 
    
 
    COMPONENT Integrado
    
    PORT(
         CLK : IN  std_logic;
         enable : IN  std_logic;
         Slave_address : IN  std_logic_vector(6 downto 0);
         RW : IN  std_logic;
         DataI : IN  std_logic_vector(7 downto 0);
          
         DataO : OUT  std_logic_vector(7 downto 0);
         Ack : OUT  std_logic;
         SDA : INOUT  std_logic;
         SCL2 : inOUT  std_logic
        );
    END COMPONENT;
	 
   --Inputs
   signal CLK : std_logic := '0';
   signal enable : std_logic := '0';
   signal Slave_address : std_logic_vector(6 downto 0) := (others => '0');
   signal RW : std_logic := '0';
   signal DataI : std_logic_vector(7 downto 0) := (others => '0');
    
	--BiDirs
   signal SDA : std_logic;

 	--Outputs
   signal DataO : std_logic_vector(7 downto 0);
   signal Ack : std_logic;
   signal SCL2 : std_logic;

	constant CLK_period : time := 10 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Integrado PORT MAP (
			 CLK => CLK,
          enable => enable,
          Slave_address => Slave_address,
          RW => RW,
          DataI => DataI,
         
          DataO => DataO,
          Ack => Ack,
          SDA => SDA,
			 
          SCL2 => SCL2
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      enable<='0'; 
		RW<='1'; 
		slave_address<= "1000111"; 
		Datai<= "10101010"; 
		
	
		wait for clk_period * 30; 
		
		enable<='1'; 
		RW<='0'; 
		slave_address<= "1000111"; 
		Datai<= "10101010"; 
		 
		
		wait for 30 ns; 
		enable<='0';

      -- insert stimulus here 

      wait;
   end process;

END;