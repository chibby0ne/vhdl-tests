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

entity shift_register_tb is
end entity shift_register_tb;
--------------------------------------

architecture circuit of shift_register_tb is
    
    -- dut decla
    component shift_register is
        port (
                 din: in std_logic;
                 rst: in std_logic;
                 clk: in std_logic;
                 dout: out std_logic);
    end component shift_register;

    
    -- signal declarations
        signal din_tb: std_logic := '0';
        signal rst_tb: std_logic := '1';
        signal clk_tb: std_logic := '0';
        signal dout_tb: std_logic;

        -- signal din_tb2: std_logic := '0';
        -- signal rst_tb2: std_logic := '1';
        -- signal clk_tb2: std_logic := '0';
        -- signal dout_tb2: std_logic;


        for dut: shift_register use entity work.shift_register(circuit); 
        -- for dut2: shift_register use entity work.shift_register(circuit2); 

begin
    
    -- dut ins
    dut: shift_register port map (
        din => din_tb,
        rst => rst_tb,
        clk => clk_tb,
        dout => dout_tb 
    );

    -- dut2: shift_register port map (
    --     din => din_tb2,
    --     rst => rst_tb2,
    --     clk => clk_tb2,
    --     dout => dout_tb2
    -- );
    
    -- stimuli gen

    -- clk
    clk_tb <= not clk_tb after 20 ns;
    -- clk_tb2 <= not clk_tb2 after 20 ns;

    
    -- rst
    rst_tb <= '0' after 40 ns;
    -- rst_tb2 <= '0' after 40 ns;

    
    -- din
    process 
    begin
        wait for 80 ns;
        din_tb <= '1';
        -- din_tb2 <= '1';
        wait for 40 ns;
        din_tb <= '0';
        -- din_tb2 <= '0';
        wait for 40 ns;
        din_tb <= '1';
        -- din_tb2 <= '1';
        wait for 120 ns;
        din_tb <= '0';
        -- din_tb2 <= '0';
        wait;
    end process;


    
    -- output verificaton
    process 
        --declarativepart
    begin
        wait for 80 ns + 40 ns + 20 ns + 1 ns;
        assert dout_tb = '1'
        report "error dout not match at 141 ns"
        severity failure;

        wait for 40 ns;
        assert dout_tb = '0'
        report "error dout not match at 181 ns"
        severity failure;

        wait for 40 ns;
        assert dout_tb = '1'
        report "error dout not match at 221 ns"
        severity failure;

        wait for 120 ns;
        assert dout_tb = '0'
        report "error dout not match at 341 ns"
        severity failure;

        assert false
        report "no errors"
        severity note;
        wait;
    end process;


end architecture circuit;


