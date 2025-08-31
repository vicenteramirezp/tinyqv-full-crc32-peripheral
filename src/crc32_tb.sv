
module crc32_tb;

  // Parameters
    
  //Ports
logic clk;
logic rst;
logic crc_trigger;
logic data_done;
  logic [7:0] crc_32_in;
  logic crc_busy;
  logic crc_finished;
  logic [31:0] crc_out32;

  logic RefIn;
  logic RefOut;
  logic Xor_out;
  logic Init;
  logic [31:0]POLY_in;

  
  crc32  crc32_inst (
    .clk(clk),
    .rst(rst),
    .crc_trigger(crc_trigger),
    .data_done(data_done),
    .crc_32_in(crc_32_in),
    .RefIn(RefIn),
    .RefOut(RefOut),
    .Xor_out(Xor_out),
    .Init(Init),
    .POLY_in(POLY_in),
    .crc_busy(crc_busy),
    .crc_finished(crc_finished),
    .crc_out32_xor(crc_out32)
  );

always #5  clk = ! clk ;



initial begin
    clk=0;
    rst=0;
    data_done=0;
    POLY_in=32'h04C11DB7; // ISO-HDLC
   // POLY_in=32'h814141AB; // AIXM
    RefIn=1;
    Init=1;
    Xor_out=1;
    #10
    rst=1;
    #10
    rst=0;
    
    for(int i = 0; i<9; i++)begin
       #100
       crc_32_in=49+i;
       #10
       crc_trigger=1;
        #10
        crc_trigger=0;
        
    end
    #100
    data_done=1;
    #100
    data_done=0;
    #10
    POLY_in=32'h814141AB; // AIXM
    RefIn=0;
    Init=0;
    Xor_out=0;
    for(int i = 0; i<9; i++)begin
      #100
      crc_32_in=49+i;
      #10
      crc_trigger=1;
       #10
       crc_trigger=0;
       
   end



end

endmodule