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
    port (
        -- inputs
        clk: in std_logic;
        rst: in std_logic;
        code_rate: in t_code_rate;
        parity_out: in t_parity_out_contr;

        -- outputs
        iter: out t_iter;
        app_rd_addr: out t_app_ram_addr;
        app_wr_addr: out t_app_ram_addr;
        msg_rd_addr: out t_msg_addr_contr;
        msg_wr_addr: out t_msg_addr_contr;
        shift: out t_shift_contr;
        new_codeword: out std_logic;                                 -- mutiplexers at input of app ram used for loading new codeword
        dummy_value: out std_logic_vector(CFU_PAR_LEVEL - 1 downto 0);      -- mutiplexers at output of app ram used for loading new codeword
        reset_msg_ram: out std_logic                                 -- used to reset msg ram at every new codeword
        );
end entity controller;
--------------------------------------------------------
architecture circuit of controller is

    -- signals used in FSM
    type state is (START_STORE_FIRST_HALF, START_STORE_SECOND_HALF, LOAD_NEW_CODEWORD, NEW_SUBITER, NEW_ITER);
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
    
    
    -- signals used for paritiy check matrix
    -- I'm choosing the biggest size of them and to address them I'm using the max check degree
    signal matrix_addr: t_array64 := (others => 0);      
    signal matrix_shift: t_array64 := (others => 0);
    signal matrix_length: natural range 0 to 64;
    signal matrix_max_check_degree: natural range 0 to 16;
    
    
