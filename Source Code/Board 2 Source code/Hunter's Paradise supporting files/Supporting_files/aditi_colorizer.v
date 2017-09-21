`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright:	 Hunter's paradise team,2016
// Created by:	 Hunter's paradise team
// Create Date:  06/05/2016 
// Module Name:  colorizer.v 
// 
// Create Date: 06/05/2016 01:43:59 PM
// Project Name: ECE540 final project "Hunter's paradise"
// Target Devices: Nexys4 FPGA
// Tool Versions: Vivado 5.1
//-------------------------------------------------------------------------------------------------------
// Description: This module instantiates the 3 128 by 128 digits 
// used to display the countdown digits 3,2 and 1 before teh 
// start of the game. The main goal of this module is to provide 
// appropriate values of RGB to be displayed on the VGA screen. 
// the score, timer, score and timer labels, hunter, arrow, 
// animals, and background RGB values are appropriately provided
// 
// Revision:
// Revision 0.01 - File Created
//
// Additional Comments: This module was sourced from ECE540 
// project 2 
// 
//////////////////////////////////////////////////////////////////////////////////
module colorizer(
  input clk,					// system clock
  input [7:0] World,			// game backgrund colors
  input [7:0] opening_screen,		// opening screen colors
  input [7:0] Icon,				// hunter icon's colors
  input [7:0] icon_arrw,			// arrow icon's colors
  input [7:0] icon_animal,		// animal icon's colors
  input [13:0] addr_num,			// address from the icon module to be given to the instantiations of the 3 countdown digits 3,2 and 1
  input [9:0] pixel_row,			// unused
  input video_on,		
  input reset,				// system reset
  // output reg [15:0] random,		// used for debugging using leds, unused here
  input num_en,				// countdown number enable, when 1, display the countdown digit
  input [1:0]    score_num_low,	// ones digit color of the score 
  input [1:0]    score_num_high,	// tens digit color of the score 
  input [1:0]    f_score_num_low,	// ones digit of the final scores color (after game over)
  input [1:0]    f_score_num_high,	// tens digit color of the final score (after game over)
  input [7:0]    timer_low_color,	// ones digit color of the timer display 
  input [7:0]    timer_high_color,// tens digit color of the timer display
  input [7:0]    timer_color_3rd,	// hundreds digit color of the timer display
  input [7:0]    timer_label,	// timer label colors
  input [7:0]    score_label,	// score label colors
  input          end_screen,		// screen colors after game over
  output reg [2:0] countdown,	// count register, given as a port for debugging purposes
  output reg game_over,			// game over flag
  output reg [7:0] COLOR  // 3 outs RGB combination together to form a 12 bit colour code
);

  // temporary RGB variables
  wire [2:0] r_world,g_world;
  wire [1:0]b_world;
  wire [2:0] r_icon, g_icon;
  wire [1:0]b_icon;
  wire [2:0] r_opening, g_opening;
  wire [1:0]b_opening;
  wire [2:0] r_icon_arrw, g_icon_arrw;
  wire [1:0]b_icon_arrw;
  wire [2:0] r_icon_animal, g_icon_animal;
  wire [1:0]b_icon_animal;

  // output of the digit IPs 
  wire [7:0] dout_num1,dout_num2,dout_num3;
  
  //reg game_over;
  reg [40:0] game_over_count;
  reg [35:0] countdown_timer;

  localparam  BLACK = 0;
  // RGB value assignments 	   
  assign r_opening = {opening_screen[2:0]};
  assign g_opening = {opening_screen[5:3]};
  assign b_opening = {opening_screen[7:6]};	   

  assign r_world = {World[2:0]};
  assign g_world = {World[5:3]};
  assign b_world = {World[7:6]};

  assign r_icon = {Icon[2:0]};
  assign g_icon = {Icon[5:3]};
  assign b_icon = {Icon[7:6]};

  assign r_icon_arrw = {icon_arrw[2:0]};
  assign g_icon_arrw = {icon_arrw[5:3]};
  assign b_icon_arrw = {icon_arrw[7:6]};	

  assign r_icon_animal = {icon_animal[2:0]};
  assign g_icon_animal = {icon_animal[5:3]};
  assign b_icon_animal = {icon_animal[7:6]};

  //instantiate the 3 countdown digit IPs
  digit1_1bit num1_inst (
    .clka(clk),    // input wire clka
    .addra(addr_num),  // input wire [7 : 0] addra
    .douta(dout_num1)  // output wire [0 : 0] douta
  );

  digit2_1bit num2_inst (
    .clka(clk),    // input wire clka
    .addra(addr_num),  // input wire [7 : 0] addra
    .douta(dout_num2)  // output wire [0 : 0] douta
  );

  digit3_1bit num3_inst (
    .clka(clk),    // input wire clka
    .addra(addr_num),  // input wire [7 : 0] addra
    .douta(dout_num3)  // output wire [0 : 0] douta
  );

  // if video ON, dispaly the background/ icons, else display black screen
  always @(posedge clk)
    begin

      if (reset)
        COLOR<=0; 
      else
        begin
          // random <= timer_low_color; debugging 
          if (video_on == 0)	// if video off, output black
            COLOR <= BLACK;

          //	else if (|Icon)			// if icon is any color but black, pass through
          //	COLOR <= Icon;

          // display the opening screen and the game start countdown			
          else if (video_on == 1 && game_over == 0)
            begin
              if(countdown<7)
                case(countdown[2:0])
                  // display opening screen
                  3'b000: COLOR <= {r_opening,g_opening,b_opening};
                  // display opening screen
                  3'b001: COLOR <= {r_opening,g_opening,b_opening};
                  // display opening screen
                  3'b010: COLOR <= {r_opening,g_opening,b_opening};
                  // display opening screen
                  3'b011: COLOR <= {r_opening,g_opening,b_opening};
                  // display countdown digit 3
                  3'b100: if(num_en) COLOR <= {dout_num3[2:0],dout_num3[5:3],dout_num3[7:6]};
                  // display countdown digit 2
                  3'b101: if(num_en) COLOR <= {dout_num2[2:0],dout_num2[5:3],dout_num2[7:6]};
                  // display countdown digit 1
                  3'b110: if(num_en) COLOR <= {dout_num1[2:0],dout_num1[5:3],dout_num1[7:6]};
                  default: COLOR <= 8'b0;
                endcase

              // dispaly backgound if no icon present in that area     
              else if((countdown==3'b111)&&(Icon == 255)&&(timer_label==0)&&(score_label==0)&&(timer_color_3rd == 8'd255)&&(timer_low_color == 8'd255)&&(timer_high_color == 8'd255)&&(score_num_high == 2'b11)&&(score_num_low == 2'b11) && (icon_animal == 04||icon_animal == 255) && ((!icon_arrw)||(icon_arrw == 255)))    
                COLOR <= {r_world,g_world,b_world};

              else
                begin
                  // display hunter icon
                  if(Icon != 255)
                    COLOR <= {r_icon,g_icon,b_icon};

                  // display arrow icon    
                  else if (icon_arrw)
                    COLOR <= {r_icon_arrw,g_icon_arrw,b_icon_arrw}; 

                  // display ones digit of score
                  else if (score_num_low == 2'b00 || score_num_low == 2'b01)
                    case(score_num_low[0])
                      1'b0: COLOR <= 8'b00000000;
                      1'b1: COLOR <= 8'b11100000;
                    endcase

                  // display tens digit of score
                  else if (score_num_high == 2'b00 || score_num_high == 2'b01)
                    case(score_num_high[0])
                      1'b0: COLOR <= 8'b00000000;
                      1'b1: COLOR <= 8'b11100000;
                    endcase

                  // display ones digit of the timer                              
                  else if(timer_low_color == 8'd0 || timer_low_color == 8'b11100000)
                    COLOR <= timer_low_color;

                  // display tenss digit of the timer 
                  else if(timer_high_color == 8'd0 || timer_high_color == 8'b11100000)
                    COLOR <= timer_high_color;

                  // display hundreds digit of the timer 
                  else if(timer_color_3rd == 8'd0 || timer_color_3rd == 8'b11100000)
                    COLOR <= timer_color_3rd;

                  // display the timer label
                  else if(timer_label)
                    COLOR <= timer_label;

                  // display the score label
                  else if (score_label)
                    COLOR <= score_label;

                  // dispaly the animal icons                                     
                  else
                    COLOR <= {r_icon_animal,g_icon_animal,b_icon_animal};  

                end //else icons 
            end //else game

          // do when game is over
          else 
            begin
              // dispaly final score
              if((f_score_num_high == 2'b11)&&(f_score_num_low == 2'b11))
                case(end_screen)
                  1'b0: COLOR <= 8'b00000000;
                  1'b1: COLOR <= 8'b00011100;
                endcase
              else if (f_score_num_low == 2'b00 || f_score_num_low == 2'b01)
                case(f_score_num_low[0])
                  1'b0: COLOR <= 8'b00000000;
                  1'b1: COLOR <= 8'b11100000;
                endcase
              // dispaly background
              else if (f_score_num_high == 2'b00 || f_score_num_high == 2'b01)
                case(f_score_num_high[0])
                  1'b0: COLOR <= 8'b00000000;
                  1'b1: COLOR <= 8'b11100000;
                endcase
            end

        end //else video on
    end //always



  // define countdown value from 0 to 7
  always@(posedge clk)
    begin
      if(reset)
        begin
          countdown <= 3'b0;
          countdown_timer <= 36'b0;
        end

      else if((countdown<7)&&(countdown_timer == 36'd120000000))
        begin
          countdown <= countdown + 1'b1;
          countdown_timer <= 0;
        end

      else
        begin
          countdown <= countdown;
          countdown_timer <= countdown_timer + 1'b1;
        end
    end

  // a timer that stops the game after 120 seconds
  always@(posedge clk)
    begin
      if(reset)
        begin
          game_over <= 3'b0;
          game_over_count <= 40'b0;
        end

      else if(game_over_count == 40'd12000000000)
        begin
          game_over <= 1'b1;
        end

      else
        begin
          game_over <= 1'b0;
          game_over_count <= game_over_count + 1'b1;
        end
    end
endmodule