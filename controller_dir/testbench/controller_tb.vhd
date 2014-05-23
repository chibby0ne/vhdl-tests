--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: controller_tb.vhd
--! @brief: testbench for controller
--! @author: Antonio Gutierrez
--! @date: 2014-05-22
--!
--!
--------------------------------------------------------
library ieee;
library work;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_support.all;
use work.pkg_types.all;
use work.pkg_param.all;
use work.pkg_param_derived.all;


--------------------------------------------------------
entity controller_tb is
    generic (PERIOD: time := 40 ns;
            PD: time := 3 ns);
end entity controller_tb;
--------------------------------------------------------
architecture circuit of controller_tb is
    
    -- dut declaration
    component controller is
    port (
        -- inputs
        clk: in std_logic;
        rst: in std_logic;
        code_rate: in t_code_rate;
        parity_out: in t_parity_out_contr;

        -- outputs
        ena_vc: out std_logic;
        ena_rp: out std_logic;
        ena_ct: out std_logic;
        ena_cf: out std_logic;
        valid_output: out std_logic;
        iter: out t_iter;
        app_rd_addr: out std_logic;
        app_wr_addr: out std_logic;
        msg_rd_addr: out t_msg_addr_contr;
        msg_wr_addr: out t_msg_addr_contr;
        shift: out t_shift_contr;
        mux_input_app: out std_logic_vector(CFU_PAR_LEVEL - 1 downto 0);        -- mux at input of app rams used for storing (0 = CNB, 1 = new code)
        mux_output_app: out t_mux_out_app                    -- mux output of appram used for selecting input of CNB (0 = app, 1 = dummy, 2 = new_code)
        );
    end component controller;


    -- signal declaration
    signal clk_tb: std_logic := '0';
    signal rst_tb: std_logic := '0';
    signal code_rate_tb: t_code_rate;
    signal parity_out_tb: t_parity_out_contr;

    signal ena_vc_tb: std_logic := '0';
    signal ena_rp_tb: std_logic := '0';
    signal ena_ct_tb: std_logic := '0';
    signal ena_cf_tb: std_logic := '0';
    signal valid_output_tb: std_logic := '0';
    signal iter_tb: t_iter; 
    signal app_rd_addr_tb: std_logic;
    signal app_wr_addr_tb: std_logic;
    signal msg_rd_addr_tb: t_msg_addr_contr;
    signal msg_wr_addr_tb: t_msg_addr_contr;
    signal shift_tb: t_shift_contr;
    signal mux_input_app_tb: std_logic_vector(CFU_PAR_LEVEL - 1 downto 0);
    signal mux_output_app_tb: t_mux_out_app;
    
    file fin: text open read_mode is "input_controller.txt";
    -- file fout: text open read_mode is "output_controller.txt";
   
    
begin
    
    --------------------------------------------------------------------------------------
    -- dut instantiation
    --------------------------------------------------------------------------------------
    dut: controller port map (
        clk => clk_tb,
        rst => rst_tb,
        code_rate => code_rate_tb,
        parity_out => parity_out_tb,
        ena_vc => ena_vc_tb,
        ena_rp => ena_rp_tb,
        ena_ct => ena_ct_tb,
        ena_cf => ena_cf_tb,
        valid_output => valid_output_tb,
        iter => iter_tb,
        app_rd_addr => app_rd_addr_tb,
        app_wr_addr => app_wr_addr_tb,
        msg_rd_addr => msg_rd_addr_tb,
        msg_wr_addr => msg_wr_addr_tb,
        shift => shift_tb,
        mux_input_app => mux_input_app_tb,
        mux_output_app => mux_output_app_tb
    );

    
    --------------------------------------------------------------------------------------
    -- stimuli generation
    --------------------------------------------------------------------------------------

    
    -- clk
    clk_tb <= not clk_tb after PERIOD / 2;


    -- rst
    rst_tb <= '0';


    -- code rate
    code_rate_tb <= R050;
    

    -- parity_out (could use an input)
    process
        variable l: line;
        variable val: integer range 0 to 42 := 0;
        variable first: boolean := false;
        
    begin
        if (not endfile(fin)) then
            if (first = false) then
                first := true;
                wait for PERIOD / 2 + PERIOD * 3;
            else
                wait for PERIOD;
            end if;
            for i in 0 to SUBMAT_SIZE - 1 loop
                readline(fin, l);
                read(l, val);
                if (val = 1) then
                    parity_out_tb(i) <= '1';
                else
                    parity_out_tb(i) <= '0';
                end if;
            end loop;
        else
            wait for PERIOD / 2;
            assert false
            report "no errors"
            severity failure;
        end if;


    end process;


    
    --------------------------------------------------------------------------------------
    -- output verification
    --------------------------------------------------------------------------------------

    
    -- ena_vc


    
    -- ena_rp


    
    -- ena_ct


    
    -- ena_cf


    
end architecture circuit;
