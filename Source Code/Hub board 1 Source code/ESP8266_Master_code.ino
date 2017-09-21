/*************************************************************
  Blynk is a platform with iOS and Android apps to control
  Arduino, Raspberry Pi and the likes over the Internet.
  You can easily build graphic interfaces for all your
  projects by simply dragging and dropping widgets.

    Downloads, docs, tutorials: http://www.blynk.cc
    Blynk community:            http://community.blynk.cc
    Social networks:            http://www.fb.com/blynkapp
                                http://twitter.com/blynk_app

  Blynk library is licensed under MIT license
  This example code is in public domain.

 *************************************************************
 // ESP8266_Master_code - Code for the  ESP 8266 on the Hub FPGA board  //
 //
 //
 // Created  By:  	 	Joel Jacob (JJ)
 // Modified By:  	  Nishad Saraf (NS),PArimal Kulkarni (PK)
 //
 //
 // Revision History:
 // -----------------
 // 10th March-2017     	JJ  	        Created this module
 // 15th March-2017		    JJ	      		Modified for Testing.
 // 19th March-2017		    JJ,NS,PK		  Modified to implement final functionality.
 //
 // Description
 // -----------
 // This module implements an interface between the ESP 8266,that receives control information,
 // from the Android phone and also implements the Blynk Bridge API to connect to the Bot.
 // The Accelerometer input from the Android phone is also sent to the HUB FPGA to be sent to the
 // Second FPGA board which contains the "hunter's Paradise" Game.
 //////////

 *************************************************************/

/* Comment this out to disable prints and save space */
#define BLYNK_PRINT Serial


#include <ESP8266WiFi.h>
#include <BlynkSimpleEsp8266.h>

// You should get Auth Token in the Blynk App.
// Go to the Project Settings (nut icon).

char auth[] = "Auth Key"; //local server


// Your WiFi credentials.
// Set password to "" for open networks.

char ssid[] = "SSID";
char pass[] = "PAss";

//Set up global constants
int a = 0, b = 0, c = 0, d = 0, e = 0;
int incomingByte = 0;   // for incoming serial data
int up = 0,down = 2;

//Define pins
#define LED_PIN 0
#define LED_PIN_1 2

//Define GPIO ports
#define JC_0 12
#define JC_1 13
#define JC_2 14
#define JC_3 16
#define JC_4 2
#define JC_5 4
#define JC_6 5

// function to read values from UART port
void ReadSerial()
{
  if (Serial.available() > 0 && e == 0) {
      // read the incoming byte
         incomingByte = Serial.read();//not using this
         if(incomingByte == 87 ) //w
         {
           a = 1;
           b = c = d = 0;
           GoForward();
         }
       else if(incomingByte == 83) //s
        {
           d = 1;
           a=b=c=0;
           GoReverse();
        }else if(incomingByte == 65) //a
        {
           c = 1;
           a=b=d=0;
           GoLeft();
        }else if(incomingByte == 68) //d
        {
          b = 1;
          a=c=d=0;
          GoRight();
        }
        else if(incomingByte == 81) //q
        {
          a=0;
          d=0;
          GoForward();
          GoReverse();
        }
   }
}

//Bridge API to connect to the bot's ESP8266
// Bridge widget on virtual pin 1
WidgetBridge bridge1(V10);

BLYNK_CONNECTED() {
  bridge1.setAuthToken("Auth Key"); // Place the AuthToken of the second hardware here
}


//"Hunter's Paradise" game controls mapped to the GPIO pins
BLYNK_WRITE(V6) //RESET
{
  int l = param.asInt();

  if (l == 1) {
    digitalWrite(JC_4, HIGH);
    }
  else {
    digitalWrite(JC_4, LOW);
  }
}


BLYNK_WRITE(V5) //Mode select
{
  int y = param.asInt();

  if (y == 1) {
    digitalWrite(JC_3, HIGH);
  }
  else {
    digitalWrite(JC_3, LOW);
  }
}
BLYNK_WRITE(V8) //FIRE
{
  int y = param.asInt();

  if (y == 1) {
    digitalWrite(JC_2, HIGH);
  }
  else {
    digitalWrite(JC_2, LOW);
  }
}

BLYNK_WRITE(V9) //Accelerometer
{
  int x = param[0].asInt();
  int y = param[1].asInt();
  int z = param[2].asInt();
  int accleromrter_values;

  //11 condition

  if (y >= -10 && y <= -8)
  {
    digitalWrite(JC_1, LOW);
    digitalWrite(JC_0, LOW);
    accleromrter_values = B11;
  }

  //10 condition
  else if (y >= -7 && y <= -5)
  {
    digitalWrite(JC_1, LOW);
    digitalWrite(JC_0, HIGH);
    accleromrter_values = B10;
  }

  //01 condition
  else if (y >= -4 && y <= -2)
  {
    digitalWrite(JC_1, HIGH);
    digitalWrite(JC_0, LOW);
    accleromrter_values = B01;
  }
  else
  {

    //00 ccondition
    //reset position
    digitalWrite(JC_1, HIGH);
    digitalWrite(JC_0, HIGH);
    accleromrter_values = B00;
  }
}


//Car Control input values

BLYNK_WRITE(V0)
{
  e = param.asInt();
}

BLYNK_WRITE(V1) //Forward
{
  if(e == 1)
 {
  a = param.asInt();
  GoForward();
 }
}
BLYNK_WRITE(V2) //Right
{
  if(e ==1)
  {
    b = param.asInt();
    GoRight();
  }
}
BLYNK_WRITE(V3) //Left
{
  if(e ==1)
  {
    c = param.asInt();
    GoLeft();
  }
}
BLYNK_WRITE(V4) //Reverse
{
  if(e ==1)
  {
    d = param.asInt();
    GoReverse();
  }
}

// Functions to send appropriate control values to the Bot

void GoForward()
{
   if (a == 1)
  {
    bridge1.virtualWrite(V1, HIGH);
  }
  else
  {
    bridge1.virtualWrite(V1, LOW);
  }
}

void GoReverse()
{
   if (d == 1)
  {
    // reverse direction
    bridge1.virtualWrite(V4, HIGH);
  }
  else
  {
    bridge1.virtualWrite(V4, LOW);
  }
}

void GoLeft()
{
  if (c == 1)
  {
    bridge1.virtualWrite(V3, HIGH);
  }
  else
  {
    bridge1.virtualWrite(V3, LOW);
  }
}

void GoRight()
{
  if (b == 1)
  {
    bridge1.virtualWrite(V2, HIGH);
  }
  else
  {
    bridge1.virtualWrite(V2, LOW);
  }
}


void setup()
{
  //  Debug console
  Serial.begin(115200);
  
  // You can also specify server:
  Blynk.begin(auth, ssid, pass, IPAddress(0, 0, 0, 0), 8442);

  // Configure LED and timer
  pinMode(LED_PIN, OUTPUT);
  pinMode(LED_PIN_1, OUTPUT);
  pinMode(JC_0, OUTPUT);
  pinMode(JC_1, OUTPUT);
  pinMode(JC_2, OUTPUT);
  pinMode(JC_3, OUTPUT);
}

void loop()
{
  Blynk.run();
  ReadSerial();
}
