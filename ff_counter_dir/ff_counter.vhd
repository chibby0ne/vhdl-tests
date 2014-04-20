
-- Lessons learned:
-- VHDL pre-2008 Can't read output so arch circuit2 is not compilable unless we compile with 2008 option
-- You can assign signal from multiple sources AS LONG AS IT NOT ASSIGNED FROM MULTIPLE SOURCES IN THE SAME CCLOCK CYCLE
-- Expressions used for conditionals i.e: if, elsif. Can have an addition in one of the sides of the comparison e.g: i + 1 = 8 
-- same functionality achieved by the 3 different architectures

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------
entity ff_counter is
--generic declarations
    port (
        clk: in std_logic;
        rst: in std_logic;
        count: out natural range 0 to 7);
end entity ff_counter;
--------------------------------------

--------------------------------------
-- check to see if behaviour is the same as arch2 and arch3
--------------------------------------

architecture circuit of ff_counter is
--signals and declarations
begin
    proc: process (rst, clk)
        variable i: natural range 0 to 7 := 0;
    begin
        if (rst = '1') then
            i := 0;
        elsif (clk'event and clk = '1') then
            if (i + 1 = 8) then
                i := 0;
            else
                i := i + 1;
            end if;
        end if;
        count <= i;
    end process proc;
end architecture circuit;

--------------------------------------
-- check to see if behaviour is the same as arch1 and arch3
--------------------------------------
architecture circuit2 of ff_counter is
--signals and declarations
begin
    proc: process (rst, clk)
    begin
        if (rst = '1') then
            count <= 0;
        elsif (clk'event and clk = '1') then
            if (count + 1 = 8) then
                count <= 0;
            else
                count <= count + 1;
            end if;
        end if;
    end process proc;
end architecture circuit2;

--------------------------------------
-- used in the book
--------------------------------------

architecture circuit3 of ff_counter is
--signals and declarations
begin
    proc: process (rst, clk)
        variable i: natural range 0 to 8 := 0;
    begin
        if (rst = '1') then
            i := 0;
        elsif (clk'event and clk = '1') then
            i := i + 1;
            if (i = 8) then
                i := 0;
            end if;
        end if;
        count <= i;
    end process proc;
end architecture circuit3;
--------------------------------------
