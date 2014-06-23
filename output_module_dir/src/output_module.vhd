--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: output_module.vhd
--! @brief: output module used for ordering the output of app information into row order
--! @author: Antonio Gutierrez
--! @date: 2014-06-23
--!
--!
--------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_ieee_802_11ad_matrix.all;
use work.pkg_param.all;
use work.pkg_types.all;
--------------------------------------------------------
entity output_module is
--generic declarations
    port (
        clk: in std_logic;
        valid: in std_logic;
        code_rate: in t_code_rate;
        input: in t_message_app_half_codeword;
        output: out t_message_app_full_codeword);
end entity output_module;
--------------------------------------------------------
architecture circuit of output_module is
    type t_output_vector is array (1 downto 0) of t_message_app_half_codeword;
    signal shift: t_array16;
    
begin

    
    --------------------------------------------------------------------------------------
    -- combinational part
    -- select shifting info depending on coder ate selected
    --------------------------------------------------------------------------------------

    shift <= IEEE_802_11AD_P42_N672_R050_SHIFTING_INFO when code_rate = R050 else 
             IEEE_802_11AD_P42_N672_R062_SHIFTING_INFO when code_rate = R062 else
             IEEE_802_11AD_P42_N672_R075_SHIFTING_INFO when code_rate = R075 else 
             IEEE_802_11AD_P42_N672_R081_SHIFTING_INFO;  


    
    --------------------------------------------------------------------------------------
    -- sequential part:
    -- storing both halves and arranging output vector according to shifting info
    --------------------------------------------------------------------------------------

    process (clk, rst)
        variable count: integer range 0 to 1 := 0;
        variable val: integer range 0 to SUBMAT_SIZE - 1 := 0;      
        variable base: integer range 0 to MAX_CHV - 1 := 0;         -- vng group
        variable input_reg: t_output_vector;
        variable input_whole: t_message_app_full_codeword;
        
    begin
        if (rst = '1') then
            output <= (others => (others => '0'));
        elsif (clk'event and clk = '1') then
            if (valid = '1') then
                if (count = 0) then
                    input_reg(0) := input;
                    count := count + 1;
                else
                    input_reg(1) := input;
                    count := 0;

                    input_whole((CFU_PAR_LEVEL * 2) - 1 downto CFU_PAR_LEVEL) := input_reg(1);
                    input_whole(CFU_PAR_LEVEL - 1 downto 0) := input_reg(0);

                    for i in 1 to 2 loop                                -- for each half
                        for j in 0 to CFU_PAR_LEVEL - 1 loop            -- for all the apps
                            for k in 0 to SUBMAT_SIZE - 1 loop          -- for each bit of the apps
                                base := i * j;
                                val := (shift(base) + k) mod SUBMAT_SIZE;    -- which of the bits in that submatrix corresponds to the first of that app
                                -- base := i * j * SUBMAT_SIZE;            
                                output(base)(k) <= input_whole(base)(val);
                                end loop;
                            end loop;
                    end loop;

                end if;
            end if;
        end if;
    end process;


end architecture circuit;

