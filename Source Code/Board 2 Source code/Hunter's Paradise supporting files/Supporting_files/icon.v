`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright:	 Hunter's paradise team,2016
// Created by:	 Hunter's paradise team
// Create Date:  06/05/2016 
// Module Name:  icon.v 
// 
// Create Date: 06/05/2016 01:43:59 PM
// Project Name: ECE540 final project "Hunter's paradise"
// Target Devices: Nexys4 FPGA
// Tool Versions: Vivado 5.1
//-------------------------------------------------------------------------------------------------------
// Description: This module instantiates several IPs that 
// contain the encoded values of the RGB to be displayed on the // colorizer. This module provides appropriate color values 
// according to the location of the icon to be displayed. the 
// icon IPs instantiated in this module are: hunter, score 
// digits, animals, and arrow 
//
// Revision:
// Revision 0.01 - File Created
//
// Additional Comments: This module was sourced from ECE540 
// project 2 
//////////////////////////////////////////////////////////////////////////////////

module icon(
  //
  ////////////////////////////////////////////////////////////////////////////
  // INPUT
  ////////////////////////////////////////////////////////////////////////////
  //
  input        clock, reset,
  input [7:0]  locX_register,	      // INPUTS FROM BOTINFO REGOSTER
  input [7:0]  Loc_Y_register,
  input [7:0]  botinfo_register,
  input [9:0]  pixel_row, pixel_col,       // INPUTS FROM DTG
  input [3:0]	 bow_orient,
  input disp_en,
  input [7:0]  animal_x,
  input [7:0]  animal_y,
  input [2:0]  animalsel,
  input [7:0] vid_pixel_out, 
  input [7:0]  score_low,
  input [7:0]  score_high,
  input animal_hit_flag,  
  //
  ////////////////////////////////////////////////////////////////////////////
  // OUTPUT
  ////////////////////////////////////////////////////////////////////////////
  //
  output reg [7:0] icon_out,		// hunter icon's colors
  output reg [7:0] icon_arrw_out,	// arrow icon's colors
  output reg [7:0] icon_animal,		// animal icon's colors
  output reg [7:0] opening_screen,	// starting screen colors
  output  [13:0] addr_num,			// address of count down number to be displayed before the start of the game
  output reg [1:0]  score_num_low,	// colors of the ones digit of score
  output reg [1:0]  score_num_high,	// colors of the tens  digit of score
  output reg [1:0]  f_score_num_low,	// colors of the ones digit of final score
  output reg [1:0]  f_score_num_high, // colors of the tens digit of final score
  output reg [7:0]  timer_label,	// colors of the timer label
  output reg [7:0]  score_label,	// colors of the score label
  output reg num_en,				// enable for the countdown digits to be displayed before the start of the game
  output reg end_screen 
);

	// temporary wires to connect to the IPs
  wire [13:0] addr_hunter;
  wire [9:0] addr_arrow;
  wire [11:0] addr_animal;
  wire [16:0] addr_screen,addr_end_screen;
  wire [7:0]  dout_screen;
  wire [7:0] dout_ne, dout_n, dout_e, dout_en, dout_idle;  
  wire [7:0] dout_arrow_e, dout_arrow_en, dout_arrow_ne, dout_arrow_n;
  wire [7:0] dout_owl,dout_monkey,dout_fb,dout_deer;
  wire [9:0]  hunter_row, hunter_col;
  wire [9:0]  loc_row, loc_col;
  wire [9:0]  animal_row, animal_col;
  wire [9:0]  num_row_scaled, num_col_scaled;
  wire [7:0]  num_row, num_col;
  wire [9:0]  score_row_low, score_col_low;
  wire [9:0]  score_row_high, score_col_high;
  wire [9:0]  f_score_row_low, f_score_col_low;
  wire [9:0]  f_score_row_high, f_score_col_high;
  wire [7:0]  score_row_l, score_col_l;
  wire [7:0]  score_row_h, score_col_h;
  wire [7:0]  addr_score_low;
  wire [7:0]  addr_score_high;
  wire [7:0]  f_addr_score_low;
  wire [7:0]  f_addr_score_high;
  wire [9:0]  screen_x, screen_y;
  wire [9:0]  endscreen_row, endscreen_col;
  wire [8:0]  addr_timer_label, addr_score_label;
  wire [9:0]  timelabel_row, timelabel_col, scorelabel_row, scorelabel_col;
  wire [7:0]  timelabel_dout, scorelabel_dout;
  wire  dout_0,dout_1,dout_2,dout_3,dout_4,dout_5,dout_6,dout_7,dout_8,dout_9;
  wire  dout_0_h,dout_1_h,dout_2_h,dout_3_h,dout_4_h,dout_5_h,dout_6_h,dout_7_h,dout_8_h,dout_9_h;
  wire  f_dout_0,f_dout_1,f_dout_2,f_dout_3,f_dout_4,f_dout_5,f_dout_6,f_dout_7,f_dout_8,f_dout_9;
  wire  f_dout_0_h,f_dout_1_h,f_dout_2_h,f_dout_3_h,f_dout_4_h,f_dout_5_h,f_dout_6_h,f_dout_7_h,f_dout_8_h,f_dout_9_h;
  wire [7:0] temp_row, temp_col;
  wire dout_end_screen;

	// fixed location of icons
  assign    hunter_row = 320;
  assign    hunter_col = 0;
  assign    num_row = 200;
  assign    num_col = 200;
  assign    score_row_low = 32;
  assign    score_col_low = 480;
  assign    score_row_high = 32;
  assign    score_col_high = 460;
  assign    f_score_row_low = 350;
  assign    f_score_col_low = 420;
  assign    f_score_row_high = 350;
  assign    f_score_col_high = 400;
  assign    screen_x = 20;
  assign    screen_y = 125;
  assign    timelabel_row = 16;
  assign    timelabel_col = 400;
  assign    scorelabel_row = 32;
  assign    scorelabel_col = 400; 
  assign    endscreen_row = 120;
  assign    endscreen_col = 125;

