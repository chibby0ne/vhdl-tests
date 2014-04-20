--! 
--! Copyright (C) 2010 - 2013 Creonic GmbH
--!
--! @file: signed_unsigned_tests.vhd
--! @brief: signed unsigned tests
--! @author: Antonio Gutierrez
--! @date: 2014-04-17
--!
--!
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------

--------------------------------------
entity signed_unsigned_tests is
    generic (N: natural := 7);
end entity signed_unsigned_tests;
--------------------------------------

--------------------------------------
architecture circuit of signed_unsigned_tests is

    -- used for setting a positive and a negative value of the same magnitude
    signal signed1: signed(N-1 downto 0);
    signal signed2: signed(N-1 downto 0);

    -- used for testing conversion between signed and unsigned
    signal unsig_from_sign1: unsigned(N-1 downto 0);
    signal unsig_from_sign2: unsigned(N-1 downto 0);
    

    -- used for getting the "magnitude" part of the signed numbers
    signal unsigned1: unsigned(N-2 downto 0);
    signal unsigned2: unsigned(N-2 downto 0);

    -- proving the function ivnerse twos function
    signal unsigned1_fun: unsigned(N-2 downto 0);
    signal unsigned2_fun: unsigned(N-2 downto 0);

    -- values used for the signeds
    signal int_pos: integer range -32 to 31 := 5;
    signal int_neg: integer range -32 to 31 := -5;

    -- used for getting the high and low values of the signeds
    signal int_signed1_high: integer range -32 to 31 := 31; 
    signal int_signed1_low: integer range -32 to 31 := -32; 

    -- used for getting the high and low values of the unsigned
    signal int_unsigned1_high: integer range 0 to 31 := 31; 
    signal int_unsigned1_low: integer range 0 to 31 :=  0; 

    
-- function for converting two's complement to magnitude
    -- function get_magnitude(input : signed) return signed;
    function get_magnitude(input : signed) return signed is
        variable temp: signed(input'high downto input'low) := input;
    begin
        if (input(input'left) = '0') then
            return temp(temp'high-1 downto temp'low);
            -- return unsigned(input(input'high-1 downto input'low));
        else
            temp := temp - 1;
            for i in input'range loop
                temp(i) := not temp(i);
            end loop;
            return temp(temp'high-1 downto temp'low);
        end if;
    end function get_magnitude;
    
begin
    signed1 <= to_signed(int_pos, N);
    signed2 <= to_signed(int_neg, N);

    unsig_from_sign1 <= unsigned(signed1);
    unsig_from_sign2 <= unsigned(signed2);

    unsigned1 <= unsigned(signed1(N-2 downto 0));
    unsigned2 <= unsigned(signed2(N-2 downto 0));

    unsigned1_fun <= unsigned(get_magnitude(signed1));
    unsigned2_fun <= unsigned(get_magnitude(signed2));

    int_signed1_high <= signed1'left;
    int_signed1_low <= signed1'right;

    int_unsigned1_high <= unsigned1'left;
    int_unsigned1_low <= unsigned1'right;

    
    process
         --declarative part
    begin
        wait for 90 ns;
        assert false
        -- report "signed1 high = " & integer'image(int_signed1_high);
        report "signed1 high = " & integer'image(signed1'high)
        severity note;

        assert false
        report "signed1 low = " & integer'image(signed1'low)
        severity note;

        assert false
        report "unsigned1 high = " & integer'image(unsigned1'high)
        severity note;

        assert false
        report "unsigned1 low = " & natural'image(unsigned1'low)
        severity note;

    end process;

end architecture circuit;
