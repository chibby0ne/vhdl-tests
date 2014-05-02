--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: controller.vhd
--! @brief: controller for LDPC decoder
--! @author: Antonio Gutierrez
--! @date: 2014-05-02
--!
--!
--------------------------------------------------------
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_support.all;
use work.pkg_types.all;
use work.pkg_param.all;
use work.pkg_param_derived.all;
--------------------------------------------------------
entity controller is
--generic declarations
    port (
        -- inputs
        clk: in std_logic;
        rst: in std_logic;
        code_rate: in t_code_rate;
        parity_out: in std_logic_vector(1 downto 0);

        -- outputs
        iter: out std_logic_vector(BW_ITER - 1 downto 0);
        app_rd_addr: out std_logic_vector(BW_APP_RAM - 1 downto 0);
        app_wr_addr: out std_logic_vector(BW_APP_RAM - 1 downto 0);
        msg_rd_addr: out std_logic_vector(BW_MSG_RAM - 1 downto 0);
        msg_wr_addr: out std_logic_vector(BW_MSG_RAM - 1 downto 0);
        shift: out std_logic_vector(BW_SHIFT_VEC - 1 downto 0);
        new_codeword: out std_logic;
        );
end entity controller;
--------------------------------------------------------
architecture circuit of controller is

    -- signals used in FSM
    type state is (START, LOAD_NEW_CODEWORD, NEW_SUBITER, NEW_ITER);
    signal pr_state: state;
    signal nx_state: state;
    attribute enum_encoding: string;
    attribute enum_encoding of state: type is "sequential";
    
    -- signals used for typecasting

    -- signals used for keeping score of the number of layers checked so far
    signal num_layers: integer range 0 to MSG_RAM_DEPTH -1 := '0';
    

    -- signals used for handling parity check matrix 
    signal addr_vector: integer  := '0';
    signal addr_length: std_logic := '0';
    
    
    




begin
   
   --------------------------------------------------------------------------------------
   -- Lower section of FSM: sequential part
   -- Here the state transitions is done
   --------------------------------------------------------------------------------------
    process (clk, rst)
    begin
        if (rst = '1') then
            pr_state <= START;
        elsif (clk'event and clk = '1') then
            pr_state <= nx_state;
        end if;
    end process;
end architecture circuit;
--------------------------------------------------------

/
--------------------------------------------------------------------------------------
-- Upper section of FSM: combinational part
-- Here outputs of the FSM are handled, using the inputs as conditions 
--------------------------------------------------------------------------------------
process (pr_state, parity_out)
begin
    case pr_sate is
        when START => 
            new_codeword <= '1';
            app_rd_addr <= std_logic_vector(to_unsigned(0, BW_APP_RAM));
            app_wr_addr <= std_logic_vector(to_unsigned(1, BW_APP_RAM));
            nx_state <= NEW_SUBITERATION;

        when LOAD_NEW_CODEWORD =>

        when NEW_SUBITER =>

        when NEW_ITER =>


    end case;

end process;


--------------------------------------------------------------------------------------
-- selection of matrices depending on the code rate
--------------------------------------------------------------------------------------

matrix_length <= IEEE_802_11AD_P42_N672_R050_ADDR'length when code_rate = R050 else
               IEEE_802_11AD_P42_N672_R062_ADDR'length when code_rate = R062 else
               IEEE_802_11AD_P42_N672_R075_ADDR'length when code_rate = R075 else
               IEEE_802_11AD_P42_N672_R081_ADDR'length; 


j: for identifer in range generate
    concurrent_statements
end generate j;
