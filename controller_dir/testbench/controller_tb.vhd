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
use work.pkg_ieee_802_11ad_matrix.all;
use work.pkg_ieee_802_11ad_param.all;


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
   

    -- signals used for determining matrices and its properties
    signal matrix_addr: t_array64 := (others => 0);      
    signal matrix_shift: t_array64 := (others => 0);
    signal matrix_length: natural range 0 to 64;
    signal matrix_rows: natural range 0 to 8:= 1;
    signal matrix_max_check_degree: natural range 0 to 16;
    
begin

    
    --------------------------------------------------------------------------------------
    -- signals used for verification
    --------------------------------------------------------------------------------------
    
    gen_matrix_addr: for i in 0 to 63 generate
        matrix_addr(i) <= IEEE_802_11AD_P42_N672_R050_ADDR(i) when code_rate_tb = R050 else 
                          IEEE_802_11AD_P42_N672_R062_ADDR(i) when i < 60 else -1 when code_rate_tb = R062 else
                          IEEE_802_11AD_P42_N672_R075_ADDR(i) when i < 60 else -1 when code_rate_tb = R075 else
                          IEEE_802_11AD_P42_N672_R081_ADDR(i) when i < 48 else -1 when code_rate_tb = R081;
    end generate gen_matrix_addr;


    gen_matrix_shift: for i in 0 to 63 generate
        matrix_shift(i) <= IEEE_802_11AD_P42_N672_R050_SHIFT(i) when code_rate_tb = R050 else 
                           IEEE_802_11AD_P42_N672_R062_SHIFT(i) when i < 60 else -1 when code_rate_tb = R062 else
                           IEEE_802_11AD_P42_N672_R075_SHIFT(i) when i < 60 else -1 when code_rate_tb = R075 else
                           IEEE_802_11AD_P42_N672_R081_SHIFT(i) when i < 48 else -1 when code_rate_tb = R081;
    end generate gen_matrix_shift;

    matrix_length <= IEEE_802_11AD_P42_N672_R050_ADDR'length when code_rate_tb = R050 else
                     IEEE_802_11AD_P42_N672_R062_ADDR'length when code_rate_tb = R062 else
                     IEEE_802_11AD_P42_N672_R075_ADDR'length when code_rate_tb = R075 else
                     IEEE_802_11AD_P42_N672_R081_ADDR'length;

    matrix_rows <= R050_ROWS when code_rate_tb = R050 else
                   R062_ROWS when code_rate_tb = R062 else
                   R075_ROWS when code_rate_tb = R075 else
                   R081_ROWS;

    matrix_max_check_degree <= matrix_length / matrix_rows;



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
    process
    begin
        rst_tb <= '1';
        wait for PERIOD;
        rst_tb <= '0';
        wait;
    end process;


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
                wait for PERIOD / 2 + PERIOD * 4;
                wait for PD;
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
            wait;
            -- wait for PERIOD / 2;
            -- assert false
            -- report "no errors"
            -- severity failure;
        end if;


    end process;


    
    --------------------------------------------------------------------------------------
    -- output verification
    --------------------------------------------------------------------------------------

    
    -- ena_vc
    process
    begin
        wait for PD;
        assert ena_vc_tb = '0'
        report "error ena_vc_tb at time " & time'image(now)
        severity failure;

        wait for PERIOD + PERIOD / 2;
        assert ena_vc_tb = '1'
        report "error ena_vc_tb at time " & time'image(now)
        severity failure;
        
        wait for PERIOD * 2;
        assert ena_vc_tb = '0'
        report "error ena_vc_tb at time " & time'image(now)
        severity failure;

        wait for PERIOD;
        assert ena_vc_tb = '1'
        report "error ena_vc_tb at time " & time'image(now)
        severity failure;
        
        wait for PERIOD * 10;
        assert ena_vc_tb = '1'
        report "error ena_vc_tb at time " & time'image(now)
        severity failure;
        
        wait;

    end process;


    
    -- ena_rp
    process
    begin
        wait for PD;
        assert ena_rp_tb = '0'
        report "error ena_rp_tb at time " & time'image(now)
        severity failure;

        wait for PERIOD + PERIOD / 2;
        assert ena_rp_tb = '1'
        report "error ena_rp_tb at time " & time'image(now)
        severity failure;
        
        wait for PERIOD * 2;
        assert ena_rp_tb = '1'
        report "error ena_rp_tb at time " & time'image(now)
        severity failure;

        wait for PERIOD;
        assert ena_rp_tb = '1'
        report "error ena_rp_tb at time " & time'image(now)
        severity failure;
        
        wait for PERIOD * 10;
        assert ena_rp_tb = '1'
        report "error ena_rp_tb at time " & time'image(now)
        severity failure;

        wait;
    end process;



    
    -- ena_ct
    process
    begin
        wait for PD;
        assert ena_ct_tb = '0'
        report "error ena_ct_tb at time " & time'image(now)
        severity failure;

        wait for PERIOD * 2 + PERIOD / 2;
        assert ena_ct_tb = '1'
        report "error ena_ct_tb at time " & time'image(now)
        severity failure;

        wait for PERIOD;
        assert ena_ct_tb = '1'
        report "error ena_ct_tb at time " & time'image(now)
        severity failure;
        
        wait for PERIOD * 10;
        assert ena_ct_tb = '1'
        report "error ena_ct_tb at time " & time'image(now)
        severity failure;

        wait;
    end process;

    
    -- ena_cf
    process
    begin
        wait for PD;
        assert ena_cf_tb = '0'
        report "error ena_cf_tb at time " & time'image(now)
        severity failure;

        wait for PERIOD * 3 + PERIOD / 2;
        assert ena_cf_tb = '1'
        report "error ena_cf_tb at time " & time'image(now)
        severity failure;

        wait for PERIOD;
        assert ena_cf_tb = '1'
        report "error ena_cf_tb at time " & time'image(now)
        severity failure;
        
        wait for PERIOD * 10;
        assert ena_cf_tb = '1'
        report "error ena_cf_tb at time " & time'image(now)
        severity failure;

        wait;

    end process;



    -- mux_output_app and shift
    process
        variable iter_int: integer range 0 to 10 := 0;
        variable rows: integer range 0 to 8 := 0;
        variable halves: integer range 0 to 2 := 0;
        variable first: boolean := false;
        variable state: integer := 0;
        variable index_addr: integer range 0 to 64 := 0;

        
        
    begin
        while iter_int < 10 loop            -- for all iterations

            while rows < matrix_rows loop   -- for all rows

                while halves < 2 loop

                    -- delays
                    if (first = false) then
                        first := true;
                        wait for PERIOD + PERIOD / 2 + PD;
                    else
                        wait for PERIOD;
                    end if;



                    for i in 0 to CFU_PAR_LEVEL - 1 loop        -- for all row entries

                        if (state mod 2 = 0) then                 -- first half

                            while (matrix_addr(index_addr) = -1) loop
                                index_addr := index_addr + 1;
                            end loop;

                            if (i = matrix_addr(index_addr)) then           --  is valid entry

                                if (state < 2) then                         -- loading codewords
                                    assert mux_output_app_tb(i) = std_logic_vector(to_unsigned(2, mux_output_app_tb(0)'length))
                                    report "output mismatch with mux_output_app_tb(" & integer'image(i) & ") at time = " & time'image(now)
                                    severity failure;

                                else                                        -- cnb full / iterating
                                    assert mux_output_app_tb(i) = std_logic_vector(to_unsigned(0, mux_output_app_tb(0)'length))
                                    report "output mismatch with mux_output_app_tb(" & integer'image(i) & ") at time = " & time'image(now)
                                    severity failure;
                                end if;                 -- end if (state < 2)

                                assert shift_tb(i) = std_logic_vector(to_unsigned(matrix_shift(index_addr), shift_tb(0)'length))
                                report "output mismatch with shift_tb(" & integer'image(i) & ") at time = " & time'image(now)
                                severity failure;

                                index_addr := index_addr + 1;

                            else                                            -- dummy value
                                assert mux_output_app_tb(i) = std_logic_vector(to_unsigned(1, mux_output_app_tb(0)'length))
                                report "output mismatch with mux_output_app_tb(" & integer'image(i) & ") at time = " & time'image(now)
                                severity failure;

                                assert shift_tb(i) = std_logic_vector(to_unsigned(0, shift_tb(0)'length))
                                report "output mismatch with shift_tb(" & integer'image(i) & ") at time = " & time'image(now)
                                severity failure;
                            end if;                             -- end if is valid entry

                        else                                            -- second half

                            if (i + matrix_max_check_degree = matrix_addr(index_addr)) then  -- is valid entry

                                if (state < 2) then                 -- loading codewords
                                    assert mux_output_app_tb(i) = std_logic_vector(to_unsigned(2, mux_output_app_tb(0)'length))
                                    report "output mismatch with mux_output_app_tb(" & integer'image(i) & ") at time = " & time'image(now)
                                    severity failure;
                                else                                -- cnb full / iterating
                                    assert mux_output_app_tb(i) = std_logic_vector(to_unsigned(0, mux_output_app_tb(0)'length))
                                    report "output mismatch with mux_output_app_tb(" & integer'image(i) & ") at time = " & time'image(now)
                                    severity failure;
                                end if;

                                assert shift_tb(i) = std_logic_vector(to_unsigned(matrix_shift(index_addr), shift_tb(0)'length))
                                report "output mismatch with shift_tb(" & integer'image(i) & ") at time = " & time'image(now)
                                severity failure;

                                index_addr := index_addr + 1;

                            else                                    -- dummy values
                                assert mux_output_app_tb(i) = std_logic_vector(to_unsigned(1, mux_output_app_tb(0)'length))
                                report "output mismatch with mux_output_app_tb(" & integer'image(i) & ") at time = " & time'image(now)
                                severity failure;

                                assert shift_tb(i) = std_logic_vector(to_unsigned(0, shift_tb(0)'length))
                                report "output mismatch with shift_tb(" & integer'image(i) & ") at time = " & time'image(now)
                                severity failure;
                            end if;


                        end if;                                 -- end if which half

                    end loop;       -- for loop each element in array


                    state := state + 1;

                    halves := halves + 1;

                end loop;   -- while halves < 2

                halves := 0;
                rows := rows + 1;

            end loop;       -- while rows < matrix_rows

            rows := 0;
            index_addr := 0;
            iter_int := iter_int + 1;

        end loop;       -- while iters < 10

        assert false
        report "no errors"
        severity failure;

    end process;

end architecture circuit;
