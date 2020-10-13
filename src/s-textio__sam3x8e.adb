------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                       S Y S T E M . T E X T _ I O                        --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1992-2014, Free Software Foundation, Inc.         --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.                                     --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  Minimal version of Text_IO body for use on Sam3x8e, using UART

with System.Sam3x8; use System.Sam3x8;

package body System.Text_IO is

   Baudrate : constant := 115_200;
   --  Bitrate to use

   ---------
   -- Get --
   ---------

   function Get return Character is
      (Character'Val (UART.UART_RHR and 16#FF#));

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      PA8 : constant := 2 ** 8; --  RX line
      PA9 : constant := 2 ** 9; --  TX line

      Uart_Ports : constant := PA8 + PA9;

   begin
      Initialized := True;

      --  Init uart1

      --  Power-up clocks

      PMC.PMC_PCER0 := 2 ** UART_ID + 2 ** PIOA_ID;

      --  Setup IO pins

      PIOA.PDR := Uart_Ports;
      PIOA.ODR := Uart_Ports;
      PIOA.PUER := PA9;
      PIOA.MDDR := Uart_Ports;
      PIOA.ABSR := PIOA.ABSR and not Uart_Ports;

      UART.UART_BRGR := 84_000_000 / (16 * Baudrate);
      UART.UART_MR := UART_MR.CHMODE_NORMAL or UART_MR.PAR_NO;
      UART.UART_CR := UART_CR.TXEN or UART_CR.RXEN;
   end Initialize;

   -----------------
   -- Is_Tx_Ready --
   -----------------

   function Is_Tx_Ready return Boolean is
      ((UART.UART_SR and UART_SR.TXRDY) /= 0);

   -----------------
   -- Is_Rx_Ready --
   -----------------

   function Is_Rx_Ready return Boolean is
      ((UART.UART_SR and UART_SR.RXRDY) /= 0);

   ---------
   -- Put --
   ---------

   procedure Put (C : Character) is
   begin
      UART.UART_THR := Character'Pos (C);
   end Put;

   ----------------------------
   -- Use_Cr_Lf_For_New_Line --
   ----------------------------

   function Use_Cr_Lf_For_New_Line return Boolean is (True);
end System.Text_IO;
