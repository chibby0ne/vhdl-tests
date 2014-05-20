--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: cnd.vhd
--! @brief: 
--! @author: Antonio Gutierrez
--! @date: 2014-04-30
--!
--!
--------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_support.all;
use work.pkg_param_derived.all;
use work.pkg_types.all;
--------------------------------------------------------
entity cnb is
    port (
             clk: in std_logic;
             we: in std_logic;
             code_rate: in t_code_rate;
             wr_address: in std_logic_vector(BW_MSG_RAM-1 downto 0);
             rd_address: in std_logic_vector(BW_MSG_RAM-1 downto 0);
             data_in: in t_cn_message;
             data_out: out t_cn_message);
end entity cnb;
--------------------------------------------------------
architecture circuit of cnb is
-- declaration 
    component msg_ram is
        port (
                 clk: in std_logic;
                 we: in std_logic;
                 wr_address: in std_logic_vector(BW_MSG_RAM-1 downto 0);
                 rd_address: in std_logic_vector(BW_MSG_RAM-1 downto 0);
                 data_in: in t_cn_message;
                 data_out: out t_cn_message);

    end component msg_ram;

    signal depth: natural range 0 to 16;
    
begin
    depth <= 2*8 when code_rate = R050 else 
             2*6 when code_rate = R062 else 
             2*4 when code_rate = R075 else
             2*3;
    
    ram: msg_ram 
    port map (
        clk => clk,
        we => we,
        wr_address => wr_address,
        rd_address => rd_address,
        data_in => data_in,
        data_out => data_out
    );


end architecture circuit;
