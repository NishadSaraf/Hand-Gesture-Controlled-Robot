/*************************************************************
// ESP8266_Master_code - Code for the  Hub FPGA board to send data to the second FPGA baord  //
//
//
// Created  By:  	 	Joel Jacob (JJ)
// Modified By:  	 	Joel Jacob (JJ)
//
//
// Revision History:
// -----------------
// 10th March-2017     	JJ  	        Created this module
// 15th March-2017		  JJ	      		Modified for Testing.
// 19th March-2017		  JJ	          Modified to implement final functionality.
//
// Description
// -----------
// This module accepts an input from the GPIO ports and sends them over to another set of GPIO's
// to set up commuhnication between the Hub and the second FPGA.
//////////

*************************************************************/

//Define pins
int JC_0  = 48;
int JC_1  = 49;
int JC_2  = 50;
int JC_3  = 51;
int JC_4  = 52;

int JB_0 = 40;
int JB_1 = 41;
int JB_2 = 42;
int JB_3 = 43;
int JB_4 = 44;

void setup() {
  //Pinmode
  pinMode(JC_0, INPUT);
  pinMode(JC_1, INPUT);
  pinMode(JC_2, INPUT);
  pinMode(JC_3, INPUT);
  pinMode(JC_4, INPUT);

  pinMode(JB_0, OUTPUT);
  pinMode(JB_1, OUTPUT);
  pinMode(JB_2, OUTPUT);
  pinMode(JB_3, OUTPUT);
  pinMode(JB_4, OUTPUT);

  pinMode(14, OUTPUT);
  pinMode(13, OUTPUT);
  pinMode(12, OUTPUT);
  pinMode(15, OUTPUT);

}

void loop() {

  Gpio_read_0();
  Gpio_read_1();
  Gpio_read_2();
  Gpio_read_3();
  Gpio_read_4();

}

//Read and Write Gpio's appropriately
void Gpio_read_0() {

  int buttonState_0 = digitalRead(JC_0);
  if (buttonState_0 == 1) {
    digitalWrite(14, HIGH);
    digitalWrite(JB_0, HIGH);
  }
  else {
    digitalWrite(14, LOW);
    digitalWrite(JB_0, LOW);
  }
  delay(1);

}

void Gpio_read_1() {
  int buttonState_1 = digitalRead(JC_1);
  if (buttonState_1 == 1) {
    digitalWrite(12, HIGH);
    digitalWrite(JB_1, HIGH);
  }
  else {
    digitalWrite(12, LOW);
    digitalWrite(JB_1, LOW);
  }
  delay(1);
}

void Gpio_read_2() {
  int buttonState_2 = digitalRead(JC_2);
  if (buttonState_2 == 1) {
    digitalWrite(13, HIGH);
    digitalWrite(JB_2, HIGH);
  }
  else {
    digitalWrite(13, LOW);
    digitalWrite(JB_2, LOW);
  }
  delay(1);
}

void Gpio_read_3() {
  int buttonState_3 = digitalRead(JC_3);
  if (buttonState_3 == 1) {
    digitalWrite(15, HIGH);
    digitalWrite(JB_3, HIGH);
  }
  else {
    digitalWrite(15, LOW);
    digitalWrite(JB_3, LOW);
  }

  delay(1);        // delay in between reads for stability
}


void Gpio_read_4() {

  int buttonState_4 = digitalRead(JC_4);
  if (buttonState_4 == 1) {
    digitalWrite(JB_4, HIGH);
  }
  else {
    digitalWrite(JB_4, LOW);
  }
  delay(1);

}
