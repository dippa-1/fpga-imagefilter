----------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
----------------------------------------------------------------------
-- This file contains the UART Receiver.  This receiver is able to
-- receive 8 bits of serial data, one start bit, one stop bit,
-- and no parity bit.  When receive is complete o_rx_dv will be
-- driven high for one clock cycle. 
-- o_rx_dv is not used. Line_ready will be driven high for one clock cycle after receiving 240 Bytes
-- 
-- Set Generic g_CLKS_PER_BIT as follows:
-- g_CLKS_PER_BIT = (Frequency of i_Clk)/(Frequency of UART)
-- Example: 10 MHz Clock, 115200 baud UART
-- (10000000)/(115200) = 87
--
LIBRARY  IEEE;

USE IEEE.std_logic_1164.ALL;



PACKAGE buffer_types IS

    TYPE line_t IS ARRAY(0 TO 239) OF STD_LOGIC_VECTOR(7 DOWNTO 0);--Zeile eines bildes

    type image_part_t is array(0 to 5) of STD_LOGIC_VECTOR(7 downto 0);-- nur ein signaltyp von dominik?

END PACKAGE buffer_types;



LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;

USE IEEE.numeric_std.ALL;



USE work.buffer_types.ALL;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
entity UART_RX is
  generic (
    g_CLKS_PER_BIT : integer := 868     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    o_rx_active    : out std_logic;
    o_RX_Byte   : out std_logic_vector(7 downto 0);
    o_line_ready     : out std_logic;
    o_line : out line_t
    );
end UART_RX;
 
 
architecture rtl of UART_RX is
 
  type t_SM_Main is (s_Idle, s_RX_Start_Bit, s_RX_Data_Bits,
                     s_RX_Stop_Bit, s_Cleanup);
  signal line_pixel : line_t;

 -- Bildverarbeitung
  
  signal line_ready : std_logic :='0';
  signal r_SM_Main : t_SM_Main := s_Idle;


  signal r_RX_Data_R : std_logic := '1';
  signal r_RX_Data   : std_logic := '1';
  signal r_rx_active    : std_logic:='0';
  signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
  signal r_pixel_index : integer range 0 to 240 := 0;  -- 240 Bits Total
  signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
  --signal r_RX_DV     : std_logic := '0';
   
begin
 
  -- Purpose: Double-register the incoming data.
  -- This allows it to be used in the UART RX Clock Domain.
  -- (It removes problems caused by metastabiliy)
  p_SAMPLE : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
      r_RX_Data_R <= i_RX_Serial;
      r_RX_Data   <= r_RX_Data_R;
    end if;
  end process p_SAMPLE;
   
 
  -- Purpose: Control RX state machine
  p_UART_RX : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
         
      case r_SM_Main is
 
        when s_Idle =>
          --r_RX_DV     <= '0';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;
          line_ready <= '0';
          if r_RX_Data = '0' then       -- Start bit detected
            r_SM_Main <= s_RX_Start_Bit;
          else
            r_SM_Main <= s_Idle;
          end if;
 
           
        -- Check middle of start bit to make sure it's still low
        when s_RX_Start_Bit =>
        r_rx_active<='1';
          if r_Clk_Count = (g_CLKS_PER_BIT-1)/2 then
            if r_RX_Data = '0' then
              r_Clk_Count <= 0;  -- reset counter since we found the middle
              r_SM_Main   <= s_RX_Data_Bits;
            else
              r_SM_Main   <= s_Idle;
            end if;
          else
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Start_Bit;
          end if;
 
           
        -- Wait g_CLKS_PER_BIT-1 clock cycles to sample serial data
        when s_RX_Data_Bits =>
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Data_Bits;
          else
            r_Clk_Count            <= 0;
            r_RX_Byte(r_Bit_Index) <= r_RX_Data;
             
            -- Check if we have sent out all bits
            if r_Bit_Index < 7 then
              r_Bit_Index <= r_Bit_Index + 1;
              r_SM_Main   <= s_RX_Data_Bits;
            else
              r_Bit_Index <= 0;
              r_SM_Main   <= s_RX_Stop_Bit;
              line_pixel(r_pixel_index)<=r_RX_Byte;--save 1 byte to line_pixel
              r_pixel_index<= r_pixel_index +1;-- 
            end if;
          end if;
          
          
 
        -- Receive Stop bit.  Stop bit = 1
        when s_RX_Stop_Bit =>
          -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if r_pixel_Index = 240 then --line ready?
            
            line_ready <= '1';-- Line is ready!, reset r_pixel_index
            r_pixel_index <= 0;
          else
            line_ready <= '0';
            
          end if;
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_RX_Stop_Bit;
          else
            --r_RX_DV     <= '1';--byte was received
            r_Clk_Count <= 0;
            r_SM_Main   <= s_Cleanup;
            r_rx_active<='0';
          end if;
 
                   
        -- Stay here 1 clock
        when s_Cleanup =>
          r_SM_Main <= s_Idle;
          --r_RX_DV   <= '0';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;
          line_ready <= '0';
        when others =>
          r_SM_Main <= s_Idle;
 
      end case;
    
    end if;
  end process p_UART_RX;
    o_line <= line_pixel;
    --o_RX_DV   <= r_RX_DV;
    o_RX_Byte <= r_RX_Byte;
    o_line_ready <= line_ready;
    o_rx_active<=r_rx_active;
end rtl;