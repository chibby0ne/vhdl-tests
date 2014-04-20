--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: ff_delay_tb.vhd
--! @brief: testbench for ff delay
--! @author: Antonio Gutierrez
--! @date: 2014-04-13
--!
--!
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------

--------------------------------------
entity ff_delay_tb is
    generic (N: integer := 5);
end entity ff_delay_tb;
--------------------------------------

--------------------------------------
architecture circuit of ff_delay_tb is
    
    -- dut declaration
    component ff_delay is
    port (
        clk: in std_logic;
        input: in std_logic_vector(N-1 downto 0);
        output: out std_logic_vector(N-1 downto 0));
    end component ff_delay;

    -- signals declarations
    signal clk_tb: std_logic := '0';
    signal input_tb: std_logic_vector(N-1 downto 0) := (others => '0');
    signal output_tb: std_logic_vector(N-1 downto 0) := (others => '0');
    
    
    for dut: ff_delay use entity work.ff_delay(circuit);

begin

    
    -- comp ins 
    dut: ff_delay port map (
        clk => clk_tb,
        input => input_tb,
        output => output_tb
    );

    -- stimuli
    -- clk

    clk_tb <= not clk_tb after 20 ns;
    

    -- input
    input_tb <= "11100" after 40 ns,
                "00011" after 80 ns;

end architecture circuit;


