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
    output logic crc_busy, crc_finished,
    output logic [31:0] crc_out32_xor
    );

    localparam POLY = 32'hEDB8_8320;

    typedef enum logic [1:0] {IDLE, Byte_Xor, Poly_Xor,Done} state_t;

    logic [31:0] crc_out32;

    assign crc_out32_xor=crc_out32^32'hFFFF_FFFF;


    state_t state,next_state;

    always_comb begin
        crc_busy = 'b0;
        crc_finished = 'b0;
        next_state = state;
        case (state)
            IDLE: begin
                if(crc_trigger)
                    next_state = Byte_Xor;
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
            Done: begin
                crc_finished = 'b1;
                if(crc_trigger) begin
                    next_state=Byte_Xor;
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
            crc32_next=32'hFFFF_FFFF;
        end
        Byte_Xor: begin
            crc32_next=crc_out32^crc_32_in;
        end
        Poly_Xor: begin
            crc32_next=(crc_out32[0])?(crc_out32 >> 1) ^ POLY:(crc_out32 >> 1);
        end
        Done: begin
        end
        endcase
    end


   
    //Counter for Poly Xor
    logic [2:0] counter,counter_next;

    always_comb begin 
        if(state==Poly_Xor)
        counter_next=counter+1;
        else
        counter_next=counter;
    end


    always_ff @( posedge clk ) begin 
    if (rst) begin
        counter <= 0;
        crc_out32<=32'hFFFF_FFFF;
    end
    else
        begin
        counter <= counter_next;   
        crc_out32<=crc32_next;
        end
    end


endmodule
