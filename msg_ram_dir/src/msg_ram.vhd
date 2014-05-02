-- questions to phillip:
-- which design units should have their IOs as std_logic(vector)? 
-- i.e should only the top level design unit have std_logic? should every design unit?
--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: msg_ram.vhd
--! @brief: msg_ram implementation
--! @author: Antonio Gutierrez
--! @date: 2014-04-23
--!
--!
--------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_param_derived.all;
use work.pkg_param.all;
use work.pkg_types.all;

--------------------------------------------------------
entity msg_ram is
    port (
        clk: in std_logic;
        wr_address: in std_logic_vector(BW_MSG_RAM - 1 downto 0);
        rd_address: in std_logic_vector(BW_MSG_RAM - 1 downto 0);
        data_in: in t_cn_message;
        data_out: out t_cn_message);
end entity msg_ram;
--------------------------------------------------------
architecture circuit of msg_ram is

    -- signal declarations
    type memory is array (0 to MSG_RAM_DEPTH - 1) of t_cn_message;    -- 16 max num of layers
    signal myram: memory := (
    others => (others => (others => '0')));

    signal wr_address_int: integer range 0 to 2**BW_MSG_RAM - 1;
    signal rd_address_int: integer range 0 to 2**BW_MSG_RAM - 1;

begin

    
    
    --------------------------------------------------------------------------------------
    -- typecast entity signals
    --------------------------------------------------------------------------------------
    wr_address_int <= to_integer(unsigned(wr_address));
    rd_address_int <= to_integer(unsigned(rd_address));


    --------------------------------------------------------------------------------------
    -- registered input and output
    --------------------------------------------------------------------------------------
    process (clk)
    begin
        if (clk'event and clk = '1') then
            myram(wr_address_int) <= data_in;
        end if;
    end process;
    data_out <= myram(rd_address_int);

end architecture circuit;
