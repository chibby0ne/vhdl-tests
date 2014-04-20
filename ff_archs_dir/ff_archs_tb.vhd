library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------
entity ff_archs_tb is
end entity ff_archs_tb;
--------------------------------------
architecture circuit of ff_archs_tb is

    -- dut declaration
    component ff_archs is
        port (
                 clk: in std_logic;
                 rst: in std_logic;
                 d: in std_logic;
                 q: out std_logic);
    end component ff_archs;

    -- signals declarations
    signal clk_tb: std_logic := '0';
    signal rst_tb: std_logic := '0';
    signal d_tb: std_logic := '0';
    signal q_tb: std_logic;

    signal clk_tb2: std_logic := '0';
    signal rst_tb2: std_logic := '0';
    signal d_tb2: std_logic := '0';
    signal q_tb2: std_logic;

    for dut: ff_archs use entity work.ff_archs(circuit);
    for dut2: ff_archs use entity work.ff_archs(circuit2);


begin
    
    --------------------------------------
    -- comp instantiation
    --------------------------------------
    
    dut: ff_archs port map (
        clk => clk_tb,
        rst => rst_tb,
        d => d_tb,
        q => q_tb
    );

    dut2: ff_archs port map (
        clk => clk_tb2,
        rst => rst_tb2,
        d => d_tb2,
        q => q_tb2
    );



    --------------------------------------
    -- stimuli generation
    --------------------------------------

    -- clock
    clk_tb <= not clk_tb after 10 ns;
    clk_tb2 <= clk_tb;

    -- rst
    process
         --declarative part
    begin
        wait for 40 ns;
        rst_tb <= '1';
        rst_tb2 <= '1';
        wait for 40 ns;     -- 80 ns
        rst_tb <= '0';
        rst_tb2 <= '0';
        wait;
    end process;

    -- d input
    process
         --declarative part
    begin
        wait for 20 ns;
        d_tb <= '1';
        d_tb2 <= '1';
        wait for 40 ns;     -- 60 ns
        d_tb <= '0';
        d_tb2 <= '0';
        wait for 10 ns;     -- 70 ns
        d_tb <= '1';
        d_tb2 <= '1';
        wait for 25 ns;     -- 95 ns
        d_tb <= '0';
        d_tb2 <= '0';
        wait for 10 ns;     -- 105 ns
        d_tb <= '1';
        d_tb2 <= '1';
        wait;
    end process;


    --------------------------------------
    -- output verification
    --------------------------------------
    
    process
         --declarative part
    begin
        wait for 11 ns;
        assert q_tb = '0'
        report "q_tb doesn't match 0 at time 11 ns"
        severity failure;
        wait for 20 ns;     --31         
        assert q_tb = '1'
        report "q_tb doesn't match 1 at time 31 ns"
        severity failure;
        wait for 20 ns;     --51
        assert q_tb = '0'
        report "q_tb doesn't match 0 at time 51 ns"
        severity failure;
        wait for 40 ns;     --91
        assert q_tb = '1'
        report "q_tb doesn't match 1 at time 91 ns"
        severity failure;
        wait for 20 ns;     -- 111
        assert q_tb = '1'
        report "q_tb doesn't match 1 at time 111 ns"
        severity failure;
        assert false
        report "no errors for tb"
        severity note;
        wait;
    end process;

end architecture circuit;

