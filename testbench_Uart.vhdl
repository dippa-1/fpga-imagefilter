library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
entity uart_tb is
end uart_tb;

LIBRARY work;

USE work.buffer_types.ALL;

architecture behave of uart_tb is
 
  component uart_tx is
    generic (
      g_CLKS_PER_BIT : integer := 868   -- Needs to be set correctly
      );
    port (
      i_clk       : in  std_logic;
      i_need_line     : in  std_logic;
      o_tx_active : out std_logic;
      o_tx_serial : out std_logic;
      o_tx_done   : out std_logic
      );
  end component uart_tx;
  
  component uart_rx is
    generic (
      g_CLKS_PER_BIT : integer := 868   -- Needs to be set correctly
      );
    port (
      o_line : out line_t;
      i_clk       : in  std_logic;
      i_rx_serial : in  std_logic;
      o_rx_byte   : out std_logic_vector(7 downto 0);
      o_line_ready : out std_logic;
      o_RX_Active : out std_logic
      );
  end component uart_rx;

   -- Test Bench uses a 10 MHz Clock
  -- Want to interface to 115200 baud UART
  -- 10000000 / 115200 = 87 Clocks Per Bit.
  constant c_CLKS_PER_BIT : integer := 868;

  constant c_BIT_PERIOD : time := 8680 ns;--(1/fclock)*clk_per_bit
   
  signal r_CLOCK     : std_logic                    := '0';
  signal r_need_line     : std_logic                    := '0'; --equal to need_line
  signal w_TX_SERIAL : std_logic;
  signal w_TX_DONE   : std_logic;
  --signal w_RX_DV     : std_logic;
  signal w_RX_BYTE   : std_logic_vector(7 downto 0);
  signal r_RX_SERIAL : std_logic := '1';
  signal r_tx_active    : std_logic;
  signal r_line_ready    : std_logic;
  signal r_rx_active    : std_logic;
  signal byte_pixel : line_t;
   
   -- byte-write testbench
  procedure UART_WRITE_BYTE (
    i_data_in       : in  std_logic_vector(7 downto 0);
    signal o_serial : out std_logic) is
  begin
 
    -- Send Start Bit
    o_serial <= '0';
    wait for c_BIT_PERIOD;
 
    -- Send Data Byte
    for ii in 0 to 7 loop
      o_serial <= i_data_in(ii);
      wait for c_BIT_PERIOD;
    end loop;  -- ii
 
    -- Send Stop Bit
    o_serial <= '1';
    wait for c_BIT_PERIOD;
  end UART_WRITE_BYTE;

  begin
 
    -- Instantiate UART transmitter
    UART_TX_INST : uart_tx
      generic map (
        g_CLKS_PER_BIT => c_CLKS_PER_BIT
        )
      port map (
        i_clk       => r_CLOCK,
        i_need_line  => r_need_line,
        o_tx_active => r_tx_active,
        o_tx_serial => w_TX_SERIAL,
        o_tx_done   => w_TX_DONE
        );
   
    UART_RX_INST : uart_rx
    generic map (
      g_CLKS_PER_BIT => c_CLKS_PER_BIT
      )
    port map (
      o_line  => byte_pixel ,
      i_clk       => r_CLOCK,
      i_rx_serial => r_RX_SERIAL,
      o_rx_byte   => w_RX_BYTE,
      o_line_ready=>r_line_ready,
      o_RX_Active=>r_rx_active
      );

    r_CLOCK <= not r_CLOCK after 5 ns;  -- fclock=1/2t=1/T
    
    
    process is
    begin
       -- Tell the UART to send a command.
       for I in 0 to 239 loop
          wait until rising_edge(r_CLOCK);
      end loop;
       
       r_need_line   <= '1';
      wait until rising_edge(r_CLOCK);
      r_need_line   <= '0';
      
       wait until w_TX_DONE = '1';
       
       -- Send a command to the UART
      for I in 0 to 239 loop
          wait until rising_edge(r_CLOCK);
          UART_WRITE_BYTE(X"3F", r_RX_SERIAL);
      end loop;
      wait until rising_edge(r_CLOCK);
  UART_WRITE_BYTE(X"53", r_RX_SERIAL);
      -- Check that the correct command was received
      wait until rising_edge(r_CLOCK);
      wait until rising_edge(r_CLOCK);
    end process; 
end behave;