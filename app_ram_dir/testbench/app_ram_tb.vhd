-- lesson learned:
-- for variables in processes:
-- variables in processes are initialized only once, i.e the first time the process is run, afterwards they use the value they stored in the last process run
-- for simulation of testbenches:
-- when a signal that is feed into a flip flop or register toogles/changes at the rising edge of the clk, the value chosen by modelsim is the value that the signal had before toogling/changing
-- all simulation processes should have a wait statement otherwise modelsim hangs!, except of course the process that stops the simulation (commonly the output verification process, as it has an assert and report failure)
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
--------------------------------------------------------
entity app_ram_tb is
    generic (PERIOD: time := 40 ns;
            PD: time := 3 ns;
            M: integer := 1);
end entity app_ram_tb;
--------------------------------------------------------
architecture circuit of app_ram_tb is

    --------------------------------------------------------
    -- dut declaration
    --------------------------------------------------------
    component app_ram is
        port (
                 clk: in std_logic;
                 we: in std_logic;
                 -- wr_address: in std_logic_vector(M-1 downto 0);
                 -- rd_address: in std_logic_vector(M-1 downto 0);

                 wr_address: in std_logic;
                 rd_address: in std_logic;
                 data_in: in t_app_messages;
                 data_out: out t_app_messages);
    end component app_ram;

    
    --------------------------------------------------------
    -- signal declarations
    --------------------------------------------------------
    signal clk_tb: std_logic := '0';
    signal we_tb: std_logic := '0';
    -- signal wr_address_tb: std_logic_vector(M-1 downto 0);
    -- signal rd_address_tb: std_logic_vector(M-1 downto 0);
    signal wr_address_tb: std_logic;
    signal rd_address_tb: std_logic;
    signal data_in_tb: t_app_messages;
    signal data_out_tb: t_app_messages;
    
    --------------------------------------------------------
    -- input files
    --------------------------------------------------------
    file fin: text open read_mode is "input_ram.txt";
    file fout: text open read_mode is "output_ram.txt";
    

begin

    
    --------------------------------------------------------------------------------------
    -- dut instantiation
    --------------------------------------------------------------------------------------
    dut: app_ram port map (
    clk_tb,
    we_tb,
    wr_address_tb,
    rd_address_tb,
    data_in_tb,
    data_out_tb
    );


    --------------------------------------------------------------------------------------
    -- stimuli generation
    --------------------------------------------------------------------------------------
    -- clk
    clk_tb <= not clk_tb after PERIOD/2;


    -- we 
    process
    begin
        we_tb <= '0';
        wait for PERIOD + PERIOD/2  + PD;  -- 63 ns         -- two first rising edge anothing is written
        we_tb <= '1';
        wait;
    end process;
    

    -- wr_addr
    process
    begin
        -- wr_address_tb <= std_logic_vector(to_unsigned(0, 1));
        -- wait for PERIOD/2 + PD;         -- 23 ns
        -- wr_address_tb <= std_logic_vector(to_unsigned(1, 1));
        -- wait for PERIOD;                -- 63 ns
        -- wr_address_tb <= std_logic_vector(to_unsigned(0, 1));
        -- wait for PERIOD;                -- 103 ns
        -- wr_address_tb <= std_logic_vector(to_unsigned(1, 1));
        
        wr_address_tb <= '0';
        wait for PERIOD/2 + PD;         -- 23 ns
        wr_address_tb <= '1';
        wait for PERIOD;                -- 63 ns
        wr_address_tb <= '0';
        wait for PERIOD;                -- 103 ns
        wr_address_tb <= '1';
        wait;
    end process;
    

    -- data_in
    process
        variable l: line;
        variable value: integer range -512 to 511;
        variable first: integer range 0 to 1 := 0;
    begin
        if (not endfile(fin)) then
            for i in 0 to SUBMAT_SIZE-1 loop
                readline(fin, l); -- read line
                read(l, value); -- read value
                data_in_tb(i) <= to_signed(value, BW_APP); -- put value to input 
            end loop;
            if (first = 0) then
                wait for PERIOD/2 + PD;      -- 23 ns
                first := 1;
            else
                wait for PERIOD;      -- 63/103 ns
            end if;
        else
            wait;
            -- assert false
            -- report "no errors"
            -- severity failure;
        end if;
    end process;


    -- rd_addr
    process
    begin
        -- rd_address_tb <= std_logic_vector(to_unsigned(1, 1));
        -- wait for PERIOD/2 + PD;        -- 23 ns
        -- rd_address_tb <= std_logic_vector(to_unsigned(0, 1));
        -- wait for PERIOD;        -- 63 ns
        -- rd_address_tb <= std_logic_vector(to_unsigned(1, 1));
        -- wait for PERIOD;        -- 103 ns
        -- rd_address_tb <= std_logic_vector(to_unsigned(0, rd_address_tb'length));
        -- wait for PERIOD;        -- 143 ns
        -- rd_address_tb <= std_logic_vector(to_unsigned(1, rd_address_tb'length));

        rd_address_tb <= '1';
        wait for PERIOD/2 + PD;        -- 23 ns
        rd_address_tb <= '0'; 
        wait for PERIOD;        -- 63 ns
        rd_address_tb <= '1';
        wait for PERIOD;        -- 103 ns
        rd_address_tb <= '0'; 
        wait for PERIOD;        -- 143 ns
        rd_address_tb <= '1';


        wait;
    end process;

    
    --------------------------------------------------------------------------------------
    -- output comparison
    --------------------------------------------------------------------------------------
    process
        variable l: line;
        variable value: integer range -512 to 511; 
        variable first: integer range 0 to 1 := 0;

    begin
        if (not endfile(fout)) then
            if (first = 0) then
                first := 1;
                wait for PERIOD/2 + PD;
                wait for PD;
            else
                wait for PERIOD;
            end if;
            for i in 0 to SUBMAT_SIZE-1 loop
                readline(fout, l);
                read(l, value);
                assert data_out_tb(i) <= to_signed(value, BW_APP)
                report "output mismatch"
                severity failure;
            end loop;
        else
            wait for 40 ns; -- 186 ns
            assert false
            report "no errors"
            severity failure;
        end if;
    end process;

end architecture circuit;

