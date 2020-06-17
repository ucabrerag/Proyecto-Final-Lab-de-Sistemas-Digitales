--Segundo intento

library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity I2CM is 
    port (ni,n2 : out std_logic_vector (7 downto 0);--output for each digit that contain 8 bits
          clkI2M: in std_logic;--Input board signal from the board crystal oscillator
          Io_SDA: inout std_logic; --SDA I/O port
          o_SCL: out std_logic --SCL out port
          );
end I2CM;

architecture behaivoral of I2CM is

    constant ss: integer :=1; --Change to 1 for READ/0 for write

    signal CLK, clk200k_1; std_logic; --Output signal for clock divider/clk200 is a signal used from counter
    signal counter200k: std_logic_vector (6 downto 0); --signal for clock divider's counter that counts from 0 to 40
    signal state: integer range 0 to 100:=0; --Integer number signal to declare maximum state of FSM
    signal 