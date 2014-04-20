--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: ff_delay.vhd
--! @brief: ff delay
--! @author: Antonio Gutierrez
--! @date: 2014-04-13
--!
--!
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------

--------------------------------------
entity ff_delay is
    generic (N: integer := 5;
            REG_INPUT: boolean := true);
    port (
        clk: in std_logic;
        input: in std_logic_vector(N-1 downto 0);
        output: out std_logic_vector(N-1 downto 0));
end entity ff_delay;
--------------------------------------

--------------------------------------
architecture circuit of ff_delay is
    signal input_reg: std_logic_vector(N-1 downto 0);
    signal input_real: std_logic_vector(N-1 downto 0);
    
begin
    gen_no_reg_input: if REG_INPUT = false generate
        input_real <= input;
    end generate gen_no_reg_input;

    gen_reg_input: if REG_INPUT = true generate
        input_real <= input_reg;

        process (clk)
        begin
            if (clk'event and clk = '1') then
                input_reg <= input;
            end if;
        end process;

    end generate gen_reg_input;

    output <= input_real;

end architecture circuit;
--------------------------------------
architecture circuit2 of ff_delay is
--signals and declarations
begin
    process (clk)
        --declarativepart
    begin
        if (clk'event and clk = '1') then
            output <= input;
        end if;
    end process;
end architecture circuit2;
--------------------------------------

