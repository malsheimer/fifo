LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fifo IS
  GENERIC (
    elem_num  : positive := 4; -- number of elements
    elem_bits : positive := 3); -- number of bits per element

  PORT (
    wr       : IN    STD_LOGIC;
    rd       : IN    STD_LOGIC;
    clk      : IN    STD_LOGIC;
    elem_in  : IN    STD_LOGIC_VECTOR(elem_bits - 1 DOWNTO 0);
    elem_out : OUT   STD_LOGIC_VECTOR(elem_bits - 1 DOWNTO 0));
END fifo;


ARCHITECTURE arch OF fifo IS
  TYPE     elem_array_type IS array(elem_num - 1 DOWNTO 0) of STD_LOGIC_VECTOR(elem_bits - 1 DOWNTO 0);
  SIGNAL   elem_array : elem_array_type;
  CONSTANT empty_elem : STD_LOGIC_VECTOR(elem_bits - 1 DOWNTO 0) := (others => '0');
  SIGNAL   u1         : UNSIGNED (2 DOWNTO 0);

BEGIN

  main_fifo : PROCESS (clk) IS
    -- vsg_off variable_007
    VARIABLE counter : natural range 0 TO elem_num := 0;
    VARIABLE prev_rd : boolean                     := false;
  -- vsg_on variable_007
  BEGIN
    IF (rising_edge(clk)) THEN
      IF (prev_rd) THEN
        elem_array <= empty_elem & elem_array(elem_num - 1 DOWNTO 1);
      END IF;

      IF (wr = '1' AND (counter /= elem_num)) THEN
        elem_array(counter) <= elem_in;
        counter             := counter + 1;
      END IF;

      IF (rd = '1' AND (counter /= 0)) THEN
        counter := counter - 1;
        prev_rd := true;
      END IF;

      IF (rd = '0') THEN
        prev_rd := false;
      END IF;
    END IF;
  END PROCESS main_fifo;

  elem_out <= elem_array(0);

END arch;
