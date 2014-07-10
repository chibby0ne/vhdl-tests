--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: permutation_network_tb.vhd
--! @brief: permutation network tb
--! @author: Antonio Gutierrez
--! @date: 2014-05-02
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
use work.pkg_param_derived.all;
use std.textio.all;
--------------------------------------------------------
entity permutation_network_tb is
    generic (PERIOD: time := 40 ns;
            PD: time := 3 ns);
end entity permutation_network_tb;
--------------------------------------------------------
architecture circuit of permutation_network_tb is
    
    -- dut declaration 
    component permutation_network is
        port (
                 input: in t_app_messages;
                 -- shift: in t_shift_perm_net;
                 shift: in std_logic_vector(BW_SHIFT_VEC - 1 downto 0);
                 output: out t_app_messages);
    end component permutation_network;
    
    -- signals declaration
    signal input_tb: t_app_messages;
    signal shift_tb: std_logic_vector(BW_SHIFT_VEC - 1 downto 0);
    signal output_tb: t_app_messages;

    -- files for input and output
    file fin: text open read_mode is "input_ram.txt";
    file fout: text open read_mode is "output_ram.txt";
    
    -- additional signals
    signal clk_tb: std_logic := '0';
    
    
    -- test circular right shift
    -- signal circular_right_shift: std_logic_vector(3 downto 0) := "0100";
    
    
begin

    
    --------------------------------------------------------------------------------------
    -- dut instantiation
    --------------------------------------------------------------------------------------
    dut: permutation_network port map (
        input => input_tb,
        shift => shift_tb,
        output => output_tb
    );

    
    --------------------------------------------------------------------------------------
    -- stimuli generation
    --------------------------------------------------------------------------------------

    -- circular right shift
    -- circular_right_shift <= circular_right_shift ror 2;

    -- clk
    clk_tb <= not clk_tb after PERIOD / 2;

    -- input
    process
        variable l: line;
        variable value: integer range -256 to 255;
        variable first: integer range 0 to 1 := 0;
    begin
        for i in 0 to SUBMAT_SIZE - 1 loop
            readline(fin, l);
            read(l, value);
            input_tb(i) <= to_signed(value, input_tb(i)'length);
        end loop;
        wait;
    end process;

    -- shift
    process
        variable first: integer range 0 to 1 := 0;
    begin
        for i in 0 to SUBMAT_SIZE - 1 loop
            shift_tb <= std_logic_vector(to_unsigned(i, BW_SHIFT_VEC));
            if (first = 0) then
                first := 1;
                wait for PERIOD / 2 + PD;
            else
                wait for PERIOD;
            end if;
        end loop;
        wait;
    end process;
    

    
    --------------------------------------------------------------------------------------
    -- output comparison
    --------------------------------------------------------------------------------------

    process
        variable l: line;
        variable value: integer range -256 to 255;
        variable first: integer range 0 to 1 := 0;
    begin
        if (not endfile(fout)) then
            if (first = 0) then
                wait for PD;
            end if;
            for i in 0 to SUBMAT_SIZE - 1 loop
                readline(fout, l);
                read(l, value);
                assert output_tb(i) = to_signed(value, output_tb(i)'length)
                report "output mismatch at " & time'image(now)
                severity failure;
            end loop;
            if (first = 0) then
                first := 1;
                wait for PERIOD / 2 + PD;
            else
                wait for PERIOD;
            end if;
        else
            assert false
            report "no errors"
            severity failure;
        end if;
    end process;

end architecture circuit;


