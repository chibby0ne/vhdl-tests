--! 
--! @file: pkg_ieee_802_11ad_matrix.vhd
--! @brief: Package with functions and types for the generation of full matrixes
--! @author: Antonio Gutierrez
--! @date: 2013-12-06
--!
--!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_param.all;
use work.pkg_param_derived.all;
use work.pkg_ieee_802_11ad_param.all;


package pkg_ieee_802_11ad_matrix is

    -- types for used for different matrices sizes in reduced form
    type t_array64 is array (0 to 63) of integer range -1 to SUBMAT_SIZE;
    type t_array60 is array (0 to 59) of integer range -1 to SUBMAT_SIZE;
    type t_array48 is array (0 to 47) of integer range -1 to SUBMAT_SIZE;
    
    -- type for matrices in full form
    type t_array_full_r050 is array (0 to R050_ROWS * SUBMAT_SIZE - 1, 0 to MAT_COLUMNS * SUBMAT_SIZE - 1) of std_logic;    -- array[8*42][16*42]
    type t_array_full_r062 is array (0 to R062_ROWS * SUBMAT_SIZE - 1, 0 to MAT_COLUMNS * SUBMAT_SIZE - 1) of std_logic;    -- array[6*42][16*42]
    type t_array_full_r075 is array (0 to R075_ROWS * SUBMAT_SIZE - 1, 0 to MAT_COLUMNS * SUBMAT_SIZE - 1) of std_logic;    -- array[4*42][16*42]
    type t_array_full_r081 is array (0 to R081_ROWS * SUBMAT_SIZE - 1, 0 to MAT_COLUMNS * SUBMAT_SIZE - 1) of std_logic;    -- array[3*42][16*42]
    
    -- type for P submatrix
    type t_submatrix is array (0 to SUBMAT_SIZE - 1, 0 to SUBMAT_SIZE - 1) of std_logic;  


    -- matrices in reduced form for different code rates
    constant IEEE_802_11AD_P42_N672_R050_ADDR : t_array64 := (
    0, 2, 4, 6, 8, -1, -1, -1, 
    0, 2, 4, 7, 8, 9, -1, -1, 
    1, 3, 5, 7, 9, 10, -1, -1, 
    1, 3, 5, 6, 10, 11, -1, -1, 
    0, 2, 4, 6, 8, 11, 12, -1, 
    0, 2, 5, 7, 9, 11, 13, -1, 
    1, 3, 5, 7, 10, 13, 14, -1, 
    1, 3, 4, 6, 8, 12, 14, 15);

    constant IEEE_802_11AD_P42_N672_R050_SHIFT : t_array64 := (
    40, 38, 13, 5, 18, -1, -1, -1, 
    34, 35, 27, 30, 2, 1, -1, -1, 
    36, 31, 7, 34, 10, 41, -1, -1, 
    27, 18, 12, 20, 15, 6, -1, -1, 
    35, 41, 40, 39, 28, 3, 28, -1, 
    29, 0, 22, 4, 28, 27, 23, -1, 
    31, 23, 21, 20, 12, 0, 13, -1, 
    22, 34, 31, 14, 4, 13, 22, 24);
    
    constant IEEE_802_11AD_P42_N672_R062_ADDR : t_array60 := (
    0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 
    0, 1, 3, 5, 6, 7, 8, 9, 10, 11, 
    0, 2, 4, 6, 8, 11, 12, -1, -1, -1, 
    0, 2, 5, 7, 9, 11, 12, 13, -1, -1, 
    1, 3, 5, 7, 9, 10, 13, 14, -1, -1, 
    1, 3, 4, 6, 8, 14, 15, -1, -1, -1);

    constant IEEE_802_11AD_P42_N672_R062_SHIFT : t_array60 := (
    20, 36, 34, 31, 20, 7, 41, 34, 10, 41, 
    30, 27, 18, 12, 20, 14, 2, 25, 15, 6, 
    35, 41, 40, 39, 28, 3, 28, -1, -1, -1, 
    29, 0, 22, 4, 28, 27, 24, 23, -1, -1, 
    31, 23, 21, 20, 9, 12, 0, 13, -1, -1, 
    22, 34, 31, 14, 4, 22, 24, -1, -1, -1);

    constant IEEE_802_11AD_P42_N672_R075_ADDR : t_array60 := (
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, -1, -1, 
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, -1, 
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, -1, 
    0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15);

    constant IEEE_802_11AD_P42_N672_R075_SHIFT : t_array60 := (
    35, 19, 41, 22, 40, 41, 39, 6, 28, 18, 17, 3, 28, -1, -1, 
    29, 30, 0, 8, 33, 22, 17, 4, 27, 28, 20, 27, 24, 23, -1, 
    37, 31, 18, 23, 11, 21, 6, 20, 32, 9, 12, 29, 0, 13, -1, 
    25, 22, 4, 34, 31, 3, 14, 15, 4, 14, 18, 13, 13, 22, 24);

    constant IEEE_802_11AD_P42_N672_R081_ADDR : t_array48 := (
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, -1, -1, 
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, -1, 
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);

    constant IEEE_802_11AD_P42_N672_R081_SHIFT : t_array48 := (
    29, 30, 0, 8, 33, 22, 17, 4, 27, 28, 20, 27, 24, 23, -1, -1, 
    37, 31, 18, 23, 11, 21, 6, 20, 32, 9, 12, 29, 10, 0, 13, -1, 
    25, 22, 4, 34, 31, 3, 14, 15, 4, 2, 14, 18, 13, 13, 22, 24);

    constant DUMMY_VALUES : t_submatrix := (others => 31);

    function gen_identity_matrix(shift : integer) return t_submatrix;

end package pkg_ieee_802_11ad_matrix;
------------------------------
package body pkg_ieee_802_11ad_matrix is

    function gen_identity_matrix(shift : integer) return t_submatrix is
        variable shifted_identity_matrix: t_submatrix;
    begin
        rows: for i in 0 to SUBMAT_SIZE-1 loop
            columns: for j in SUBMAT_SIZE-1 loop
                if (j + shift mod SUBMAT_SIZE = j) then      -- if we are on the column number(j + shift mod SUBMAT) 
                    shifted_identity_matrix(i,j) := '1';
                else 
                    shifted_identity_matrix(i, j) := '0';   -- else we fill with 0's the rest of the matrix
                end if;
            end loop columns;
        end loop rows;
    end function gen_identity_matrix;

   

end package body pkg_ieee_802_11ad_matrix;
