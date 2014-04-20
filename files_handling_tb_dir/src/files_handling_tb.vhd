

--
-- tb for reading and writing from/to files
--

--------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.pkg_types.all;
use work.pkg_param.all;
--------------------------------------

--------------------------------------
entity file_handling_tb is
    generic (DELAY_TP: time := 3 ns);
end entity file_handling_tb;
--------------------------------------

--------------------------------------
architecture circuit of file_handling_tb is
    
    -- dut declaration
    component file_handling is
        -- generic(const_name const_type = const_value)
        port (
                 clk: in std_logic;
                 rst: in std_logic;
                 input: in t_cn_message;
                 output: out t_cn_message);
    end component file_handling;
    
    -- signal declarations
    signal clk_tb: std_logic := '0';
    signal rst_tb: std_logic := '1';
    signal input_tb: t_cn_message;
    signal output_tb: t_cn_message;
    file f: text open read_mode is "input_cn.txt";
    file f_comp: text open read_mode is "input_cn_copy.txt";
    
    signal first: std_logic := '0';
    
    
begin

    -- dut instantiation
    dut: file_handling port map (
        clk_tb,
        rst_tb,
        input_tb,
        output_tb
    );

    --
    -- stimuli generation
    --
    clk_tb <= not clk_tb after 20 ns;
    

    
    -- rst
    rst_tb <= '0' after 40 ns;

    
    -- input_tb
    process
        variable l: line;
        variable input_val: integer range -32 to 31;
        variable index_input: natural range 0 to 8;
        variable i: natural := 0;
        variable j: natural := 0;
    begin
        if (not endfile(f)) then
            -- report "reading from the input file";
            i := 0;
            while (i < CFU_PAR_LEVEL) loop
                readline(f, l);  --fourth (this one has data)
                read(l, index_input);
                read(l, input_val);
                -- report natural'image(index_input) & ' ' & integer'image(input_val);

                input_tb(index_input) <= to_signed(input_val, BW_EXTR);

                i := i + 1;
            end loop;

            wait for 20 ns;
            if (first = '0') then
                wait for DELAY_TP;
                first <= '1';
            end if;

            -- report "reading from the output file";
            j := 0;
            while (j < CFU_PAR_LEVEL) loop
                readline(f_comp, l);
                read(l, index_input);
                read(l, input_val);

                -- report natural'image(index_input) & ' ' & integer'image(input_val);

                assert (output_tb(index_input) = input_val)
                report "output mismatch!"
                severity failure;

                j := j + 1;
            end loop;

            wait for 20 ns;
        else
            assert false
            report "no errors"
            severity failure;
            wait;
        end if;
    end process;




end architecture circuit;


