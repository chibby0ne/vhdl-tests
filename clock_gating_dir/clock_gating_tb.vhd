--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: clock_gating_tb.vhd
--! @brief: 
--! @author: Antonio Gutierrez
--! @date: 2014-05-16
--!
--!
--------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------
entity ff_clock_gating_tb is
    generic (PERIOD: time := 40 ns;
            PD: time := 3 ns);
end entity ff_clock_gating_tb;
--------------------------------------------------------
architecture circuit of ff_clock_gating_tb is

    
    --------------------------------------------------------------------------------------
    -- component declaration
    --------------------------------------------------------------------------------------
    component ff_clock_gating is
        port (
                 input: in natural range 0 to 10;
                 clk: in std_logic;
                 ena: in std_logic;
                 output: out natural range 0 to 10);
    end component ff_clock_gating;

    
    --------------------------------------------------------------------------------------
    -- signal declaration
    --------------------------------------------------------------------------------------
    signal input_tb: natural range 0 to 10;
    signal clk_tb: std_logic := '0';
    signal ena_tb: std_logic := '0';
    signal output_tb: natural range 0 to 10;
    
begin

    
    --------------------------------------------------------------------------------------
    -- component instantiation
    --------------------------------------------------------------------------------------

    dut: ff_clock_gating port map (
        input => input_tb,
        clk => clk_tb,
        ena => ena_tb,
        output => output_tb
    );

    
    --------------------------------------------------------------------------------------
    -- stimuli generation
    --------------------------------------------------------------------------------------

    -- clk
    clk_tb <= not clk_tb after PERIOD / 2;
    
    -- ena
    process
    begin
        wait for PERIOD / 2;
        ena_tb <= '1';
        wait for PERIOD;
        ena_tb <= '0';
        wait for PERIOD;
        ena_tb <= '1';
        wait;
    end process;

    -- input
    process
    begin
        input_tb <= 5;
        wait for PERIOD / 2;
        input_tb <= 8;
        wait for PERIOD;
        input_tb <= 1;
        wait;
    end process;

    
    --------------------------------------------------------------------------------------
    -- output comparison
    --------------------------------------------------------------------------------------
    process
    begin
        wait for PERIOD / 2; 
        wait for PD;

        -- assert output_tb = 5
        -- report "output mismatch"
        -- severity failure;

        wait for PERIOD; 
        
        assert output_tb = 8
        report "output mismatch"
        severity failure;

        wait for PERIOD;


        assert output_tb = 8
        report "output mismatch"
        severity failure;


        wait for PERIOD;

        assert false
        report "no errors"
        severity failure;
    end process;
end architecture circuit;

