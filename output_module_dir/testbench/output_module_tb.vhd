--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: output_module_tb.vhd
--! @brief: testbench for output module
--! @author: Antonio Gutierrez
--! @date: 2014-06-23
--!
--!
library ieee;
library work;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_support.all;
use work.pkg_types.all;
--------------------------------------------------------
entity output_module_tb is
    generic (PERIOD: time := 40 ns;
            PD: time := 3 ns);
end entity output_module_tb;
--------------------------------------------------------
architecture circuit of output_module_tb is
    
    --------------------------------------------------------------------------------------
    -- component declaration
    --------------------------------------------------------------------------------------
    component output_module is
        port (
                 clk: in std_logic;
                 valid: in std_logic;
                 code_rate: in t_code_rate;
                 input: in t_message_app_half_codeword;
                 output: out t_message_app_full_codeword);
    end component output_module;

    
    --------------------------------------------------------------------------------------
    -- signals declaration
    --------------------------------------------------------------------------------------
    signal clk_tb: std_logic := '0';
    signal valid_tb: std_logic := '0';
    signal code_rate_tb: t_code_rate;
    signal input_tb: t_message_app_half_codeword;
    signal output_tb: t_message_app_full_codeword;
    file fin: text open read_mode is "test_file.txt";
    
    
    

begin
    
    --------------------------------------------------------------------------------------
    -- component instantiation
    --------------------------------------------------------------------------------------
    dut: output_module port map (
        clk => clk_tb,
        valid => valid_tb,
        code_rate => code_rate_tb,
        input => input_tb,
        output => output_tb
    );

    
    --------------------------------------------------------------------------------------
    -- stimuli generation
    --------------------------------------------------------------------------------------

    -- clk
    clk_tb <= not clk_tb after PERIOD / 2;
    
    -- valid
    valid_tb <= 

    -- code_rate
    code_rate_tb <= R050;

    -- input
    process
        variable l: line;
        variable val: integer := 0;
    begin
        if (not endfile(fin)) then
            if (first = false) then
                first := true;
                wait for PERIOD / 2;
            else
                wait for PERIOD;
            end if;
            for i in CFU_PAR_LEVEL - 1 downto 0 loop
                readline(fin, l);
                read(l, val);
                input_tb(i) <= to_signed(val, BW_APP);
            end loop;
        end if;
    end process;


   --------------------------------------------------------------------------------------
   -- output verification
   --------------------------------------------------------------------------------------

   -- output

end architecture circuit;
