library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_support.all;
use work.pkg_types.all;
-- use work.pkg_support_global.all;
use work.pkg_param.all;

--------------------------------------------------------
entity functions is
end entity functions;

--------------------------------------------------------
architecture circuit of functions is
    signal num_signed: signed(4-1 downto 0);
    signal num_signed1: signed(3-1 downto 0);
    
    signal sign_mag_num_extr_pos: std_logic_vector(BW_EXTR-1 downto 0);
    signal sign_mag_num_extr_neg: std_logic_vector(BW_EXTR-1 downto 0);

    signal signed_num_extr_pos: std_logic_vector(BW_EXTR-1 downto 0);
    signal signed_num_extr_neg: std_logic_vector(BW_EXTR-1 downto 0);
    
    
    signal sign_mag_num_extr_neg_signed: signed(BW_EXTR-1 downto 0);
    signal sign_mag_num_extr_pos_signed: signed(BW_EXTR-1 downto 0);

    signal pos_vector: std_logic_vector(4-1 downto 0) := "0111";    -- 7
    signal neg_vector: std_logic_vector(4-1 downto 0) := "1111";    -- -7

    signal pos_signed: signed(3-1 downto 0);
    signal neg_signed: signed(3-1 downto 0);
    
    
    signal app_ram: signed(BW_APP-1 downto 0);
    signal app_ram_satur: signed(BW_EXTR-1 downto 0);
    signal app_ram_satur_sign_mag: signed(BW_EXTR-1 downto 0);
    signal check_node_in: std_logic_vector(BW_EXTR-1 downto 0);
    
    
    signal signed_bigger: signed(4-1 downto 0);
    signal signed_smaller: signed(3-1 downto 0);
    signal signed_result_sub: signed(4-1 downto 0);
    signal signed_result_add: signed(4-1 downto 0);
    
    
    
    

    
begin
    
    --------------------------------------------------------------------------------------
    -- saturate from BW_APP to BW_EXTR
    --------------------------------------------------------------------------------------
    -- in: value signed, BW natural, out signed
    num_signed <= to_signed(-8, 4);
    num_signed1 <= saturate(num_signed, 3);     -- should be -4 but is -3 according to function

    pos_signed <= saturate(signed(pos_vector), 3);
    neg_signed <= saturate(signed(neg_vector), 3);

    --------------------------------------------------------------------------------------
    -- 2's complement to signed-magnitude
    --------------------------------------------------------------------------------------
    sign_mag_num_extr_pos <= std_logic_vector(sign_magnitude(to_signed(5, BW_EXTR)));
    sign_mag_num_extr_neg <= std_logic_vector(sign_magnitude(to_signed(-5, BW_EXTR)));
    sign_mag_num_extr_pos_signed <= sign_magnitude(to_signed(5, BW_EXTR));
    sign_mag_num_extr_neg_signed <= sign_magnitude(to_signed(-5, BW_EXTR));


    --------------------------------------------------------------------------------------
    -- signed-magnitude to 2's complement
    --------------------------------------------------------------------------------------
    signed_num_extr_pos <= twos_comp(sign_mag_num_extr_pos);
    signed_num_extr_neg <= twos_comp(sign_mag_num_extr_neg);


    
    --------------------------------------------------------------------------------------
    -- decoder conversion flow
    --------------------------------------------------------------------------------------
    app_ram <= to_signed(-32, BW_APP);
    
    app_ram_satur <= saturate(app_ram, BW_EXTR);    -- -5 

    app_ram_satur_sign_mag <= sign_magnitude(app_ram_satur);    -- -5

    check_node_in <= std_logic_vector(app_ram_satur_sign_mag);  -- -5

    
    --------------------------------------------------------------------------------------
    -- test of substraction between different width
    --------------------------------------------------------------------------------------

    signed_bigger <= to_signed(5, 4);
    signed_smaller <= to_signed(4, 3);
    signed_result_sub <= signed_bigger - signed_smaller;
    signed_result_add <= signed_bigger + signed_smaller;


end architecture circuit;
