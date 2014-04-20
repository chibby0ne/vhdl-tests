--!
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file   pkg_types.vhd
--! @brief  Package holding global types
--! @author Philipp Schläfer
--! @date   2013/02/02
--!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_param.all;

package pkg_types is

	-- Check node types
	---------------------

	-- Array of data in/outputs of a check node
    -- type t_cn_message is array (CFU_PAR_LEVEL - 1 downto 0) of std_logic_vector(BW_EXTR - 1 downto 0);
	type t_cn_message is array (CFU_PAR_LEVEL - 1 downto 0) of signed(BW_EXTR - 1 downto 0);
	
end pkg_types;
