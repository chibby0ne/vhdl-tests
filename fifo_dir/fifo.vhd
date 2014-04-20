
-- lessons learned:
-- I can use a std_logic_vector with a bitwidth of 0 to 0 as a std_logic, as long as I assign it just like a std_logic_vector and not a std_logic. (e.g others => '0' instead of '0')
-- configuration usage
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------
entity fifo is
    generic (N: integer := 0);
    port (
        clk, rst: in std_logic;
        D: in std_logic_vector(N downto 0);
        Q: out std_logic_vector(N downto 0));
end entity fifo;
--------------------------------------
architecture circuit of fifo is
    signal d_in: std_logic_vector(N downto 0) := (others => '0');
    signal clk_sec: std_logic := '0';
begin
    
    -- input handling
    process (rst, clk)
        --declarativepart
    begin
        if (rst = '1') then
            d_in <= (others => '0');
        elsif (clk'event and clk = '1') then
            d_in <= D;
        end if;
    end process;

    -- output generation
    process (clk_sec, rst)
        --declarativepart
    begin
        if (rst = '1') then
            Q <= (others => '0');
        elsif (clk_sec'event and clk_sec = '1') then
            Q <= d_in;
        end if;
    end process;

    -- clock sec generation
    process (clk)
    begin
        if (clk'event and clk = '1') then
            clk_sec <= not clk_sec;
        end if;
    end process;
end architecture circuit;
--------------------------------------


--------------------------------------
architecture circuit2 of fifo is
    signal d_in: std_logic_vector(N downto 0) := (others => '0');
    signal clk_sec: std_logic := '0';
begin
    
    -- data in handling and clk sec generation
    process (rst, clk)
        variable count: natural range 0 to 2 := 0;
    begin
        if (rst = '1') then
            d_in <= (others => '0');
        elsif (clk'event and clk = '1') then
            d_in <= D;
            count := count + 1;
            if (count = 2) then
                clk_sec <= not clk_sec;
                count := 0;
            end if;
        end if;
    end process;

    
    -- output generation
    process (rst, clk_sec)
        --declarativepart
    begin
        if (rst = '1') then
            Q <= (others => '0');
        elsif (clk_sec'event and clk_sec = '1') then
            Q <= d_in;
        end if;
    end process;
end architecture circuit2;
--------------------------------------

--------------------------------------
configuration config of fifo is
    for circuit
    end for;
end configuration config;
--------------------------------------

