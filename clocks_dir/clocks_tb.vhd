--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------
entity clocks_tb is
    generic (PERIOD: time := 40 ns);
end entity clocks_tb;
--------------------------------------
architecture circuit of clocks_tb is

-- dut decla
    component clocks is
        -- generic(const_name const_type = const_value)
        port (
            clk: in std_logic;
            clk_sec: out std_logic);
    end component clocks;

    -- signals 
    signal clk_tb: std_logic := '0';
    signal clk_sec_tb: std_logic := '0';

begin
    
    -- dut instan
    dut: clocks port map (
        clk => clk_tb,
        clk_sec => clk_sec_tb
    );
    
    -- sitmuli gen
    -- clk
    clk_tb <= not clk_tb after PERIOD/2;
end architecture circuit;
--------------------------------------

