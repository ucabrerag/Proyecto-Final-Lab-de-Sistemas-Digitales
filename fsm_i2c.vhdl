library ieee;
use ieee.std_logic_1164.all;
entity fsm_i2c is
    port( clk2, rst, wr_enable: in std_logic;
          sclk: out std_logic;
          sda: inout std_logic);
end entity;

architecture logic_flow of fsm_i2c is

    type state is (st_idle, st0_start, st1_txSlaveAddress, st2_ack1, st3_txRegAddress, st4_ack2, st5_txData, st6_ack3, st7_stop);
    signal present_state, next_state: state;
    signal clk, dclk: std_logic;
    constant data: std_logic_vector(7 downto 0) :="11101100";
    constant slave_address: std_logic_vector(7 downto 0) :="11101100"; 
    constant register_address: std_logic_vector(7 downto 0) :="11101100";
    constant max_length: natural:=8;
    constant max_delay: natural:=8;
    signal data_index: natural range 0 to max_length -1;
    signal timer: natural range 0 to max_delay;
    signal ack_bits: std_logic_vector(2 downto 0);