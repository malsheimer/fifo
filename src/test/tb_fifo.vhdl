LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY vunit_lib;
CONTEXT vunit_lib.vunit_context;


ENTITY fifo_tb IS
  GENERIC (
    runner_cfg : string);
END fifo_tb;

ARCHITECTURE behavioral OF fifo_tb IS

  COMPONENT fifo IS
    GENERIC (
      elem_num  : positive;
      elem_bits : positive);
    PORT (
      wr       : IN    STD_LOGIC;
      rd       : IN    STD_LOGIC;
      clk      : IN    STD_LOGIC;
      elem_in  : IN    STD_LOGIC_VECTOR(ELEM_BITS - 1 DOWNTO 0);
      elem_out : OUT   STD_LOGIC_VECTOR(ELEM_BITS - 1 DOWNTO 0));
  END COMPONENT fifo;

  CONSTANT elem_bits : positive  := 3;
  SIGNAL   clk       : STD_LOGIC;
  SIGNAL   rd        : STD_LOGIC := '0';
  SIGNAL   wr        : STD_LOGIC := '0';
  SIGNAL   elem_in   : STD_LOGIC_VECTOR(elem_bits - 1 DOWNTO 0);
  SIGNAL   elem_out  : STD_LOGIC_VECTOR(elem_bits - 1 DOWNTO 0);
  CONSTANT t         : time      := 20 ns;

BEGIN

  clock_generation : PROCESS
  BEGIN
    clk <= '0';
    wait for t / 2;
    clk <= '1';
    wait for t / 2;
  END PROCESS clock_generation;

  uut : fifo
    GENERIC MAP (
      elem_num  => 4,
      elem_bits => ELEM_BITS)
    PORT MAP (
      rd       => rd,
      clk      => clk,
      wr       => wr,
      elem_in  => elem_in,
      elem_out => elem_out);

  tb : PROCESS
  BEGIN
    test_runner_setup(runner, runner_cfg);

    WHILE test_suite LOOP

      IF run("test1") THEN
        info("Test 1 passed");

      ELSIF run("test2") THEN
        info("Test 2 passed");

      ELSIF run("test3") THEN
        info("Test 3 passed");

      END IF;
    END LOOP;

    test_runner_cleanup(runner);
  END PROCESS tb;

END behavioral;
