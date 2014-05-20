library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------
entity ff_clock_gating is
--generic declarations
    port (
        input: in natural range 0 to 10;
        clk: in std_logic;
        ena: in std_logic;
        output: out natural range 0 to 10);
end entity ff_clock_gating;
--------------------------------------------------------
architecture circuit of ff_clock_gating is

begin
    process (clk)
    begin
        if (clk'event and clk = '1') then
            if (ena = '1') then
                output <= input;
            end if;
        end if;
    end process;

end architecture circuit;