// scaling of icon locations
  assign    loc_row = {Loc_Y_register[7:0],2'b00};
  assign    loc_col = {locX_register[7:0],2'b00}; 
  assign    animal_row = {animal_y[7:0],2'b00};
  assign    animal_col = {animal_x[7:0],2'b00};
  assign    num_row_scaled = {2'b00,num_row};
  assign    num_col_scaled = {2'b00,num_col};
  

// address generation for IPs
  assign addr_arrow = {pixel_row[4:0] - loc_row[4:0] , pixel_col[4:0] - loc_col[4:0]};
  assign addr_hunter = {pixel_row[6:0] - hunter_row[6:0] , pixel_col[6:0] - hunter_col[6:0]};
  assign addr_animal = {pixel_row[5:0] - animal_row[5:0] , pixel_col[5:0] - animal_col[5:0]};
  assign addr_num = {pixel_row[6:0]- num_row_scaled[6:0], pixel_col[6:0] - num_col_scaled[6:0]};
  assign addr_score_low = {pixel_row[3:0] - score_row_low[3:0], pixel_col[3:0] - score_col_low[3:0]};
  assign addr_score_high = {pixel_row[3:0] - score_row_high[3:0], pixel_col[3:0] - score_col_high[3:0]};
  assign f_addr_score_low = {pixel_row[3:0] - f_score_row_low[3:0], pixel_col[3:0] - f_score_col_low[3:0]};
  assign f_addr_score_high = {pixel_row[3:0] - f_score_row_high[3:0], pixel_col[3:0] - f_score_col_high[3:0]};
  assign addr_screen = {pixel_row[7:0]- screen_y[7:0],pixel_col[8:0]-screen_x[8:0]};
  assign addr_end_screen = {pixel_row[7:0]- endscreen_row[7:0],pixel_col[8:0]- endscreen_col[8:0]};
  assign addr_score_label = {pixel_row[3:0]- scorelabel_row[3:0], pixel_col[4:0]- scorelabel_col[4:0]};
  assign addr_timer_label = {pixel_row[3:0]- timelabel_row[3:0], pixel_col[4:0]- timelabel_col[4:0]};

// instantiate the timer label IP
  Timer_Label_IP tinst
  (
    .clka(clock),
    .addra(addr_timer_label),
    .douta(timelable_dout)
  );

// instantiate the digits for ones digit of the final score display
  number_0  f_numinst_0
  (
    .clka(clock),
    .addra(f_addr_score_low),
    .douta(f_dout_0)
  );

  number_1  f_numinst_1
  (
    .clka(clock),
    .addra(f_addr_score_low),
    .douta(f_dout_1)
  );

  number_2  f_numinst_2
  (
    .clka(clock),
    .addra(f_addr_score_low),
    .douta(f_dout_2)
  );

  number_3  f_numinst_3
  (
    .clka(clock),
    .addra(f_addr_score_low),
    .douta(f_dout_3)
  );

  number_4  f_numinst_4
  (
    .clka(clock),
    .addra(f_addr_score_low),
    .douta(f_dout_4)
  );

  number_5  f_numinst_5
  (
    .clka(clock),
    .addra(f_addr_score_low),
    .douta(f_dout_5)
  );

  number_6  f_numinst_6
  (
    .clka(clock),
    .addra(f_addr_score_low),
    .douta(f_dout_6)
  );

  number_7  f_numinst_7
  (
    .clka(clock),
    .addra(f_addr_score_low),
    .douta(f_dout_7)
  );

  number_8  f_numinst_8
  (
    .clka(clock),
    .addra(f_addr_score_low),
    .douta(f_dout_8)
  );

  number_9  f_numinst_9
  (
    .clka(clock),
    .addra(f_addr_score_low),
    .douta(f_dout_9)
  );

// instantiate the digits for tens digit of the final score display
  number_0  f_numinst_0_h
  (
    .clka(clock),
    .addra(f_addr_score_high),
    .douta(f_dout_0_h)
  );

  number_1  f_numinst_1_h
  (
    .clka(clock),
    .addra(f_addr_score_high),
    .douta(f_dout_1_h)
  );

  number_2  f_numinst_2_h
  (
    .clka(clock),
    .addra(f_addr_score_high),
    .douta(f_dout_2_h)
  );

  number_3  f_numinst_3_h
  (
    .clka(clock),
    .addra(f_addr_score_high),
    .douta(f_dout_3_h)
  );

  number_4  f_numinst_4_h
  (
    .clka(clock),
    .addra(f_addr_score_high),
    .douta(f_dout_4_h)
  );

  number_5  f_numinst_5_h
  (
    .clka(clock),
    .addra(f_addr_score_high),
    .douta(f_dout_5_h)
  );

  number_6  f_numinst_6_h
  (
    .clka(clock),
    .addra(f_addr_score_high),
    .douta(f_dout_6_h)
  );

  number_7  f_numinst_7_h
  (
    .clka(clock),
    .addra(f_addr_score_high),
    .douta(f_dout_7_h)
  );

  number_8  f_numinst_8_h
  (
    .clka(clock),
    .addra(f_addr_score_high),
    .douta(f_dout_8_h)
  );

  number_9  f_numinst_9_h
  (
    .clka(clock),
    .addra(f_addr_score_high),
    .douta(f_dout_9_h)
  );

// instantiate the score label IP
  Score_label_IP sinst
  (
    .clka(clock),
    .addra(addr_score_label),
    .douta(scorelabel_dout)
  );

// instantiate the start screen IP
  Start_screen screen_inst
  (
    .clka(clock),
    .addra(addr_screen),
    .douta(dout_screen)
  );

// instantiate the game over screen IP
  gameoverbackground1bit gameinst (
    .clka(clock),    // input wire clka
    .addra(addr_end_screen),  // input wire [16 : 0] addra
    .douta(dout_end_screen)  // output wire [0 : 0] douta
  );

// instantiate the digits for ones digit of the score display
  number_0  numinst_0
  (
    .clka(clock),
    .addra(addr_score_low),
    .douta(dout_0)
  );

  number_1  numinst_1
  (
    .clka(clock),
    .addra(addr_score_low),
    .douta(dout_1)
  );

  number_2  numinst_2
  (
    .clka(clock),
    .addra(addr_score_low),
    .douta(dout_2)
  );

  number_3  numinst_3
  (
    .clka(clock),
    .addra(addr_score_low),
    .douta(dout_3)
  );

  number_4  numinst_4
  (
    .clka(clock),
    .addra(addr_score_low),
    .douta(dout_4)
  );

  number_5  numinst_5
  (
    .clka(clock),
    .addra(addr_score_low),
    .douta(dout_5)
  );

  number_6  numinst_6
  (
    .clka(clock),
    .addra(addr_score_low),
    .douta(dout_6)
  );

  number_7  numinst_7
  (
    .clka(clock),
    .addra(addr_score_low),
    .douta(dout_7)
  );

  number_8  numinst_8
  (
    .clka(clock),
    .addra(addr_score_low),
    .douta(dout_8)
  );

  number_9  numinst_9
  (
    .clka(clock),
    .addra(addr_score_low),
    .douta(dout_9)
  );

// instantiate the digits for tens digit of the score display
  number_0  numinst_0_h
  (
    .clka(clock),
    .addra(addr_score_high),
    .douta(dout_0_h)
  );

  number_1  numinst_1_h
  (
    .clka(clock),
    .addra(addr_score_high),
    .douta(dout_1_h)
  );

  number_2  numinst_2_h
  (
    .clka(clock),
    .addra(addr_score_high),
    .douta(dout_2_h)
  );

  number_3  numinst_3_h
  (
    .clka(clock),
    .addra(addr_score_high),
    .douta(dout_3_h)
  );

  number_4  numinst_4_h
  (
    .clka(clock),
    .addra(addr_score_high),
    .douta(dout_4_h)
  );

  number_5  numinst_5_h
  (
    .clka(clock),
    .addra(addr_score_high),
    .douta(dout_5_h)
  );

  number_6  numinst_6_h
  (
    .clka(clock),
    .addra(addr_score_high),
    .douta(dout_6_h)
  );

  number_7  numinst_7_h
  (
    .clka(clock),
    .addra(addr_score_high),
    .douta(dout_7_h)
  );

  number_8  numinst_8_h
  (
    .clka(clock),
    .addra(addr_score_high),
    .douta(dout_8_h)
  );

  number_9  numinst_9_h
  (
    .clka(clock),
    .addra(addr_score_high),
    .douta(dout_9_h)
  );

// instantiate animal IPs
  owl owl_inst
  (
    .clka(clock),
    .addra(addr_animal),
    .douta(dout_owl)
  );

  monkey monkey_inst (
    .clka(clock),    // input wire clka
    .addra(addr_animal),  // input wire [11 : 0] addra
    .douta(dout_monkey)  // output wire [7 : 0] douta
  );

  flying_bird fb_inst (
    .clka(clock),    // input wire clka
    .addra(addr_animal),  // input wire [11 : 0] addra
    .douta(dout_fb)  // output wire [7 : 0] douta
  );

  deer deer1 
  (
    .clka(clock),    // input wire clka
    .addra(addr_animal),  // input wire [11 : 0] addra
    .douta(dout_deer)  // output wire [7 : 0] douta
  );

// instantiate the arrow IPs
  arrow_n ainst_n
  (
    .clka(clock),
    .addra(addr_arrow),
    .douta(dout_arrow_n)
  );

  arrow_ne ainst_ne
  (
    .clka(clock),
    .addra(addr_arrow),
    .douta(dout_arrow_ne)
  );

  arrow_en ainst_en
  (
    .clka(clock),
    .addra(addr_arrow),
    .douta(dout_arrow_en)
  );

  arrow_e ainst_e
  (
    .clka(clock),
    .addra(addr_arrow),
    .douta(dout_arrow_e)
  );

// instantiate the hunter IPs
  Hunter_E hinst_e
  (
    .clka(clock),
    .addra(addr_hunter),
    .douta(dout_e)
  );

  hunter_EN hinst_en
  (
    .clka(clock),
    .addra(addr_hunter),
    .douta(dout_en)
  );

  hunter_N hinst_n
  (
    .clka(clock),
    .addra(addr_hunter),
    .douta(dout_n)
  );

  hunter_NE hinst_ne 
  (
    .clka(clock),    	// input wire clka
    .addra(addr_hunter),  	// input wire [9 : 0] addra
    .douta(dout_ne)  	// output wire [7 : 0] douta
  );

  hunter_idle hinst_idle
  (
    .clka(clock),
    .addra(addr_hunter),
    .douta(dout_idle)
  );

// display the appropriate icons depending on the current pixel x and y value and the location at which the icons are to be displayed
  always @ (posedge clock) begin
    if(reset)
      begin
        icon_out<=8'b00;
        icon_arrw_out<= 8'b0;
        icon_animal<= 8'b0;
      end

    else
      begin
// display appropriate hunter orientation depending on the bow orient input from the firmware
        if(((pixel_row >=hunter_row) && (pixel_row <= (hunter_row + 10'b0001111111) )) && ((pixel_col >= hunter_col) && (pixel_col <= (hunter_col + 10'b0001111111) )))
          if(animal_hit_flag)
            icon_out <= dout_idle;
        else
          case(bow_orient)
            4'hf:	icon_out <= dout_e;
            4'h0:   icon_out <= dout_e;
            4'h1:	icon_out <= dout_en;
            4'h2:	icon_out <= dout_ne;
            4'h3:	icon_out <= dout_n;
            4'h4:	icon_out <= dout_n;
            default:icon_out <= dout_e;
          endcase      
        else
          icon_out <= 8'd255;

// display the appropriate arrow orientation 
        if(((pixel_row >= loc_row) && (pixel_row <= (loc_row + 10'b0000011111) )) && ((pixel_col >= loc_col) && (pixel_col <= (loc_col + 10'b0000011111) )))
          if(animal_hit_flag)
            icon_arrw_out <= 8'd00;
        else
          case(bow_orient)
            4'hf:	icon_arrw_out <= dout_arrow_e;
            4'h0:   icon_arrw_out <= dout_arrow_e;
            4'h1:	icon_arrw_out <= dout_arrow_en;
            4'h2:	icon_arrw_out <= dout_arrow_ne;
            4'h3:	icon_arrw_out <= dout_arrow_n;
            4'h4:	icon_arrw_out <= dout_arrow_n;
            default:icon_arrw_out <= dout_arrow_e;
          endcase      
        else
          icon_arrw_out <= 8'd00;        

//display the ones digit of the score 
        if(((pixel_row >= score_row_low) && (pixel_row <= (score_row_low + 10'b0000001111) )) && ((pixel_col >= score_col_low) && (pixel_col <= (score_col_low + 10'b0000001111))))
          case(score_low[4:0])
            5'h0: score_num_low <= {1'b0,dout_0};
            5'h1: score_num_low <= {1'b0,dout_1};
            5'h2: score_num_low <= {1'b0,dout_2};
            5'h3: score_num_low <= {1'b0,dout_3};
            5'h4: score_num_low <= {1'b0,dout_4};
            5'h5: score_num_low <= {1'b0,dout_5};
            5'h6: score_num_low <= {1'b0,dout_6};
            5'h7: score_num_low <= {1'b0,dout_7};
            5'h8: score_num_low <= {1'b0,dout_8};
            5'h9: score_num_low <= {1'b0,dout_9};
            default:score_num_low <= {1'b0,dout_0};
          endcase

        else
          score_num_low <= 2'b11;

// display the starting screen
        if(((pixel_row >= screen_y) && (pixel_row <= (screen_y + 10'b0011111111) )) && ((pixel_col >= screen_x) && (pixel_col <= (screen_x + 10'b0111111111))))
          opening_screen <= dout_screen;

        else
          opening_screen <= 8'b00;

// display the game over screen
        if(((pixel_row >= endscreen_row) && (pixel_row <= (endscreen_row + 10'b0011111111) )) && ((pixel_col >= endscreen_col) && (pixel_col <= (endscreen_col + 10'b0111111111))))
          end_screen <= dout_end_screen;

        else
          end_screen <= 1'b0;            

// dispaly the score label
        if(((pixel_row >= scorelabel_row) && (pixel_row <= (scorelabel_row + 10'b000001111) )) && ((pixel_col >= scorelabel_col) && (pixel_col <= (scorelabel_col + 10'b000011111))))
          score_label <= scorelabel_dout;
        else
          score_label <= 8'b00;

// display the timer label
        if(((pixel_row >= timelabel_row) && (pixel_row <= (timelabel_row + 10'b000001111) )) && ((pixel_col >= timelabel_col) && (pixel_col <= (timelabel_col + 10'b000011111))))
          timer_label <= timelable_dout;
        else
          timer_label <= 8'b00;    


// display the tens digit of the final score
        if(((pixel_row >= f_score_row_high) && (pixel_row <= (f_score_row_high + 10'b0000001111) )) && ((pixel_col >= f_score_col_high) && (pixel_col <= (f_score_col_high + 10'b0000011111))))
          case(score_high[4:0])
            5'h0: f_score_num_high <= {1'b0,f_dout_0_h};
            5'h1: f_score_num_high <= {1'b0,f_dout_1_h};
            5'h2: f_score_num_high <= {1'b0,f_dout_2_h};
            5'h3: f_score_num_high <= {1'b0,f_dout_3_h};
            5'h4: f_score_num_high <= {1'b0,f_dout_4_h};
            5'h5: f_score_num_high <= {1'b0,f_dout_5_h};
            5'h6: f_score_num_high <= {1'b0,f_dout_6_h};
            5'h7: f_score_num_high <= {1'b0,f_dout_7_h};
            5'h8: f_score_num_high <= {1'b0,f_dout_8_h};
            5'h9: f_score_num_high <= {1'b0,f_dout_9_h};
            default:f_score_num_high <= {1'b0,f_dout_0_h};
          endcase

        else
          f_score_num_high <= 2'b11;

// display the ones digit of the final score
        if(((pixel_row >= f_score_row_low) && (pixel_row <= (f_score_row_low + 10'b0000001111) )) && ((pixel_col >= f_score_col_low) && (pixel_col <= (f_score_col_low + 10'b0000001111))))
          case(score_low[4:0])
            5'h0: f_score_num_low <= {1'b0,f_dout_0};
            5'h1: f_score_num_low <= {1'b0,f_dout_1};
            5'h2: f_score_num_low <= {1'b0,f_dout_2};
            5'h3: f_score_num_low <= {1'b0,f_dout_3};
            5'h4: f_score_num_low <= {1'b0,f_dout_4};
            5'h5: f_score_num_low <= {1'b0,f_dout_5};
            5'h6: f_score_num_low <= {1'b0,f_dout_6};
            5'h7: f_score_num_low <= {1'b0,f_dout_7};
            5'h8: f_score_num_low <= {1'b0,f_dout_8};
            5'h9: f_score_num_low <= {1'b0,f_dout_9};
            default:f_score_num_low <= {1'b0,f_dout_0};
          endcase

        else
          f_score_num_low <= 2'b11;

// display the tens digit of the score
        if(((pixel_row >= score_row_high) && (pixel_row <= (score_row_high + 10'b0000001111) )) && ((pixel_col >= score_col_high) && (pixel_col <= (score_col_high + 10'b0000011111))))
          case(score_high[4:0])
            5'h0: score_num_high <= {1'b0,dout_0_h};
            5'h1: score_num_high <= {1'b0,dout_1_h};
            5'h2: score_num_high <= {1'b0,dout_2_h};
            5'h3: score_num_high <= {1'b0,dout_3_h};
            5'h4: score_num_high <= {1'b0,dout_4_h};
            5'h5: score_num_high <= {1'b0,dout_5_h};
            5'h6: score_num_high <= {1'b0,dout_6_h};
            5'h7: score_num_high <= {1'b0,dout_7_h};
            5'h8: score_num_high <= {1'b0,dout_8_h};
            5'h9: score_num_high <= {1'b0,dout_9_h};
            default:score_num_high <= {1'b0,dout_0_h};
          endcase

        else
          score_num_high <= 2'b11;

// display the animal according to the input from the randomizer module
        if(((pixel_row >= animal_row) && (pixel_row <= (animal_row + 10'b0000111111) )) && ((pixel_col >= animal_col) && (pixel_col <= (animal_col + 10'b0000111111) )))
          begin
            if(animal_hit_flag)
              icon_animal <= 8'd04;
            else
              if(animalsel!=4)//lion
                begin
                  case(animalsel[1:0])
                    3'h0:    icon_animal <= dout_deer;
                    3'h1:    icon_animal <= dout_owl;
                    3'h2:    icon_animal <= dout_monkey;
                    3'h3:    icon_animal <= dout_fb;
                  endcase
                end
            else
              begin
                icon_animal<=dout_e;
              end                
          end      
        else
          icon_animal <= 8'd04;
      end
  end

// generate the enable for display of the countdown digits 3,2,1 displayed at the beginning of the game
// the enable is one when the pixel x and y values are in the desired range
  always@(posedge clock)
    begin
      if(((pixel_row >= num_row_scaled) && (pixel_row <= (num_row_scaled + 10'b0001111111) )) && ((pixel_col >= num_col_scaled) && (pixel_col <= (num_col_scaled + 10'b001111111) )))
        num_en <= 1;
      else
        num_en <= 0;
    end

endmodule