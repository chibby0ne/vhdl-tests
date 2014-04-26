--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------

--------------------------------------
entity pipeline_tb is
    generic (N: integer := 5;
            PERIOD: time := 40 ns;
            PD: time := 3 ns);
end entity pipeline_tb;
--------------------------------------

--------------------------------------
architecture circuit of pipeline_tb is
    
    -- dut declaration
    component pipeline is
        port (
                 clk: in std_logic;
                 input: in std_logic_vector(N-1 downto 0);
                 output: out std_logic_vector(N-1 downto 0));
    end component pipeline;

    signal clk_tb: std_logic := '0';
    signal input_tb: std_logic_vector(N-1 downto 0);
    signal output_tb: std_logic_vector(N-1 downto 0);
    
    
begin
    
    -- dut instantiation
    dut: pipeline port map (
    clk_tb, input_tb, output_tb
    );

    
    -- stimuli generation
    clk_tb <= not clk_tb after PERIOD/2;
    
    input_tb <= "00111", "00110" after PERIOD/2 + PD, "00100" after PERIOD + PERIOD/2 + PD, "00000" after PERIOD * 2 + PERIOD/2 + PD;

    
    -- output verification
    process
         --declarative part
    begin
        wait for PERIOD/2 + PD + 2 * PERIOD;    -- 103 ns
        assert output_tb = "00001"
        report "Error output not matching"
        severity failure;

        wait for PERIOD;                        -- 143 ns
        assert output_tb = "00010"
        report "Error output not matching"
        severity failure;

        wait for PERIOD;                        -- 183 ns
        assert output_tb = "00100"
        report "Error output not matching"
        severity failure;

        wait for PERIOD;                        -- 223 ns
        assert output_tb = "00000"
        report "Error output not matching"
        severity failure;

        assert false
        report "No errors. End of simulation"
        severity failure;
    end process;
    
end architecture circuit;


