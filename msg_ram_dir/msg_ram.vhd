--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: msg_ram.vhd
--! @brief: 
--! @author: Antonio Gutierrez
--! @date: 2014-04-25
--!
--!
--------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_support.all;
use work.pkg_types.all;
--------------------------------------------------------
entity msg_ram is
--generic declarations
    port (
        clk: in std_logic;
        wr_addr: in std_logic_vector(M-1 downto 0);
        rd_addr: in std_logic_vector(M-1 downto 0);
        new_msg: in t_messages;
        old_msg: out t_messages);
end entity msg_ram;
--------------------------------------------------------
architecture circuit of msg_ram is
    
    -- ram type
    type message_ram is array () of t_cn_message;
    signal myram: std_logic := '0';
    
begin
    --architecture_statements_part
end architecture circuit;

