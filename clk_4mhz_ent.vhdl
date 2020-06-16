library ieee;
use ieee.std_logic_1164.all;


entity clk_4mhz_ent is
port ( clk_100MHz: in std_logic;
clk_4mhz: out std_logic);
end entity;


architecture logic_flow of clk_4mhz_ent is
    signal count: natural range 0 to 11;
    signal count2: natural range 0 to 3;
    signal temp_clk_out: std_logic;
    signal clk_4mhz_s,sclk, dclk: std_logic;
    
begin

    process(clk_100MHz)
        begin
        if (rising_edge(clk_100MHz)) then
        count <= count + 1;
        if(count=11) then
        temp_clk_out<=not temp_clk_out;
        count<=0;
        end if;
        end if;
    end process;
    
    clk_4mhz_s <= temp_clk_out;


    process (clk_4mhz_s)
        --variable count: integer range 0 to 3;
        begin
        if (rising_edge(clk_4mhz_s)) then
        count2 <= count2 + 1;
        if(count2=0) then
        sclk<='0';
        elsif(count2=1) then
        dclk<='1';
        elsif(count2=2) then
        sclk<='1';
        else
        dclk<='0';
        end if;
        end if;
    end process;
end architecture;
