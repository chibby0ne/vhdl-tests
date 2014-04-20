--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: ff_counter_tb.vhd
--! @brief: 
--! @author: Antonio Gutierrez
--! @date: 2014-04-05
--!
--!
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------
entity ff_counter_tb is
end entity ff_counter_tb;
--------------------------------------
architecture circuit of ff_counter_tb is
    
    -- dut declaration
    component ff_counter is
    port (
        clk: in std_logic;
        rst: in std_logic;
        count: out natural range 0 to 7);
    end component ff_counter;
    
    -- signals declarations
    signal clk_tb: std_logic := '0';
    signal rst_tb: std_logic := '0';
    signal count_tb: natural range 0 to 7;

    signal clk_tb2: std_logic := '0';
    signal rst_tb2: std_logic := '0';
    signal count_tb2: natural range 0 to 7;

    signal clk_tb3: std_logic := '0';
    signal rst_tb3: std_logic := '0';
    signal count_tb3: natural range 0 to 7;

    for dut: ff_counter use entity work.ff_counter(circuit);
    for dut2: ff_counter use entity work.ff_counter(circuit2);
    for dut3: ff_counter use entity work.ff_counter(circuit3);
begin
    
    -- dut instantiation
    dut: ff_counter port map (
        clk => clk_tb,
        rst => rst_tb,
        count => count_tb
    );

    dut2: ff_counter port map (
        clk => clk_tb2,
        rst => rst_tb2,
        count => count_tb2
    );


    dut3: ff_counter port map (
        clk => clk_tb3,
        rst => rst_tb3,
        count => count_tb3
    );

    -- stimuli generation
    -- clk
    clk_tb <= not clk_tb after 10 ns;
    clk_tb2 <= not clk_tb2 after 10 ns;
    clk_tb3 <= not clk_tb3 after 10 ns;

    
    -- rst
    process
         --declarative part
    begin
        wait for 40 ns;
        rst_tb <= '1';
        rst_tb2 <= '1';
        rst_tb3 <= '1';
        wait for 20 ns;  -- 60 ns
        rst_tb <= '0';
        rst_tb2 <= '0';
        rst_tb3 <= '0';
        wait;
    end process;
    
    
    -- output verification
    process
         --declarative part
    begin

        -- check for time 11 ns
        wait for 11 ns;
        assert count_tb = 1
        report "count is not 1 at time 11 ns"
        severity failure;

        -- check for time 31 ns
        wait for 20 ns;
        assert count_tb = 2
        report "count is not 2 at time 31 ns"
        severity failure;

        -- check for time 51 ns
        wait for 20 ns;
        assert count_tb = 0
        report "count is not 2 at time 51 ns"
        severity failure;

        -- check for time 71 ns
        wait for 20 ns;
        assert count_tb = 1
        report "count is not 1 at time 71 ns"
        severity failure;

        -- check for time 91 ns
        wait for 20 ns;
        assert count_tb = 2
        report "count is not 2 at time 91 ns"
        severity failure;

        -- check for time 111 ns
        wait for 20 ns;
        assert count_tb = 3
        report "count is not 3 at time 111 ns"
        severity failure;

        -- check for time 131 ns
        wait for 20 ns;
        assert count_tb = 4
        report "count is not 4 at time 131 ns"
        severity failure;

        -- check for time 151 ns
        wait for 20 ns;
        assert count_tb = 5
        report "count is not 5 at time 151 ns"
        severity failure;

        -- check for time 171 ns
        wait for 20 ns;
        assert count_tb = 6
        report "count is not 6 at time 171 ns"
        severity failure;

        -- check for time 191 ns
        wait for 20 ns;
        assert count_tb = 7
        report "count is not 7 at time 191 ns"
        severity failure;

        -- check for time 211 ns
        wait for 20 ns;
        assert count_tb = 0
        report "count is not 0 at time 211 ns"
        severity failure;

        -- check for time 231 ns
        wait for 20 ns;
        assert count_tb = 1
        report "count is not 1 at time 231 ns"
        severity failure;

        -- check for time 251 ns
        wait for 20 ns;
        assert false
        report "no errors for tb"
        severity note;
        wait;

    end process;




end architecture circuit;

