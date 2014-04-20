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
entity shift_register is
    generic (N: integer := 2);
    port (
        din: in std_logic;
        rst: in std_logic;
        clk: in std_logic;
        dout: out std_logic);
end entity shift_register;
--------------------------------------

--------------------------------------
architecture circuit of shift_register is

   --  signal two_down_corr: std_logic_vector(N-1 downto 0) := "0010";
   --  -- (N-1 downto 2 => '0') & '1' & '0';    -- MSB 0010 LSB  correct
   --
   --  signal two2_to_inco: std_logic_vector(0 to N-1) := "0010";
   --  --(0 to 1 => '0') & '1' & '0';         -- LSB 0010 MSB  incorrect
   --
   --  signal two3_to_corr: std_logic_vector(0 to N-1) := "0100";
   --  --'0' & '1' & (2 to N-1 => '0');          -- LSB 0100 MSB  correct
   --
   --  signal two4_down_inco: std_logic_vector(N-1 downto 0) := "0100";
   -- -- '0' & '1' & (1 downto 0 => '0');    -- MSB 0100 LSB  incorrect

begin
    process (rst, clk)
        variable q: std_logic_vector(N-1 downto 0) := (others => '0');
        -- variable q: std_logic_vector(0 to N-1) := (others => '0');
    begin
        if (rst = '1') then
            q := (others => '0');
        elsif (clk'event and clk = '1') then
            q := q(N-2 downto 0) & din;
            -- q := din & q(N-2 downto 0);
            -- q := q(0 to N-2) & din;   
            -- q := din & q(0 to N-2);
        end if;
        dout <= q(N-1);
    end process;
end architecture circuit;
--------------------------------------

--------------------------------------

architecture circuit2 of shift_register is
    signal q_sig: std_logic_vector(N-1 downto 0) := (others => '0');
begin
    process (rst, clk)
        --declarativepart
    begin
        if (rst = '1') then
            q_sig <= (others => '0');
        elsif (clk'event and clk = '1') then
            q_sig <= q_sig(N-2 downto 0) & din;
        end if;
        dout <= q_sig(N-1);
    end process;
end architecture circuit2;
--------------------------------------
