-- Lesson learned:
-- Output verification must be done where there aren't any switching, i.e assert must NOT be done at times where the signal is toggling
-- Signals don't change simply because they're not being constantly assigned, meaning that signals assigned in a process maintain the values they were assigned after exiting the process e.g: one can create a ff without using variables in a process

-- configuration doesn't work as the book states but you can use: for component_label compopent_name use entity work.entity(architecture)
-- where component_label and component_name is the label and name respectively of the component instantiated in the tb and entity and architecture are the names in the design files of that component
--
-- some simple sequential circuits to clarify understanding of signals
--
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------

entity ff_archs is
--generic declarations
    port (
        clk: in std_logic;
        rst: in std_logic;
        d: in std_logic;
        q: out std_logic);
end entity ff_archs;

--------------------------------------
-- architecture just using input signal (like the book)
--------------------------------------

architecture circuit of ff_archs is
--signals and declarations
begin
    proc: process (rst, clk)
        --declarativepart
    begin
        if (rst = '1') then
            q <= '0';
        elsif (clk'event and clk = '1') then
            q <= d;
        end if;
    end process proc;
end architecture circuit;

--------------------------------------
-- architecture using variable
--------------------------------------

architecture circuit2 of ff_archs is
--signals and declarations
begin
    proc: process (rst, clk)
        variable d_temp: std_logic;
    begin
        if (rst = '1') then
            d_temp := '0';
        elsif (clk'event and clk = '1') then
            d_temp := d;
        end if;
        q <= d_temp;
    end process proc;
end architecture circuit2;

--------------------------------------
-- architecture for testing configuration
--------------------------------------

architecture circuit3 of ff_archs is
--signals and declarations
begin
    process (rst, clk)
    begin
        if (rst = '1') then
            q <= '1';
        elsif (clk'event and clk = '1') then
            q <= '1';
        end if;
    end process;
end architecture circuit3;

--------------------------------------
-- select which architecture to use for the entity
--------------------------------------
--
-- configuration config of ff_archs is
--     for circuit 
--     end for;
-- end configuration config;
--------------------------------------

