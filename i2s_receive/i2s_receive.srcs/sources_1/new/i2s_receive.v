`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2020 10:52:35 AM
// Design Name: 
// Module Name: i2s_receive
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


module i2s_receive#(
    parameter DATA_WIDTH = 32,
   parameter PACKET_WIDTH=2
   )
(
       input M_AXIS_ACLK,
       input M_AXIS_ARESETN,
       output reg  M_AXIS_TVALID,
       output reg [DATA_WIDTH-1 : 0] M_AXIS_TDATA,
       output reg  M_AXIS_TLAST,
       input wire  M_AXIS_TREADY,
       
       input i_sck,
       input i_ws,
       input i_sd
   );
   
   
   //Croosing clock domains Double Flopping  
   //4 DFFs (as a shiftreg) and a AND2B1 to detect the edge on the slow clock
  reg [1:0] sck_sync;
  always @(posedge M_AXIS_ACLK)
    sck_sync <= {sck_sync,i_sck};
  wire sck_rise = sck_sync == 2'b01;
  wire sck_fall = sck_sync == 2'b10;
   
  
       
      //ws regs
      reg wsd=0;
      reg wsdd=0;
      always@(posedge M_AXIS_ACLK)
        begin
        if(sck_rise)
            begin
                wsd <= i_ws;
                wsdd <= wsd;
            end
        end
    
     //WSP gen 
     wire wsp = wsd ^ wsdd;
    
 
 
         //counter
      reg[$clog2(DATA_WIDTH+1)-1:0] counter=0;
      wire [DATA_WIDTH:0] en;
     
     //wire loop 
       genvar i;        
        generate        
        for (i = 0; i < DATA_WIDTH+1; i = i+1) 
            begin  
                assign en[i] = (counter == i);
            end
        endgenerate 
        //counter
        always@(posedge M_AXIS_ACLK)
            begin
            if(sck_fall)
                begin
                    if(wsp)
                        counter <= 0;
                     else if (~en[DATA_WIDTH])
                        counter <= counter + 1;
                 end
            end
        
   
      //paralles regs
      integer ii=0;
      reg[0:DATA_WIDTH-1] r_data=0;
    //firt reg special case
      always@(posedge M_AXIS_ACLK)
        begin
            if(en[0] & sck_rise)
               r_data[0] <= i_sd;
        end
  
      always@(posedge M_AXIS_ACLK)
        begin
        if(sck_rise)
            begin
                for(ii=1;ii < DATA_WIDTH; ii = ii+1)
                    begin
                    if(wsp)
                        r_data[ii] <= 0;
                    else if(en[ii])
                        r_data[ii] <= i_sd;
                    end
             end
          end
      
        //AXI SIGNALS
         always @(posedge M_AXIS_ACLK)
            if (sck_rise && wsp)
              M_AXIS_TDATA <= r_data;

          always @(posedge M_AXIS_ACLK)
            begin
            if (!M_AXIS_ARESETN)
              M_AXIS_TVALID <= 0;
            
            else if (sck_rise && wsp)
              M_AXIS_TVALID <= 1;
           
            else if (M_AXIS_TREADY)
              M_AXIS_TVALID <= 0;
            
            end
           
           
           
            //TLAST GENERATION
            reg [$clog2(PACKET_WIDTH)-1:0] count_last=0;
            wire tlast_gen= (count_last == PACKET_WIDTH-1) ? 1 : 0;
            
                    
          always @(posedge M_AXIS_ACLK)
              begin
                   if(!M_AXIS_ARESETN)
                    count_last <= 0;
                  
                   else if (sck_rise && wsp)
                      count_last <= count_last + 1;
              end
              
          always @(posedge M_AXIS_ACLK)
            begin
            if (sck_rise && wsp && tlast_gen)
                 M_AXIS_TLAST <= 1;
             else
               M_AXIS_TLAST <= 0;
            end
   
 endmodule