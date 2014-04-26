--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: ram.vhd
--! @brief: ram implementation
--! @author: Antonio Gutierrez
--! @date: 2014-04-23
--!
--!
--------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_types.all;

--------------------------------------------------------
entity ram is
    generic (M: integer := 1);
    port (
        clk: in std_logic;
        wr_address: in std_logic_vector(M-1 downto 0);
        rd_address: in std_logic_vector(M-1 downto 0);
        data_in: in t_app_messages;
        data_out: out t_app_messages);
end entity ram;
--------------------------------------------------------
architecture circuit of ram is

    -- signal declarations
    type memory is array (0 to 1) of t_app_messages;
    signal myram: memory := (
    others => (others => (others => '0')));

    signal wr_address_int: integer range 0 to 1;
    signal rd_address_int: integer range 0 to 1;

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