begin

    --------------------------------------------------------------------------------------
    -- selection of matrices depending on the code rate 
    --------------------------------------------------------------------------------------

    matrix_addr <= IEEE_802_11AD_P42_N672_R050_ADDR when code_rate = R050 else
                   IEEE_802_11AD_P42_N672_R062_ADDR when code_rate = R062 else
                   IEEE_802_11AD_P42_N672_R075_ADDR when code_rate = R075 else
                   IEEE_802_11AD_P42_N672_R081_ADDR;

    matrix_shift <= IEEE_802_11AD_P42_N672_R050_SHIFT when code_rate = R050 else
                   IEEE_802_11AD_P42_N672_R062_SHIFT when code_rate = R062 else
                   IEEE_802_11AD_P42_N672_R075_SHIFT when code_rate = R075 else
                   IEEE_802_11AD_P42_N672_R081_SHIFT;

    matrix_length <= IEEE_802_11AD_P42_N672_R050_ADDR'length when code_rate = R050 else
                   IEEE_802_11AD_P42_N672_R062_ADDR'length when code_rate = R062 else
                   IEEE_802_11AD_P42_N672_R075_ADDR'length when code_rate = R075 else
                   IEEE_802_11AD_P42_N672_R081_ADDR'length;

    matrix_rows <= R050_ROWS when code_rate = R050 else
                   R062_ROWS when code_rate = R062 else
                   R075_ROWS when code_rate = R075 else
                   R081_ROWS;

    matrix_max_check_degree <= matrix_length / matrix_rows;

    
   --------------------------------------------------------------------------------------
   -- Lower section of FSM: sequential part
   -- Here the state transitions is done
   --------------------------------------------------------------------------------------

    process (clk, rst)
    begin
        if (rst = '1') then
            pr_state <= START_STORE_FIRST_HALF;
        elsif (clk'event and clk = '1') then
            pr_state <= nx_state;
        end if;
    end process;
    --------------------------------------------------------


    --------------------------------------------------------------------------------------
    -- Upper section of FSM: combinational part
    -- Here outputs of the FSM are handled, using the inputs as conditions 
    --------------------------------------------------------------------------------------

    process (pr_state, parity_out)

        -- app rams
        variable app_rd_addr_int: integer range 0 to 1 := 0;
        variable app_wr_addr_int: integer range 0 to 1 := 1;
        
        -- base address of matrix (cng_counter * matrix_max_check_degree)
        variable vector_addr: integer range 0 to 64 := 0;

        -- row number in reduced matrix
        variable cng_counter: integer range 0 to 8 := 0;
        
        
        -- halves identification
        variable first_half: boolean := false;
        
        -- iteratons
        variable iter_int: integer range 0 to 10 := 0;
        variable last_row: boolean := false;
        
        -- msg rams
        variable msg_row: integer range 0 to 16 := 0;
        variable addr_rd_msg: integer range 0 to 16 := 0;
        variable addr_wr_msg: integer range 0 to 16 := 0;


        -- parity checks
        variable ok_checks: integer range 0 to 672/2:= 0;
        variable count: integer range 0 to 2 := 0;
        
        
        
        
        
        
    begin
        case pr_sate is
            

            --------------------------------------------------------------------------------------
            -- first state 
            --------------------------------------------------------------------------------------
            when START_STORE_FIRST_HALF =>                   -- store first half of codeword/ new codeword

                --
                -- new codeword (first half)
                --
                new_codeword <= '1';


                --
                -- App ram
                --
                app_rd_addr <= std_logic_vector(to_unsigned(0, BW_APP_RAM));
                app_wr_addr <= std_logic_vector(to_unsigned(0, BW_APP_RAM));
                

                --
                -- max_app_val or real app val + real shift 
                --
                vector_addr := cng_counter * matrix_max_check_degree;
                for i in 0 to CFU_PAR_LEVEL - 1 loop            --- maybe change order of loop if not storing in correct place
                    if (matrix_addr(i + vector_addr) < 8) then                -- have we check entire first half row values?
                        if (i = matrix_addr(i + vector_addr)) then            -- if the value of matrix is not this one but it's not at the end of it
                            dummy(i) := '0';            
                            shift(i) <= matrix_shift(i + vector_addr);
                        else
                            dummy(i) := '1';                    -- put all max_extr_msg 
                            shift(i) <= '0';       
                        end if;
                    else                                        -- this is a value from the second half

                        --store index of matrix where to start from  for second half 
                        start_pos_next_half := i;  

                        -- put the rest of the dummy values to the rest of the APP rams
                        while i < CFU_PAR_LEVEL - 1 loop                               
                            dummy(i) := '1';       
                            shift(i) <= '0';       
                            i := i + 1;
                        end loop;
                    end if;
                end loop;
                

                --
                -- inside CNB 
                --
                iter <= std_logic_vector(to_unsigned(0, BW_MAX_ITER));
                reset_msg_ram <= '0';
                for i in SUBMAT_SIZE - 1 downto 0 loop
                    msg_rd_addr(i) <= std_logic_vector(to_unsigned(msg_row, BW_MSG_RAM));
                end loop;
                msg_row := msg_row + 1;


                --
                -- next state
                --
                nx_state <= START_STORE_SECOND_HALF;

                
                
            --------------------------------------------------------------------------------------
            -- second state
            --------------------------------------------------------------------------------------
            when START_STORE_SECOND_HALF =>   -- store second half of codeword

                -- new codeword (second half)
                new_codeword <= '1';


                --
                -- APP RAM
                --
                app_rd_addr <= std_logic_vector(to_unsigned(1, BW_APP_RAM));
                app_wr_addr <= std_logic_vector(to_unsigned(1, BW_APP_RAM));


                --
                -- max_app_val or real app val + real shift 
                --
                vector_addr := cng_counter * matrix_max_check_degree;
                i := start_pos_next_half;                   -- start from position in index where value is >= 8 (meaning second half start)
                for j in 0 to CFU_PAR_LEVEL - 1 loop        -- for all the APP rams
                    if i < matrix_check_degree - 1 then     -- if this is still part of this second half row of the matrix 
                        if (j = matrix_addr(i)) then        -- if this value of the matrix corresponds to this app ram
                            dummy(j) := '0';                
                            shift(j) <= matrix_shift(i);        
                        else 
                            dummy(j) := '1';       
                            shift(j) <= '0';      
                        end if;
                        i := i + 1;
                    else                                    -- for all the remaining APP rams put out dummy value
                        dummy(i) := '1';                    -- put all max_extr_msg 
                        shift(i) <= '0';                    -- because the matrix has the same values it is indifferent how much we shift 
                    end if;
                end loop;
                cng_counter := cng_counter + 1;             -- next time start from next row(cng)


                --
                -- inside CNB
                --
                iter <= std_logic_vector(to_unsigned(0, BW_MAX_ITER));
                for i in SUBMAT_SIZE - 1 downto 0 loop
                    msg_rd_addr(i) <= std_logic_vector(to_unsigned(msg_row, BW_MSG_RAM));
                end loop;
                msg_row := msg_row + 1;


                --
                -- next state
                --
                nx_state <= CNB_INPUT_FULL;


            
            --------------------------------------------------------------------------------------
            -- third state
            --------------------------------------------------------------------------------------
            when CNB_INPUT_FULL =>          -- at first in CT

                --
                -- new codeword (no)
                --
                new_codeword <= '0';


                --
                -- APP RAM
                --
                app_rd_addr <= not app_rd_addr;
                app_wr_addr <= not app_wr_addr;


                --
                -- max_app_val or real app val + real shift 
                --
                vector_addr := cng_counter * matrix_max_check_degree;
                for i in 0 to CFU_PAR_LEVEL - 1 loop            --- maybe change order of loop if not storing in correct place
                    if (matrix_addr(i + vector_addr) < 8) then       
                        if (i = matrix_addr(i + vector_addr)) then            -- if the value of the matrix is not this 1 but it's not at the end of it
                            dummy(i) := '0';            
                            shift(i) <= matrix_shift(i + vector_addr);
                        else
                            dummy(i) := '1';                    -- put all max_extr_msg 
                            shift(i) <= '0';       
                        end if;
                    else                                        -- this is a value from the second half

                        --store index of matrix where to start from  for second half 
                        start_pos_next_half := i + vector_addr;  

                        -- put the rest of the dummy values to the rest of the APP rams
                        while i < CFU_PAR_LEVEL - 1 loop                               
                            dummy(i) := '1';       
                            shift(i) <= '0';       
                        end loop;
                    end if;
                end loop;


                --
                -- inside CNB
                --
                iter <= std_logic_vector(to_unsigned(0, BW_MAX_ITER));
                for i in SUBMAT_SIZE - 1 downto 0 loop
                    msg_rd_addr(i) <= std_logic_vector(to_unsigned(msg_row, BW_MSG_RAM));
                end loop;
                msg_row := msg_row + 1;


                --
                -- Parity checks handling
                --
                count := count + 1;


                --
                -- iteration handling 
                --



                --
                -- next state
                --
                nx_state <= ITERATING_CT;


            --------------------------------------------------------------------------------------
            -- four state (whole datapath is full)
            --------------------------------------------------------------------------------------
            when ITERATING_CT =>            

                --
                -- new codeword (no)
                --
                new_codeword <= '0';


                --
                -- APP RAM
                --
                app_rd_addr <= not app_rd_addr;
                app_wr_addr <= not app_wr_addr;


                --
                -- max_app_val or real app val + real shift 
                --
                vector_addr := cng_counter * matrix_max_check_degree;   -- base address of row

                -- first half
                if (first_half = true) then
                    first_half := false;                            -- next time other half

                    for i in 0 to CFU_PAR_LEVEL - 1 loop            --- maybe change order of loop if not storing in correct place
                        if (matrix_addr(i + vector_addr) < 8) then       
                            if (i = matrix_addr(i + vector_addr)) then            -- if the value of matrix isn't this 1 but it's not at the end of it
                                dummy(i) := '0';            
                                shift(i) <= matrix_shift(i + vector_addr);
                            else
                                dummy(i) := '1';                    -- put all max_extr_msg 
                                shift(i) <= '0';       
                            end if;
                        else                                        -- this is a value from the second half

                            --store index of matrix where to start from  for second half 
                            start_pos_next_half := i;  

                            -- put the rest of the dummy values to the rest of the APP rams
                            while i < CFU_PAR_LEVEL - 1 loop                               
                                dummy(i) := '1';       
                                shift(i) <= '0';       
                            end loop;
                        end if;
                    end loop;

                -- second half
                else
                    first_half := true;                         -- next time other half

                    i := start_pos_next_half;                   -- start from position in index where value is >= 8 (meaning second half start)
                    for j in 0 to CFU_PAR_LEVEL - 1 loop        -- for all the APP rams
                        if (i < matrix_check_degree - 1) then     -- if this is still part of this second half row of the matrix 
                            if (j = matrix_addr(i + vector_addr)) then        -- if this value of the matrix corresponds to this app ram
                                dummy(j) := '0';                
                                shift(j) <= matrix_shift(i + vector_addr);        
                            else 
                                dummy(j) := '1';       
                                shift(j) <= '0';      
                            end if;
                            i := i + 1;
                        else                                    -- for all the remaining APP rams put out dummy value
                            dummy(j) := '1';                    -- put all max_extr_msg 
                            shift(j) <= '0';                    -- because the matrix has the same values it is indifferent how much we shift 
                        end if;
                    end loop;
                    cng_counter := cng_counter + 1;
                    if (cng_counter = matrix_rows) then
                        cng_counter := 0;
                        last_row := true;
                    end if;

                end if;



                --
                -- inside CNB
                --
                iter <= std_logic_vector(to_unsigned(iter_int, BW_MAX_ITER));
                for i in 0 to SUBMAT_SIZE - 1 loop
                    msg_rd_addr(i) <= std_logic_vector(to_unsigned(msg_row, BW_MSG_RAM));
                end loop;
                msg_row := msg_row + 1;
                if (msg_row = MSG_RAM_DEPTH) then
                    msg_row := 0;
                end if;


                --
                -- Parity checks handling
                --
                -- parity_out out of CN, which happens every 2 cycles in CT stage in the pipeline, we add and accumulate the parity_check
                count := count + 1;
                if (count = 2) then                 -- parity out is calculated every two cycles
                    count := 0;
                    for i in 0 to SUBMAT_SIZE - 1 loop
                        ok_checks := ok_checks + to_integer(unsigned(parity_out(i)));
                    end loop;
                end if;


                --
                -- iteration handling 
                --
                if (last_row = true) then
                    iter_int := iter_int + 1;
                end if;


                --
                -- next state 
                --
                if (last_row = true) then
                    if (iter_int = 10 or ok_checks = matrix_rows * SUBMAT_SIZE) then
                        iter_int := 0;
                        ok_checks := 0;
                        nx_state <= FINISHING_ITER;
                    else
                        nx_state <= ITERATING_CT;
                    end if;
                end if;


            --------------------------------------------------------------------------------------
            -- we have to let the pipeline flush itself out
            --------------------------------------------------------------------------------------
            when FINISHING_ITER =>      -- when we have either reached maximum number of iterations or all pchks satisfied



                --
                -- new codeword(no)
                -- 
                new_codeword <= '0';


                --
                -- APP ram
                -- 
                -- doesn't matter

                --
                -- max_app_val or real app val + real shift 
                -- 
                -- doesn't matter


                --
                -- inside CNB
                --
                -- doesn't matter

                

                if (flush_complete = true) then
                    nx_state <= START_STORE_FIRST_HALF;
                else
                    nx_state <= FINISHING_ITER;
                end if;

            end case;

        end process;

end architecture circuit;



-- NOTE!!
-- app_ram_addresses don't need to be std_logic_vector they can be std_logic, and also they're the same for all APP ram instances becasue they only depend on state and the half we're dealing with


-- TODO:
-- change std_logic_vectors in i/o entity into subtype in all designs and test them and declare them in pkg_types
-- change app ram addresses from std_logic_vector to std_logic
-- clock gating



