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
            PD: time := 3 ns;
            CYCLES_PER_ROW : natural := 4);
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
        finish_iter: out std_logic;
        iter: out t_iter;
        app_rd_addr: out std_logic;
        app_wr_addr: out std_logic;
        msg_rd_addr: out t_msg_ram_addr;
        msg_wr_addr: out t_msg_ram_addr;
        shift: out t_shift_contr;
        mux_input_halves: out std_logic;           -- mux choosing input codeword halves
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
    signal finish_iter_tb: std_logic := '0';
    signal iter_tb: t_iter; 
    signal app_rd_addr_tb: std_logic;
    signal app_wr_addr_tb: std_logic;
    signal msg_rd_addr_tb: t_msg_ram_addr;
    signal msg_wr_addr_tb: t_msg_ram_addr;
    signal shift_tb: t_shift_contr;

    signal mux_input_halves_tb: std_logic;           -- mux choosing input codeword halves
    signal mux_output_app_tb: t_mux_out_app;
    
    file fin: text open read_mode is "input_controller.txt";
    file fin_valid: text open read_mode is "input_controller_valid.txt";
    -- file fout: text open read_mode is "output_controller.txt";
   

    -- signals used for determining matrices and its properties
    signal matrix_addr: t_array64 := (others => 0);      
    signal matrix_offset: t_array64 := (others => 0);
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


    gen_matrix_offset: for i in 0 to 63 generate
        matrix_offset(i) <= IEEE_802_11AD_P42_N672_R050_OFFSET(i) when code_rate_tb = R050 else 
                            IEEE_802_11AD_P42_N672_R062_OFFSET(i) when i < 60 else -1 when code_rate_tb = R062 else
                            IEEE_802_11AD_P42_N672_R075_OFFSET(i) when i < 60 else -1 when code_rate_tb = R075 else
                            IEEE_802_11AD_P42_N672_R081_OFFSET(i) when i < 48 else -1 when code_rate_tb = R081;
    end generate gen_matrix_offset;

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
        finish_iter => finish_iter_tb,
        iter => iter_tb,
        app_rd_addr => app_rd_addr_tb,
        app_wr_addr => app_wr_addr_tb,
        msg_rd_addr => msg_rd_addr_tb,
        msg_wr_addr => msg_wr_addr_tb,
        shift => shift_tb,
        mux_input_halves => mux_input_halves_tb,
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
        wait for PERIOD / 2;
        rst_tb <= '0';
        wait;
    end process;


    -- code rate
    code_rate_tb <= R050;
    

    -- parity_out (could use an input)
    -- process
    --     variable l: line;
    --     variable val: integer range 0 to 42 := 0;
    --     variable first: boolean := false;
    --
    -- begin
    --     if (not endfile(fin)) then
    --         if (first = false) then
    --             first := true;
    --             wait for PERIOD / 2 + PERIOD * 4;
    --         else
    --             wait for PERIOD;
    --         end if;
    --         for i in 0 to SUBMAT_SIZE - 1 loop
    --             readline(fin, l);
    --             read(l, val);
    --             if (val = 1) then
    --                 parity_out_tb(i) <= '1';
    --             else
    --                 parity_out_tb(i) <= '0';
    --             end if;
    --         end loop;
    --     else
    --         wait;
    --     end if;
    -- end process;

    -- process
    --     variable l: line;
    --     variable val: integer range 0 to 42 := 0;
    --     variable first: boolean := false;
    --
    -- begin
    --     if (not endfile(fin_valid)) then
    --         if (first = false) then
    --             first := true;
    --             wait for PERIOD / 2 - PD;
    --             -- wait for PERIOD * 145;
    --             wait for PERIOD * 4;
    --         else
    --             wait for PERIOD;
    --         end if;
    --         for i in 0 to SUBMAT_SIZE - 1 loop
    --             readline(fin_valid, l);
    --             read(l, val);
    --             if (val = 1) then
    --                 parity_out_tb(i) <= '1';
    --             else
    --                 parity_out_tb(i) <= '0';
    --             end if;
    --         end loop;
    --     else
    --         wait;
    --     end if;
    -- end process;


    --------------------------------------------------------------------------------------
    -- output verification
    --------------------------------------------------------------------------------------

    
    -- -- ena_vc
    process
    begin
        wait for PD;                                        -- reset (0 to PERIOD / 2)
        wait for PERIOD / 2;
        assert ena_vc_tb = '0'
        report "ena_vc_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_vc_tb))))
        severity failure;


        wait for PERIOD;                                    -- FIRST (PERIOD + PERIOD / 2 to PERIOD * 2 + PERIOD / 2)
        assert ena_vc_tb = '0'
        report "ena_vc_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_vc_tb))))
        severity failure;

        wait for PERIOD;                                    -- SECOND
        assert ena_vc_tb = '0'
        report "ena_vc_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_vc_tb))))
        severity failure;

        wait for PERIOD;                                    -- THIRD
        assert ena_vc_tb = '0'
        report "ena_vc_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_vc_tb))))
        severity failure;

        wait for PERIOD;                                   -- FOURTH
        assert ena_vc_tb = '1'
        report "ena_vc_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_vc_tb))))
        severity failure;

        -- for the rest of the iterations

        for i in 0 to MAX_ITER - 3 loop
            for j in 0 to CYCLES_PER_ROW * matrix_rows - 1 loop
                wait for PERIOD;
                if ((j mod 4 = 0) or ((j + 1) mod 4 = 0 and j /= 0)) then
                    assert ena_vc_tb = '1'
                    report "ena_vc_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_vc_tb))))
                    severity failure;
                else
                    assert ena_vc_tb = '0'
                    report "ena_vc_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_vc_tb))))
                    severity failure;
                end if;
            end loop;
        end loop;

        wait;
    end process;



    -- ena_rp
    process
    begin
        wait for PD;                                        -- reset (0 to PERIOD / 2)
        wait for PERIOD / 2;
        assert ena_rp_tb = '0'
        report "ena_rp_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_rp_tb))))
        severity failure;

        wait for PERIOD;                                    -- FIRST (PERIOD + PERIOD / 2 to PERIOD * 2 + PERIOD / 2)
        assert ena_rp_tb = '1'
        report "ena_rp_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_rp_tb))))
        severity failure;

        wait for PERIOD;                                    -- SECOND
        assert ena_rp_tb = '1'
        report "ena_rp_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_rp_tb))))
        severity failure;

        wait for PERIOD;                                    -- THIRD
        assert ena_rp_tb = '0'
        report "ena_rp_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_rp_tb))))
        severity failure;

        wait for PERIOD;                                   -- FOURTH
        assert ena_rp_tb = '0'
        report "ena_rp_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_rp_tb))))
        severity failure;

        -- for the rest of the iterations

        for i in 0 to MAX_ITER - 3 loop
            for j in 0 to CYCLES_PER_ROW * matrix_rows - 1 loop
                wait for PERIOD;
                if ((j mod 4 = 0) or ((j - 1) mod 4 = 0 and j /= 0)) then
                    assert ena_rp_tb = '1'
                    report "ena_rp_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_rp_tb))))
                    severity failure;
                else
                    assert ena_rp_tb = '0'
                    report "ena_rp_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_rp_tb))))
                    severity failure;
                end if;
            end loop;
        end loop;

        wait;


    end process;




    -- ena_ct
    process
    begin
        wait for PD;                                        -- reset (0 to PERIOD / 2)
        wait for PERIOD / 2;
        assert ena_ct_tb = '0'
        report "ena_ct_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_ct_tb))))
        severity failure;

        wait for PERIOD;                                    -- FIRST (PERIOD + PERIOD / 2 to PERIOD * 2 + PERIOD / 2)
        assert ena_ct_tb = '0'
        report "ena_ct_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_ct_tb))))
        severity failure;

        wait for PERIOD;                                    -- SECOND
        assert ena_ct_tb = '1'
        report "ena_ct_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_ct_tb))))
        severity failure;

        wait for PERIOD;                                    -- THIRD
        assert ena_ct_tb = '1'
        report "ena_ct_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_ct_tb))))
        severity failure;

        wait for PERIOD;                                   -- FOURTH
        assert ena_ct_tb = '0'
        report "ena_ct_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_ct_tb))))
        severity failure;

        -- for the rest of the iterations
        for i in 0 to MAX_ITER - 3 loop
            for j in 0 to CYCLES_PER_ROW * matrix_rows - 1 loop
                wait for PERIOD;
                if (((j - 1) mod 4 = 0 and j /= 0) or ((j + 2) mod 4 = 0 and j /= 0)) then
                    assert ena_ct_tb = '1'
                    report "ena_ct_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_ct_tb))))
                    severity failure;
                else
                    assert ena_ct_tb = '0'
                    report "ena_ct_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_ct_tb))))
                    severity failure;
                end if;
            end loop;
        end loop;

        wait;

    end process;


    -- ena_cf
    process
    begin
        wait for PD;                                        -- reset (0 to PERIOD / 2)
        wait for PERIOD / 2;
        assert ena_cf_tb = '0'
        report "ena_cf_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_cf_tb))))
        severity failure;

        wait for PERIOD;                                    -- FIRST (PERIOD + PERIOD / 2 to PERIOD * 2 + PERIOD / 2)
        assert ena_cf_tb = '0'
        report "ena_cf_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_cf_tb))))
        severity failure;

        wait for PERIOD;                                    -- SECOND
        assert ena_cf_tb = '0'
        report "ena_cf_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_cf_tb))))
        severity failure;

        wait for PERIOD;                                    -- THIRD
        assert ena_cf_tb = '1'
        report "ena_cf_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_cf_tb))))
        severity failure;

        wait for PERIOD;                                   -- FOURTH
        assert ena_cf_tb = '1'
        report "ena_cf_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_cf_tb))))
        severity failure;

        -- for the rest of the iterations (almost all iterations)
        for i in 0 to MAX_ITER - 3 loop
            for j in 0 to CYCLES_PER_ROW * matrix_rows - 1 loop
                wait for PERIOD;
                if (((j + 2) mod 4 = 0 and j /= 0) or ((j + 1) mod 4 = 0 and j /= 0)) then
                    assert ena_cf_tb = '1'
                    report "ena_cf_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_cf_tb))))
                    severity failure;
                else
                    assert ena_cf_tb = '0'
                    report "ena_cf_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & ena_cf_tb))))
                    severity failure;
                end if;
            end loop;
        end loop;

        wait;
    end process;


    -- valid output 
    process
    begin
        wait for PD;
        wait for PERIOD / 2;

        assert valid_output_tb = '0'
        report "valid_output should be 0"
        severity failure;

        wait;
    end process;


    -- iter
    process
    begin
        wait for PD;
        wait for PERIOD / 2;

        for i in 0 to MAX_ITER - 1 loop
            for j in 0 to CYCLES_PER_ROW * matrix_rows - 1 loop
                wait for PERIOD;
                assert iter_tb = std_logic_vector(to_unsigned(i, iter_tb'length))
                report "iter should be " & integer'image(i) & " but is " & integer'image(to_integer(unsigned(iter_tb)))
                severity failure;
            end loop;
        end loop;

        wait;

    end process;


    -- process to stop
    process
    begin
        wait for PD;
        wait for PERIOD / 2;

        for i in 0 to MAX_ITER - 2 loop
            for j in 0 to CYCLES_PER_ROW * matrix_rows - 1 loop
                wait for PERIOD;
            end loop;
        end loop;

        wait for PERIOD;        -- FIRST one last time 
        wait for PERIOD;        -- FINISH
        wait for PERIOD;        -- START RESET

        assert false
        report "no errors"
        severity failure;

    end process;


    -- app_rd_addr           ( 1 when SECOND but not the first time, else 0)
    process
    begin
        wait for PD;
        wait for PERIOD / 2;
        assert app_rd_addr_tb = '0'
        report "app_rd_addr_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_rd_addr_tb))))
        severity failure;

        wait for PERIOD;                -- FIRST
        assert app_rd_addr_tb = '0'
        report "app_rd_addr_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_rd_addr_tb))))
        severity failure;

        wait for PERIOD;                -- SECOND
        assert app_rd_addr_tb = '0'
        report "app_rd_addr_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_rd_addr_tb))))
        severity failure;

        wait for PERIOD;                -- THIRD
        assert app_rd_addr_tb = '0'
        report "app_rd_addr_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_rd_addr_tb))))
        severity failure;

        wait for PERIOD;                -- FOURTH
        assert app_rd_addr_tb = '0'
        report "app_rd_addr_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_rd_addr_tb))))
        severity failure;

        for i in 0 to MAX_ITER - 3 loop
            for j in 0 to CYCLES_PER_ROW * matrix_rows - 1 loop
                wait for PERIOD;
                if (j mod 4 = 0) then
                    assert app_rd_addr_tb = '0'
                    report "app_rd_addr_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_rd_addr_tb))))
                    severity failure;
                else
                    assert app_rd_addr_tb = '1'
                    report "app_rd_addr_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_rd_addr_tb))))
                    severity failure;
                end if;
            end loop;
        end loop;

        wait;
    end process;



    -- app_wr_addr          (1 when FIRST but not the first time, else 0)
    process
    begin
        wait for PD;
        wait for PERIOD / 2;
        assert app_wr_addr_tb = '0'
        report "app_wr_addr_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_wr_addr_tb))))
        severity failure;

        wait for PERIOD;                -- FIRST
        assert app_wr_addr_tb = '0'
        report "app_wr_addr_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_wr_addr_tb))))
        severity failure;

        wait for PERIOD;                -- SECOND
        assert app_wr_addr_tb = '0'
        report "app_wr_addr_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_wr_addr_tb))))
        severity failure;

        wait for PERIOD;                -- THIRD
        assert app_wr_addr_tb = '0'
        report "app_wr_addr_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_wr_addr_tb))))
        severity failure;

        wait for PERIOD;                -- FOURTH
        assert app_wr_addr_tb = '0'
        report "app_wr_addr_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_wr_addr_tb))))
        severity failure;

        for i in 0 to MAX_ITER - 3 loop
            for j in 0 to CYCLES_PER_ROW * matrix_rows - 1 loop
                wait for PERIOD;
                if ((j + 1) mod 4 = 0 and j /= 0) then
                    assert app_wr_addr_tb = '0'
                    report "app_wr_addr_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_wr_addr_tb))))
                    severity failure;
                else
                    assert app_wr_addr_tb = '1'
                    report "app_wr_addr_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & app_wr_addr_tb))))
                    severity failure;
                end if;
            end loop;
        end loop;

        wait;
    end process;



    -- msg_rd_addr
    process
    begin
        wait for PD;
        wait for PERIOD / 2;
        assert msg_rd_addr_tb = std_logic_vector(to_unsigned(0, msg_rd_addr_tb'length))
        report "msg_rd_addr should be 0 but is " & integer'image(to_integer(unsigned(msg_rd_addr_tb)))
        severity failure;
        
        for i in 0 to MAX_ITER - 2 loop
            for j in 0 to  matrix_rows - 1 loop
                for k in 0 to CYCLES_PER_ROW - 1 loop
                    wait for PERIOD;
                    if (k = 0) then
                        assert msg_rd_addr_tb = std_logic_vector(to_unsigned(2 * j, msg_rd_addr_tb'length))
                        report "msg_rd_addr should be " & integer'image(2 * j) & " but is " & integer'image(to_integer(unsigned(msg_rd_addr_tb)))
                        severity failure;
                    else
                        assert msg_rd_addr_tb = std_logic_vector(to_unsigned(2 * j + 1, msg_rd_addr_tb'length))
                        report "msg_rd_addr should be " & integer'image(2 * j + 1) &  " but is " & integer'image(to_integer(unsigned(msg_rd_addr_tb)))
                        severity failure;
                    end if;
                end loop;
            end loop;
        end loop;

        report "reached end of msg rd addr comparison"
        severity note;
        wait;

    end process;


    -- msg_wr_addr
    process
    begin
        wait for PD;
        wait for PERIOD / 2;
        assert msg_wr_addr_tb = std_logic_vector(to_unsigned(0, msg_wr_addr_tb'length))
        report "msg_wr_addr should be 0 but is " & integer'image(to_integer(unsigned(msg_wr_addr_tb)))
        severity failure;
        
        for i in 0 to MAX_ITER - 2 loop
            for j in 0 to  matrix_rows - 1 loop
                for k in 0 to CYCLES_PER_ROW - 1 loop
                    wait for PERIOD;
                    if (k = 3) then
                        assert msg_wr_addr_tb = std_logic_vector(to_unsigned(2 * j + 1, msg_wr_addr_tb'length))
                        report "msg_wr_addr should be " & integer'image(2 * j + 1) &  " but is " & integer'image(to_integer(unsigned(msg_wr_addr_tb)))
                        severity failure;
                    else
                        assert msg_wr_addr_tb = std_logic_vector(to_unsigned(2 * j, msg_wr_addr_tb'length))
                        report "msg_wr_addr should be " & integer'image(2 * j) & " but is " & integer'image(to_integer(unsigned(msg_wr_addr_tb)))
                        severity failure;
                    end if;
                end loop;
            end loop;
        end loop;

        wait;

    end process;


    -- mux_input_halves     (I don't need to test it I'm already seeing it in the wave... it doesn't change after going to 1 until there's a new codeword)
    process
    begin
        wait for PD;
        wait for PERIOD / 2;
        assert mux_input_halves_tb = '0'
        report "mux_input_halves_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & mux_input_halves_tb))))
        severity failure;

        wait for PERIOD;                        -- FIRST
        assert mux_input_halves_tb = '0'
        report "mux_input_halves_tb should be 0 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & mux_input_halves_tb))))
        severity failure;

        wait for PERIOD;                        -- SECOND
        assert mux_input_halves_tb = '1'
        report "mux_input_halves_tb should be 1 but is " & integer'image(to_integer(unsigned(std_logic_vector'("" & mux_input_halves_tb))))
        severity failure;

        wait;

    end process;





    -- mux_output_app and shift
    process
        variable vector_addr: integer := 0;
        variable cng_counter: integer := 0;
        variable index_row: integer := 0;
        variable start_pos_next_half: integer := 0;
        
    begin
        wait for PD;
        wait for PERIOD / 2;

        for l in 0 to CFU_PAR_LEVEL - 1 loop
            assert mux_output_app_tb(l) = std_logic_vector(to_unsigned(0, mux_output_app_tb(0)'length))
            report "output mismatch with mux_output_app_tb(" & integer'image(l) & ") should be " & integer'image(0) & "but is " & integer'image(to_integer(unsigned(mux_output_app_tb(l))))
            severity failure;

            assert shift_tb(l) = std_logic_vector(to_unsigned(0, shift_tb(0)'length))
            report "output mismatch with shift_tb(" & integer'image(l) & ") should be " & integer'image(0) & " but is " & integer'image(to_integer(unsigned(shift_tb(l))))
            severity failure;
        end loop;


        for i in 0 to MAX_ITER - 2 loop
            cng_counter := 0;
            for j in 0 to matrix_rows - 1 loop
                for k in 0 to CYCLES_PER_ROW - 1 loop

                    wait for PERIOD;

                    vector_addr := cng_counter * matrix_max_check_degree;

                    if (k = 0) then                                                 -- first state
                        index_row := 0;
                        for l in 0 to CFU_PAR_LEVEL - 1 loop                        -- each one of the edges
                            if (l = matrix_addr(index_row + vector_addr)) then
                                if (now < 5 * PERIOD) then                          -- reading from input
                                    -- MUX_OUTPUT
                                    assert mux_output_app_tb(l) = std_logic_vector(to_unsigned(2, mux_output_app_tb(0)'length))
                                    report "output mismatch with mux_output_app_tb(" & integer'image(l) & ") should be " & integer'image(2) & " but is " & integer'image(to_integer(unsigned(mux_output_app_tb(l))))
                                    severity failure;
                                else                                                -- reading from APP
                                    -- MUX_OUTPUT
                                    assert mux_output_app_tb(l) = std_logic_vector(to_unsigned(0, mux_output_app_tb(0)'length))
                                    report "output mismatch with mux_output_app_tb(" & integer'image(l) & ") should be " & integer'image(0) & " but is " & integer'image(to_integer(unsigned(mux_output_app_tb(l))))
                                    severity failure;
                                end if;                                             -- where comes: APP or Input

                                -- SHIFT
                                assert shift_tb(l) = std_logic_vector(to_unsigned(matrix_offset(index_row + vector_addr), shift_tb(0)'length))
                                report "output mismatch with shift_tb(" & integer'image(l) & ") should be " & integer'image(matrix_offset(index_row + vector_addr)) & " but is " & integer'image(to_integer(unsigned(shift_tb(l))))
                                severity failure;
                                index_row := index_row + 1;

                            else                                                    -- when not a valid edge
                                -- MUX_OUTPUT
                                assert mux_output_app_tb(l) = std_logic_vector(to_unsigned(1, mux_output_app_tb(0)'length))
                                report "output mismatch with mux_output_app_tb(" & integer'image(l) & ") should be " & integer'image(1) & " but is " & integer'image(to_integer(unsigned(mux_output_app_tb(l))))
                                severity failure;


                                -- SHIFT
                                assert shift_tb(l) = std_logic_vector(to_unsigned(0, shift_tb(0)'length))
                                report "output mismatch with shift_tb(" & integer'image(l) & ") should be " & integer'image(0) & " but is " & integer'image(to_integer(unsigned(shift_tb(l))))
                                severity failure;

                            end if;                                                      -- is it valid or not?
                        end loop;                                                        -- check all edges

                        start_pos_next_half := index_row;

                    else                                                                -- second, third and fourth state
                        index_row := start_pos_next_half;
                        for l in 0 to CFU_PAR_LEVEL - 1 loop                            -- for all edges
                            if (index_row < matrix_max_check_degree) then               -- is this still part of the second half of the row
                                if (l + CFU_PAR_LEVEL = matrix_addr(index_row + vector_addr)) then      -- when is valid edge
                                    if (now < 5 * PERIOD) then                          -- reading from input
                                        -- MUX_OUTPUT
                                        assert mux_output_app_tb(l) = std_logic_vector(to_unsigned(2, mux_output_app_tb(0)'length))
                                        report "output mismatch with mux_output_app_tb(" & integer'image(l) & ") should be " & integer'image(2) & " but is " & integer'image(to_integer(unsigned(mux_output_app_tb(l))))
                                        severity failure;

                                    else                                                -- reading from APP
                                        -- MUX_OUTPUT
                                        assert mux_output_app_tb(l) = std_logic_vector(to_unsigned(0, mux_output_app_tb(0)'length))
                                        report "output mismatch with mux_output_app_tb(" & integer'image(l) & ") should be " & integer'image(0) & " but is " & integer'image(to_integer(unsigned(mux_output_app_tb(l))))
                                        severity failure;

                                    end if;                                             -- where comes: APP or Input

                                    -- SHIFT
                                    assert shift_tb(l) = std_logic_vector(to_unsigned(matrix_offset(index_row + vector_addr), shift_tb(0)'length))
                                    report "output mismatch with shift_tb(" & integer'image(l) & ") should be " & integer'image(matrix_offset(index_row + vector_addr)) & " but is " & integer'image(to_integer(unsigned(shift_tb(l))))
                                    severity failure;
                                    index_row := index_row + 1;

                                else                                                    -- when not a valid edge
                                    -- MUX_OUTPUT
                                    assert mux_output_app_tb(l) = std_logic_vector(to_unsigned(1, mux_output_app_tb(0)'length))
                                    report "output mismatch with mux_output_app_tb(" & integer'image(l) & ") should be " & integer'image(1) & " but is " & integer'image(to_integer(unsigned(mux_output_app_tb(l))))
                                    severity failure;


                                    -- SHIFT
                                    assert shift_tb(l) = std_logic_vector(to_unsigned(0, shift_tb(0)'length))
                                    report "output mismatch with shift_tb(" & integer'image(l) & ") should be " & integer'image(0) & " but is " & integer'image(to_integer(unsigned(shift_tb(l))))
                                    severity failure;


                                end if;                                                  -- valid or not?
                            end if;                                                      -- is it still part of the second half of the row?
                        end loop;                                                        -- check all edges
                    end if;                                                              -- which state?

                end loop;       -- cycles_per_row

                cng_counter := cng_counter + 1;
            end loop;           -- matrix_rows

        end loop;               -- max_iter


        report "we have reached the end of the shift"
        severity note;
        wait;


    end process;



end architecture circuit;
