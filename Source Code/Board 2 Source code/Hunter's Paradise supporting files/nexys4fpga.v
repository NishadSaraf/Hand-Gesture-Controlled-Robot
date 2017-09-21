`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Created by:	 Hunter's paradise team:Parimal Kulkarni ,Aditi Kulkarni,Rucha Rasane,Omkar Ghatpande
// Create Date:  06/05/2016 
// Module Name:  nexys4fpga.v 
// Modified by:  Parimal Kulkarni for Android Interface via other board
// 
// Create Date: 06/05/2016 01:43:59 PM
// Project Name: ECE540 final project "Hunter's paradise"
// Target Devices: Nexys4 FPGA
// Tool Versions: Vivado 5.1
//-------------------------------------------------------------------------------------------------------
// Description: This is a top level module that instantiates 
// several modules that perform the functions pertaining to the 
// Hunter's paradise game. 
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Modified the constraints for JC header for connecting to other board which is connected 
//				   to android phone via blynk. Added small logic for checking which accelerometer data to 
//				   use for hunter control(phone's or on board) same for center button and reset  	  
//
// Additional Comments: This module was sourced from ECE540 project 2 and additional modules were instantiated 
// in this top level module. The other modules though unused are retained in the project. 
//////////////////////////////////////////////////////////////////////////////////////////////////////


module nexys4fpga
(
input clk, 		// 100MHz clock from on-board oscillator
input btnL, btnR, 	// pushbutton inputs - left (db_btns[4])and right
				// (db_btns[2])
input btnU, btnD, 	// pushbutton inputs - up (db_btns[3]) and down
				// (db_btns[1])
input btnC, 		// pushbutton inputs - center button -> db_btns[5]
input btnCpuReset, 	// red pushbutton input -> db_btns[0]
input [15:0] sw, 	// switch input	
output [15:0] led, 	// LED outputs
output [6:0] seg, 	// Seven segment display cathode pins
output dp,
output [7:0] an, 	// Seven segment display anode pins
output [7:0] JA, 	// JA Header
input [7:0] JC,     //JC header

output vga_hsync,vga_vsync, // VGA sync ports
output [2:0] vga_red,vga_green,
output [1:0] vga_blue,

output   SCLK,			 // SPI interface ports
output   MOSI,
input    MISO ,
output   SS 

);
 //alternative to accelerometer input

// interconnecting wires
// interconnecting wires
  wire locked;
  wire VIDEO_CLOCK;
  wire vga_hsync1,vga_vsync1;
  wire [7:0] Icon;
  wire [1:0] world;
  wire video_on;
  wire [2:0] vga_red1,vga_green1;
  wire [1:0] vga_blue1;
  wire [2:0] countdown;
  wire end_screen;

wire [15:0] db_sw; // debounced switches
wire [5:0] db_btns; // debounced buttons
wire [5:0] alternate_db_btns;


wire sysclk; // 100MHz clock from on-board oscillator
wire sysreset; // system reset signal - asserted high to force
// reset
//wire [4:0] dig7, dig6,dig5, dig4,dig3, dig2,dig1, dig0; // display digits
wire [7:0] decpts; // decimal points
wire [7:0] segs_int; // segment outputs (internal)
wire [63:0] digits_out; // digits_out (only for simulation)
//wire clk_2Hz_en; // Tail light clock enable. used as interrupt to
// PicoBlaze
// PicoBlaze interface
wire [11:0] address;
wire [17:0] instruction;
wire bram_enable;
wire [7:0] port_id;
wire [7:0] out_port;
wire [7:0] in_port;
wire writestrobe;
wire k_write_strobe;
wire readstrobe;
wire interrupt;
wire interrupt_ack;
wire [7:0] decpts_reg;
//Bot registers
wire [7:0]	motctl;			
wire [7:0]	locx;       
wire [7:0]	locy;		
wire [7:0]	botinfo;    
wire [7:0]	sensors;	
wire [7:0]	lmdist;                 
wire [7:0]	rmdist;					  
wire    	upd_sysregs;				  

//Video output
wire [9:0]	vid_row;                 
wire [9:0]	vid_col;					  
wire [7:0]	vid_pixel_out;				  
wire [7:0] x1,x2;
wire [11:0]ACCEL_X;
wire [11:0]ACCEL_Y;
wire [11:0]ACCEL_Z;
wire Data_Ready;	
wire [4:0] control;
//Connection to other nexys4ddr board 
assign control=~JC;
//Inverted for active low logic. 
//Control[3] bit decides which data to use for hunter control 
//For control[3]==1, Data from phone else from same board(push button and on board accelerometer) 
assign accelerometer = (control[3]==1'b1)?{6'b0,control[1:0]}:{4'b0,ACCEL_Y[11:8]};
assign alternate_db_btns=(control[3]==1'b1)?{control[2],5'b00000}:{db_btns};

assign led[15:12]=control[3:0];
wire  [9:0] vid_row_new ;
wire [9:0]  vid_col_new ;

wire kcpsm6_sleep;
wire kcpsm6_reset;
wire cpu_reset;
wire rdl;
wire int_request;
wire [15:0] random;

wire [7:0] x1,x2;
wire [11:0]ACCEL_X;
wire [11:0]ACCEL_Y;
wire [11:0]ACCEL_Z;
wire Data_Ready;	
wire 	[4:0]		dig7, dig6,
				dig5, dig4,
				dig3, dig2, 
				dig1, dig0;				
wire 	[7:0]	animal_x;
wire 	[7:0]	animal_y;
wire    [2:0]   animalsel;
wire    [5:0]   minutes;
wire 	[7:0]	arrow_x;
wire 	[7:0] 	arrow_y;
wire 	[7:0]	accelerometer;
wire	[3:0]	bow_orient;
wire	[7:0]	animal_hit_flag;
wire	[7:0]	arrow_mvmt;
wire    [7:0]  icon_arrow;
wire    [7:0]  icon_animal;
wire    [7:0]  arr_x_out;
wire    [7:0]  arr_y_out;
wire    [13:0]  addr_num;
wire    [7:0]  opening_screen;
wire    [7:0]  timer_low_color;
wire    [7:0]  timer_high_color;
wire    [7:0]  timer_color_3rd;
wire    [7:0] score_label;
wire    [7:0]  timer_label;
wire    disp_en;
wire   num_en;
wire   [1:0]   score_num_low;
wire   [1:0]   score_num_high;
wire   [1:0]   f_score_num_low;
wire   [1:0]   f_score_num_high;
wire    game_on;
wire    game_over;
	
parameter SIMULATE = 0;
assign decpts=decpts_reg;
assign decpts=decpts_reg;
assign sysclk = clk;
assign sysreset = control[4]; // Reset the game from android phone

// RESET_POLARITLY_LOW is 1 because btnCpuReset is asserted
// high and the debounced version of btnCpuReset becomees
// sysreset

assign vga_red = vga_red1;
assign vga_green = vga_green1;
assign vga_blue = vga_blue1;

assign vga_hsync = vga_hsync1;
assign vga_vsync = vga_vsync1;

assign vid_row_new = vid_row ;
assign vid_col_new = vid_col ;

assign dp = segs_int[7];
assign seg = segs_int[6:0];

assign	JA = {sysclk, sysreset, 6'b000000};

assign arrow_x = arr_x_out;	// unused
assign arrow_y = arr_y_out;	// unused

//assign game_on = 1;

//instantiate the  random animal location generator module
animalrandomizer random_gen1(
.clk(sysclk),
.loc_animal_X(animal_x),
.loc_animal_Y(animal_y),
.animalselect(animalsel),
.animal_hit_flag(animal_hit_flag[0]),
.minutes(minutes),
//.random(random), used for debugging using leds. now left unused
.reset(~sysreset)
);
	
// instantiate th edebounce module
debounce
#(
.RESET_POLARITY_LOW(1),
.SIMULATE(SIMULATE)
) 

DB
(
.clk(sysclk),
.pbtn_in({btnC,btnL,btnU,btnR,btnD,btnCpuReset}),
.switch_in(sw),
.pbtn_db(db_btns),
.swtch_db(db_sw)
);

// instantiate the 7-segment, 8-digit display
sevensegment
#(
.RESET_POLARITY_LOW(1),
.SIMULATE(SIMULATE)
) 

SSB
(
// inputs for control signals
.d0(dig0),
.d1(dig1),
.d2(dig2),
.d3(dig3),
.d4(dig4),
.d5(dig5),
.d6(dig6),
.d7(dig7),
.dp(decpts),
// outputs to seven segment display
.seg(segs_int),
.an(an),
// clock and reset signals (100 MHz clock, active high reset)
.clk(sysclk),
.reset(sysreset),
// ouput for simulation only
.digits_out(digits_out)
);

// instantiate the firmware module
proj2demo #(
.C_FAMILY ("7S"), // Family 'S6' or 'V6' or '7S
.C_RAM_SIZE_KWORDS (2), // Program size '1', '2' or '4'
.C_JTAG_LOADER_ENABLE (1)) // Include JTAG Loader when set to 1'b1
APPPGM (
.rdl (rdl),
.enable (bram_enable),
.address (address),
.instruction (instruction),
.clk (sysclk));

// this module is used only to instantiate map.v 
// other variables, though left connected aren't used in the project
bot bot_inst
(
  .MotCtl_in(motctl),
  .LocX_reg(locx),
  .Loc_Y_reg(locy),
  .Sensors_reg(sensors),
  .BotInfo_reg(botinfo),
  .LMDist_reg(lmdist),
  .RMDist_reg(rmdist),
  .vid_row(vid_row_new >> 1),		
  .vid_col(vid_col_new >> 1),		
  .vid_pixel_out(vid_pixel_out),	
  .clk(sysclk),
  .reset(~sysreset),			
  .upd_sysregs(upd_sysregs),
  .minutes(minutes)
 );

//instantiate the interface file that connects the hardware to the firmware
nexys4_bot_if
  #(
    .RESET_POLARITY_LOW(1)
  )
  
  n4 (
    .sysclk(sysclk),
    .port_id(port_id),
    .out_port(out_port),				
    .in_port(in_port),				
    .k_write_strobe(k_write_strobe),			
    .writestrobe(writestrobe),
    .readstrobe(readstrobe),			    
    .interrupt(interrupt),
	.interrupt_ack(interrupt_ack),
    .dig7(dig7),
    .dig6(dig6),
    .dig5(dig5),
	.dig4(dig4),
	.dig3(dig3),
	.dig2(dig2),
	.dig1(dig1),
	.dig0(dig0),
    .dp1(decpts_reg[3:0]),
    .dp2(decpts_reg[7:4]),
    .led0to7(x2),
    .led15to8(x1),
    .db_btns(alternate_db_btns),				
    .db_sw(db_sw),
    .motctl(motctl),
    .locx(locx),
    .Loc_Y(locy),
    .botinfo(botinfo),
    .sensors(sensors),
    .lmdist(lmdist),
    .rmdist(rmdist),
    .upd_sysreg(upd_sysregs),
	.animal_x(animal_x),
	.animal_y(animal_y),
	.game_on(~game_over),
	.arrow_y(arrow_y),
	.arr_x_out(arr_x_out),
	.arr_y_out(arr_y_out),
	.accelerometer(accelerometer),
	.bow_orient(bow_orient),
	.animal_hit_flag(animal_hit_flag),
	.arrow_mvmt(arrow_mvmt)
  );
  
//instantiate the colorizer module
colorizer col(
    .clk(sysclk),
    .World(vid_pixel_out),
    .Icon(Icon),
    .icon_arrw(icon_arrow),
    .icon_animal(icon_animal),
	.video_on(video_on),
	.reset(~sysreset),
	.addr_num(addr_num),
	.num_en(num_en),
	.score_num_low(score_num_low),
	.score_num_high(score_num_high),
	.countdown(countdown),
	.timer_low_color(timer_low_color),
    .timer_high_color(timer_high_color),
    .timer_color_3rd(timer_color_3rd),
    .score_label(score_label),
    .timer_label(timer_label),
    .f_score_num_low(f_score_num_low),
    .f_score_num_high(f_score_num_high),
    //.random(random),
    .pixel_row(vid_row),
	.opening_screen(opening_screen),
	.end_screen(end_screen),
	.game_over(game_over),
    .COLOR({vga_red1,vga_green1,vga_blue1})  // 3 outs RGB combination together to form a 12 bit colour code
    );
 
//instantiate the timer display countdown module
 timer_display down_timer
 (
 .clk(sysclk),
 .reset(~sysreset),
 .pixel_row(vid_row),
 .pixel_col(vid_col),
 .random(random),
 .timer_color_low(timer_low_color),
 .timer_color_high(timer_high_color),
 .timer_color_3rd(timer_color_3rd)
    );  
  
//instantiate the DTG module
  dtg d1  
  ( .clock(VIDEO_CLOCK),
    .rst(~sysreset),
    .horiz_sync(vga_hsync1),
    .vert_sync(vga_vsync1),
    .video_on(video_on),
    .pixel_row(vid_row),
    .pixel_column(vid_col)
    );


// instantiate the icon module
icon flag_ship
(
.clock(sysclk),
.reset(~sysreset),
.botinfo_register(botinfo),
.locX_register(arr_x_out),
.Loc_Y_register(arr_y_out),
.pixel_row(vid_row),
.pixel_col(vid_col),
.icon_out(Icon),
.icon_arrw_out(icon_arrow),
.bow_orient(bow_orient),
.disp_en(disp_en),
.animal_x(animal_x),
.animal_y(animal_y),
.icon_animal(icon_animal),
.animalsel(animalsel),
.vid_pixel_out(vid_pixel_out),
.addr_num(addr_num),
.score_num_low(score_num_low),
.score_num_high(score_num_high),
.f_score_num_low(f_score_num_low),
.f_score_num_high(f_score_num_high),
.score_low({3'b0, dig0}),
.score_high({3'b0, dig1}),
.score_label(score_label),
.timer_label(timer_label),
.opening_screen(opening_screen),
.animal_hit_flag(animal_hit_flag[0]),
.end_screen(end_screen),
.num_en(num_en)
);

// instantiate the accelerometer module
ADXL362Ctrl
#
(
   //.SYSCLK_FREQUENCY_HZ(SYSCLK_FREQUENCY_HZ),
   //.SCLK_FREQUENCY_HZ(SCLK_FREQUENCY_HZ),
   //.NUM_READS_AVG(NUM_READS_AVG),   
   //.UPDATE_FREQUENCY_HZ(UPDATE_FREQUENCY_HZ)
)
ACC
(
 .SYSCLK(sysclk), 
 .RESET(~sysreset), 
 
 // Accelerometer data signals
 .ACCEL_X(ACCEL_X),
 .ACCEL_Y(ACCEL_Y), 
 .ACCEL_Z(ACCEL_Z),
 .ACCEL_TMP(), 
 .Data_Ready(Data_Ready), 
 
 //SPI Interface Signals
 .SCLK(SCLK), 
 .MOSI(MOSI),
 .MISO(MISO), 
 .SS(SS)
);

// connected but unused in this program
assign kcpsm6_sleep = 1'b0;

// instantiate the 2Hz clock divider. This module takes the 100MHz input clock
// and generates a single pulse at 2Hz. We use this as an interrupt to the PicoBlaze
kcpsm6 #(
.interrupt_vector (12'h3FF),
.scratch_pad_memory_size (64),
.hwbuild (8'h00))
APPCPU(
.address (address),
.instruction (instruction),
.bram_enable (bram_enable),
.port_id (port_id),
.write_strobe (writestrobe),
.k_write_strobe (k_write_strobe),
.out_port (out_port),
.read_strobe (readstrobe),
.in_port (in_port),
.interrupt (interrupt),
.interrupt_ack (interrupt_ack),
.reset (~(sysreset|rdl)),
.sleep (kcpsm6_sleep),
.clk (sysclk));

// instantiate the clock divider IP to be given to the DTG module
clk_wiz_0 video_clock_instance
     (
     // Clock in ports
      .clk_in1(sysclk),      // input clk_in1
      // Clock out ports
      .clk_out1(VIDEO_CLOCK),     // output clk_out1
      // Status and control signals
      .reset(~sysreset), // input reset
      .locked(locked)
      );      // output locked
  // INST_TAG_END ------ End INSTANTIATION Template ---------


endmodule
    