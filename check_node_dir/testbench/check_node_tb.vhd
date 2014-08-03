--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: check_node_tb.vhd
--! @brief: testbench for check node
--! @author: Antonio Gutierrez
--! @date: 2014-04-14
--!
--!
--------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.pkg_types.all;
use work.pkg_param.all;
use work.pkg_support.all;

--------------------------------------
entity check_node_tb is
    generic (PD: time := 3 ns;
            PERIOD: time := 40 ns);
end entity check_node_tb;
--------------------------------------
architecture circuit of check_node_tb is
    
    --------------------------------------------------------
    -- dut declaration
    --------------------------------------------------------


    component check_node is
        -- generic(const_name const_type = const_value)
        port(

    -- INPUTS
                rst           : in std_logic;
                clk           : in std_logic;
                ena_cf        : in std_logic;
                data_in       : in t_cn_message;
                split         : in std_logic; -- is the CN working in split mode

    -- OUTPUTS
                data_out      : out t_cn_message
            );

    end component check_node;
    
    -- signal declarations
    signal rst_tb: std_logic := '0';
    signal clk_tb: std_logic := '0';
    signal ena_cf_tb: std_logic := '0';
    signal data_in_tb: t_cn_message;
    signal split_tb: std_logic := '0';
    signal data_out_tb: t_cn_message;
    
    
    -- file f: text open read_mode is "input_cn.txt";
    -- file f_comp: text open read_mode is "output_cn.txt";
    file f: text open read_mode is "input_cn_test_bug.txt";
    file f_comp: text open read_mode is "output_cn_test_bug.txt";
    signal first: std_logic := '0';

    signal input: t_cn_message;
    


begin

    
    --------------------------------------------------------
    -- dut instatiation
    --------------------------------------------------------


    dut: check_node port map (
        rst => rst_tb,
        clk => clk_tb,
        ena_cf => ena_cf_tb,
        data_in => data_in_tb,
        split => split_tb, 
        data_out => data_out_tb
    );

    
    --------------------------------------------------------
    -- stimuli generation
    --------------------------------------------------------

    -- clk
    clk_tb <= not clk_tb after PERIOD / 2;
    

    -- rst (not configured)
    rst_tb <= '0' after PERIOD;


    -- ena_cf
    process
    begin
        ena_cf_tb <= '1';           -- this could be 0 when input is first assigned to input signal and then to data_in_tb
        wait for PERIOD / 2;
        ena_cf_tb <= '1';
        wait;
    end process;


    -- data_in
    process
        variable l: line;
        variable input_val: integer range -32 to 31;
        variable index_input: natural range 0 to 16;
        variable i: natural := 0;
        variable first: integer range 0 to 1 := 0;
        variable val_conv: signed(BW_EXTR - 1 downto 0);
        -- variable input: t_cn_message;
        
    begin
        if (not endfile(f)) then
            for i in 0 to CFU_PAR_LEVEL-1 loop
                readline(f, l);  
                read(l, index_input);
                read(l, input_val);
                -- data_in_tb(i) <= to_signed(input_val, BW_EXTR);
                -- use this when using correct implementation in design else use the to_signed line above
                val_conv := to_signed(input_val, BW_EXTR);
                input(i) <= val_conv;
                data_in_tb(i) <= sign_magnitude(val_conv);
            end loop;
            if (first = 0) then
                wait for PERIOD / 2;
                first := 1;
            else
                wait for PERIOD;
            end if;
        else
            wait;
        end if;
    end process;

    
    --------------------------------------------------------------------------------------
    -- output comparison
    --------------------------------------------------------------------------------------
    process
        variable l_comp: line;
        variable index_output: integer range 0 to 16 := 0;
        variable output_val: integer range -32 to 31 := 0;
        variable first: integer range 0 to 1 := 0;
        variable i: integer range 0 to 16 := 0;
    begin
        if (not endfile(f_comp)) then
            if (first = 0) then
                wait for PD;
                wait for PERIOD / 2;
                -- wait for PERIOD;            -- include this when using signal input for input
                first := 1;
            end if;
            for i in 0 to CFU_PAR_LEVEL - 1 loop
                readline(f_comp, l_comp);
                read(l_comp, index_output);
                read(l_comp, output_val);

                assert (data_out_tb(i) = to_signed(output_val, BW_EXTR))
                report "data_out(" & integer'image(i) & ") = " & integer'image(to_integer(data_out_tb(i))) & ". But should be : " & integer'image(output_val)
                severity failure;
            end loop;
            wait for PERIOD;
        else
            assert false
            report "no errors"
            severity failure;
        end if;
    end process;

end architecture circuit;
