--------------------------------------------------------
--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: permutation_network_tb.vhd
--! @brief: permutation network design file
--! @author: Antonio Gutierrez
--! @date: 2014-05-01
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
use work.pkg_param_derived.all;
--------------------------------------------------------
entity permutation_network is
    port (
        input: in t_app_messages;
        -- shift: in t_shift_perm_net;
        shift: in std_logic_vector(BW_SHIFT_VEC - 1 downto 0);
        output: out t_app_messages);
end entity permutation_network;
--------------------------------------------------------
architecture circuit of permutation_network is
    signal shift_int: integer range 0 to SUBMAT_SIZE - 1;
begin
    shift_int <= to_integer(unsigned(shift));
    output <= input when shift_int = 0 else 
              input(shift_int - 1 downto 0) & input(input'high downto shift_int);
              -- input(input'high - shift_int downto 0) & input(input'high downto input'high - shift_int + 1); 
end architecture circuit;
--------------------------------------------------------


