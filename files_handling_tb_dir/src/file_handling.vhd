--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: file_handling.vhd
--! @brief: file_handling vhd
--! @author: Antonio Gutierrez
--! @date: 2014-04-16
--!
--!
--------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_types.all;
--------------------------------------

--------------------------------------
entity file_handling is
--generic declarations
    port (
        clk: in std_logic;
        rst: in std_logic;
        input: in t_cn_message;
        output: out t_cn_message);
end entity file_handling;
--------------------------------------

--------------------------------------
architecture circuit of file_handling is

begin
    gen1: for i in input'range generate
        output(i) <= input(i) when rst = '0' else (others => '0');
    end generate gen1;

    -- process (rst, clk)
    --     --declarativepart
    -- begin
    --     if (rst = '1') then
    --         for i in input'range loop
    --             output(i) <= (others => '0');
    --         end loop;
    --     elsif (clk'event and clk = '1') then
    --         for i in input'range loop
    --             output(i) <= input(i);
    --         end loop;
    --     end if;
    -- end process;
end architecture circuit;

