--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------

--------------------------------------
entity pipeline is
    generic (N: integer := 5);
    port (
        clk: in std_logic;
        input: in std_logic_vector(N-1 downto 0);
        output: out std_logic_vector(N-1 downto 0));
end entity pipeline;
--------------------------------------

--------------------------------------
architecture circuit of pipeline is
    signal input_i: std_logic_vector(N-1 downto 0);
    signal input_i_uns: signed(N-1 downto 0);
    signal input_i_uns_reg: signed(N-1 downto 0);
    signal res: signed(N-1 downto 0);
    

begin
    
    --
    -- input register
    --
    process (clk)
    begin
        if (clk'event and clk = '1') then
            input_i <= input;
        end if;
    end process;


    --
    -- combinational part
    --
    input_i_uns <= signed(input_i);

    
    --
    -- register to store first value
    --
    process (clk)
    begin
        if (clk'event and clk = '1') then
            input_i_uns_reg <= input_i_uns;
        end if;
    end process;


    --
    -- combinational part
    --
    res <= input_i_uns_reg - input_i_uns;
    

    --
    -- output register
    --
    process (clk)
    begin
        if (clk'event and clk = '1') then
            output <= std_logic_vector(res);
        end if;
    end process;
    
end architecture circuit;
