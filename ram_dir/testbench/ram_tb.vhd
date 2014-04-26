-- lesson learned:
-- for simulation of testbenches:
-- when a signal that is feed into a flip flop or register toogles/changes at the rising edge of the clk, the value chosen by modelsim is the value that the signal had before toogling/changing
--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: ram_tb.vhd
--! @brief: 
--! @author: Antonio Gutierrez
--! @date: 2014-04-24
--!
--!
--------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.pkg_types.all;
use work.pkg_param.all;
-- use work.pkg_support.all;
-- use work.pkg_types.all;
--------------------------------------------------------
entity ram_tb is
    generic (PERIOD: time := 40 ns;
            PD: time := 3 ns;
            M: integer := 1);
end entity ram_tb;
--------------------------------------------------------
architecture circuit of ram_tb is

    --------------------------------------------------------
    -- dut declaration
    --------------------------------------------------------
    component ram is
        port (
                 clk: in std_logic;
                 wr_address: in std_logic_vector(M-1 downto 0);
                 rd_address: in std_logic_vector(M-1 downto 0);
                 data_in: in t_app_messages;
                 data_out: out t_app_messages);
    end component ram;

    
    --------------------------------------------------------
    -- signal declarations
    --------------------------------------------------------
    signal clk_tb: std_logic := '0';
    signal wr_address_tb: std_logic_vector(M-1 downto 0);
    signal rd_address_tb: std_logic_vector(M-1 downto 0);
    signal data_in_tb: t_app_messages;
    signal data_out_tb: t_app_messages;
    
    --------------------------------------------------------
    -- input files
    --------------------------------------------------------
    file fin: text open read_mode is "input_ram.txt";
    -- file fout: text open read_mode is "output_ram.txt";
    

begin

    
    --------------------------------------------------------------------------------------
    -- dut instantiation
    --------------------------------------------------------------------------------------
    dut: ram port map (
    clk_tb,
    wr_address_tb,
    rd_address_tb,
    data_in_tb,
    data_out_tb
    );


    --------------------------------------------------------------------------------------
    -- stimuli generation
    --------------------------------------------------------------------------------------
    --clk
    clk_tb <= not clk_tb after PERIOD/2;
    

    -- wr_addr
    process
    begin
        wr_address_tb <= std_logic_vector(to_unsigned(0, 1));
        wait for PERIOD;        -- 40 ns
        wr_address_tb <= std_logic_vector(to_unsigned(1, 1));
        wait for PERIOD;        -- 80 ns
        wr_address_tb <= std_logic_vector(to_unsigned(0, 1));
        wait for PERIOD;        -- 120 ns
        wr_address_tb <= std_logic_vector(to_unsigned(1, 1));
        wait;
    end process;
    

    -- data_in
    process
        variable l: line;
        variable value: integer range -512 to 511;
        variable first: integer range 0 to 1 := 0;
        
    begin
        if (not endfile(fin)) then
            if (first = 0) then
                first := 1;
            else
                wait for PERIOD/2;      -- 20/60/100/140
            end if;
            for i in 0 to 7 loop
                readline(fin, l); -- read line
                read(l, value); -- read value
                data_in_tb(i) <= to_signed(value, BW_APP); -- put value to input 
            end loop;
            wait for PERIOD/2;      -- 40/80/120/160 ns
        else
            wait for 60 ns;
            assert false
            report "no errors"
            severity failure;
        end if;
    end process;


    -- rd_addr
    process
    begin
        rd_address_tb <= std_logic_vector(to_unsigned(1, 1));
        wait for PERIOD;        -- 40 ns
        rd_address_tb <= std_logic_vector(to_unsigned(0, 1));
        wait for PERIOD;        -- 80 ns
        rd_address_tb <= std_logic_vector(to_unsigned(1, 1));
        wait for PERIOD;        -- 120 ns
        rd_address_tb <= std_logic_vector(to_unsigned(0, rd_address_tb'length));
        wait for PERIOD;        -- 160 ns
        rd_address_tb <= std_logic_vector(to_unsigned(1, rd_address_tb'length));
        wait;
    end process;

    
    --------------------------------------------------------------------------------------
    -- output comparison
    --------------------------------------------------------------------------------------



end architecture circuit;

