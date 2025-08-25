/*
 * Copyright (c) 2025 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

 `default_nettype none

 // Change the name of this module to something that reflects its functionality and includes your name for uniqueness
 // For example tqvp_yourname_spi for an SPI peripheral.
 // Then edit tt_wrapper.v line 41 and change tqvp_example to your chosen module name.
 module crc_wrapper (
     input         clk,          // Clock - the TinyQV project clock is normally set to 64MHz.
     input         rst_n,        // Reset_n - low to reset.
 
     input  [7:0]  ui_in,        // The input PMOD, always available.  Note that ui_in[7] is normally used for UART RX.
                                 // The inputs are synchronized to the clock, note this will introduce 2 cycles of delay on the inputs.
 
     output [7:0]  uo_out,       // The output PMOD.  Each wire is only connected if this peripheral is selected.
                                 // Note that uo_out[0] is normally used for UART TX.
 
     input [5:0]   address,      // Address within this peripheral's address space
     input [31:0]  data_in,      // Data in to the peripheral, bottom 8, 16 or all 32 bits are valid on write.
 
     // Data read and write requests from the TinyQV core.
     input [1:0]   data_write_n, // 11 = no write, 00 = 8-bits, 01 = 16-bits, 10 = 32-bits
     input [1:0]   data_read_n,  // 11 = no read,  00 = 8-bits, 01 = 16-bits, 10 = 32-bits
     
     output [31:0] data_out,     // Data out from the peripheral, bottom 8, 16 or all 32 bits are valid on read when data_ready is high.
     output        data_ready,
 
     output        user_interrupt  // Dedicated interrupt request for this peripheral
 );
 
     always @(posedge clk) begin
         if (rst_n==1) begin
            Enable_reg <= 0;
            Config_reg<=0;
            input_data<=0;
         end else begin
             if (address == 6'h0) begin
                 if (data_write_n != 2'b11)              Enable_reg[7:0]   <= data_in[7:0];
                 if (data_write_n[1] != data_write_n[0]) Enable_reg[15:8]  <= data_in[15:8];
                 if (data_write_n == 2'b10)              Enable_reg[31:16] <= data_in[31:16];
             end
             if (address == 6'h4) begin
                if (data_write_n != 2'b11)              Config_reg[7:0]   <= data_in[7:0];
                if (data_write_n[1] != data_write_n[0]) Config_reg[15:8]  <= data_in[15:8];
                if (data_write_n == 2'b10)              Config_reg[31:16] <= data_in[31:16];
            end
            if (address == 6'h8) begin
                if (data_write_n != 2'b11)              input_data[7:0]   <= data_in[7:0];
                if (data_write_n[1] != data_write_n[0]) input_data[15:8]  <= data_in[15:8];
                if (data_write_n == 2'b10)              input_data[31:16] <= data_in[31:16];
            end
         end

     end
     
     reg [7:0] Enable_reg;
     reg [7:0] Config_reg;
     reg [7:0] input_data;
     reg [31:0] output_data;

 
     // All other addresses read 0.
     assign data_out = (address == 6'h0) ? {24'h0, Enable_reg} :
                       (address == 6'h4) ? {24'h0, Config_reg} :
                       (address == 6'hC) ? output_data :
                       32'h0;
 
     // All reads complete in 1 clock
     assign data_ready = 1;
     

 


     // List all unused inputs to prevent warnings
     // data_read_n is unused as none of our behaviour depends on whether
     // registers are being read.
     wire _unused = &{data_read_n,1'b0};
 
 endmodule