library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_support.all;
use work.pkg_types.all;
--------------------------------------------------------
entity pipeline is
--generic declarations
    port (
        in: in std_logic;
        out: out std_logic);
end entity pipeline;
--------------------------------------------------------
architecture circuit of pipeline is
--signals and declarations
begin

    -- APP ram
    appram: app_ram port map (
    clk => clk,
    ena_vc => ena_vc,
    addr_app_ram_read => addr_app_ram_read,
    addr_app_ram_write => addr_app_ram_write,
    app_in => app_in,
    app_out => app_out
    );

    
    -- mux in the output of app
    app_out <= app_out when dummy = '0' else 
               dummy when dummy = '1' else 
               codeword;
   
    -- permutation network 
    perm_net: permutation_network port map (
        input => input,
        shift => shift,
        output => output,
    );

    -- CNB
    cnb: check_node_block port map (
    rst => rst,
    clk => clk,
    split => split,
    iter => iter,
    ena_rp => ena_rp,
    ena_ct => ena_ct,
    ena_cv => ena_cf,
    addr_msg_ram_read => addr_msg_ram_read,
    addr_msg_ram_write => addr_msg_ram_write,
    app_in => app_in,
    app_out => app_out
    );

    -- controller 
    contr: controller port map (
        clk => clk,
        rst => rst,
    );

   
    
end architecture circuit;
