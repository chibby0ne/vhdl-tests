--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: ff.vhd
--! @brief: Flip Flop
--! @author: Antonio Gutierrez
--! @date: 2014-09-01
--!
--!
--------------------------------------------------------
library ieee;
library work;
library unisim;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use unisim.vcomponents.all;
--------------------------------------------------------
entity ff is
    port (
        rst: in std_logic;
        clk: in std_logic;
        ena: in std_logic;
        input: in std_logic;
        output: out std_logic);
end entity ff;
--------------------------------------------------------
architecture circuit of ff is
    signal gclk: std_logic := '0';

    attribute buffer_type: string;
    attribute buffer_type of gclk: signal is "bufg";

    attribute clock_signal: string;
    attribute clock_signal of gclk: signal is "yes";

begin

    lut2_ins: lut2
    generic map (init => x"8")
    port map (
            i0 => clk,
        i1 => ena,
        o => gclk
    );

    process (rst, gclk)
    begin
        if (rst = '1') then
            output <= '0';
        elsif (gclk'event and gclk = '1') then
            output <= input;
        end if;
    end process;

end architecture circuit;
--------------------------------------------------------

