--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: demux1_2.vhd
--! @brief: demux 1-to-2 used for selecting between shifiting info or normal cnb output
--! @author: Antonio Gutierrez
--! @date: 2014-08-08
--!
--!
--------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_support.all;
use work.pkg_types.all;
use work.pkg_param.all;
--------------------------------------------------------
entity demux1_2 is
--generic declarations
    port (
        input: in t_app_messages;
        sel: in std_logic;
        output0: out t_app_messages;
        output1: out t_app_messages);
end entity demux1_2;
--------------------------------------------------------
architecture circuit of demux1_2 is
    signal zero: t_app_messages := (others => (others => '0'));
    
begin
    output0 <= input when sel = '0' else zero;
    output1 <= input when sel = '1' else zero;
end architecture circuit;
--------------------------------------------------------
