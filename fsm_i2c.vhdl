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

begin
    process(clk2, rst)
     begin
      if (rst='1') then
        present_state<= st_idle;
        data_index <= 0;
      elsif (clk2'event and clk2='1') then
       if(data_index=timer-1) then
        present_state<=next_state;
        data_index <=0;
       else
         data_index <= data_index +1;
       end if;
     end if;
    end process;

    process(clk2, rst)
     begin
      if (rst='1') then
        present_state<= st_idle;
        data_index <= 0;
      elsif (clk2'event and clk2='1') then
       if(data_index=timer-1) then
        present_state<=next_state;
        data_index <=0;
       else
        data_index <= data_index +1;
       end if;
  --    elsif (clk'event and clk='0') then
       end if;

       if(present_state=st2_ack1) then
        ack_bits(0)<=sda;
        elsif( present_state=st4_ack2) then
            ack_bits(1)<=sda;
        elsif( present_state= st6_ack3) then
            ack_bits(2)<=sda;
        end if;

    end process;




-----------------------------------------------------


--- Circuit outputs and next state values 
    process(clk, present_state, wr_enable)
     begin
      case present_state is
       when st_idle =>
        sclk<='1';
        sda<='1';
        timer<=1;
       if(wr_enable ='1') then
        next_state<= st0_start;
       else
        next_state<= st_idle;
       end if;

       when st0_start =>
        sclk <='1';
        sda<=dclk;
        timer<=1;
        next_state<= st1_txSlaveAddress;
        
       when st1_txSlaveAddress =>
        sclk<=clk;
        sda<= slave_address (7- data_index);
        timer<=8;
        next_state<= st2_ack1;

       when st2_ack1=>
        sclk<=clk;
        sda<='Z';
        timer<=1;
        next_state<= st3_txRegAddress; 

       when st3_txRegAddress =>
        sclk<=clk;
        sda<= register_address (7- data_index);
        timer<=8;
        next_state<= st4_ack2;

       when st4_ack2=>
        sclk<=clk;
        sda<= 'Z';
        timer<=1;
        next_state<= st5_txData;

       when st5_txData =>
        sclk<=clk;
        sda<= data (7- data_index);
        timer<=8;
        next_state<= st6_ack3;

       when st6_ack3=>
        sclk<=clk;
        sda<= 'Z';
        timer<=1;
        next_state<= st7_stop;

       when st7_stop =>
        sclk<='1';
        sda<= not dclk;
        timer<=1;
        next_state<= st_idle;
     end case;
    end process;
    end logic_flow;