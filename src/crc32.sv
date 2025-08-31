`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2025 09:10:02 PM
// Design Name: 
// Module Name: crc32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module crc32(
    input logic clk, rst, 
    input logic crc_trigger,data_done,
    input logic [7:0] crc_32_in,
    input logic RefIn,
    input logic RefOut,
    input logic Xor_out,
    input logic Init,
    input logic [31:0]POLY_in,
    output logic crc_busy, crc_finished,
    output logic [31:0] crc_out32_xor
    );

    //localparam POLY = 32'hEDB8_8320;

    typedef enum logic [2:0] {IDLE, Byte_Xor,Byte_Xor_ref, Poly_Xor_ref,Poly_Xor,Done} state_t;

    logic [31:0] crc_out32;

    assign crc_out32_xor=(Xor_out)?crc_out32^32'hFFFF_FFFF:crc_out32^32'd0;

    logic [31:0]POLY;

    bit_reverser  bit_reverser_inst (
        .en(RefIn),
        .in_data(POLY_in),
        .out_data(POLY)
      );



    state_t state,next_state;

    always_comb begin
        crc_busy = 'b0;
        crc_finished = 'b0;
        next_state = state;
        case (state)
            IDLE: begin
                if(crc_trigger)begin
                    if(RefIn)
                    next_state = Byte_Xor_ref;
                    else
                        next_state = Byte_Xor;
                end

            end
            Byte_Xor: begin
                crc_busy = 'b1;
                next_state=Poly_Xor;
            end
            Poly_Xor: begin
                crc_busy = 'b1;
                if(counter==3'h7)
                    next_state=Done;
            end
            Byte_Xor_ref: begin
                crc_busy = 'b1;
                next_state=Poly_Xor_ref;
            end
            Poly_Xor_ref: begin
                crc_busy = 'b1;
                if(counter==3'h7)
                    next_state=Done;
            end
            Done: begin
                crc_finished = 'b1;
                if(crc_trigger) begin
                    next_state=(RefIn)?Byte_Xor_ref:Byte_Xor;
                end
                else if (data_done) begin
                    next_state=IDLE;
                end
            end
        endcase
    end


    /* FSM that governs CRC functionality */
    always_ff @(posedge clk) begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;   
    end

    logic [31:0]crc32_next;


    always_comb begin 
        crc32_next=crc_out32;
        case (state)
        IDLE: begin
            crc32_next=(Init)?32'hFFFF_FFFF:32'd0;
        end
        Byte_Xor_ref: begin
            crc32_next=crc_out32^crc_32_in;
        end
        Poly_Xor_ref: begin
            crc32_next=(crc_out32[0])?(crc_out32 >> 1) ^ POLY:(crc_out32 >> 1);
        end
        Byte_Xor: begin
            crc32_next={crc_out32[31:24]^crc_32_in,crc_out32[23:0]};
        end
        Poly_Xor: begin
            crc32_next=(crc_out32[31])?(crc_out32 << 1) ^ POLY:(crc_out32 << 1);
        end
        Done: begin
        end
        endcase
    end


   
    //Counter for Poly Xor
    logic [2:0] counter,counter_next;

    always_comb begin 
        if(state==Poly_Xor|state==Poly_Xor_ref)
        counter_next=counter+1;
        else
        counter_next=counter;
    end


    always_ff @( posedge clk ) begin 
    if (rst) begin
        counter <= 0;
        crc_out32<=(Init)?32'hFFFF_FFFF:32'd0;
    end
    else
        begin
        counter <= counter_next;   
        crc_out32<=crc32_next;
        end
    end


endmodule
