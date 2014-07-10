--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: check_node_block_tb.vhd
--! @brief: tb for check node bloc
--! @author: Antonio Gutierrez
--! @date: 2014-04-23
--!
--!
--------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.pkg_support.all;
use work.pkg_param.all;
use work.pkg_param_derived.all;
use work.pkg_types.all;
--------------------------------------------------------
entity check_node_block_tb is
    generic (PERIOD: time := 40 ns;
            PD: time := 3 ns);
end entity check_node_block_tb;
--------------------------------------------------------
architecture circuit of check_node_block_tb is
    
    
    --------------------------------------------------------------------------------------
    -- dut declaration
    --------------------------------------------------------------------------------------
    component check_node_block is
    port (

    -- inputs
        rst: in std_logic;
        clk: in std_logic;
        split: in std_logic;
        ena_rp: in std_logic;
        ena_ct: in std_logic;
        ena_cf: in std_logic;
        iter: in t_iter;
        addr_msg_ram_read: in t_msg_ram_addr;
        addr_msg_ram_write: in t_msg_ram_addr;
        app_in: in t_cnb_message_tc;   -- input type has to be of CFU_PAR_LEVEL because that's the number of edges that CFU handle
        
    -- outputs
        app_out: out t_cnb_message_tc;  -- output type should be the same as input
        check_node_parity_out: out std_logic
    );

    end component check_node_block;

    
    --------------------------------------------------------------------------------------
    -- signals declaration
    --------------------------------------------------------------------------------------
    signal rst_tb: std_logic := '0';
    signal clk_tb: std_logic := '0';
    signal split_tb: std_logic := '0';
    signal ena_rp_tb: std_logic := '0';
    signal ena_ct_tb: std_logic := '0';
    signal ena_cf_tb: std_logic := '0';
    signal iter_tb: t_iter := (others => '0');
    signal addr_msg_ram_read_tb: t_msg_ram_addr;
    signal addr_msg_ram_write_tb: t_msg_ram_addr;
    signal app_in_tb: t_cnb_message_tc;
    signal app_out_tb: t_cnb_message_tc;
    signal check_node_parity_out_tb: std_logic := '0';
    
    file fin: text open read_mode is "input_app.txt";       -- used for entering app_in
    file fout: text open read_mode is "output_app.txt";     -- used for comparing app_out
    
    
    


begin
    
    
    --------------------------------------------------------------------------------------
    -- dut instantiation
    --------------------------------------------------------------------------------------
    dut: check_node_block port map (
        rst => rst_tb,
        clk => clk_tb,
        split => split_tb,
        iter => iter_tb,
        ena_rp => ena_rp_tb,
        ena_ct => ena_ct_tb,
        ena_cf => ena_cf_tb,
        addr_msg_ram_read => addr_msg_ram_read_tb,
        addr_msg_ram_write => addr_msg_ram_write_tb,
        app_in => app_in_tb,
        app_out => app_out_tb,
        check_node_parity_out => check_node_parity_out_tb
    );

    
    --------------------------------------------------------------------------------------
    -- stimuli generation
    --------------------------------------------------------------------------------------
    -- rst
    rst_tb <= '0';

    -- clk
    clk_tb <= not clk_tb after PERIOD / 2;
    
    --split
    split_tb <= '0';

    
    -- ena_rp
    process
    begin
        ena_rp_tb <= '1';
        wait;
    end process;

    -- ena_ct
    process
    begin
        wait for PERIOD / 2;
        ena_ct_tb <= '1';
        wait;
    end process;


    -- ena_cf
    process
         --declarative part
    begin
        wait for PERIOD / 2 + PERIOD;
        ena_cf_tb <= '1';
        wait;
    end process;

    -- iter
    iter_tb <= (others => '0');

    -- addr_msg_ram_read
    process
    begin
        addr_msg_ram_read_tb <= std_logic_vector(to_unsigned(0, BW_MSG_RAM));
        -- wait for PD;
        wait for PERIOD / 2;
        addr_msg_ram_read_tb <= std_logic_vector(to_unsigned(1, BW_MSG_RAM));
        wait for PERIOD;
        addr_msg_ram_read_tb <= std_logic_vector(to_unsigned(2, BW_MSG_RAM));
        wait for PERIOD;
        addr_msg_ram_read_tb <= std_logic_vector(to_unsigned(3, BW_MSG_RAM));
        wait for PERIOD;
        addr_msg_ram_read_tb <= std_logic_vector(to_unsigned(4, BW_MSG_RAM));
        wait for PERIOD;
        addr_msg_ram_read_tb <= std_logic_vector(to_unsigned(5, BW_MSG_RAM));
        wait for PERIOD;
        addr_msg_ram_read_tb <= std_logic_vector(to_unsigned(6, BW_MSG_RAM));
        wait for PERIOD;
        addr_msg_ram_read_tb <= std_logic_vector(to_unsigned(7, BW_MSG_RAM));
        wait;
    end process;

    -- addr_msg_ram_write
    process
    begin
        wait for PERIOD/ 2;
        wait for 2 * PERIOD;
        addr_msg_ram_write_tb <= std_logic_vector(to_unsigned(0, BW_MSG_RAM));
        wait for PERIOD;
        addr_msg_ram_write_tb <= std_logic_vector(to_unsigned(1, BW_MSG_RAM));
        wait for PERIOD;
        addr_msg_ram_write_tb <= std_logic_vector(to_unsigned(2, BW_MSG_RAM));
        wait for PERIOD;
        addr_msg_ram_write_tb <= std_logic_vector(to_unsigned(3, BW_MSG_RAM));
        wait for PERIOD;
        addr_msg_ram_write_tb <= std_logic_vector(to_unsigned(4, BW_MSG_RAM));
        wait;
    end process;
    
    -- app_in
    process
        variable l: line;
        variable value: integer range -256 to 255;
        variable first: integer range 0 to 1 := 0;
    begin
        if (not endfile(fin)) then
            for i in 0 to CFU_PAR_LEVEL - 1 loop
                readline(fin, l);
                read(l, value);
                app_in_tb(i) <= to_signed(value, BW_APP);
            end loop;
            if (first = 0) then
                first := 1;
                wait for PD;                -- 3 
                wait for PERIOD / 2;            -- 23
            else
                wait for PERIOD;            -- 63, 103, 143, 143
            end if;
        else
            wait;
        end if;
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
                first := 1;
                wait for PD;                -- 3
                wait for PERIOD / 2;        -- 23
                wait for 2 * PERIOD;        -- 103
            end if;
            for i in 0 to CFU_PAR_LEVEL - 1 loop
                readline(fout, l);
                read(l, value);
                assert (app_out_tb(i) = to_signed(value, BW_APP))
                report "output is " & integer'image(to_integer(app_out_tb(i))) & " and should be " & integer'image(value) & ". Output mismatch at time " & time'image(NOW)
                severity failure;
            end loop;
            wait for PERIOD;            -- 143, 183, 223, 243 
        else
            assert false
            report "no errors!"
            severity failure;
        end if;
    end process;

end architecture circuit;

