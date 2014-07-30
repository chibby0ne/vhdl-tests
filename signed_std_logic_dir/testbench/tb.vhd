--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: tb.vhd
--! @brief: testbench
--! @author: Antonio Gutierrez
--! @date: 2014-07-10
--!
--!
--------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
--------------------------------------------------------
entity tb is
    generic (BW_APP: integer := 9;
            SUBMAT_SIZE: integer := 42;
            CFU_PAR_LEVEL: integer := 8;
            PERIOD: time := 40 ns);
end entity tb;
--------------------------------------------------------
architecture circuit of tb is


    type t_app_messages is array (SUBMAT_SIZE - 1 downto 0) of signed(BW_APP - 1 downto 0);
    type t_hard_decision_app is array (SUBMAT_SIZE - 1 downto 0) of std_logic; 

    type t_hard_decision_half_codeword is array (CFU_PAR_LEVEL - 1 downto 0) of t_hard_decision_app;
    type t_app_message_half_codeword is array (CFU_PAR_LEVEL - 1 downto 0) of t_app_messages;


    signal mux_app_input_in_cnb: t_app_message_half_codeword;
    signal hard_bits_cnb: t_hard_decision_half_codeword;

    file f: text open read_mode is "input_file.txt";

    
begin

    
    -- app message
    process
        variable l: line;
        variable var: integer := 0;
        variable var_signed: signed(BW_APP - 1 downto 0);
        
    begin
        if (not endfile(f)) then
            for i in CFU_PAR_LEVEL - 1 downto 0 loop
                for j in SUBMAT_SIZE - 1 downto 0 loop
                    readline(f, l);
                    read(l, var);
                    var_signed := to_signed(var, BW_APP);
                    mux_app_input_in_cnb(i)(j) <= var_signed;
                end loop;
            end loop;
        else
            wait;
        end if;
    end process;
    

    -- hard decision
    process
    begin
        wait for PERIOD;
        for i in CFU_PAR_LEVEL - 1 downto 0 loop
            for j in SUBMAT_SIZE - 1 downto 0 loop
                hard_bits_cnb(i)(j) <= mux_app_input_in_cnb(i)(j)(BW_APP - 1);
            end loop;
        end loop;

        wait for PERIOD;

        assert false
        report "sim end"
        severity failure;

    end process;

end architecture circuit;
