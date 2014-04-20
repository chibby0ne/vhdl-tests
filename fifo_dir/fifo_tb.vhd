--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------
entity fifo_tb is
    generic (N: integer := 0;
            PERIOD: time := 40 ns;
            delay: time := 2 ns);
end entity fifo_tb;
--------------------------------------
architecture circuit of fifo_tb is

-- dut declaration 
    component fifo is
    port (
        clk, rst: in std_logic;
        D: in std_logic_vector(N downto 0);
        Q: out std_logic_vector(N downto 0));
    end component fifo;

    -- signal declarations
    signal clk_tb: std_logic := '0';
    signal rst_tb: std_logic := '0';
    signal D_tb: std_logic_vector(N downto 0) := (others => '0');
    signal Q_tb: std_logic_vector(N downto 0);

    signal clk_tb2: std_logic := '0';
    signal rst_tb2: std_logic := '0';
    signal D_tb2: std_logic_vector(N downto 0) := (others => '0');
    signal Q_tb2: std_logic_vector(N downto 0);

    for dut: fifo use entity work.fifo(circuit);
    for dut2: fifo use entity work.fifo(circuit2);

begin
    
    -- dut instantiation
    dut: fifo port map (
        clk => clk_tb,
        rst => rst_tb,
        D => D_tb,
        Q => Q_tb
    );

    dut2: fifo port map (
        clk => clk_tb2,
        rst => rst_tb2,
        D => D_tb2,
        Q => Q_tb2
    );


    -- stimuli generation
    -- clk 
    clk_tb <= not clk_tb after PERIOD/2;
    clk_tb2 <= not clk_tb2 after PERIOD/2;
    
    -- rst
    rst_tb <= '1', '0' after 2 * PERIOD;
    rst_tb2 <= '1', '0' after 2 * PERIOD;

    -- D
    D_tb <= (others => '1') after PERIOD + delay, (others => '0') after 2 * PERIOD + delay, (others => '1') after 4 * PERIOD + delay;
    D_tb2 <= (others => '1') after PERIOD + delay, (others => '0') after 2 * PERIOD + delay, (others => '1') after 4 * PERIOD + delay;


end architecture circuit;
