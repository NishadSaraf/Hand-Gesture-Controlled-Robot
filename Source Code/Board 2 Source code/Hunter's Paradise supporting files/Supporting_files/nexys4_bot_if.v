`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2016 01:43:04 PM
// Design Name: 
// Module Name: nexys4_bot_if
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


module nexys4_bot_if
  #(
    parameter integer RESET_POLARITY_LOW = 1
  )
  (
    input                   sysclk,
    //Interface between nexys4 and picoblaze
    input 	[7:0]			port_id,                // Port ID
    input	[7:0]			out_port,				// Data on output reg port from picoblaze to nexys4
    output reg	[7:0]		in_port,				// Data on input port to picoblaze from nexys4
    input				    k_write_strobe,			//write strobe from picoblaze to nexys4
    input				    writestrobe,			//write strobe from picoblaze to nexys4
    input				    readstrobe,			    //read strobe from picoblaze to nexys4
    output reg		        interrupt,				// nexys4 to picoblaze  
    input                   interrupt_ack,          // picoblaze to nexys4
    output reg	[4:0]		dig7,					//For digit 7 
    output reg	[4:0]		dig6,					//For digit 6
    output reg	[4:0]		dig5,					//For digit 5
    output reg	[4:0]		dig4,					//For digit 4
    output reg	[4:0]		dig3,					//For digits 3
    output reg	[4:0]		dig2,					//For digits 2
    output reg	[4:0]		dig1,					//For digits 1
    output reg	[4:0]		dig0,					//For digits 0



    output reg	[3:0]		dp1,dp2,						//For decimal points
    input	[5:0]			db_btns,				
    input	[15:0]			db_sw,				    //For digits 3 to 0
    output reg	[7:0]		led0to7,					//Driving LED's
    output reg	[7:0]		led15to8,					//Driving LED's



    //Interface between Nexys4 and bot

    output reg	[7:0]		motctl,				    //control of bot motors
    input 	[7:0]			locx,                   // Location x
    input	[7:0]			Loc_Y,				    // Location y
    input 	[7:0]			botinfo,                // Location x
    input	[7:0]			sensors,				// proximity and 
    input 	[7:0]			lmdist,                 // Distance 
    input	[7:0]			rmdist,					//  
    input				upd_sysreg,				//  

	//hunter's paradise parameters
	input [7:0]			animal_x,
	input [7:0]			animal_y,
	input              game_on,
	input [7:0] 		arrow_y,
	input [7:0]			accelerometer,
	output reg [3:0]	bow_orient,
	output reg [7:0]	animal_hit_flag,
	output reg [7:0]	arrow_mvmt,
	output reg [7:0]    arr_x_out,
	output reg [7:0]    arr_y_out
);
  // interruptt logic as per tbrd tail light example given by Roy
  
  

  
  
  
  always @ (posedge sysclk) 
    begin
      if (interrupt_ack == 1'b1) begin
        interrupt <= 1'b0;
      end
      else if (upd_sysreg == 1'b1) begin
        interrupt <= 1'b1;
      end
      else begin
        interrupt <= interrupt;
      end
    end
    
    
  always @ (posedge sysclk) begin
      case (port_id[7:0])
      8'h00 : in_port <= {3'b000,db_btns[5:1]};
      8'h10 : in_port <= {3'b0, db_btns[5:1]};
      8'h01 : in_port <= db_sw;
      8'h11 : in_port <= db_sw[15:8];
      
      8'h0A : in_port <= locx;
      8'h0B : in_port <= Loc_Y;
      8'h0C : in_port <= botinfo;
      8'h0D : in_port <= sensors;
      8'h0E : in_port <= lmdist;
      8'h0F : in_port <= rmdist;
	  8'h20 : in_port <= accelerometer;
	  8'h21 : in_port <= animal_x;
	  8'h22 : in_port <= animal_y;
	  8'h23 : in_port <= {7'b0, game_on};
	  8'h24 : in_port <= arrow_y;
      default : in_port <= 8'b0 ;
    endcase
  end
  always @ (posedge sysclk) 
    begin
      if (writestrobe == 1'b1) 
        begin
          case (port_id[7:0])
            8'h02 : led0to7<=out_port;
            8'h03 : dig3<=out_port[4:0];
            8'h04 : dig2<=out_port[4:0];
            8'h05 : dig1<=out_port[4:0];
            8'h06 : dig0<=out_port[4:0];
            8'h09 : motctl <=out_port;
                        
            8'h07 : dp1<=out_port[3:0];
            8'h12 : led15to8<=out_port;
            8'h13 : dig7<=out_port[4:0];
            8'h14 : dig6<=out_port[4:0];
            8'h15 : dig5<=out_port[4:0];
            8'h16 : dig4<=out_port[4:0];
            8'h17 : dp2<=out_port[3:0];
			
			8'h30 : bow_orient <= out_port[3:0]; 
			8'h31 : animal_hit_flag <= out_port;
			8'h32 : arrow_mvmt <=  out_port;
			8'h33 : arr_x_out <= out_port;
			8'h34 : arr_y_out <= out_port;
            default :  ;
          endcase
        end
    end
endmodule
