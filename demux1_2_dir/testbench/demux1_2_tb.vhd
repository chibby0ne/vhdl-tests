--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: demux1_2_tb.vhd
--! @brief: testbench for demux 1 to 2
--! @author: Antonio Gutierrez
--! @date: 2014-08-08
--!
--!
--------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_support.all;
use work.pkg_types.all;
use work.pkg_param.all;
use std.textio.all;
--------------------------------------------------------
entity demux1_2_tb is
    generic (PERIOD: time := 40 ns;
            PD: time := 3 ns);
end entity demux1_2_tb;
--------------------------------------------------------
architecture circuit of demux1_2_tb is
    
    -- comp declaration
    component demux1_2 is
        port (
            input: in t_app_messages;
            sel: in std_logic;
            output0: out t_app_messages;
            output1: out t_app_messages);
    end component demux1_2;

    
    -- signal declarations
    signal input_tb: t_app_messages;
    signal sel_tb: std_logic;
    signal output0_tb: t_app_messages;
    signal output1_tb: t_app_messages;
    file f: text open read_mode is "input.txt";
    file fout: text open read_mode is "output.txt";
    
    signal clk_tb: std_logic := '0';
    
    
    

begin

    
    -- comp instantiation
    dut: demux1_2 port map (
        input => input_tb,
        sel => sel_tb,
        output0 => output0_tb,
        output1 => output1_tb
    );
    

    
    -- stimuli generation

    -- clk
    clk_tb <= not clk_tb after PERIOD / 2;
    

    -- input
    process
        variable l: line;
        variable val: integer;
    begin
        if (not endfile(f)) then
            for i in 0 to SUBMAT_SIZE - 1 loop
                readline(f, l);
                read(l, val);
                input_tb(i) <= to_signed(val, BW_APP);
            end loop;
        else
            wait;
        end if;
    end process;


    -- sel
    process
    begin
        sel_tb <= '0';
        wait for PERIOD + PERIOD / 2;
        sel_tb <= '1';
        wait;
    end process;


    -- output comparison
    process
        variable l: line;
        variable val: integer;
        variable first: boolean := true;
        
    begin
        if (not endfile(fout)) then
            if (first = true) then
                first := false;
                wait for PD;
            end if;
            for i in 0 to SUBMAT_SIZE - 1 loop
                readline(fout, l);
                read(l, val);
                if (now < PERIOD + PERIOD / 2) then
                    assert output0_tb(i) = to_signed(val, BW_APP)
                    report "error. output0_tb(" & integer'image(i) & ") is = " & integer'image(to_integer(output0_tb(i))) & " but should be " & integer'image(val)
                    severity failure;

                    assert output1_tb(i) = to_signed(0, BW_APP)
                    report "error. output0_tb(" & integer'image(i) & ") is = " & integer'image(to_integer(output1_tb(i))) & " but should be " & integer'image(0)
                    severity failure;

                else
                    assert output1_tb(i) = to_signed(val, BW_APP)
                    report "error. output0_tb(" & integer'image(i) & ") is = " & integer'image(to_integer(output1_tb(i))) & " but should be " & integer'image(val)
                    severity failure;

                    assert output0_tb(i) = to_signed(0, BW_APP)
                    report "error. output0_tb(" & integer'image(i) & ") is = " & integer'image(to_integer(output0_tb(i))) & " but should be " & integer'image(0)
                    severity failure;

                end if;
            end loop;
            wait for PERIOD;
        else
            assert false
            report "no errors"
            severity failure;
        end if;
    end process;



end architecture circuit;
