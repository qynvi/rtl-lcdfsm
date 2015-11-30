-- William Fan
-- 02/11/2011
-- LCD Display Driver RTL

-- vector table
--    direction of horizontal display --->
-- _  012345
-- _  ABCDEF |
-- 0  >      |
-- 1  >>     |
-- 2   >     |
-- 3   >>    |
-- 4    >    |
-- 5    >>   |
-- 6     >   |
-- 7     >>  |
-- 8      >  |
-- 9      >> |
-- 10      > |
-- 11 >    > |

library ieee;
use ieee.std_logic_1164.all;

entity fsmlcd is
	generic (clkdiv: positive := 500_000; -- divide down to 1ms clock cycles
			 sclk: natural := 3_000_000; -- slow clock toggles singular ">" prints to 60ms
			 fclk: natural := 1_500_000; -- fast clock toggles shadowed ">>" prints to 30ms
			 char: std_logic_vector(7 downto 0) := "00111110"; -- this is the code for ">"
			 blank: std_logic_vector(7 downto 0) := "00100000"); -- this is the code for a blank space
	port(clk: in std_logic;
	     RS, RW, LCD_ON, BKL_ON: out std_logic;
	     E: buffer std_logic;
	     DB: out std_logic_vector(7 downto 0));
end fsmlcd;

architecture lcd of fsmlcd is
	type state is (f1,f2,f3,f4,CD,DC,EM,
				    -- define all possible states from the vector table
				    a_0_1,
				    ab_1_2,
				    ab_2_0,
				    b_3_1,
				    b_4_2,
				    bc_5_3,
				    bc_6_1,
				    c_7_2,
				    c_8_3,
				    cd_9_4,
				    cd_10_2,
				    d_11_3,
				    d_12_4,
				    de_13_5,
				    de_14_3,
				    e_15_4,
				    e_16_5,
				    ef_17_6,
				    ef_18_4,
				    f_19_5,
				    f_20_0,
				    fa_21_1,
				    fa_22_5,
				    a_23_6,
				    a_24_1);
	signal pr_state, nx_state: state;
	shared variable cv: positive := clkdiv;
	begin
		lcd_on <= '1'; bkl_on <= '1';
		process (clk)
			variable count: integer range 0 to sclk := 0;
			begin
				if (clk'event and clk='1') then
					count := count + 1;
						if (count=cv) then
							E <= NOT E;
							count := 0;
						end if;
				end if;
		end process;

		process (E)
		begin
			if (E'EVENT AND E='1') then
				pr_state <= nx_state;
			end if;
		end process;

		process (pr_state)

		-- state names arrangement motif
		-- <a/b/c/d/e/f>_<time step>_<coordinate of the cursor>

		begin
			case pr_state is

				-- initialization elements
				when f1 =>
					RS<='0'; RW<='0';
					DB <= "0011XX00";
					nx_state <= f2;
				when f2 =>
					RS<='0'; RW<='0';
					DB <= "0011XX00";
					nx_state <= f3;
				when f3 =>
					RS<='0'; RW<='0';
					DB <= "0011XX00";
					nx_state <= f4;
				when f4 =>
					RS<='0'; RW<='0';
					DB <= "00111000";
					nx_state <= cd;
				when CD => -- clear display
					RS<='0'; RW<='0';
					DB <= "00000001";
					nx_state <= dc;
				when DC => -- display control vector
					RS<='0'; RW<='0';
					DB <= "00001100";
					nx_state <= em;
				when EM => -- entry mode
					RS<='0'; RW<='0';
					DB <= "00000110";
					nx_state <= a_0_1;

				-- loop elements
				-- from <null> character, time = -1, cursor at 0
				when a_0_1 =>
					RS<='1'; RW<='0';
					DB <= char;
					cv := sclk;
					nx_state <= ab_1_2;
				when ab_1_2 =>
					RS<='1'; RW<='0';
					DB <= char;
					cv := fclk;
					nx_state <= ab_2_0;
				when ab_2_0 =>
					RS<='0'; RW<='0';
					DB <= "10000000";
					cv := clkdiv;
					nx_state <= b_3_1;
				when b_3_1 =>
					RS<='1'; RW<='0';
					DB <= blank;
					cv := sclk;
					nx_state <= b_4_2;
				when b_4_2 =>
					RS<='0'; RW<='0';
					DB <= "10000010";
					cv := clkdiv;
					nx_state <= bc_5_3;
				when bc_5_3 =>
					RS<='1'; RW<='0';
					DB <= char;
					cv := fclk;
					nx_state <= bc_6_1;
				when bc_6_1 =>
					RS<='0'; RW<='0';
					DB <= "10000001";
					cv := clkdiv;
					nx_state <= c_7_2;
				when c_7_2 =>
					RS<='1'; RW<='0';
					DB <= blank;
					cv := sclk;
					nx_state <= c_8_3;
				when c_8_3 =>
					RS<='0'; RW<='0';
					DB <= "10000011";
					cv := clkdiv;
					nx_state <= cd_9_4;
				when cd_9_4 =>
					RS<='1'; RW<='0';
					DB <= char;
					cv := fclk;
					nx_state <= cd_10_2;
				when cd_10_2 =>
					RS<='0'; RW<='0';
					DB <= "10000010";
					cv := clkdiv;
					nx_state <= d_11_3;
				when d_11_3 =>
					RS<='1'; RW<='0';
					DB <= blank;
					cv := sclk;
					nx_state <= d_12_4;
				when d_12_4 =>
					RS<='0'; RW<='0';
					DB <= "10000101";
					cv := clkdiv;
					nx_state <= de_13_5;
				when de_13_5 =>
					RS<='1'; RW<='0';
					DB <= char;
					cv := fclk;
					nx_state <= de_14_3;
				when de_14_3 =>
					RS<='0'; RW<='0';
					DB <= "10000011";
					cv := clkdiv;
					nx_state <= e_15_4;
				when e_15_4 =>
					RS<='1'; RW<='0';
					DB <= blank;
					cv := sclk;
					nx_state <= e_16_5;
				when e_16_5 =>
					RS<='0'; RW<='0';
					DB <= "10000101";
					cv := clkdiv;
					nx_state <= ef_17_6;
				when ef_17_6 =>
					RS<='1'; RW<='0';
					DB <= char;
					cv := fclk;
					nx_state <= ef_18_4;
				when ef_18_4 =>
					RS<='0'; RW<='0';
					DB <= "10000100";
					cv := clkdiv;
					nx_state <= f_19_5;
				when f_19_5 =>
					RS<='1'; RW<='0';
					DB <= blank;
					cv := sclk;
					nx_state <= f_20_0;
				when f_20_0 =>
					RS<='0'; RW<='0';
					DB <= "10000000";
					cv := clkdiv;
					nx_state <= fa_21_1;
				when fa_21_1 =>
					RS<='1'; RW<='0';
					DB <= char;
					cv := fclk;
					nx_state <= fa_22_5;
				when fa_22_5 =>
					RS<='0'; RW<='0';
					DB <= "10000101";
					cv := clkdiv;
					nx_state <= a_23_6;
				when a_23_6 =>
					RS<='1'; RW<='0';
					DB <= blank;
					cv := sclk;
					nx_state <= a_24_1;
				when a_24_1 =>
					RS<='0'; RW<='0';
					DB <= "10000001";
					cv := clkdiv;
					nx_state <= ab_1_2;

			end case;
		end process;

end architecture;
