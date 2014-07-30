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
use work.pkg_ieee_802_11ad_matrix.all;
use work.pkg_support.all;
use work.pkg_types.all;
use work.pkg_param.all;
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
                 rst: in std_logic;
                 clk: in std_logic;
                 finish_iter: in std_logic;
                 code_rate: in t_code_rate;
                 input: in t_hard_decision_half_codeword;
                 output: out t_hard_decision_full_codeword);
    end component output_module;

    
    --------------------------------------------------------------------------------------
    -- signals declaration
    --------------------------------------------------------------------------------------
    signal rst_tb: std_logic := '0';
    signal clk_tb: std_logic := '0';
    signal finish_iter_tb: std_logic := '0';
    signal code_rate_tb: t_code_rate;
    signal input_tb: t_hard_decision_half_codeword;
    signal output_tb: t_hard_decision_full_codeword;
    file fin: text open read_mode is "input.txt";
    file fout: text open read_mode is "output.txt";
    
    signal shift: t_array16;
    

begin
    
    --------------------------------------------------------------------------------------
    -- component instantiation
    --------------------------------------------------------------------------------------
    dut: output_module port map (
        rst => rst_tb,
        clk => clk_tb,
        finish_iter => finish_iter_tb,
        code_rate => code_rate_tb,
        input => input_tb,
        output => output_tb
    );

    
    --------------------------------------------------------------------------------------
    -- stimuli generation
    --------------------------------------------------------------------------------------

    -- clk
    clk_tb <= not clk_tb after PERIOD / 2;

    -- rst 
    process
         --declarative part
    begin
        rst_tb <= '1';
        wait for PERIOD;
        rst_tb <= '0';
        wait;
    end process;

    
    -- finish_iter
    process
    begin
        wait for PERIOD;
        finish_iter_tb <= '1';
        wait for 2 * PERIOD;
        finish_iter_tb <= '0';
        wait;
    end process;


    -- code_rate
    code_rate_tb <= R050;

    -- shift
    shift <= IEEE_802_11AD_P42_N672_R050_SHIFTING_INFO when code_rate_tb = R050 else 
             IEEE_802_11AD_P42_N672_R062_SHIFTING_INFO when code_rate_tb = R062 else
             IEEE_802_11AD_P42_N672_R075_SHIFTING_INFO when code_rate_tb = R075 else 
             IEEE_802_11AD_P42_N672_R081_SHIFTING_INFO;  


    -- input
    process
        variable l: line;
        variable val: integer := 0;
        variable val_assigned: std_logic := '0';
        variable first: boolean := false;
    begin
        if (not endfile(fin)) then
            if (first = false) then
                first := true;
                wait for PERIOD;
            else
                wait for PERIOD;
            end if;
            for i in CFU_PAR_LEVEL - 1 downto 0 loop
                for j in SUBMAT_SIZE - 1 downto 0 loop
                    readline(fin, l);
                    read(l, val);
                    if (val = 0) then
                        val_assigned := '0';
                    else
                        val_assigned := '1';
                    end if;
                    input_tb(i)(j) <= val_assigned; 
                end loop;
            end loop;
        else
            wait;
        end if;
    end process;


   --------------------------------------------------------------------------------------
   -- output verification
   --------------------------------------------------------------------------------------

    process
        variable l: line;
        variable val: integer;
        variable val_assigned: std_logic := '0';
        variable first: boolean := false;
        variable index: integer := 0;
        variable sign: integer := 0;
        variable output_tb_int: integer := 0;
        
        
    begin
        if (not endfile(fout)) then
            if (first = false) then
                first := true;
                wait for 2 * PERIOD + PERIOD / 2 + PD;
            else
                wait for PERIOD;
            end if;
            for i in 2 * CFU_PAR_LEVEL - 1 downto 0 loop
                for j in SUBMAT_SIZE - 1 downto 0 loop
                    readline(fout, l);
                    read(l, val);

                    -- get value of file as std_logic (needed for assertion)
                    if (val = 0) then
                        val_assigned := '0';
                    else
                        val_assigned := '1';
                    end if;

                    -- get value of index
                    index := (shift((2 * CFU_PAR_LEVEL - 1) - i) + j) mod SUBMAT_SIZE;
                    
                    -- get value of output as int (needed for assertion)
                    if output_tb(i)(index) = '0' then
                        output_tb_int := 0;
                    else
                        output_tb_int := 1;
                    end if;


                    assert output_tb(i)(index) = val_assigned 
                    report "for group " & integer'image(i) & " output should be " & integer'image(val) & " with index = " & integer'image(index) & " but instead is " & integer'image(output_tb_int)
                    severity failure;
                end loop;
            end loop;
        else
            assert false
            report "Testbench passed"
            severity failure;
        end if;
    end process;

end architecture circuit;
