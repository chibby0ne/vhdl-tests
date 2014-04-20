--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------
entity clocks is
--generic declarations
    port (
        clk: in std_logic;
        clk_sec: out std_logic);
end entity clocks;
--------------------------------------
architecture circuit of clocks is
    signal clk_temp: std_logic := '0';
begin
    process (clk)
        --declarativepart
    begin
        if (clk'event and clk = '1') then
            clk_temp <= not clk_temp;
        end if;
    end process;
    clk_sec <= clk_temp;
end architecture circuit;
--------------------------------------

