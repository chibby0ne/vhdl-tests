-- lessons learned:
-- when a signal is assigned inside a process its value is updated after the conclussion of the currecnt clock process (i.e if rising edge then at falling edge), so if its value is used again inside the process we would still be using its old value.

-- variables are updated inmediatelly and can be assignned multiple times

-- difference between downto and to
-- is all about in which index has the MSB: 
-- downto = N-1 
-- to: 0
-- for all of them the MSB is the leftmost and the LSB is the rightmost

--------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------

--------------------------------------
entity shift_register_unistage is
    generic (N: integer := 2);
    port (
        din: in std_logic;
        rst: in std_logic;
        clk: in std_logic;
        dout: out std_logic);
end entity shift_register_unistage;
--------------------------------------

--------------------------------------
architecture circuit of shift_register_unistage is

begin
    process (rst, clk)
        variable q: std_logic_vector(N-1 downto 0) := (others => '0');
    begin
        if (rst = '1') then
            q := (others => '0');
        elsif (clk'event and clk = '1') then
            q := q(N-2 downto 0) & din;
        end if;
        dout <= q(N-1);
    end process;
end architecture circuit;
--------------------------------------


