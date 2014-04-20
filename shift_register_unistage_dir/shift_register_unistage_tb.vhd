--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: shift_register_dirshift_register_tb.vhd
--! @brief: 
--! @author: Antonio Gutierrez
--! @date: 2014-04-08
--!
--!
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------

entity shift_register_unistage_tb is
    generic (N: integer := 2;
             PERIOD: time := 40 ns);
end entity shift_register_unistage_tb;
--------------------------------------

architecture circuit of shift_register_unistage_tb is
    
    -- dut decla
    component shift_register_unistage is
        port (
                 din: in std_logic;
                 rst: in std_logic;
                 clk: in std_logic;
                 dout: out std_logic);
    end component shift_register_unistage;

    
    -- signal declarations
        signal din_tb: std_logic := '0';
        signal rst_tb: std_logic := '1';
        signal clk_tb: std_logic := '0';
        signal dout_tb: std_logic;

begin
    
    -- dut ins
    dut: shift_register_unistage port map (
        din => din_tb,
        rst => rst_tb,
        clk => clk_tb,
        dout => dout_tb 
    );

    
    -- stimuli gen

    -- clk
    clk_tb <= not clk_tb after PERIOD/2;

    
    -- rst
    rst_tb <= '0' after PERIOD;

    
    -- din
    process 
    begin
        wait for 2 * PERIOD;
        din_tb <= '1';
        wait for PERIOD;
        din_tb <= '0';
        wait for PERIOD;
        din_tb <= '1';
        wait for 3 * PERIOD;
        din_tb <= '0';
        wait;
    end process;


    -- output verificaton
    process 
        --declarativepart
    begin
        wait for 2 * PERIOD + PERIOD + PERIOD/2 + 1 ns;
        assert dout_tb = '1'
        report "error dout not match at 141 ns"
        severity failure;

        wait for PERIOD;
        assert dout_tb = '0'
        report "error dout not match at 181 ns"
        severity failure;

        wait for PERIOD;
        assert dout_tb = '1'
        report "error dout not match at 221 ns"
        severity failure;

        wait for 3 * PERIOD;
        assert dout_tb = '0'
        report "error dout not match at 341 ns"
        severity failure;

        assert false
        report "no errors"
        severity note;
        wait;
    end process;


end architecture circuit;


